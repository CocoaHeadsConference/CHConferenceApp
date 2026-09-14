import CocoaHeadsCore
import Foundation
import Testing

@testable import CocoaHeadsKit

@Suite("Event home feed")
struct EventHomeFeedTests {
  private let chapters = [
    ChapterSummary(id: "sp", name: "São Paulo"),
    ChapterSummary(id: "rj", name: "Rio de Janeiro"),
    ChapterSummary(id: "cwb", name: "Curitiba")
  ]

  @Test func nationalTimelineIncludesFeaturedEventsButDoesNotRepeatOngoingRows() throws {
    let now = try referenceNow()
    let saoPaulo = try event(
      "sp-live", start: "2026-09-13T17:00:00Z",
      end: "2026-09-13T20:00:00Z", featured: true)
    let rio = try event(
      "rj-live", chapterID: "rj", start: "2026-09-13T16:30:00Z",
      end: "2026-09-13T18:30:00Z")
    let promoted = try event(
      "promoted", start: "2026-09-14T18:00:00Z",
      end: "2026-09-14T20:00:00Z", featured: true)
    let next = try event("next", start: "2026-09-15T18:00:00Z", end: "2026-09-15T20:00:00Z")
    let card = feature("event-card", chapterID: "sp", destination: .event(id: promoted.id))
    let catalog = EventCatalog(chapters: chapters, events: [next, saoPaulo, promoted, rio], features: [card])

    let feed = EventHomeFeed(catalog: catalog, chapterID: nil, query: "", period: .upcoming, now: now)

    #expect(feed.ongoing.map(\.id) == ["rj-live", "sp-live"])
    #expect(feed.features == [card])
    #expect(feed.months.flatMap(\.events).map(\.id) == ["promoted", "next"])
    #expect(feed.upcomingMonths.flatMap(\.events).map(\.id) == ["rj-live", "sp-live", "promoted", "next"])
  }

  @Test(arguments: EventHomePeriod.allCases)
  func chapterExposesItsEntireTimelineAndAllOwnFeaturesRegardlessOfPeriod(period: EventHomePeriod) throws {
    let now = try referenceNow()
    let ended = try event("ended", start: "2026-09-13T10:00:00Z", end: "2026-09-13T12:00:00Z")
    let live = try event("live", start: "2026-09-13T17:00:00Z", end: "2026-09-13T20:00:00Z")
    let future = try event("future", start: "2026-09-14T18:00:00Z", end: "2026-09-14T20:00:00Z")
    let recent = try event("recent", start: "2026-09-12T18:00:00Z", end: "2026-09-12T20:00:00Z")
    let old = try event("old", start: "2026-08-10T18:00:00Z", end: "2026-08-10T20:00:00Z")
    let other = try event(
      "other-city", chapterID: "rj", start: "2026-09-14T18:00:00Z",
      end: "2026-09-14T20:00:00Z")
    let first = feature("sp-first", chapterID: "sp", destination: .event(id: future.id))
    let second = feature("sp-second", chapterID: "sp")
    let catalog = EventCatalog(
      chapters: chapters, events: [other, old, future, recent, live, ended],
      features: [first, feature("national"), second, feature("rj-card", chapterID: "rj")])

    let feed = EventHomeFeed(catalog: catalog, chapterID: "sp", query: "", period: period, now: now)

    #expect(feed.features == [first, second])
    #expect(feed.ongoing.map(\.id) == ["live"])
    #expect(feed.upcomingMonths.flatMap(\.events).map(\.id) == ["ended", "live", "future"])
    #expect(feed.pastMonths.flatMap(\.events).map(\.id) == ["recent", "old"])
    #expect(feed.months.flatMap(\.events).map(\.id) == ["ended", "live", "future"])
    #expect(!feed.isEmpty)

    let historical = EventHomeFeed(
      catalog: EventCatalog(chapters: chapters, events: [recent]),
      chapterID: "sp", query: "", period: period, now: now)
    #expect(historical.upcomingMonths.isEmpty)
    #expect(historical.pastMonths.flatMap(\.events).map(\.id) == ["recent"])
    #expect(!historical.isEmpty)
  }

