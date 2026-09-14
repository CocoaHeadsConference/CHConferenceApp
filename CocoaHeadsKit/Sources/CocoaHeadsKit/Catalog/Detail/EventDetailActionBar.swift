//
//  EventDetailActionBar.swift
//  CocoaHeadsKit
//
//  Bottom primary action pinned in the safe area. Opens the event page externally.
//

import CocoaHeadsCore
import SwiftUI

struct EventDetailActionBar: View {
  let phase: EventPhase
  let url: URL

  @Environment(\.openURL) private var openURL

  var body: some View {
    Button {
      openURL(url)
    } label: {
      Text(EventDetailFormatting.primaryActionTitle(for: phase))
        .font(.headline)
        .foregroundStyle(MataTheme.onAccent)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }
    #if os(visionOS)
      .buttonStyle(.borderedProminent)
    #else
      .buttonStyle(.glassProminent)
    #endif
    .tint(MataTheme.accent)
    .controlSize(.large)
    .frame(maxWidth: EventDetailFormatting.readableWidth)
    .frame(maxWidth: .infinity)
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
    .accessibilityHint("Abre a página do evento no navegador")
  }
}
