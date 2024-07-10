//
//  PersistenceController.swift
//  PersistentPlatform
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import CoreData
import Domain
import Utilities

actor PersistenceController {
  static let shared = PersistenceController()
  var persistentStoreNotLoaded = true
  let container: NSPersistentContainer = {
    let objectModel = try! NSManagedObjectModel.managedObjectModel(
      forResource: Constants.CoreData.model)
    let container = NSPersistentContainer(
      name: Constants.CoreData.model, managedObjectModel: objectModel)
    let description = container.persistentStoreDescriptions.first
    description?.shouldInferMappingModelAutomatically = false
    description?.shouldMigrateStoreAutomatically = false
    return container
  }()

  var viewContext: NSManagedObjectContext {
    container.viewContext
  }
}

// MARK: Preparation

extension PersistenceController {

  private func saveContext(_ context: NSManagedObjectContext) {
    guard context.hasChanges else { return }
    do {
      try context.save()
    } catch {
      assertionFailure("Unresolved error \(error)")
    }
  }

  private func fetch<T>(
    _ request: NSFetchRequest<T>,
    context: NSManagedObjectContext
  ) throws -> [T] where T: NSFetchRequestResult {
    try context.performAndWait {
      try context.fetch(request)
    }

  }

  func prepare() async throws {
    if persistentStoreNotLoaded {
      _ = try await loadPersistentStore()
      persistentStoreNotLoaded = false
    }
  }

  func rebuild() async throws {
    guard let storeURL = container.persistentStoreDescriptions.first?.url else {
      throw AppError.databaseCorrupted(
        "PersistentContainer was not set up properly.")
    }

    try NSPersistentStoreCoordinator.destroyStore(at: storeURL)

    return try await withCheckedThrowingContinuation { continuation in
      container.loadPersistentStores { _, error in
        guard error == nil else {
          let message = "Was unable to load store \(String(describing: error))."
          continuation.resume(throwing: AppError.databaseCorrupted(message))
          return
        }
      }
    }
  }

  func materializedObjects(
    context: NSManagedObjectContext, predicate: NSPredicate
  ) -> [NSManagedObject] {
    context.performAndWait {
      var objects = [NSManagedObject]()
      for object in context.registeredObjects where !object.isFault {
        guard object.entity.attributesByName.keys.contains("uid"),
          predicate.evaluate(with: object)
        else { continue }
        objects.append(object)
      }
      return objects
    }
  }

  private func loadPersistentStore() async throws {
    return try await withCheckedThrowingContinuation { continuation in
      container.loadPersistentStores { desc, error in
        guard error == nil else {
          let message = "Was unable to load store \(String(describing: error))."
          continuation.resume(throwing: AppError.databaseCorrupted(message))
          return
        }
        debugPrint("Persistent store loaded: \(desc)")
        continuation.resume()
      }
    }
  }
}

// MARK: Foundation

extension PersistenceController {

  private func batchFetch<MO: NSManagedObject>(
    entityType: MO.Type,
    fetchLimit: Int = 100,
    predicate: NSPredicate? = nil,
    findBeforeFetch: Bool = false,
    sortDescriptors: [NSSortDescriptor]? = nil,
    context: NSManagedObjectContext
  ) -> [MO] {
    var results = [MO]()
    results = context.performAndWait {
      if findBeforeFetch, let predicate = predicate {
        if let objects = materializedObjects(
          context: context, predicate: predicate)
          as? [MO],
          !objects.isEmpty
        {
          results = objects
        }
      }
      let request = NSFetchRequest<MO>(
        entityName: String(describing: entityType)
      )
      request.predicate = predicate
      request.fetchLimit = fetchLimit
      request.sortDescriptors = sortDescriptors

      results = (try? fetch(request, context: context)) ?? []
      return results
    }
    return results
  }

  func batchFetchDomainObject<MO: NSManagedObject>(
    entityType: MO.Type,
    fetchLimit: Int = 100,
    predicate: NSPredicate? = nil,
    findBeforeFetch: Bool = false,
    sortDescriptors: [NSSortDescriptor]? = nil,
    context: NSManagedObjectContext? = nil
  ) -> [MO.DomainType] where MO: DomainConvertible {
    let context = context ?? container.newBackgroundContext()
    return batchFetch(
      entityType: entityType,
      fetchLimit: fetchLimit,
      predicate: predicate,
      findBeforeFetch: findBeforeFetch,
      sortDescriptors: sortDescriptors,
      context: context
    ).asDomain(context: context)
  }

  private func fetch<MO: NSManagedObject>(
    entityType: MO.Type,
    predicate: NSPredicate? = nil,
    findBeforeFetch: Bool = false,
    commitChanges: ((MO?) -> Void)? = nil,
    context: NSManagedObjectContext
  ) -> MO? {
    return context.performAndWait {
      let managedObject = batchFetch(
        entityType: entityType, fetchLimit: 1,
        predicate: predicate, findBeforeFetch: findBeforeFetch,
        context: context
      ).first
      commitChanges?(managedObject)
      return managedObject
    }
  }

  private func fetchDomainObject<MO: Identifiable>(
    entityType: MO.Type,
    uid: String,
    findBeforeFetch: Bool = false,
    commitChanges: ((MO?) -> Void)? = nil,
    contextToUse: NSManagedObjectContext? = nil
  ) -> MO.DomainType? where MO: DomainConvertible {
    let context = contextToUse ?? container.newBackgroundContext()
    return context.performAndWait {
      fetch(
        entityType: entityType,
        uid: uid,
        findBeforeFetch: findBeforeFetch,
        commitChanges: commitChanges,
        context: context
      )?.asDomain(context: context)
    }
  }

