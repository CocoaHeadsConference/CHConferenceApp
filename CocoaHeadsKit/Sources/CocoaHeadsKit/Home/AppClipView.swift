//
//  AppClipView.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/9/25.
//

import SwiftUI

// TODO: Break things out from CocoaHeadsKit specifically for the AppClip – size reduction is important
public struct AppClipView: View {
  public init() {}

  enum ViewState {
    case loaded(Event)
    case error
    case loading
  }

  @State private var state = ViewState.loading
  @Environment(\.cloudKitService) var cloudKit

  public var body: some View {
    VStack {
      switch state {
      case .loading:
        ProgressView()
      case .loaded(let event):
        EventDetail(
          title: event.title,
          image: nil,
          imageID: event.id,
          ui: event.ui,
          shareURL: event.rsvpURL
        )
      case .error:
        ContentUnavailableView {
          Text("Algum erro ocorreu")
        } actions: {
          Button {
            Task {
              await fetchData()
            }
          } label: {
            Text("Tentar novamente")
          }
        }
      }
    }
    .task {
      await Config.fetchEnvironment()
      await fetchData()
    }
  }

  private func fetchData() async {
    state = .loading
    do {
      let chapters = try await cloudKit.fetchData()
      guard
        let event = chapters.first(where: {
          !$0.events.isEmpty
        })?.events.first
      else {
        state = .error
        return
      }

      state = .loaded(event)
    } catch {
      state = .error
    }
  }
}
