import CocoaHeadsCore
import SwiftUI

struct EventHomeRow: View {
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  let event: CommunityEvent
  let chapter: ChapterSummary?
  let now: Date

  var body: some View {
    NavigationLink(value: event) {
      let layout =
        dynamicTypeSize.isAccessibilitySize
        ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
        : AnyLayout(HStackLayout(alignment: .center, spacing: 16))
      layout {
        EventDateBadge(event: event)
        VStack(alignment: .leading, spacing: 5) {
          Text(event.title)
            .font(.headline)
            .foregroundStyle(.primary)
            .fixedSize(horizontal: false, vertical: true)
          Text(EventHomeFeed.subtitle(for: event, chapter: chapter))
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
          if case .endedToday = event.phase(at: now) {
            Text("Encerrado hoje")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        if !dynamicTypeSize.isAccessibilitySize {
          Image(systemName: "chevron.right")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.tertiary)
            .accessibilityHidden(true)
        }
      }
      .padding(18)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      .background(MataTheme.surface, in: RoundedRectangle(cornerRadius: 24))
      .contentShape(RoundedRectangle(cornerRadius: 24))
    }
    .buttonStyle(.plain)
    .accessibilityElement(children: .combine)
    .accessibilityHint("Abre os detalhes do evento")
  }
}

struct EventHomeOngoingCard: View {
  let event: CommunityEvent
  let chapter: ChapterSummary?
  let openQuestions: (String) -> Void

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  private var usesColumns: Bool {
    horizontalSizeClass == .regular && !dynamicTypeSize.isAccessibilitySize
  }

  var body: some View {
    Group {
      if usesColumns {
        HStack(alignment: .top, spacing: 0) {
          hero
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
          eventSections
            .padding(20)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
        .fixedSize(horizontal: false, vertical: true)
      } else {
        VStack(alignment: .leading, spacing: 0) {
          hero
          eventSections
            .padding(20)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(MataTheme.surface)
    .clipShape(RoundedRectangle(cornerRadius: 24))
  }

  private var hero: some View {
    NavigationLink(value: event) {
      EventArtwork(
        title: event.title,
        eyebrow: "Acontecendo agora",
        subtitle: EventHomeFeed.subtitle(for: event, chapter: chapter),
        imageURL: event.imageURL,
        cornerRadius: 0,
        fillsAvailableHeight: usesColumns)
    }
    .buttonStyle(.plain)
    .accessibilityElement(children: .combine)
    .accessibilityHint("Abre a programação completa do evento")
  }

  private var eventSections: some View {
    VStack(alignment: .leading, spacing: 18) {
      if let venue = event.venue, event.format != .online {
        EventDirectionsView(
          venue: venue,
          presentation: horizontalSizeClass == .regular ? .embeddedExpanded : .embeddedExpandable)
      }

      if let onlineURL = event.onlineURL, event.format != .inPerson {
        VStack(alignment: .leading, spacing: 12) {
          Label("Transmissão online", systemImage: "video")
            .font(.headline)
          Text("Acompanhe o encontro e participe da conversa de onde estiver.")
            .font(.subheadline).foregroundStyle(.secondary)
          Link("Abrir transmissão", destination: onlineURL)
            .foregroundStyle(MataTheme.onAccent)
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }

      if let sessionID = event.qaSessionID,
        !sessionID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      {
        if event.venue != nil || event.onlineURL != nil {
          Divider()
        }
        EventQuestionsPreview(isEmbedded: true) { openQuestions(sessionID) }
      }
    }
  }
}
