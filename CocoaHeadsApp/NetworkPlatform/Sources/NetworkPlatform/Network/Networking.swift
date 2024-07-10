//
//  Networking.swift
//  NetworkPlatform
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import Alamofire
import Combine
import CombineMoya
import Foundation
import Moya
import Utilities

class OnlineProvider<Target> where Target: Moya.TargetType {
  private let online: AnyPublisher<Bool, Never>
  private let provider: MoyaProvider<Target>
  private var authprovider = MoyaProvider<AuthAPI>()

  init(
    endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure =
      MoyaProvider<Target>.defaultEndpointMapping,
    requestClosure: @escaping MoyaProvider<Target>.RequestClosure =
      MoyaProvider<Target>.defaultRequestMapping,
    stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider<
      Target
    >.neverStub,
    session: Session = MoyaProvider<Target>.defaultAlamofireSession(),
    plugins: [PluginType] = [VerbosePlugin(verbose: true)],
    trackInflights: Bool = false,
    online: AnyPublisher<Bool, Never>
  ) {
    self.online = online
    provider = MoyaProvider(
      endpointClosure: endpointClosure,
      requestClosure: requestClosure,
      stubClosure: stubClosure,
      session: session,
      plugins: plugins,
      trackInflights: trackInflights)
  }

  func request(_ target: Target) -> AnyPublisher<Moya.Response, MoyaError> {
    return provider.requestPublisher(target)
      .tryCatch { [weak self] error -> AnyPublisher<Moya.Response, MoyaError> in
        guard let `self` = self else { throw error }
        // 401 Error, update access token
        if let response = error.response,
          let statusCode = HTTPStatusCode(rawValue: response.statusCode),
          statusCode == .unauthorized
        {
          // TODO: handle network retry
          return self.fetchAccessToken(target: target)
        } else {
          throw error
        }
      }
      // TODO: investigate
      .mapError { $0 as! MoyaError }
      .handleEvents(
        receiveOutput: { response in
          Logger.info("Status Code: \(response.statusCode)")
        },
        receiveCompletion: { completion in
          switch completion {
          case .finished:
            Logger.success("Request Finished")
          case let .failure(error):
            // TODO: handle network error
            Logger.error(error.localizedDescription)
          }
        }
      )
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }

  func fetchAccessToken(target: Target) -> AnyPublisher<
    Moya.Response, MoyaError
  > {
    return
      authprovider
      .requestPublisher(.accessToken)
      .handleEvents(
        receiveOutput: { _ in

        },
        receiveCompletion: { completion in
          switch completion {
          case .finished:
            // TODO: Update new tokens
            break
          case let .failure(error):
            Logger.error(error.localizedDescription)
          // TODO: delete existing token and logout from app
          }

        }
      )
      .flatMap { _ in  // TODO: fix use weak self
        self.request(target)
      }.eraseToAnyPublisher()
  }
}
