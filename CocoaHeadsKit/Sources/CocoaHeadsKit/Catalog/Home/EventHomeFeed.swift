import CocoaHeadsCore
import Foundation

enum EventHomePeriod: String, CaseIterable, Identifiable {
  case upcoming, past

  var id: Self { self }
  var title: String { self == .upcoming ? "Próximos" : "Passados" }
}

/// Chapter pages expose their complete timeline; the national feed filters only its ordinary rows.
struct EventHomeFeed {
  struct Month: Identifiable {
    let id: String
    let title: String
    var events: [CommunityEvent]
  }

  let ongoing: [CommunityEvent]
  let features: [CatalogFeature]
  let upcomingMonths: [Month]
  let pastMonths: [Month]
  let months: [Month]
  let isEmpty: Bool

  init(
    catalog: EventCatalog, chapterID: String?, query: String,
    period: EventHomePeriod, now: Date
  ) {
    let query = Self.normalized(query)
    let chapterNames = Dictionary(
      catalog.chapters.map { ($0.id, $0.name) },
      uniquingKeysWith: { first, _ in first })
    let eventsByID = Dictionary(
      catalog.events.map { ($0.id, $0) },
      uniquingKeysWith: { first, _ in first })
    let matching = catalog.events.filter { event in
      guard chapterID == nil || event.chapterID == chapterID else { return false }
      return query.isEmpty || Self.normalized(Self.searchableText(for: event, chapters: chapterNames)).contains(query)
    }

    let chronological = matching.sorted(by: Self.ascending)
    let live = chronological.filter { $0.phase(at: now) == .ongoing }
    let upcoming = chronological.filter { $0.phase(at: now) != .past }
    let past = chronological.filter { $0.phase(at: now) == .past }.sorted {
      if $0.startDate == $1.startDate { return $0.id < $1.id }
      return $0.startDate > $1.startDate
    }

    let sourceFeatures =
      catalog.features.isEmpty
      ? Self.legacyFeatures(in: catalog, now: now)
      : catalog.features
    let scopedFeatures: [CatalogFeature]
    if let chapterID {
      scopedFeatures = sourceFeatures.filter { $0.chapterID == chapterID }
    } else {
      var selectedChapters = Set<String>()
      scopedFeatures = sourceFeatures.filter { feature in
        guard let chapterID = feature.chapterID else { return true }
        return selectedChapters.insert(chapterID).inserted
      }
    }

    // Choose a chapter's national feature before searching; a later feature must not replace it.
    let visibleFeatures = scopedFeatures.filter { feature in
      guard !query.isEmpty else { return true }
      var text = [feature.title, feature.subtitle ?? "", chapterNames[feature.chapterID ?? ""] ?? ""]
      if case .event(let id) = feature.destination, let event = eventsByID[id] {
        text.append(Self.searchableText(for: event, chapters: chapterNames))
      }
      return Self.normalized(text.joined(separator: " ")).contains(query)
    }

    let upcomingGroups = Self.groupedByMonth(upcoming)
    let pastGroups = Self.groupedByMonth(past)
    let ordinaryGroups: [Month]
    if chapterID != nil {
      // Chapter UI renders these and pastMonths as separate, always-visible timeline sections.
      ordinaryGroups = upcomingGroups
    } else if period == .past {
      ordinaryGroups = pastGroups
    } else {
      ordinaryGroups = Self.groupedByMonth(upcoming.filter { $0.phase(at: now) != .ongoing })
    }

    ongoing = live
    features = visibleFeatures
    upcomingMonths = upcomingGroups
    pastMonths = pastGroups
    months = ordinaryGroups
    isEmpty =
      live.isEmpty && visibleFeatures.isEmpty && ordinaryGroups.isEmpty
      && (chapterID == nil || pastGroups.isEmpty)
  }

  static let locale = Locale(identifier: "pt_BR")

  private static func normalized(_ value: String) -> String {
    value.trimmingCharacters(in: .whitespacesAndNewlines)
      .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: locale)
  }

  private static func searchableText(for event: CommunityEvent, chapters: [String: String]) -> String {
    ([event.title, chapters[event.chapterID] ?? ""]
      + event.talks.flatMap { [$0.title, $0.speakerName] }).joined(separator: " ")
  }

  private static func ascending(_ lhs: CommunityEvent, _ rhs: CommunityEvent) -> Bool {
    if lhs.startDate == rhs.startDate { return lhs.id < rhs.id }
    return lhs.startDate < rhs.startDate
  }

  private static func legacyFeatures(in catalog: EventCatalog, now: Date) -> [CatalogFeature] {
    catalog.events.compactMap { event in
      guard event.isFeatured, event.phase(at: now) != .ongoing, event.phase(at: now) != .past else {
        return nil
      }
      let date = event.startDate.formatted(
        Date.FormatStyle(locale: locale, timeZone: event.timeZone).day().month(.abbreviated))
      let chapter = catalog.chapters.first { $0.id == event.chapterID }
      let details = "\(date) · \(subtitle(for: event, chapter: chapter))"
      return CatalogFeature(
        id: "legacy-event-\(event.id)", chapterID: event.chapterID,
        title: event.title,
        subtitle: event.phase(at: now) == .endedToday ? "Encerrado hoje · \(details)" : details,
        imageURL: event.imageURL, destination: .event(id: event.id))
    }
  }

  private static func groupedByMonth(_ events: [CommunityEvent]) -> [Month] {
    var groups: [Month] = []
    for event in events {
      var calendar = Calendar(identifier: .gregorian)
      calendar.timeZone = event.timeZone
      let date = calendar.dateComponents([.year, .month], from: event.startDate)
      let id = "\(date.year ?? 0)-\(date.month ?? 0)"
      if let index = groups.firstIndex(where: { $0.id == id }) {
        groups[index].events.append(event)
      } else {
        let formatter = DateFormatter()
        formatter.locale = Self.locale
        formatter.timeZone = event.timeZone
        formatter.dateFormat = "MMMM 'de' yyyy"
        groups.append(
          Month(
            id: id, title: formatter.string(from: event.startDate),
            events: [event]))
      }
    }
    return groups
  }

  /// Nearby chapters can be quiet while the national community still has upcoming events.
  static func upcomingElsewhere(
    in catalog: EventCatalog, excludingChapterID: String, now: Date
  ) -> [CommunityEvent] {
    catalog.events.filter {
      $0.chapterID != excludingChapterID
        && ($0.phase(at: now) == .upcoming || $0.phase(at: now) == .ongoing)
    }.sorted {
      if $0.startDate == $1.startDate { return $0.id < $1.id }
      return $0.startDate < $1.startDate
    }
  }

  static func time(for event: CommunityEvent) -> String {
    let formatter = DateFormatter()
    formatter.locale = locale
    formatter.timeZone = event.timeZone
    formatter.dateFormat = "HH'h'mm"
    return formatter.string(from: event.startDate)
  }

  static func subtitle(for event: CommunityEvent, chapter: ChapterSummary?) -> String {
    var parts: [String] = []
    if let chapter { parts.append(chapter.name) }
    switch event.format {
    case .inPerson: break
    case .online: parts.append("Online")
    case .hybrid: parts.append("Presencial e online")
    }
    parts.append(time(for: event))
    return parts.joined(separator: " · ")
  }

}
