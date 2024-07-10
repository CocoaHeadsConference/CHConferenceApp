//
//  AnyPublisher+Extensions.swift
//  NetworkPlatform
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import Combine
import Foundation

enum AsyncError: Error {
  case finishedWithoutValue
}

extension AnyPublisher {

  func async() async throws -> Output {
    try await withCheckedThrowingContinuation { continuation in
      var cancellable: AnyCancellable?
      var finishedWithoutValue = true
      cancellable = first()
        .sink { result in
          switch result {
          case .finished:
            if finishedWithoutValue {
              continuation.resume(throwing: AsyncError.finishedWithoutValue)
            }
          case let .failure(error):
            continuation.resume(throwing: error)
          }
          cancellable?.cancel()
        } receiveValue: { value in
          finishedWithoutValue = false
          continuation.resume(with: .success(value))
        }
    }
  }
}