  func fetchDomainObject<MO: NSManagedObject>(
    entityType: MO.Type,
    predicate: NSPredicate? = nil,
    findBeforeFetch: Bool = false,
    commitChanges: ((MO?) -> Void)? = nil,
    contextToUse: NSManagedObjectContext? = nil
  ) -> MO.DomainType? where MO: DomainConvertible {

    let context = contextToUse ?? container.viewContext

    return fetch(
      entityType: entityType,
      predicate: predicate,
      findBeforeFetch: findBeforeFetch,
      commitChanges: commitChanges,
      context: context
    )?.asDomain(context: context)
  }

  private func fetch<MO: Identifiable>(
    entityType: MO.Type,
    uid: String,
    findBeforeFetch: Bool = false,
    commitChanges: ((MO?) -> Void)? = nil,
    context: NSManagedObjectContext
  ) -> MO? {
    return context.performAndWait {
      fetch(
        entityType: entityType,
        predicate: NSPredicate(format: "uid == %@", uid),
        findBeforeFetch: findBeforeFetch,
        commitChanges: commitChanges,
        context: context
      )
    }
  }

  private func fetchOrCreate<MO: NSManagedObject>(
    entityType: MO.Type,
    predicate: NSPredicate? = nil,
    commitChanges: ((MO?) -> Void)? = nil,
    context: NSManagedObjectContext
  ) -> MO {
    if let storedDomainObject: MO = fetch(
      entityType: entityType,
      predicate: predicate,
      context: context
    ) {
      return storedDomainObject
    } else {
      return context.performAndWait {
        let newMO = MO(context: context)
        commitChanges?(newMO)
        saveContext(context)
        return newMO
      }

    }
  }

  private func fetchOrCreate<MO: Identifiable>(
    entityType: MO.Type, uid: String, context: NSManagedObjectContext
  ) -> MO {
    fetchOrCreate(
      entityType: entityType,
      predicate: NSPredicate(format: "uid == %@", uid),
      commitChanges: { $0?.uid = uid },
      context: context
    )
  }

  private func fetchOrCreateDomainObject<MO: NSManagedObject>(
    entityType: MO.Type,
    predicate: NSPredicate? = nil,
    commitChanges: ((MO?) -> Void)? = nil,
    context: NSManagedObjectContext
  ) -> MO.DomainType where MO: DomainConvertible {
    fetchOrCreate(
      entityType: entityType,
      predicate: predicate,
      commitChanges: commitChanges,
      context: context
    ).asDomain(context: context)
  }

  public func batchUpdate<MO: NSManagedObject>(
    entityType: MO.Type,
    predicate: NSPredicate? = nil,
    commitChanges: ([MO]) -> Void,
    context: NSManagedObjectContext
  ) {
    context.performAndWait {
      commitChanges(
        batchFetch(
          entityType: entityType,
          predicate: predicate,
          findBeforeFetch: false,
          context: context
        ))
      saveContext(context)
    }
  }

  func update<MO: NSManagedObject>(
    entityType: MO.Type,
    predicate: NSPredicate? = nil,
    createIfNil: Bool = true,
    commitChanges: @escaping (MO?) -> Void,
    contextToUse: NSManagedObjectContext? = nil
  ) {
    let context = contextToUse ?? container.newBackgroundContext()
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    context.perform {
      let storedMO: MO?

      if createIfNil {
        storedMO = self.fetchOrCreate(
          entityType: entityType, predicate: predicate, context: context)
      } else {
        storedMO = self.fetch(
          entityType: entityType, predicate: predicate, context: context)
      }

      if let storedMO = storedMO {
        context.performAndWait {
          commitChanges(storedMO)
          self.saveContext(context)
        }
      }
    }
  }

  private func update<MO: Identifiable>(
    entityType: MO.Type,
    uid: String,
    createIfNil: Bool = false,
    commitChanges: @escaping ((MO) -> Void),
    context: NSManagedObjectContext
  ) -> MO? {
    context.performAndWait {
      let storedMO: MO?
      if createIfNil {
        storedMO = fetchOrCreate(
          entityType: entityType, uid: uid, context: context)
      } else {
        storedMO = fetch(entityType: entityType, uid: uid, context: context)
      }
      if let storedMO = storedMO {
        commitChanges(storedMO)
        saveContext(context)
      }

      return storedMO
    }
  }

  public func purgeEntity<MO: NSManagedObject>(
    entityType: MO.Type, predicate: NSPredicate? = nil,
    context: NSManagedObjectContext
  ) {
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> =
      entityType.fetchRequest()
    fetchRequest.predicate = predicate
    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

    context.performAndWait {
      _ = try? context.execute(batchDeleteRequest)
      saveContext(context)
    }

  }
}

// MARK: Public API

extension PersistenceController {
  public func save(product: Domain.Product) async {
    update(entityType: Product.self, createIfNil: true) {
      $0?.id = "\(product.id)"
      $0?.title = product.title
      $0?.price = product.price
      $0?.image = product.image
      //            $0?.rating = product.rating.toManagedObject(in: persistenceController.container.newBackgroundContext())
      $0?.category = product.category
      $0?.productDescription = product.description
    }
  }

  public func getProduct(id: Int) async throws -> Domain.Product? {
    fetchDomainObject(entityType: Product.self)
  }
}

// MARK: Definition

protocol ManagedObjectConvertible {
  associatedtype ManagedObject: NSManagedObject, DomainConvertible

  @discardableResult
  func toManagedObject(in context: NSManagedObjectContext) -> ManagedObject
}

protocol Identifiable: NSManagedObject {
  var uid: String { get set }
}
