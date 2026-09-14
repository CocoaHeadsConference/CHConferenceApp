import CocoaHeadsCore
import SwiftUI

/// Featured content is editorial; its destination need not be an event.
struct CatalogFeatureGallery: View {
  let features: [CatalogFeature]
  let catalog: EventCatalog
  let isNational: Bool
  let availableWidth: CGFloat

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    if !isNational && features.count == 1, let feature = features.first {
      card(feature)
    } else {
      ScrollView(.horizontal) {
        LazyHStack(alignment: .top, spacing: 16) {
          ForEach(features) { feature in
            card(feature)
              .frame(width: cardWidth)
          }
        }
        .scrollTargetLayout()
      }
      .scrollTargetBehavior(.viewAligned)
      .scrollIndicators(.hidden)
      // Align the first card with the feed, while letting cards scroll to the screen edges.
      .contentMargins(.horizontal, 20, for: .scrollContent)
      .padding(.horizontal, -20)
      .accessibilityLabel("Destaques da comunidade")
    }
  }

  private var cardWidth: CGFloat {
    let width = max(1, min(availableWidth, 1000))
    return dynamicTypeSize.isAccessibilitySize ? width : min(620, width * 0.88)
  }

  private func card(_ feature: CatalogFeature) -> some View {
    CatalogFeatureCard(feature: feature, catalog: catalog, showsChapter: isNational)
  }
}

private struct CatalogFeatureCard: View {
  let feature: CatalogFeature
  let catalog: EventCatalog
  let showsChapter: Bool

  @State private var isPresentingPlaceholder = false

  var body: some View {
    Group {
      switch feature.destination {
      case .event(let id):
        if let event = catalog.events.first(where: { $0.id == id }) {
          NavigationLink(value: event) { artwork }
            .accessibilityHint("Abre os detalhes do evento em destaque")
        }
      case .externalURL(let url):
        Link(destination: url) { artwork }
          .accessibilityHint("Abre o destaque no navegador")
      case .placeholder:
        Button {
          isPresentingPlaceholder = true
        } label: {
          artwork
        }
        .accessibilityHint("Abre o destaque")
      }
    }
    .buttonStyle(.plain)
    .accessibilityElement(children: .combine)
    .sheet(isPresented: $isPresentingPlaceholder) {
      NavigationStack {
        if case .placeholder(let title) = feature.destination {
          CocoaHeadsPlaceholder(title)
            .navigationTitle(feature.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
              ToolbarItem(placement: .confirmationAction) {
                Button("Fechar") { isPresentingPlaceholder = false }
              }
            }
        }
      }
    }
  }

  private var artwork: some View {
    EventArtwork(
      title: feature.title, eyebrow: eyebrow, subtitle: subtitle,
      imageURL: feature.imageURL ?? linkedEvent?.imageURL
    )
    .contentShape(RoundedRectangle(cornerRadius: 24))
  }

  private var eyebrow: String {
    guard showsChapter else { return "Em destaque" }
    let chapter = catalog.chapters.first { $0.id == feature.chapterID }
    return "Em destaque · \(chapter?.name ?? "Brasil")"
  }

  private var linkedEvent: CommunityEvent? {
    guard case .event(let id) = feature.destination else { return nil }
    return catalog.events.first { $0.id == id }
  }

  private var subtitle: String? {
    if let subtitle = feature.subtitle { return subtitle }
    guard let event = linkedEvent else { return nil }
    let date = event.startDate.formatted(
      Date.FormatStyle(locale: EventHomeFeed.locale, timeZone: event.timeZone)
        .day().month(.abbreviated))
    let chapter = catalog.chapters.first { $0.id == event.chapterID }
    return "\(date) · \(EventHomeFeed.subtitle(for: event, chapter: chapter))"
  }
}
