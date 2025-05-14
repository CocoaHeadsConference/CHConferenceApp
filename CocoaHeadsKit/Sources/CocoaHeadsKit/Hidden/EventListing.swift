//
//  EventListing.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/11/25.
//

import CoreLocation
import PhotosUI
import SwiftUI

struct EventListing: View {

  @Environment(\.cloudKitService) var cloudKit

  enum ViewState {
    case loaded([Event])
    case loading
    case error(String)
  }

  @State private var viewState = ViewState.loading

  var onEventTap: ((Event) -> Void)?

  var body: some View {
    ZStack {
      switch viewState {
      case .loaded(let array):
        List(array) { event in
          if let onEventTap {
            Button {
              onEventTap(event)
            } label: {
              VStack(alignment: .leading) {
                Text(event.title)
                Text(event.page)
                  .font(.caption2)
              }
            }
          } else {
            NavigationLink {
              EventEditingView(event: event)
            } label: {
              VStack(alignment: .leading) {
                Text(event.title)
                Text(event.page)
                  .font(.caption2)
              }
            }
          }
        }
      case .loading:
        ProgressView()
          .task {
            await fetchEvents()
          }
      case .error(let description):
        ContentUnavailableView(
          "Algum erro ocorreu",
          systemImage: "xmark.circle",
          description: Text(description)
        )
      }
    }
    .toolbar {
      NavigationLink {
        EventCreationView()
      } label: {
        Image(systemName: "plus")
      }
    }
  }

  private func fetchEvents() async {
    do {
      let events = try await cloudKit.fetchEventList()
      viewState = .loaded(events)
    } catch {
      viewState = .error(error.localizedDescription)
    }
  }
}
