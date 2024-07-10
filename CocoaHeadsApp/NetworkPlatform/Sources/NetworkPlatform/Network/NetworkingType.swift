//
//  NetworkingType.swift
//  NetworkPlatform
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import Alamofire
import Combine
import Foundation
import Moya
import Utilities

protocol ProductAPIType {
  var addXAuth: Bool { get }
}

protocol NetworkingType {
  associatedtype T: TargetType, ProductAPIType
  var provider: OnlineProvider<T> { get }

  static func defaultNetworking() -> Self
  static func stubbingNetworking() -> Self
}

extension NetworkingType {
  static func endpointsClosure<T>(_: String? = nil) -> (T) -> Endpoint
  where T: TargetType, T: ProductAPIType {
    return { target in
      let endpoint = MoyaProvider.defaultEndpointMapping(for: target)
      Logger.info("Endpoint URL: \(endpoint.url)")
      // Sign all non-XApp, non-XAuth token requests
      return endpoint
    }
  }

  static func APIKeysBasedStubBehaviour<T>(_: T) -> Moya.StubBehavior {
    return .never
  }

  static var plugins: [PluginType] {
    var plugins: [PluginType] = []
    plugins.append(NetworkLoggerPlugin())
    return plugins
  }

  // (Endpoint<Target>, NSURLRequest -> Void) -> Void
  static func endpointResolver() -> MoyaProvider<T>.RequestClosure {
    return { endpoint, closure in
      do {
        var request = try endpoint.urlRequest()  // endpoint.urlRequest
        request.httpShouldHandleCookies = false
        closure(.success(request))
      } catch {
        Logger.error(error.localizedDescription)
      }
    }
  }
}

// MARK: - Provider support

func stubbedResponse(_ filename: String) -> Data! {
  @objc class TestClass: NSObject {}

  let bundle = Bundle(for: TestClass.self)
  let path = bundle.path(forResource: filename, ofType: "json")
  return (try? Data(contentsOf: URL(fileURLWithPath: path!)))
}

extension String {
  fileprivate var URLEscapedString: String {
    return addingPercentEncoding(
      withAllowedCharacters: CharacterSet.urlHostAllowed)!
  }
}

func url(_ route: TargetType) -> String {
  return route.baseURL.appendingPathComponent(route.path).absoluteString
}
