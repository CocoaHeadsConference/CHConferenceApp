//
//  DomainConvertible.swift
//  PersistentPlatform
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import CoreData
import Domain
import Foundation

public protocol DomainConvertible {
  associatedtype DomainType
  func asDomain(context: NSManagedObjectContext) -> DomainType
}

extension Array: DomainConvertible where Element: DomainConvertible {
  public func asDomain(context: NSManagedObjectContext) -> [Element.DomainType]
  {
    self.map { $0.asDomain(context: context) }
  }
}

extension Set: DomainConvertible where Element: DomainConvertible {
  public func asDomain(context: NSManagedObjectContext) -> [Element.DomainType]
  {
    self.map { $0.asDomain(context: context) }
  }
}

extension NSOrderedSet {
  func asDomain<DomainElement, EntityType: DomainConvertible>(
    context: NSManagedObjectContext, entityElementType: EntityType.Type
  ) -> [DomainElement] where EntityType.DomainType == DomainElement {
    return self.compactMap { ($0 as? EntityType)?.asDomain(context: context) }
  }
}
