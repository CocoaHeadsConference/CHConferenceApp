//
//  PrepareCoreDataUseCase.swift
//  Domain
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import Foundation

public typealias PrepareCoreDataUseCaseType = UseCase<Void, Void>

public class PrepareCoreDataUseCase: UseCase {
  var prepare: () async throws -> Void

  public init<R: PrepareRepository>(repository: R) {
    self.prepare = repository.prepare
  }

  public func callAsFunction(input: Void) async {
    try? await prepare()
  }
}
