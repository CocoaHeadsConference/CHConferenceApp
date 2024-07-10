//
//  ProductUseCase.swift
//  Domain
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import Foundation

public typealias ProductUseCaseType = UseCase<Int, Product?>

public final class ProductUseCase: UseCase {

  var getProduct: (_ input: Int) async throws -> Product?

  public init<R: RemoteProductRepository>(repository: R)
  where R.ReadInput == Input, R.ReadOutput == Output {
    self.getProduct = repository.read(input:)
  }

  public func callAsFunction(input: Int) async throws -> Product? {
    return try await getProduct(input)
  }
}
