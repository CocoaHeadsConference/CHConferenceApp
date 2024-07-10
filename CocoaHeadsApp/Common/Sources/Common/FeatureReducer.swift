//
//  FeatureReducer.swift
//  Common
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

// MARK: FeatureReducer
public protocol FeatureReducer: Reducer
where State: Sendable & Hashable, Action == FeatureAction<Self> {
  associatedtype ViewAction: Sendable = Never
  associatedtype InternalAction: Sendable = Never
  associatedtype ChildAction: Sendable = Never
  associatedtype DelegateAction: Sendable = Never

  func reduce(into state: inout State, viewAction: ViewAction) -> Effect<Action>
  func reduce(into state: inout State, internalAction: InternalAction)
    -> Effect<Action>
  func reduce(into state: inout State, childAction: ChildAction) -> Effect<
    Action
  >
  func reduce(into state: inout State, presentedAction: Destination.Action)
    -> Effect<Action>
  func reduceDismissDestination(into state: inout State) -> Effect<Action>

  associatedtype Destination: DestinationReducer = EmptyDestination
  associatedtype ViewState: Equatable = Never
}

extension Reducer where Self: FeatureReducer {
  public typealias Action = FeatureAction<Self>

  public var body: some ReducerOf<Self> {
    Reduce(core)
  }

  public func core(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .destination(.dismiss):
      reduceDismissDestination(into: &state)
    case let .destination(.presented(presentedAction)):
      reduce(into: &state, presentedAction: presentedAction)
    case let .view(viewAction):
      reduce(into: &state, viewAction: viewAction)
    case let .internal(internalAction):
      reduce(into: &state, internalAction: internalAction)
    case let .child(childAction):
      reduce(into: &state, childAction: childAction)
    case .delegate:
      .none
    }
  }

  public func reduce(into state: inout State, viewAction: ViewAction) -> Effect<
    Action
  > {
    .none
  }

  public func reduce(into state: inout State, internalAction: InternalAction)
    -> Effect<Action>
  {
    .none
  }

  public func reduce(into state: inout State, childAction: ChildAction)
    -> Effect<Action>
  {
    .none
  }

  public func reduce(
    into state: inout State, presentedAction: Destination.Action
  ) -> Effect<Action> {
    .none
  }

  public func reduceDismissDestination(into state: inout State) -> Effect<
    Action
  > {
    .none
  }

}

public typealias PresentationStoreOf<R: Reducer> = Store<
  PresentationState<R.State>, PresentationAction<R.Action>
>

// MARK: FeatureAction
@CasePathable
public enum FeatureAction<Feature: FeatureReducer>: Sendable {
  case destination(PresentationAction<Feature.Destination.Action>)
  case view(Feature.ViewAction)
  case `internal`(Feature.InternalAction)
  case child(Feature.ChildAction)
  case delegate(Feature.DelegateAction)
}

// MARK: DestinationReducer
public protocol DestinationReducer: Reducer
where State: Sendable & Hashable, Action: Sendable & CasePathable {}

// MARK: EmptyDestination

public enum EmptyDestination: DestinationReducer {
  public struct State: Sendable, Hashable {}
  public typealias Action = Never
  public func reduce(into state: inout State, action: Never) -> Effect<Action> {
  }
  public func reduceDismissDestination(into state: inout State) -> Effect<
    Action
  > { .none }
}

extension FeatureReducer {

  public func delayedMediumEffect(internal internalAction: InternalAction)
    -> Effect<Action>
  {
    self.delayedMediumEffect(for: .internal(internalAction))
  }

  public func delayedMediumEffect(
    for action: Action
  ) -> Effect<Action> {
    delayedEffect(delay: .seconds(0.6), for: action)
  }

  public func delayedShortEffect(
    for action: Action
  ) -> Effect<Action> {
    delayedEffect(delay: .seconds(0.3), for: action)
  }

  private func delayedEffect(
    delay: Duration,
    for action: Action
  ) -> Effect<Action> {
    @Dependency(\.continuousClock) var clock
    return .run { send in
      try await clock.sleep(for: delay)
      await send(action)
    }
  }
}
