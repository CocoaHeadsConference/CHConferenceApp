//
//  EventDetailPickerView.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/9/25.
//

import SwiftUI

struct EventDetailUIViewer: View {

  let elements: [EventDetailUI] = [
    .card(title: "Card Title", ui: [.text("Card Content")]),
    .carousel(ui: [.text("Carousel Item 1"), .text("Carousel Item 2"), .link(.apple)]),
    .callToAction(title: "Learn More", url: URL(string: "https://apple.com")!, systemImage: "link"),
    .caption(text: "This is a caption"),
    .debug(.text("Debug Info")),
    .divider,
    .empty,
    .link(URL(string: "https://apple.com")!, title: "Example Link"),
    .map(address: "123 Main St", lat: 37.7749, lng: -122.4194),
    .subtitle("This is a subtitle"),
    .text("Sample text"),
    .titleSubtitle(title: "Title", subtitle: "Subtitle", systemImage: "star"),
    .vstack(ui: [.text("Item 1"), .text("Item 2")])
  ]

  @State private var uiElements: [EventDetailUI] = []

  var body: some View {
    VStack {
      if !uiElements.isEmpty {
        List($uiElements, editActions: .all) { ui in
          EventDetailRenderer(ui: [ui.wrappedValue])
            .padding()
        }
        .listStyle(.grouped)
      } else {
        Text("Select an element to preview")
          .foregroundStyle(.secondary)
          .padding()
      }
    }
    .sheet(isPresented: .constant(true)) {
      List(elements) { element in
        Button(element.id.isEmpty ? "Empty Element" : element.id) {
          uiElements.append(element)
        }
      }
      .presentationDetents([
        .fraction(0.1),
        .medium,
        .large
      ])
      .presentationDragIndicator(.visible)
      .presentationBackgroundInteraction(.enabled)
      .interactiveDismissDisabled()
    }
  }
}

#Preview {
  EventDetailUIViewer()
}
