import CocoaHeadsCore
import CocoaHeadsNetworking
import QAKit
import SwiftUI

/// The events tab keeps chapter selection and its navigation independent of the profile tab.
@MainActor
public struct EventsHomeView: View {
  @Environment(CocoaHeadsAppServices.self) private var services
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.scenePhase) private var scenePhase
  @AppStorage("catalog.selectedChapterID") private var selectedChapterID = ""

  @State private var period = EventHomePeriod.upcoming
  @Binding private var searchText: String
  private let isSearch: Bool
  @State private var path: [CommunityEvent] = []
  @State private var questionSession: QuestionSession?

  private var catalog: EventCatalogLoader { services.catalog }
  private var snapshot: ScreenSnapshot<EventCatalog>? { catalog.snapshot }
  private var hasSearchQuery: Bool {
    !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  private struct QuestionSession: Identifiable {
    let id: String
  }

  public init() {
    _searchText = .constant("")
    isSearch = false
  }

  init(searchText: Binding<String>) {
    _searchText = searchText
    isSearch = true
  }

  public var body: some View {
    GeometryReader { geometry in
      if !isSearch && geometry.size.width >= 800 && !dynamicTypeSize.isAccessibilitySize {
        NavigationSplitView {
          chapterSidebar
        } detail: {
          navigationContent(isWide: true)
        }
        .navigationSplitViewStyle(.balanced)
      } else {
        navigationContent(isWide: false)
      }
    }
    .tint(MataTheme.accent)
    .background(MataTheme.background)
    .task(id: isSearch && hasSearchQuery) {
      if !isSearch || hasSearchQuery { await catalog.load() }
    }
    .onChange(of: selectedChapterID) { _, _ in
      path.removeAll()
    }
    .onChange(of: scenePhase) { _, phase in
      if phase == .active, catalog.hasLoaded {
        Task { await refresh() }
      }
    }
    .sheet(item: $questionSession) { session in
      QAListView(sessionID: session.id)
    }
    .onChange(of: services.catalogRevision) { _, _ in
      Task { await refresh() }
    }
    .onChange(of: snapshot?.content.chapters.map(\.id), initial: true) { _, _ in
      validateSelectedChapter()
    }
  }

  private var selectedChapter: ChapterSummary? {
    snapshot?.content.chapters.first { $0.id == selectedChapterID }
  }

  private var chapterTitle: String { selectedChapter?.name ?? "Todo o Brasil" }

  private var sortedChapters: [ChapterSummary] {
    (snapshot?.content.chapters ?? []).sorted {
      $0.name.localizedStandardCompare($1.name) == .orderedAscending
    }
  }

  private var chapterSidebar: some View {
    List(selection: Binding<String?>(get: { selectedChapterID }, set: { selectedChapterID = $0 ?? "" })) {
      Label("Todo o Brasil", systemImage: "globe.americas")
        .tag("")
      Section("Capítulos") {
        ForEach(sortedChapters) { chapter in
          Label {
            VStack(alignment: .leading, spacing: 2) {
              Text(chapter.name)
              if let region = chapter.region, !region.isEmpty {
                Text(region).font(.caption).foregroundStyle(.secondary)
              }
            }
          } icon: {
            Image(systemName: "mappin.and.ellipse")
          }
          .tag(chapter.id)
        }
      }
    }
    .navigationTitle("CocoaHeads")
    .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 320)
  }

  private func navigationContent(isWide: Bool) -> some View {
    NavigationStack(path: $path) {
      GeometryReader { geometry in
        TimelineView(.periodic(from: .now, by: 30)) { context in
          screenContent(now: context.date, availableWidth: geometry.size.width)
        }
      }
      .background(MataTheme.background)
      .navigationTitle(isSearch ? "Buscar" : (isWide ? chapterTitle : "CocoaHeads"))
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        if !isWide && (!isSearch || hasSearchQuery) {
          ToolbarItem(placement: .topBarLeading) {
            chapterMenu
          }
        }
      }
      .navigationDestination(for: CommunityEvent.self) { event in
        CatalogEventDetailScreen(
          event: event,
          chapter: snapshot?.content.chapters.first { $0.id == event.chapterID })
      }
    }
  }

  private var chapterMenu: some View {
    Menu {
      Picker("Capítulo", selection: $selectedChapterID) {
        Text("Todo o Brasil").tag("")
        ForEach(sortedChapters) { chapter in
          Text(chapter.name).tag(chapter.id)
        }
      }
    } label: {
      HStack(spacing: 6) {
        Image(systemName: "mappin.and.ellipse")
        Text(chapterTitle)
          .lineLimit(1)
        Image(systemName: "chevron.down")
          .font(.caption2.weight(.semibold))
      }
    }
    .accessibilityLabel("Capítulo: \(chapterTitle)")
    .accessibilityHint("Escolha uma cidade ou veja os eventos de todo o Brasil")
  }

  @ViewBuilder
  private func screenContent(now: Date, availableWidth: CGFloat) -> some View {
    if isSearch && !hasSearchQuery {
      Color.clear
    } else if catalog.isUnsupported {
      CatalogUpdateRequiredView()
    } else if let snapshot {
      catalogContent(snapshot, now: now, availableWidth: availableWidth)
    } else if catalog.isLoading {
      ProgressView("Carregando eventos…")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    } else {
      CatalogLoadFailureView(retry: retry)
    }
  }

  private func catalogContent(
    _ snapshot: ScreenSnapshot<EventCatalog>, now: Date,
    availableWidth: CGFloat
  ) -> some View {
    let feed = EventHomeFeed(
      catalog: snapshot.content, chapterID: selectedChapter?.id,
      query: searchText, period: period, now: now)
    let chapterHasUpcoming = snapshot.content.events.contains {
      $0.chapterID == selectedChapter?.id && $0.phase(at: now) != .past
    }
    let needsChapterHelp =
      selectedChapter != nil && !chapterHasUpcoming
      && searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

    return ScrollView {
      LazyVStack(alignment: .leading, spacing: 24) {
        if !catalog.isRefreshing && (catalog.refreshFailed || snapshot.isStale) {
          CatalogRefreshNotice(date: snapshot.cachedAt, retry: retry)
        }
        if catalog.isRefreshing {
          ProgressView("Atualizando eventos…")
            .font(.footnote)
        }

        ForEach(feed.ongoing) { event in
          EventHomeOngoingCard(event: event, chapter: chapter(for: event)) { sessionID in
            questionSession = QuestionSession(id: sessionID)
          }
        }

        if !feed.features.isEmpty {
          CatalogFeatureGallery(
            features: feed.features, catalog: snapshot.content,
            isNational: selectedChapter == nil, availableWidth: availableWidth - 40)
        }

        if selectedChapter != nil {
          if needsChapterHelp, let chapter = selectedChapter {
            ChapterEmptyStateView(
              chapter: chapter,
              upcomingEvents: EventHomeFeed.upcomingElsewhere(
                in: snapshot.content, excludingChapterID: chapter.id, now: now),
              chapters: snapshot.content.chapters, now: now)
          } else if !feed.upcomingMonths.isEmpty {
            timelineHeader("Atuais e próximos")
            monthSections(feed.upcomingMonths, now: now, availableWidth: availableWidth)
          }

          if !feed.pastMonths.isEmpty {
            Divider().padding(.top, 8)
            timelineHeader("Encontros passados")
            monthSections(feed.pastMonths, now: now, availableWidth: availableWidth)
          }
          if !needsChapterHelp && feed.isEmpty {
            emptyFeed
          }
        } else {
          periodPicker
          if feed.months.isEmpty {
            if period == .past || feed.ongoing.isEmpty {
              emptyFeed
            }
          } else {
            monthSections(feed.months, now: now, availableWidth: availableWidth)
          }
        }
      }
      .padding(.horizontal, 20)
      .padding(.top, 8)
      .padding(.bottom, 28)
      .frame(maxWidth: 1040)
      .frame(maxWidth: .infinity, alignment: .top)
    }
    .refreshable { await refresh() }
  }

  private func timelineHeader(_ title: String) -> some View {
    Text(title)
      .font(.title2.weight(.bold))
      .accessibilityAddTraits(.isHeader)
  }

  private func monthSections(
    _ months: [EventHomeFeed.Month], now: Date, availableWidth: CGFloat
  ) -> some View {
    ForEach(months) { month in
      VStack(alignment: .leading, spacing: 12) {
        Text(month.title.uppercased())
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(.secondary)
          .accessibilityAddTraits(.isHeader)
        LazyVGrid(columns: gridColumns(availableWidth: availableWidth), alignment: .leading, spacing: 14) {
          ForEach(month.events) { event in
            EventHomeRow(event: event, chapter: chapter(for: event), now: now)
          }
        }
      }
    }
  }

  private var periodPicker: some View {
    Picker("Período", selection: $period) {
      ForEach(EventHomePeriod.allCases) { period in
        Text(period.title).tag(period)
      }
    }
    .pickerStyle(.segmented)
    .frame(maxWidth: 440)
    .accessibilityLabel("Período dos eventos")
  }

  private func gridColumns(availableWidth: CGFloat) -> [GridItem] {
    if dynamicTypeSize.isAccessibilitySize { return [GridItem(.flexible())] }
    let minimum = min(310, max(1, min(availableWidth, 1040) - 40))
    return [GridItem(.adaptive(minimum: minimum), spacing: 14, alignment: .top)]
  }

  private var emptyFeed: some View {
    let hasSearch = !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    return ContentUnavailableView {
      Label {
        if hasSearch {
          Text(selectedChapter == nil ? "Nenhum evento encontrado neste período" : "Nenhum evento encontrado")
        } else if selectedChapter == nil && period == .past {
          Text("Ainda não há encontros passados")
        } else if let selectedChapter {
          Text("Sem próximos encontros em \(selectedChapter.name)")
        } else {
          Text("Novos encontros vêm por aí")
        }
      } icon: {
        Image(systemName: hasSearch ? "magnifyingglass" : "cup.and.saucer")
      }
    } description: {
      if hasSearch {
        Text("Tente outro assunto, nome de palestra ou capítulo.")
      } else if selectedChapter == nil && period == .past {
        Text("Os encontros aparecem aqui depois do seu último dia.")
      } else if selectedChapter != nil {
        Text("Este capítulo ainda não tem encontros anunciados. Explore os eventos de outras cidades.")
      } else {
        Text("Os próximos eventos da comunidade aparecerão aqui assim que forem anunciados.")
      }
    } actions: {
      if hasSearch {
        Button("Limpar busca") { searchText = "" }
          .buttonStyle(.bordered)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 28)
  }

  private func chapter(for event: CommunityEvent) -> ChapterSummary? {
    snapshot?.content.chapters.first { $0.id == event.chapterID }
  }

  private func retry() {
    Task { await refresh() }
  }

  private func refresh() async {
    await catalog.refresh()
  }

  private func validateSelectedChapter() {
    if let snapshot, !selectedChapterID.isEmpty,
      !snapshot.content.chapters.contains(where: { $0.id == selectedChapterID })
    {
      selectedChapterID = ""
    }
  }
}
