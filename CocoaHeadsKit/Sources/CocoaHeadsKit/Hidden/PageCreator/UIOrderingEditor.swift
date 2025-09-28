//
//  UIOrderingEditor.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/14/25.
//

import CocoaHeadsCore
import SwiftUI

struct UIOrderingEditor: View {

  @Binding var ui: [UI]
  @State private var isExpanded: [String: Bool] = [:]

  func binding(_ uiElement: UI) -> Binding<Bool> {
    Binding(
      // TODO: This means there can be only one of these open per page
      // TODO: We need a stable UI that is independent of the inner element order
      // TODO: Maybe sort the elements inside and hash? idk
      get: { isExpanded[uiElement.description] ?? false },
      set: { isExpanded[uiElement.description] = $0 }
    )
  }

  var body: some View {
    Form {
      ForEach($ui) { uiElement in
        DisclosureGroup(isExpanded: binding(uiElement.wrappedValue)) {
          switch uiElement.wrappedValue {
          case .home(let innerUI):
            Text(innerUI.id)
          case .eventDetail(let innerUI):
            // TODO: This could be its own View
            ForEach(innerUI) { eventUI in
              Text(eventUI.id)
            }
            .onMove { indexSet, int in
              updateEventDetailUI(on: uiElement.wrappedValue) {
                $0.move(fromOffsets: indexSet, toOffset: int)
              }
            }
            .onDelete { indexSet in
              updateEventDetailUI(on: uiElement.wrappedValue) {
                $0.remove(atOffsets: indexSet)
              }
            }
          }
        } label: {
          VStack {
            Text(uiElement.wrappedValue.description)
              .font(.title2)
            Text(uiElement.id)
              .font(.caption2)
          }
        }
      }
    }
  }

  private func updateEventDetailUI(
    on base: UI,
    apply: (inout [EventDetailUI]) -> Void
  ) {
    guard
      let baseIndex = ui.firstIndex(where: { $0 == base })
    else { return }
    if case .eventDetail(var eventDetailUIArray) = ui[baseIndex] {
      apply(&eventDetailUIArray)
      ui[baseIndex] = .eventDetail(eventDetailUIArray)
    }
  }
}

#Preview {
  @Previewable @State var ui: [UI] = [
    .eventDetail([
      .card(
        title: "test card",
        ui: [
          .text("test")
        ]),
      .card(
        title: "talk card",
        ui: [
          .speaker(name: "speaker", talk: "talk")
        ]),
      .card(
        title: "call to action",
        ui: [
          .callToAction(title: "visit apple", url: .apple)
        ])
    ])
  ]
  UIOrderingEditor(ui: $ui)
}
