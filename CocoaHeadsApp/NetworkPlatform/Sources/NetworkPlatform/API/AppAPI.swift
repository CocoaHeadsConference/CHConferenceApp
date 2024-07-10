//
//  AppAPI.swift
//  NetworkPlatform
//
//  Created by Rokon on 24/01/2024.
//  Copyright © 2024 MLBD. All rights reserved.
//

import BuildConfiguration
import Foundation
import Moya

enum AppAPI {
  case product(id: Int)
}

extension AppAPI: TargetType, ProductAPIType, Stubble {
  var baseURL: URL {
    return URL(string: "https://fakestoreapi.com")!
  }

  var path: String {
    switch self {
    case let .product(id): return "/products/\(id)"
    }
  }

  var method: Moya.Method {
    switch self {
    default:
      return .get
    }
  }

  var headers: [String: String]? {
    return nil
  }

  var parameters: [String: Any]? {
    let params: [String: Any] = [:]
    switch self {
    default: break
    }
    return params
  }

  var parameterEncoding: ParameterEncoding {
    return URLEncoding.default
  }

  var sampleData: Data {
    var fileName = ""
    switch self {
    case .product:
      fileName = "Product"
    }
    return stubbedResponse(fileName)
  }

  var task: Task {
    if let parameters = parameters {
      return .requestParameters(
        parameters: parameters, encoding: parameterEncoding)
    }
    return .requestPlain
  }

  var addXAuth: Bool {
    switch self {
    default: return false
    }
  }
}
