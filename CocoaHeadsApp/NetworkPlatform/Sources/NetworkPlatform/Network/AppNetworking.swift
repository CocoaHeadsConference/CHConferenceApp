//
//  AppNetworking.swift
//  NetworkPlatform
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import Combine
import Domain
import Foundation
import Moya

struct AppNetworking: NetworkingType {
  typealias T = AppAPI
  let provider: OnlineProvider<T>

  static func defaultNetworking() -> Self {
    return AppNetworking(
      provider:
        OnlineProvider(
          endpointClosure: AppNetworking.endpointsClosure(),
          requestClosure: AppNetworking.endpointResolver(),
          stubClosure: AppNetworking.APIKeysBasedStubBehaviour,
          online: Just(true).setFailureType(to: Never.self)
            .eraseToAnyPublisher()))
  }

  static func stubbingNetworking() -> Self {
    return AppNetworking(
      provider:
        OnlineProvider(
          endpointClosure: endpointsClosure(),
          requestClosure: AppNetworking.endpointResolver(),
          stubClosure: MoyaProvider.immediatelyStub,
          online: Just(true).setFailureType(to: Never.self)
            .eraseToAnyPublisher()))
  }

  func request(_ target: T) -> AnyPublisher<Moya.Response, MoyaError> {
    let actualRequest = provider.request(target)
    return actualRequest
  }

  func requestObject<T: Codable>(
    _ target: AppAPI,
    type _: T.Type
  ) async throws -> T {
    return try await request(target)
      .filterSuccessfulStatusCodes()
      .map(T.self)
      .mapError { error -> AppError in
        AppError.networkingFailed(underlyingError: error, context: "Network")
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
      .async()
  }

  func requestArray<T: Codable>(
    _ target: AppAPI,
    type _: T.Type
  ) async throws -> [T] {
    return try await request(target)
      .filterSuccessfulStatusCodes()
      .map([T].self)
      .mapError { error -> AppError in
        AppError.networkingFailed(underlyingError: error, context: "Network")
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
      .async()
  }
}
