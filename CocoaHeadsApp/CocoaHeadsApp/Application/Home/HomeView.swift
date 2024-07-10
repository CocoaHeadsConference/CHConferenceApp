//
//  HomeView.swift
//  CocoaHeadsApp
//
//  Created by Vinicius Carvalho on 09/07/24.
//Copyright © 2024 Monstarlab. All rights reserved.
//

import SwiftUI
import Commons
import Resources
import ComposableArchitecture

public struct HomeView: View {
    let store: StoreOf<HomeFeature>

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            Text("Hello World!!!")
            .onAppear {
//                Just for example
//                store.send(.onAppear)
            }
        }
    }
}
