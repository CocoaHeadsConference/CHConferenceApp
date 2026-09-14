import CocoaHeadsCore
import SwiftUI

struct ChapterEmptyStateView: View {
  let chapter: ChapterSummary
  let upcomingEvents: [CommunityEvent]
  let chapters: [ChapterSummary]
  let now: Date

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.horizontalSizeClass) private var sizeClass

  var body: some View {
    VStack(alignment: .leading, spacing: 28) {
      ChapterHelpCard(chapter: chapter)

      Text("Enquanto isso, no Brasil")
        .font(.headline)
        .foregroundStyle(.secondary)
        .accessibilityAddTraits(.isHeader)

      if upcomingEvents.isEmpty {
        Text("Os próximos encontros da comunidade aparecerão aqui assim que forem anunciados.")
          .foregroundStyle(.secondary)
      } else {
        eventsGrid
      }
    }
  }

  private var eventsGrid: some View {
    LazyVGrid(
      columns: dynamicTypeSize.isAccessibilitySize || sizeClass == .compact
        ? [GridItem(.flexible())]
        : [GridItem(.adaptive(minimum: 310), spacing: 14)],
      alignment: .leading, spacing: 14
    ) {
      ForEach(upcomingEvents) { event in
        EventHomeRow(
          event: event, chapter: chapters.first { $0.id == event.chapterID }, now: now)
      }
    }
  }
}

private struct ChapterHelpCard: View {
  let chapter: ChapterSummary
  @State private var helpDestination: HelpDestination?

  private enum HelpDestination: String, Identifiable {
    case speak = "Quero palestrar"
    case contribute = "Quero contribuir"
    var id: Self { self }
  }

  var body: some View {
    VStack(spacing: 24) {
      Image(systemName: "cup.and.saucer")
        .font(.system(size: 40, weight: .medium))
        .foregroundStyle(MataTheme.accent)
        .frame(width: 94, height: 94)
        .background(MataTheme.accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 24))
        .accessibilityHidden(true)

      VStack(spacing: 12) {
        Text("Sem encontros em \(chapter.name)")
          .font(.title2.weight(.bold))
          .accessibilityAddTraits(.isHeader)
        Text(
          "Ajude a comunidade a organizar o próximo encontro. Compartilhe o que você sabe ou dê uma força nos bastidores."
        )
        .font(.body)
        .foregroundStyle(.secondary)
      }
      .multilineTextAlignment(.center)
      .fixedSize(horizontal: false, vertical: true)

      VStack(spacing: 12) {
        Button {
          helpDestination = .speak
        } label: {
          Text("Quero palestrar").font(.headline)
            .foregroundStyle(MataTheme.onAccent)
            .frame(maxWidth: .infinity).padding(.vertical, 8)
        }
        .buttonStyle(.borderedProminent)

        Button {
          helpDestination = .contribute
        } label: {
          Text("Quero contribuir").font(.headline)
            .frame(maxWidth: .infinity).padding(.vertical, 8)
        }
        .buttonStyle(.bordered)
      }
      .controlSize(.large)
      .buttonBorderShape(.roundedRectangle(radius: 18))
      .frame(maxWidth: 460)
    }
    .padding(28)
    .frame(maxWidth: .infinity)
    .background(MataTheme.surface, in: RoundedRectangle(cornerRadius: 28))
    .sheet(item: $helpDestination) { destination in
      NavigationStack {
        CocoaHeadsPlaceholder(destination.rawValue)
          .navigationTitle(chapter.name)
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .confirmationAction) {
              Button("Fechar") { helpDestination = nil }
            }
          }
      }
    }
  }
}
