//
//  UseCase.swift
//  Domain
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import Foundation

public protocol UseCase<Input, Output> {
  associatedtype Input
  associatedtype Output

  func callAsFunction(input: Input) async throws -> Output
}

extension UseCase where Input == Void {
  public func callAsFunction() async throws -> Output {
    try await callAsFunction(input: ())
  }
}
