//
//  NSManagedObjectModel+Compatible.swift
//  PersistentPlatform
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import CoreData
import Foundation

extension NSManagedObjectModel {
  static func compatibleModelForStoreMetadata(_ metadata: [String: Any])
    -> NSManagedObjectModel?
  {
    NSManagedObjectModel.mergedModel(
      from: [Bundle.module], forStoreMetadata: metadata)
  }
}
