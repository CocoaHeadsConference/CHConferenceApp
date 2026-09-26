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
      "date", "venue", "url", "timezone", "coordinates", "online", "talks", "links", "blankQuestions", "URLCredentials"
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
    case "coordinates": draft.venue?.latitude = 100
    case "online": draft.format = .online
    case "talks": draft.talks = [EventTalk(id: "", title: "", speakerName: "")]
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
}
