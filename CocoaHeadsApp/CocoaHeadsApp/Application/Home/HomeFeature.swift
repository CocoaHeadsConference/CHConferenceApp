//
//  HomeFeature.swift
//  CocoaHeadsApp
//
//  Created by Vinicius Carvalho on 09/07/24.
//Copyright © 2024 Monstarlab. All rights reserved.
//

import Commons
import ComposableArchitecture
import Domain
import Foundation

public struct HomeFeature: FeatureReducer {

  public init() {}

  @ObservableState
  public struct State: Equatable, Hashable {
    public init() {}
  }

  public enum ViewAction {

  }

  public enum InternalAction {

  }

  public var body: some ReducerOf<Self> {

  }

  public func reduce(into state: inout State, viewAction: ViewAction) -> Effect<Action> {
    switch viewAction {

    }
  }

  public func reduce(into state: inout State, presentedAction: Destination.Action) -> Effect<Action> {

  }

  public func reduce(into state: inout State, internalAction: InternalAction) -> Effect<Action> {
    switch internalAction {

    }
  }

  public struct Destination: DestinationReducer {

    public init() {}

    @dynamicMemberLookup
    @CasePathable
    public enum State: Hashable {

    }

    @CasePathable
    public enum Action {

    }

    public var body: some ReducerOf<Self> {

    }
  }
}
