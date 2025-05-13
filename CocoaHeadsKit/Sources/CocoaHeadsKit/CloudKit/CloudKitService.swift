//
//  CloudKitService.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/9/25.
//

import CloudKit
import Foundation
import SwiftUI

extension EnvironmentValues {
  @Entry var cloudKitService: CloudKitService = .init()
}

// TODO: Make a service protocol so we reach for a local mock when running debug builds
actor CloudKitService: Sendable {
  // TODO: Mock for testing
  let container = CKContainer(identifier: "iCloud.br.com.cocoaHeads.conf")

  fileprivate init() {}

  // TODO: Some form of persistency/caching
  // TODO: Break down in multiple steps - this is confusing as is
  func fetchData() async throws -> [Chapter] {
    let database = container.publicCloudDatabase
    let chapterRecords = try await database.records(
      matching: .init(
        recordType: "Chapter",
        predicate: NSPredicate(value: true)
      )
    )
    var chapters: [Chapter] = []

    let (results, _) = chapterRecords
    for (_, result) in results {
      switch result {
      case .success(let chapterRecord):
        var chapter = Chapter(from: chapterRecord)
        let eventRecords = chapterRecord["events"] as? [CKRecord.Reference]
        try await withThrowingTaskGroup(of: CKRecord.self) { group in
          for eventReference in eventRecords ?? [] {
            group.addTask {
              try await database.record(for: eventReference.recordID)
            }
          }
          for try await record in group {
            if let event = Event(from: record) {
              chapter?.events.append(event)
            }
          }
        }
        if let chapter {
          chapters.append(chapter)
        }
      case .failure(let error):
        print(error)
      }
    }

    return chapters
  }

  func fetchUserRecordID() async throws -> String {
    let ckRecord = try await container.userRecordID()
    return ckRecord.recordName
  }

  private(set) var hasLeaderAccess: Bool?

  @discardableResult
  func fetchLeaderAccess() async throws -> Bool {
    if let hasLeaderAccess { return hasLeaderAccess }
    let database = container.publicCloudDatabase
    do {
      let (results, _) = try await database.records(
        matching: .init(
          recordType: "Leaders",
          predicate: NSPredicate(value: true)
        )
      )
      hasLeaderAccess = !results.isEmpty
      return !results.isEmpty
    } catch {
      hasLeaderAccess = false
      return false
    }
  }

  // MARK: - Chapters
  func update(_ chapter: Chapter, byAdding event: Event) async throws {
    let database = container.publicCloudDatabase
    let chapterID = CKRecord.ID(recordName: chapter.id.uuidString)
    let eventID = CKRecord.ID(recordName: event.id.uuidString)
    let eventReference = CKRecord.Reference(recordID: eventID, action: .none)

    do {
      let chapterRecord = try await database.record(for: chapterID)
      var currentEvents = chapterRecord["events"] as? [CKRecord.Reference] ?? []
      if !currentEvents.contains(where: { $0.recordID == eventID }) {
        currentEvents.append(eventReference)
        chapterRecord["events"] = currentEvents
        try await database.save(chapterRecord)
      }
    } catch {
      print("Failed to update chapter: \(error.localizedDescription)")
      throw error
    }
  }

  // MARK: - Events
  // TODO: Create an EventService for these, same as page below (or not, idk if we'll keep this)
  func fetchEventList() async throws -> [Event] {
    let database = container.publicCloudDatabase
    let (matchResults, _) = try await database.records(
      matching: .init(
        recordType: "Event",
        predicate: NSPredicate(value: true)
      )
    )

    var events: [Event] = []
    for (_, result) in matchResults {
      switch result {
      case .success(let record):
        if let event = Event(from: record) {
          events.append(event)
        }
      case .failure(let error):
        print("Error fetching event: \(error.localizedDescription)")
      }
    }

    return events
  }

  func updateEvent(_ event: Event) async throws {
    let database = container.publicCloudDatabase
    let recordID = CKRecord.ID(recordName: event.id.uuidString)

    do {
      let record = try await database.record(for: recordID)
      record["title"] = event.title
      record["address"] = event.address
      record["location"] = CLLocation(
        latitude: event.location.coordinate.latitude, longitude: event.location.coordinate.longitude)
      record["date"] = event.date
      record["endDate"] = event.endDate
      record["rsvpURL"] = event.rsvpURL.absoluteString
      record["page"] = event.page
      try await database.save(record)
    } catch {
      print("Failed to update event: \(error.localizedDescription)")
      throw error
    }
  }

  func createEvent(_ event: Event) async throws {

  }

  // TODO: Create a PageService for these - we need swift-dependencies for this

  func createPage(
    slug: String,
    ui: [UI],
    with encoder: JSONEncoder = JSONEncoder()
  ) async throws {
    // TODO: Create page updating flow
    guard try await isSlugAvailable(slug) else {
      // TODO: throw error
      return
    }

    let database = container.publicCloudDatabase
    let record = CKRecord(recordType: "Page")
    let jsonUI = try encoder.encode(ui)
    guard let jsonUIString = String(data: jsonUI, encoding: .utf8) else {
      // TODO: throw error
      print("no ui lmao")
      return
    }
    record["slug"] = slug
    record["ui"] = jsonUIString
    try await database.save(record)
  }

  func isSlugAvailable(_ slug: String) async throws -> Bool {
    let titles = try await fetchPageList()
    return !titles.contains(slug)
  }

  // TODO: Caching
  func fetchPage(slug: String) async throws -> [UI] {
    // We need this until we add home to the database
    guard slug != "local-home" else {
      return [.home(.home)]
    }

    let database = container.publicCloudDatabase
    // TODO: Query specifically for the slug we need! This is *dumb*
    let (matchResults, _) = try await database.records(
      matching: .init(
        recordType: "Page",
        predicate: NSPredicate(value: true)
      )
    )

    for (_, result) in matchResults {
      switch result {
      case .success(let success):
        guard
          let pageSlug = success["slug"] as? String,
          slug == pageSlug,
          let pageJSON = success["ui"] as? String,
          let pageData = pageJSON.data(using: .utf8)
        else {
          // TODO: Force-update UI
          return [
            .eventDetail([
              .text("Atualize o app")
            ])
          ]
        }

        let decoder = LenientJSONDecoder()
        return try decoder.decode([UI].self, from: pageData)

      case .failure:
        continue
      }
    }

    return [
      .eventDetail([
        .text("Atualize o app")
      ])
    ]
  }

  func fetchPageList() async throws -> [String] {
    let database = container.publicCloudDatabase
    let (matchResults, _) = try await database.records(
      matching: .init(
        recordType: "Page",
        predicate: NSPredicate(value: true)
      )
    )
    var pageTitles: [String] = []
    for (_, result) in matchResults {
      switch result {
      case .success(let success):
        if let slug = success["slug"] as? String {
          pageTitles.append(slug)
        }
      case .failure:
        break
      }
    }

    return pageTitles
  }
}
