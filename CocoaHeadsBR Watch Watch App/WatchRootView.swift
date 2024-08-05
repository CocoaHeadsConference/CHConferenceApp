//
//  ContentView.swift
//  CocoaHeadsBR Watch Watch App
//
//  Created by Mauricio Cardozo on 01/08/24.
//  Copyright © 2024 Cocoaheadsbr. All rights reserved.
//

import SwiftUI
import NSBrazilLib

public struct RootView: View {

  public init(model: FeedViewModel) {
    viewModel = model
  }

  @ObservedObject var viewModel: FeedViewModel

  public var body: some View {
    switch viewModel.isLoading {
    case .loading:
      ProgressView()
    case .loaded:
      content
    case .failed:
      ContentUnavailableView(label: {
        Label("Falha no carregamento", systemImage: "network.slash")
      }, description: {
        Spacer()
      }, actions: {
        Button(action: {
          viewModel.fetchInfo()
        }) {
          Text("Tentar novamente")
        }
      })
    }
  }

  @MainActor @ViewBuilder
  var content: some View {
    TabView {
      HomeList(feedViewModel: viewModel)
      ScheduleListView(viewModel: viewModel)
    }
  }
}

#Preview("Mock") {
  RootView(model: .mock)
}

#Preview("Loading") {
  RootView(model: .init(home: [], schedule: [], loadState: .loading))
}

#Preview("Failed") {
  RootView(model: .init(home: [], schedule: [], loadState: .failed))
}
