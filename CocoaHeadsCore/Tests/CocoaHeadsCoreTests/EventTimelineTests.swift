import Foundation
import Testing

@testable import CocoaHeadsCore

private func instant(_ value: String) -> Date {
  ISO8601DateFormatter().date(from: value)!
}

private func event(
  start: String = "2026-09-12T22:00:00Z",
  end: String? = "2026-09-13T01:00:00Z", timezone: String = "America/Sao_Paulo"
) -> CommunityEvent {
  CommunityEvent(
    id: "event", chapterID: "sp", title: "CocoaHeads SP",
    startDate: instant(start), endDate: end.map(instant), timezoneID: timezone,
    summary: "Encontro da comunidade", registrationURL: URL(string: "https://example.com/event")!)
}

@Test func eventStaysUpcomingThroughItsLocalFinalDay() throws {
  let subject = event()
  #expect(subject.phase(at: instant("2026-09-12T21:59:59Z")) == .upcoming)
  #expect(subject.phase(at: subject.startDate) == .ongoing)
  #expect(subject.phase(at: try #require(subject.endDate)) == .endedToday)
  // UTC already says Sunday; in São Paulo it is still Saturday.
  #expect(subject.phase(at: instant("2026-09-13T02:59:59Z")) == .endedToday)
  #expect(subject.archiveDate == instant("2026-09-13T03:00:00Z"))
  #expect(subject.phase(at: subject.archiveDate) == .past)
}

@Test func crossingMidnightUsesTheDayTheEventEnds() {
  let subject = event(end: "2026-09-13T04:00:00Z")
  #expect(subject.phase(at: instant("2026-09-13T03:30:00Z")) == .ongoing)
  #expect(subject.archiveDate == instant("2026-09-14T03:00:00Z"))
  #expect(subject.phase(at: instant("2026-09-14T02:59:59Z")) == .endedToday)
}

@Test func multiDayEventsArchiveAfterTheirFinalDay() {
  let subject = event(end: "2026-09-14T18:00:00Z")
  #expect(subject.phase(at: instant("2026-09-13T12:00:00Z")) == .ongoing)
  #expect(subject.archiveDate == instant("2026-09-15T03:00:00Z"))
}

@Test func archiveBoundaryUsesCalendarDaysAcrossDST() {
  let subject = event(
    start: "2026-03-08T05:30:00Z", end: "2026-03-08T06:30:00Z",
    timezone: "America/New_York")
  // The final day has 23 hours; adding 86,400 seconds would be wrong.
  #expect(subject.archiveDate == instant("2026-03-09T04:00:00Z"))
}

@Test func eventWithoutEndTimeStaysOngoingUntilNextLocalMidnight() {
  let subject = event(end: nil)
  #expect(subject.endDate == nil)
  #expect(subject.phase(at: subject.startDate.addingTimeInterval(-1)) == .upcoming)
  #expect(subject.phase(at: subject.startDate) == .ongoing)
  #expect(subject.phase(at: instant("2026-09-13T02:59:59Z")) == .ongoing)
  #expect(subject.archiveDate == instant("2026-09-13T03:00:00Z"))
  #expect(subject.phase(at: subject.archiveDate) == .past)
}

@Test func eventWithoutEndTimeUsesCalendarMidnightAcrossDST() {
  let subject = event(start: "2026-03-08T05:30:00Z", end: nil, timezone: "America/New_York")
  #expect(subject.archiveDate == instant("2026-03-09T04:00:00Z"))
  #expect(subject.phase(at: instant("2026-03-09T03:59:59Z")) == .ongoing)
  #expect(subject.phase(at: subject.archiveDate) == .past)
}

@Test func omittedEndDateDecodesAsUnspecified() throws {
  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .iso8601
  let data = try encoder.encode(event(end: nil))
  let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
  #expect(json["endDate"] == nil)
  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .iso8601
  let decoded = try decoder.decode(CommunityEvent.self, from: data)
  #expect(decoded.endDate == nil)
  #expect(decoded.archiveDate == instant("2026-09-13T03:00:00Z"))
}

@Test func screenEnvelopePreservesEventIdentityAndTimezone() throws {
  let original = ScreenDocument(screen: CatalogScreen.detail, content: event())
  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .iso8601
  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .iso8601
  let decoded = try decoder.decode(ScreenDocument<CommunityEvent>.self, from: encoder.encode(original))
  #expect(decoded.schemaVersion == 1)
  #expect(decoded.screen == "eventDetail")
  #expect(decoded.content == original.content)
  #expect(decoded.content.archiveDate == original.content.archiveDate)
}
