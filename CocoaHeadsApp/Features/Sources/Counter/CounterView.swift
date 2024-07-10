//
//  CounterView.swift
//  Features
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import Common
import ComposableArchitecture
import SwiftUI

@MainActor
public struct CounterView: View {
  let store: StoreOf<Counter>

  public init(store: StoreOf<Counter>) {
    self.store = store
  }

  public var body: some View {
    WithPerceptionTracking {
      VStack(spacing: 16) {
        HStack {
          Button {
            store.send(.view(.decrementButtonTapped))
          } label: {
            Image(systemName: "minus")
          }

          Text("\(store.count)")
            .monospacedDigit()

          Button {
            store.send(.view(.incrementButtonTapped))
          } label: {
            Image(systemName: "plus")
          }
        }

        Button {
          store.send(.view(.closeButtonTapped))
        } label: {
          Text("Dismiss")
            .foregroundStyle(.white)
            .frame(width: 120, height: 40)
            .background(.blue)
        }
      }
    }
  }
}

#Preview {
  CounterView(
    store:
      .init(
        initialState: Counter.State(),
        reducer: { Counter() }
      )
  )
}
