//
//  UIOrderingEditor.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/14/25.
//

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
            .onMove {
              indexSet,
              int in
              moveEventDetailUI(
                fromOffsets: indexSet,
                toOffset: int,
                on: uiElement.wrappedValue
              )
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

  func moveEventDetailUI(
    fromOffsets indexSet: IndexSet,
    toOffset int: Int,
    on base: UI
  ) {
    let uiCopy = ui
    guard
      let baseIndex = ui.firstIndex(where: {
        $0 == base
      })
    else { return }
    if case .eventDetail(var eventDetailUIArray) = ui[baseIndex] {
      eventDetailUIArray.move(
        fromOffsets: indexSet,
        toOffset: int
      )
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
