//
//  SaveProductUseCase.swift
//  Domain
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import Foundation

public typealias SaveProductUseCaseType = UseCase<Product, Void>

public final class SaveProductUseCase: UseCase {
  var saveProduct: (_ input: Product) async throws -> Void

  public init<R: PersistentProductRepository>(repository: R)
  where R.CreateInput == Input, R.CreateOutput == Output {
    self.saveProduct = repository.create(input:)
  }

  public func callAsFunction(input: Product) async throws {
    return try await saveProduct(input)
  }
}
