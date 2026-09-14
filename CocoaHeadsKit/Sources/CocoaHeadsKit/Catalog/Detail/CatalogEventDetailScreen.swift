//
//  CatalogEventDetailScreen.swift
//  CocoaHeadsKit
//
//  Native event detail for the CocoaHeads catalog. Renders the supplied event
//  immediately, then upgrades it from the event repository (cache, then network).
//

import CocoaHeadsCore
import CocoaHeadsNetworking
import SwiftUI

struct CatalogEventDetailScreen: View {
  @Environment(\.eventRepository) private var repository
  @Environment(\.horizontalSizeClass) private var sizeClass
  @Environment(\.scenePhase) private var scenePhase
  @State private var loader: EventDetailLoader

  private let chapter: ChapterSummary?

  init(event: CommunityEvent, chapter: ChapterSummary?) {
    _loader = State(initialValue: EventDetailLoader(event: event))
    self.chapter = chapter
  }

  private var event: CommunityEvent { loader.event }

  var body: some View {
    Group {
      if loader.isUnsupported {
        CatalogUpdateRequiredView()
      } else {
        // Keeps phase changes and relative countdowns current while the screen stays open.
        TimelineView(.periodic(from: .now, by: 30)) { context in
          content(phase: event.phase(at: context.date))
        }
      }
    }
    .navigationTitle(event.title)
    .toolbarTitleDisplayMode(.inline)
    .toolbar(removing: .title)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        ShareLink(item: event.shareURL ?? event.registrationURL)
      }
    }
    .task {
      await loader.load(using: repository)
    }
    .onChange(of: scenePhase) { _, phase in
      if phase == .active {
        Task { await loader.refresh(using: repository) }
      }
    }
  }

  private func content(phase: EventPhase) -> some View {
    ScrollView {
      VStack(spacing: 0) {
        EventArtwork(
          title: event.title,
          eyebrow: EventDetailFormatting.heroCaption(for: event, chapter: chapter),
          imageURL: event.imageURL
        )
        .frame(maxWidth: .infinity)

        VStack(alignment: .leading, spacing: 28) {
          if loader.showsRefreshNotice {
            CatalogRefreshNotice(date: loader.lastUpdated) {
              Task { await loader.refresh(using: repository) }
            }
          }

          EventDetailInfoCards(event: event, phase: phase)

          if let venue = event.venue, event.format != .online {
            EventDirectionsView(venue: venue)
          }

          if !event.talks.isEmpty {
            EventDetailSpeakers(talks: event.talks)
          }

          if !event.summary.isEmpty {
            EventDetailSummary(summary: event.summary)
          }

          if !event.links.isEmpty {
            EventDetailLinks(links: event.links)
          }

          if let sessionID = event.qaSessionID,
            !sessionID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
          {
            EventDetailQAEntry(sessionID: sessionID)
          }
        }
        .frame(maxWidth: EventDetailFormatting.readableWidth, alignment: .leading)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, horizontalMargin)
        .padding(.top, 24)
        .padding(.bottom, 32)
        .background(MataTheme.background)
      }
    }
    .background {
      // Extends the hero's green behind the navigation bar and the top overscroll.
      ZStack(alignment: .top) {
        MataTheme.background
        MataTheme.accent.frame(height: 360)
      }
      .ignoresSafeArea()
    }
    .safeAreaInset(edge: .bottom) {
      EventDetailActionBar(phase: phase, url: event.registrationURL)
    }
    .refreshable {
      await loader.refresh(using: repository)
    }
  }

  private var horizontalMargin: CGFloat {
    sizeClass == .regular ? 32 : 20
  }
}

#Preview("Próximo") {
  NavigationStack {
    CatalogEventDetailScreen(
      event: CommunityEvent(
        id: "preview-42",
        chapterID: "sao-paulo",
        title: "SwiftUI em produção: lições de escala",
        edition: "Encontro #42",
        startDate: .now.addingTimeInterval(60 * 60 * 24 * 3),
        endDate: .now.addingTimeInterval(60 * 60 * 24 * 3 + 60 * 60 * 3),
        summary:
          "Como levamos uma base SwiftUI de protótipo a produção: arquitetura, performance e os erros que evitamos no caminho.",
        registrationURL: URL(string: "https://cocoaheads.com.br/eventos/42")!,
        format: .hybrid,
        venue: EventVenue(
          name: "Apple Developer Academy",
          address: "Rua Butantã 194, São Paulo - SP",
          latitude: -23.569160,
          longitude: -46.697270
        ),
        onlineURL: URL(string: "https://youtube.com/@cocoaheadsbr"),
        talks: [
          EventTalk(
            id: "t1", title: "SwiftUI em produção", speakerName: "Palestrante Convidado", speakerRole: "iOS Engineer"),
          EventTalk(
            id: "t2", title: "async/await na prática", speakerName: "Maria Silva", speakerRole: "Staff Engineer")
        ],
        links: [
          EventLink(id: "l1", title: "Slides da palestra", url: URL(string: "https://cocoaheads.com.br")!)
        ],
        qaSessionID: "preview-session"
      ),
      chapter: ChapterSummary(id: "sao-paulo", name: "São Paulo")
    )
  }
}
