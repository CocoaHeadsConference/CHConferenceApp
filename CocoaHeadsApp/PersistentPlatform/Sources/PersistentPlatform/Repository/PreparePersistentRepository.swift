//
//  PreparePersistentRepository.swift
//  PersistentPlatform
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import Domain
import Foundation

public struct PreparePersistentRepository: Domain.PrepareRepository {

  private let persistenceController: PersistenceController

  init(persistenceController: PersistenceController) {
    self.persistenceController = persistenceController
  }

  public func prepare() async {
    do {
      try await persistenceController.prepare()
    } catch {
      fatalError(error.localizedDescription)
    }
  }
}

extension PreparePersistentRepository {
  public static var live = PreparePersistentRepository(
    persistenceController: PersistenceController.shared)
}
