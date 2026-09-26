import Foundation
import Testing

@testable import CocoaHeadsCore

struct OrganizerDraftTests {
  private var draft: OrganizerEventDraft {
    OrganizerEventDraft(
      chapterID: "sp", title: "Swift em produção", startDate: Date(timeIntervalSince1970: 1_800_000_000),
      registrationURL: "https://example.com/event", venue: EventVenue(name: "Academy", address: "Rua Exemplo, 100"))
  }

  @Test("Drafts can be incomplete, publishing cannot")
  func incompleteDraft() throws {
    try OrganizerEventDraft(chapterID: "sp").validateForSaving()
    #expect(throws: OrganizerValidationError.self) {
      try OrganizerEventDraft(chapterID: "sp").publishedEvent(id: "event")
    }
  }

  @Test("Publishing preserves omitted end dates and all supplemental content")
  func roundTrip() throws {
    var draft = draft
    draft.imageURL = URL(string: "https://example.com/hero.jpg")
    draft.talks = [EventTalk(id: "talk", title: "Swift", speakerName: "Ana")]
    draft.qaSessionID = "legacy-cloudkit-session"
    let event = try draft.publishedEvent(id: "new-id")
    #expect(event.endDate == nil)
    #expect(event.id == "new-id")
    #expect(OrganizerEventDraft(event: event) == draft)
  }

  @Test(
    "Publication validates dates, venue, URLs and timezone",
    arguments: [
      "date", "venue", "url", "timezone", "coordinatePair", "coordinateRange", "online", "talks", "links",
      "blankQuestions", "URLCredentials", "encodedURLLength"
    ])
  func validation(kind: String) throws {
    var draft = draft
    switch kind {
    case "date": draft.endDate = draft.startDate!.addingTimeInterval(-1)
    case "venue": draft.venue = nil
    case "url": draft.registrationURL = "javascript:alert(1)"
    case "blankQuestions": draft.qaSessionID = " \n\t"
    case "URLCredentials": draft.registrationURL = "https://username:password@example.com/event"
    case "timezone": draft.timezoneID = "Invalid/Zone"
    case "coordinatePair": draft.venue?.latitude = 10
    case "coordinateRange":
      draft.venue?.latitude = 100
      draft.venue?.longitude = 0
    case "online": draft.format = .online
    case "talks": draft.talks = [EventTalk(id: "", title: "", speakerName: "")]
    case "encodedURLLength":
      // Within the editable limit, but percent-encoding grows it past 4,096.
      draft.registrationURL = "https://example.com/" + String(repeating: "é", count: 1_000)
    case "links": draft.links = [EventLink(id: "link", title: "Link", url: URL(string: "file:///etc/passwd")!)]
    default: break
    }
    #expect(throws: OrganizerValidationError.self) { try draft.publishedEvent(id: "event") }
  }

  @Test(
    "All optional URL fields reject embedded credentials", arguments: ["share", "online", "hero", "speaker", "link"])
  func credentials(field: String) throws {
    var draft = draft
    let url = URL(string: "https://username:password@example.com/resource")!
    switch field {
    case "share": draft.shareURL = url
    case "online": draft.onlineURL = url
    case "hero": draft.imageURL = url
    case "speaker": draft.talks = [EventTalk(id: "talk", title: "Swift", speakerName: "Ana", speakerImageURL: url)]
    case "link": draft.links = [EventLink(id: "link", title: "Saiba mais", url: url)]
    default: break
    }
    #expect(throws: OrganizerValidationError.self) { try draft.publishedEvent(id: "event") }
  }

  @Test("Publication needs a nonblank event identity")
  func blankIdentity() throws {
    #expect(throws: OrganizerValidationError.self) { try draft.publishedEvent(id: " \n") }
  }

  @Test("Saving rejects oversized drafts")
  func oversizedDraft() throws {
    var draft = draft
    draft.summary = String(repeating: "x", count: 20_001)
    #expect(throws: OrganizerValidationError.self) { try draft.validateForSaving() }
  }

  @Test("Saving bounds stored bytes, not just visible characters")
  func combiningMarks() throws {
    var draft = draft
    // One visible character carrying 200 KB of combining accents.
    draft.title = "a" + String(repeating: "\u{0301}", count: 100_000)
    #expect(draft.title.count == 1)
    #expect(throws: OrganizerValidationError.self) { try draft.validateForSaving() }
  }

  @Test("Accented text within the character limit still saves")
  func accentedText() throws {
    var draft = draft
    draft.title = String(repeating: "ção", count: 80)
    try draft.validateForSaving()
  }

  @Test("Publishing trims the Q&A session identifier")
  func trimmedQuestionSession() throws {
    var draft = draft
    draft.qaSessionID = "  legacy-cloudkit-session\n"
    #expect(try draft.publishedEvent(id: "event").qaSessionID == "legacy-cloudkit-session")
  }
}
