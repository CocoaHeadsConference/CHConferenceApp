//
//  AppFeature.swift
//  Features
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import Common
import ComposableArchitecture
import Counter
import Domain

public struct AppFeature: FeatureReducer {

  @Dependency(\.appClient) var appClient

  public init() {}

  @ObservableState
  public struct State: Equatable, Hashable {
    public init() {}

    @Presents var destination: Destination.State?
    var product: Product?
  }

  public enum ViewAction {
    case onAppear
    case showSheet
    case showFullScreenCover
    case save
  }

  public enum InternalAction {
    case dismissDestination
    case productResponse(Result<Product?, Error>)
  }

  public var body: some ReducerOf<Self> {
    Reduce(core)
      .ifLet(\.$destination, action: \.destination) {
        Destination()
      }
  }

  public func reduce(into state: inout State, viewAction: ViewAction) -> Effect<
    Action
  > {
    switch viewAction {
    case .onAppear:
      return .run { send in
        try? await appClient.prepareCoreData()
        await send(
          .internal(
            .productResponse(
              Result {
                try await appClient.getProduct(input: 2)
              })))
      }
    case .showSheet:
      state.destination = .sheet(.init())
      return .none

    case .showFullScreenCover:
      state.destination = .fullScreenCover(.init())
      return .none

    case .save:
      return .run { [product = state.product] send in
        do {
          try await appClient.saveProduct(input: product!)
        } catch {

        }
      }
    }
  }

  public func reduce(
    into state: inout State, presentedAction: Destination.Action
  ) -> Effect<Action> {
    switch presentedAction {
    case .sheet(.delegate(.close)):
      return .send(.internal(.dismissDestination))

    case .fullScreenCover(.delegate(.close)):
      return .send(.internal(.dismissDestination))

    default:
      return .none
    }
  }

  public func reduce(into state: inout State, internalAction: InternalAction)
    -> Effect<Action>
  {
    switch internalAction {
    case let .productResponse(.success(product)):
      state.product = product
      return .none
    case let .productResponse(.failure(error)) where error is AppError:
      print(error)
      return .none
    case let .productResponse(.failure(error)):
      print(error)
      return .none
    case .dismissDestination:
      state.destination = nil
      return .none
    }
  }

  public struct Destination: DestinationReducer {

    public init() {}

    @dynamicMemberLookup
    @CasePathable
    public enum State: Hashable {
      case sheet(Counter.State)
      case fullScreenCover(Counter.State)
    }

    @CasePathable
    public enum Action {
      case sheet(Counter.Action)
      case fullScreenCover(Counter.Action)
    }

    public var body: some ReducerOf<Self> {
      Scope(state: \.sheet, action: \.sheet) {
        Counter()
      }
      Scope(state: \.fullScreenCover, action: \.fullScreenCover) {
        Counter()
      }
    }
  }
}
