//
//  AppView.swift
//  Features
//
//  Created by Vinicius on 10/07/2024.
//  Copyright © 2024 CocoaHeadsBrasil. All rights reserved.
//

import Common
import ComposableArchitecture
import Counter
import SwiftUI

@MainActor
public struct AppView: View {
  let store: StoreOf<AppFeature>

  public init(store: StoreOf<AppFeature>) {
    self.store = store
  }

  public var body: some View {
    WithPerceptionTracking {
      VStack {
        VStack {
          Text("\(store.product?.title ?? "Unknown")")
          Spacer()
            .frame(height: 20)
          Text("\(store.product?.description ?? "Unknown")")
        }
        .padding()

        Form {
          Button("Save") {
            store.send(.view(.save))
          }

          Button {
            store.send(.view(.showSheet))
          } label: {
            Text("Sheet")
          }

          Button {
            store.send(.view(.showFullScreenCover))
          } label: {
            Text("Full Screen Cover")
          }
        }
      }
      .onAppear {
        store.send(.view(.onAppear))
      }
      .destinations(with: store)
    }
  }
}

extension StoreOf<AppFeature> {
  fileprivate var bindableDestination:
    ComposableArchitecture.Bindable<StoreOf<AppFeature>>
  {
    return ComposableArchitecture.Bindable(self)
  }
}

@MainActor
extension View {
  fileprivate func destinations(with store: StoreOf<AppFeature>) -> some View {
    let bindableDestination = store.bindableDestination
    return showSheet(with: bindableDestination)
      .showFulllScreenCover(with: bindableDestination)
  }

  private func showSheet(
    with destinationStore: ComposableArchitecture.Bindable<StoreOf<AppFeature>>
  ) -> some View {
    let destinationStore = destinationStore.scope(
      state: \.destination?.sheet,
      action: \.destination.sheet)

    return sheet(item: destinationStore) { store in
      CounterView(store: store)
    }
  }

  private func showFulllScreenCover(
    with destinationStore: ComposableArchitecture.Bindable<StoreOf<AppFeature>>
  ) -> some View {
    let destinationStore = destinationStore.scope(
      state: \.destination?.fullScreenCover,
      action: \.destination.fullScreenCover)

    return fullScreenCover(item: destinationStore) { store in
      CounterView(store: store)
    }
  }
}

#Preview {
  AppView(
    store:
      .init(
        initialState: AppFeature.State(),
        reducer: { AppFeature() }
      )
  )
}
