//
//  NetworkingError.swift
//  NetworkPlatform
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import Foundation

enum NetworkingError: Error {
  case error(String)
  case defaultError

  var message: String {
    switch self {
    case let .error(msg):
      return msg
    case .defaultError:
      return "Please try again later."
    }
  }
}
