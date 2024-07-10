//
//  VerbosePlugin.swift
//  NetworkPlatform
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import Combine
import Foundation
import Moya
import Utilities

struct VerbosePlugin: PluginType {
  let verbose: Bool

  func prepare(_ request: URLRequest, target _: TargetType) -> URLRequest {
    #if DEBUG
      if let body = request.httpBody,
        let string = String(data: body, encoding: .utf8)
      {
        if verbose {
          Logger.info("Request Body: \(string))")
        }
      }
    #endif
    return request
  }

  func didReceive(_ result: Result<Response, MoyaError>, target _: TargetType) {
    #if DEBUG
      switch result {
      case let .success(body):
        if verbose {
          if let json = try? JSONSerialization.jsonObject(
            with: body.data, options: .mutableContainers)
          {
            Logger.info("Response: \(json))")
          } else {
            let response = String(data: body.data, encoding: .utf8)!
            Logger.info("Response: \(response))")
          }
        }
      case .failure:
        break
      }
    #endif
  }
}
