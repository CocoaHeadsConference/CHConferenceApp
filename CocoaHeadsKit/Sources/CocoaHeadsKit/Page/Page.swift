//
//  Page.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/9/25.
//

import SwiftUI

struct Page: View {

  @Environment(\.cloudKitService) var cloudKit

  enum ViewState {
    case loaded([UI])
    case loading
  }

  let slug: String
  @State private var viewState: ViewState = .loading

  var body: some View {
    switch viewState {
    case .loaded(let ui):
      PageRenderer(ui: ui)
    case .loading:
      ProgressView()
        .task {
          await fetchPage()
        }
    }
  }

  func fetchPage() async {
    do {
      let ui = try await cloudKit.fetchPage(slug: slug)
      viewState = .loaded(ui)
    } catch {
      // TODO: Handle error
    }
  }
}

struct PageRenderer: View {
  let ui: [UI]

  var body: some View { ForEach(ui) { render($0) } }

  @ViewBuilder
  func render(_ ui: UI) -> some View {
    switch ui {
    case .home:
      Home()
    case .eventDetail(let eventDetailUI):
      if let details = eventDetailUI.first(where: { item in
        if case .details = item { return true }
        return false
      }) {
        if case .details(let title, let image, let id, let share) = details {
          // There's a very hairy issue going on here and I have no idea why.
          // Please comment the NavigationStack, run and see for yourself.
          // TODO: Try to create the nested version of `.details` by adding the NavigationStack
          // TODO: workaround to the EventDetailRenderer itself, so we can at least clean this
          // TODO: weird mess up.
          NavigationStack {
            EventDetail(
              title: title,
              image: image,
              imageID: id,
              ui: eventDetailUI,
              shareURL: share
            )
          }
        } else {
          EventDetailRenderer(ui: eventDetailUI)
        }
      } else {
        EventDetailRenderer(ui: eventDetailUI)
      }
    }
  }
}
