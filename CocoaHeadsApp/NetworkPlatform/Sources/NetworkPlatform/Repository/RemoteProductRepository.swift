//
//  NetworkRepository.swift
//  NetworkPlatform
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import Domain

public struct RemoteProductRepository: Domain.RemoteProductRepository {

  private let network: AppNetworking

  private init(network: AppNetworking) {
    self.network = network
  }

  public func create(input: Product) async throws {
    fatalError("Unimplemented")
  }

  public func read(input: Int) async throws -> Product? {
    try await network.requestObject(
      .product(id: input),
      type: Product.self)
  }
}

extension RemoteProductRepository {
  public static var live = RemoteProductRepository(
    network: AppNetworking.defaultNetworking())
  public static var stubbed = RemoteProductRepository(
    network: AppNetworking.stubbingNetworking())
}
