//
//  PersistentRepository.swift
//  PersistentPlatform
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import Domain

public struct PersistentProductRepository: Domain.PersistentProductRepository {

  private let persistenceController: PersistenceController

  private init(persistenceController: PersistenceController) {
    self.persistenceController = persistenceController
  }

  public func create(input: Domain.Product) async throws {
    await persistenceController.update(
      entityType: Product.self, createIfNil: true
    ) {
      $0?.id = "\(input.id)"
      $0?.title = input.title
      $0?.price = input.price
      $0?.image = input.image
      //FIXME: may be rating is a reserved keyword.
      //            $0?.rating = product.rating.toManagedObject(in: persistenceController.container.newBackgroundContext())
      $0?.category = input.category
      $0?.productDescription = input.description
    }
  }

  public func read(input: Int) async throws -> Domain.Product? {
    await persistenceController.fetchDomainObject(entityType: Product.self)
  }

}

extension PersistentProductRepository {
  public static var live = PersistentProductRepository(
    persistenceController: PersistenceController.shared)
  public static var stubbed = PersistentProductRepository(
    persistenceController: PersistenceController.shared)
}