  @Test func nationalFeatureSelectionPreservesSourceOrderAndPrecedesSearch() throws {
    let source = [
      feature("national-first", title: "Comunidade brasileira"),
      feature("sp-first", chapterID: "sp", title: "Arquitetura"),
      feature("rj-first", chapterID: "rj", title: "Design de apps"),
      feature("sp-later", chapterID: "sp", title: "SwiftUI em São Paulo"),
      feature("national-second", title: "SwiftUI Brasil"),
      feature("rj-later", chapterID: "rj", title: "SwiftUI no Rio")
    ]
    let catalog = EventCatalog(chapters: chapters, events: [], features: source)
    let now = try referenceNow()
    let national = EventHomeFeed(catalog: catalog, chapterID: nil, query: "", period: .upcoming, now: now)
    #expect(national.features.map(\.id) == ["national-first", "sp-first", "rj-first", "national-second"])

    let search = EventHomeFeed(catalog: catalog, chapterID: nil, query: "swiftui", period: .upcoming, now: now)
    #expect(search.features.map(\.id) == ["national-second"])
    let chapter = EventHomeFeed(catalog: catalog, chapterID: "sp", query: "swiftui", period: .past, now: now)
    #expect(chapter.features.map(\.id) == ["sp-later"])
  }

  @Test func externalAndPlaceholderFeaturesAreSearchableWithoutAnyEvents() throws {
    let external = feature(
      "mentoring", chapterID: "sp", title: "Trilha de carreira",
      subtitle: "Mentoria e portfólio",
      destination: .externalURL(try #require(URL(string: "https://example.com/mentoria"))))
    let placeholder = feature(
      "volunteering", chapterID: "sp", title: "Ajude a comunidade",
      subtitle: "Convite para voluntários", destination: .placeholder(title: "Quero contribuir"))
    let catalog = EventCatalog(chapters: chapters, events: [], features: [external, placeholder])
    let now = try referenceNow()

    for (query, expected) in [
      ("PORTFOLIO", [external]), ("voluntarios", [placeholder]),
      ("sao paulo", [external, placeholder])
    ] {
      let feed = EventHomeFeed(catalog: catalog, chapterID: "sp", query: query, period: .past, now: now)
      #expect(feed.features == expected)
      #expect(feed.upcomingMonths.isEmpty)
      #expect(feed.pastMonths.isEmpty)
      #expect(!feed.isEmpty)
    }
  }

  @Test func eventFeatureSearchIncludesLinkedEventTitleChapterTalkAndSpeaker() throws {
    let talk = EventTalk(id: "talk", title: "SwiftUI em produção", speakerName: "Álvaro Pereira")
    let linked = try event(
      "linked", title: "Escalando apps", start: "2026-09-14T18:00:00Z",
      end: "2026-09-14T20:00:00Z", talks: [talk])
    let card = feature("national-event", title: "Encontro recomendado", destination: .event(id: linked.id))
    let catalog = EventCatalog(chapters: chapters, events: [linked], features: [card])
    let now = try referenceNow()

    for query in ["escalando", "swiftui", "alvaro pereira", "sao paulo", "encontro recomendado"] {
      let feed = EventHomeFeed(catalog: catalog, chapterID: nil, query: query, period: .upcoming, now: now)
      #expect(feed.features == [card])
      #expect(!feed.isEmpty)
    }
  }

  @Test func legacyFeaturesOnlyFillAnEntirelyMissingEditorialCatalog() throws {
    let now = try referenceNow()
    let first = try event("first", start: "2026-09-15T18:00:00Z", end: "2026-09-15T20:00:00Z", featured: true)
    let second = try event("second", start: "2026-09-14T18:00:00Z", end: "2026-09-14T20:00:00Z", featured: true)
    let live = try event("live", start: "2026-09-13T17:00:00Z", end: "2026-09-13T20:00:00Z", featured: true)
    let ended = try event("ended", start: "2026-09-13T10:00:00Z", end: "2026-09-13T12:00:00Z", featured: true)
    let past = try event("past", start: "2026-09-12T18:00:00Z", end: "2026-09-12T20:00:00Z", featured: true)
    let events = [first, live, second, past, ended]
    let legacy = EventHomeFeed(
      catalog: EventCatalog(chapters: chapters, events: events),
      chapterID: "sp", query: "", period: .upcoming, now: now)
    #expect(legacy.features.map(\.destination) == [.event(id: "first"), .event(id: "second"), .event(id: "ended")])

    let editorial = feature("rj-card", chapterID: "rj")
    let catalog = EventCatalog(chapters: chapters, events: events, features: [editorial])
    let chapter = EventHomeFeed(catalog: catalog, chapterID: "sp", query: "", period: .upcoming, now: now)
    let national = EventHomeFeed(catalog: catalog, chapterID: nil, query: "", period: .upcoming, now: now)
    #expect(chapter.features.isEmpty)
    #expect(national.features == [editorial])
    #expect(national.months.flatMap(\.events).map(\.id) == ["ended", "second", "first"])
  }

  @Test(arguments: EventHomePeriod.allCases)
  func curatedFeaturesAndOngoingEventsStayVisibleAcrossNationalPeriods(period: EventHomePeriod) throws {
    let live = try event("live", start: "2026-09-13T17:00:00Z", end: "2026-09-13T20:00:00Z")
    let future = try event("future", start: "2026-09-14T18:00:00Z", end: "2026-09-14T20:00:00Z")
    let past = try event("past", start: "2026-09-12T18:00:00Z", end: "2026-09-12T20:00:00Z")
    let card = feature("recordings", destination: .event(id: past.id))
    let feed = EventHomeFeed(
      catalog: EventCatalog(chapters: chapters, events: [future, past, live], features: [card]),
      chapterID: nil, query: "", period: period, now: try referenceNow())

    #expect(feed.ongoing.map(\.id) == ["live"])
    #expect(feed.features == [card])
    #expect(feed.months.flatMap(\.events).map(\.id) == (period == .past ? ["past"] : ["future"]))
  }

  @Test func endedTodayRemainsInTheTimelineUntilTheEventTimeZoneCutoff() throws {
    let promoted = try event(
      "promoted", start: "2026-09-13T18:00:00Z",
      end: "2026-09-13T20:00:00Z", featured: true)
    let regular = try event("regular", start: "2026-09-13T17:00:00Z", end: "2026-09-13T19:00:00Z")
    let catalog = EventCatalog(chapters: chapters, events: [regular, promoted])
    // UTC already says Monday; the event's final day in São Paulo is still Sunday.
    let beforeMidnight = try instant("2026-09-14T02:59:59Z")
    let cutoff = try instant("2026-09-14T03:00:00Z")
    let ended = EventHomeFeed(catalog: catalog, chapterID: nil, query: "", period: .upcoming, now: beforeMidnight)
    #expect(ended.ongoing.isEmpty)
    #expect(ended.features.map(\.destination) == [.event(id: "promoted")])
    #expect(ended.months.flatMap(\.events).map(\.id) == ["regular", "promoted"])

    let upcoming = EventHomeFeed(catalog: catalog, chapterID: nil, query: "", period: .upcoming, now: cutoff)
    let past = EventHomeFeed(catalog: catalog, chapterID: nil, query: "", period: .past, now: cutoff)
    #expect(upcoming.isEmpty)
    #expect(past.features.isEmpty)
    #expect(past.months.flatMap(\.events).map(\.id) == ["promoted", "regular"])
  }

  @Test func pastEventsAppearNewestFirstAcrossMonths() throws {
    let oldest = try event("oldest", start: "2026-08-10T18:00:00Z", end: "2026-08-10T20:00:00Z", featured: true)
    let middle = try event("middle", start: "2026-09-01T18:00:00Z", end: "2026-09-01T20:00:00Z")
    let newest = try event("newest", start: "2026-09-12T18:00:00Z", end: "2026-09-12T20:00:00Z")
    let future = try event("future", start: "2026-09-14T18:00:00Z", end: "2026-09-14T20:00:00Z")
    let feed = EventHomeFeed(
      catalog: EventCatalog(chapters: chapters, events: [middle, oldest, future, newest]),
      chapterID: nil, query: "", period: .past, now: try referenceNow())
    #expect(feed.features.isEmpty)
    #expect(feed.months.count == 2)
    #expect(feed.months.flatMap(\.events).map(\.id) == ["newest", "middle", "oldest"])
  }

  @Test(arguments: EventHomePeriod.allCases)
  func emptyChapterDoesNotInheritNationalEventsOrFeatures(period: EventHomePeriod) throws {
    let live = try event("live", start: "2026-09-13T17:00:00Z", end: "2026-09-13T20:00:00Z")
    let catalog = EventCatalog(
      chapters: chapters, events: [live],
      features: [feature("national"), feature("sp-card", chapterID: "sp")])
    let feed = EventHomeFeed(catalog: catalog, chapterID: "cwb", query: "", period: period, now: try referenceNow())
    #expect(feed.isEmpty)
    #expect(feed.ongoing.isEmpty)
    #expect(feed.features.isEmpty)
    #expect(feed.upcomingMonths.isEmpty)
    #expect(feed.pastMonths.isEmpty)
  }

  @Test func emptyCityDiscoveryIncludesAllUpcomingBrazilEventsButNoEndedEvents() throws {
    let live = try event("live", start: "2026-09-13T17:00:00Z", end: "2026-09-13T20:00:00Z")
    let promoted = try event(
      "promoted", chapterID: "rj", start: "2026-09-15T18:00:00Z",
      end: "2026-09-15T20:00:00Z", featured: true)
    let next = try event("next", start: "2026-09-14T18:00:00Z", end: "2026-09-14T20:00:00Z")
    let ended = try event("ended", start: "2026-09-13T12:00:00Z", end: "2026-09-13T15:00:00Z")
    let past = try event("past", start: "2026-09-12T12:00:00Z", end: "2026-09-12T15:00:00Z")
    let local = try event("local", chapterID: "cwb", start: "2026-09-14T12:00:00Z", end: "2026-09-14T15:00:00Z")
    let catalog = EventCatalog(chapters: chapters, events: [past, local, promoted, ended, next, live])
    let events = EventHomeFeed.upcomingElsewhere(in: catalog, excludingChapterID: "cwb", now: try referenceNow())
    #expect(events.map(\.id) == ["live", "next", "promoted"])
  }

  @Test func detailWithoutEndTimeOnlyDescribesItsStart() throws {
    let event = CommunityEvent(
      id: "open-ended", chapterID: "sp", title: "Encontro",
      startDate: try instant("2026-09-13T18:00:00Z"), summary: "Sem horário de término",
      registrationURL: try #require(URL(string: "https://example.com/event")))
    #expect(EventDetailFormatting.timeLine(for: event) == "A partir das 15h00")
    #expect(EventDetailFormatting.accessibleTimeLine(for: event) == "a partir das 15:00")
    #expect(!EventDetailFormatting.dateLine(for: event).contains(" – "))
  }

  private func referenceNow() throws -> Date { try instant("2026-09-13T18:00:00Z") }

  private func instant(_ value: String) throws -> Date {
    try #require(ISO8601DateFormatter().date(from: value))
  }

  private func feature(
    _ id: String, chapterID: String? = nil, title: String? = nil,
    subtitle: String? = nil, destination: CatalogFeature.Destination = .placeholder(title: "Em breve")
  ) -> CatalogFeature {
    CatalogFeature(id: id, chapterID: chapterID, title: title ?? id, subtitle: subtitle, destination: destination)
  }

  private func event(
    _ id: String, chapterID: String = "sp", title: String = "Encontro",
    start: String, end: String, featured: Bool = false, talks: [EventTalk] = []
  ) throws -> CommunityEvent {
    CommunityEvent(
      id: id, chapterID: chapterID, title: title,
      startDate: try instant(start), endDate: try instant(end), timezoneID: "America/Sao_Paulo",
      summary: "Encontro da comunidade", registrationURL: try #require(URL(string: "https://example.com/event/\(id)")),
      talks: talks, isFeatured: featured)
  }
}
