//
//  CounterFeature.swift
//  Features
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import Common
import ComposableArchitecture
import Foundation

public struct Counter: FeatureReducer {

  public init() {}

  @ObservableState
  public struct State: Equatable, Hashable {
    public init() {}

    var count = 0
  }

  public enum ViewAction {
    case decrementButtonTapped
    case incrementButtonTapped
    case closeButtonTapped
  }

  public enum InternalAction {
    case close
  }

  public enum DelegateAction {
    case close
  }

  public func reduce(into state: inout State, viewAction: ViewAction) -> Effect<
    Action
  > {
    switch viewAction {
    case .decrementButtonTapped:
      state.count -= 1
      return .none

    case .incrementButtonTapped:
      state.count += 1
      return .none

    case .closeButtonTapped:
      return .send(.internal(.close))
    }
  }

  public func reduce(into state: inout State, internalAction: InternalAction)
    -> Effect<Action>
  {
    switch internalAction {
    case .close:
      return .send(.delegate(.close))
    }
  }
}
