//
//  Product+CoreDataProperties.swift
//  PersistentPlatform
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import CoreData
import Domain

extension Product {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
    return NSFetchRequest<Product>(entityName: "Product")
  }

  @NSManaged public var id: String
  @NSManaged public var price: Double
  @NSManaged public var title: String
  @NSManaged public var image: String
  @NSManaged public var category: String
  @NSManaged public var productDescription: String
}
