//
//  RaffleService.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/15/25.
//

import CloudKit
import Foundation

// Because of how CloudKit security roles work, we must allow any user to create a Raffle Entry
// but they can't alter Raffle itself, so we must add a reference to the Raffle in the Entry, not the
// other way around.

struct Raffle: Identifiable {
  let id: String
  let name: String
  var winner: RaffleEntry?
  var isOpen: Bool
}

struct RaffleEntry: Identifiable, Equatable {
  let name: String
  let cloudKitIdentifier: String
  let raffleIdentifier: String
  var id: String { cloudKitIdentifier }

  init(
    name: String,
    identifier: String,
    raffleIdentifier: String
  ) {
    self.name = name
    self.cloudKitIdentifier = identifier
    self.raffleIdentifier = raffleIdentifier
  }
}

extension CloudKitService {
  func createRaffle(name: String) async throws -> Raffle {
    let db = container.publicCloudDatabase
    let predicate = NSPredicate(format: "name == %@", name)
    let query = CKQuery(recordType: "Raffle", predicate: predicate)
    let (results, _) = try await db.records(matching: query)

    if let existing = results.first?.1, let record = try? existing.get() {
      let name = record["name"] as? String ?? ""
      let winnerRef = record["winner"] as? CKRecord.Reference
      let winner = winnerRef.map {
        RaffleEntry(name: "", identifier: $0.recordID.recordName, raffleIdentifier: name)
      }

      return Raffle(
        id: record.recordID.recordName,
        name: name,
        winner: winner,
        isOpen: record["isOpen"] as? Bool ?? false
      )
    }

    let id = UUID()
    let record = CKRecord(recordType: "Raffle", recordID: .init(recordName: id.uuidString))
    record["name"] = name
    record["winner"] = nil
    record["isOpen"] = false
    try await db.save(record)

    return Raffle(
      id: record.recordID.recordName,
      name: name,
      winner: nil,
      isOpen: false
    )
  }

  // TODO: Refactor this into something more inteligible like fetchEntry
  func fetchRaffle(name: String) async throws -> Raffle? {
    let db = container.publicCloudDatabase
    let predicate = NSPredicate(format: "name == %@", name)
    let query = CKQuery(recordType: "Raffle", predicate: predicate)
    let (results, _) = try await db.records(matching: query)

    if let existing = results.first?.1,
      let record = try? existing.get(),
      let winnerRef = record["winner"] as? CKRecord.Reference
    {
      let winnerEntry = try await db.record(for: winnerRef.recordID)
      let winner = RaffleEntry(
        name: winnerEntry["name"] ?? "",
        identifier: winnerEntry["cloudKitIdentifier"] ?? "",
        raffleIdentifier: record.recordID.recordName
      )

      return Raffle(
        id: record.recordID.recordName,
        name: name,
        winner: winner,
        isOpen: record["isOpen"] as? Bool ?? false
      )
    }

    return nil
  }

  func fetchRaffle(id: String) async throws -> Raffle? {
    let db = container.publicCloudDatabase
    let record = try await db.record(for: CKRecord.ID(recordName: id))

    let name = record["name"] as? String ?? ""
    var winner: RaffleEntry? = nil
    if let winnerRef = record["winner"] as? CKRecord.Reference {
      let winnerRecord = try await container.publicCloudDatabase.record(for: winnerRef.recordID)
      if let name = winnerRecord["name"] as? String,
        let cloudKitIdentifier = winnerRecord["cloudKitIdentifier"] as? String,
        let raffleRef = winnerRecord["raffle"] as? CKRecord.Reference
      {
        winner = RaffleEntry(
          name: name, identifier: cloudKitIdentifier, raffleIdentifier: raffleRef.recordID.recordName)
      }
    }
    return Raffle(
      id: record.recordID.recordName,
      name: name,
      winner: winner,
      isOpen: record["isOpen"] as? Bool ?? false
    )
  }

  func addEntry(_ entry: RaffleEntry) async throws -> RaffleEntry {
    let db = container.publicCloudDatabase
    let predicate = NSPredicate(
      format: "raffle == %@ AND cloudKitIdentifier == %@",
      CKRecord.Reference(recordID: .init(recordName: entry.raffleIdentifier), action: .none),
      entry.cloudKitIdentifier
    )
    let query = CKQuery(recordType: "RaffleEntry", predicate: predicate)
    let (results, _) = try await db.records(matching: query)

    if !results.isEmpty {
      // TODO: Create a new error type
      throw NSError(
        domain: "RaffleEntryError",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "You have already entered this raffle."]
      )
    }

    let record = CKRecord(recordType: "RaffleEntry")
    print("creating record for \(entry)")
    record["name"] = entry.name
    record["cloudKitIdentifier"] = entry.cloudKitIdentifier
    record["raffle"] = CKRecord.Reference(recordID: .init(recordName: entry.raffleIdentifier), action: .none)
    try await db.save(record)
    return entry
  }

  func fetchEntry(raffleID: String, cloudKitIdentifier: String) async throws -> RaffleEntry {
    let db = container.publicCloudDatabase

    let predicate = NSPredicate(
      format: "raffle == %@ AND cloudKitIdentifier == %@",
      CKRecord.Reference(recordID: .init(recordName: raffleID), action: .none),
      cloudKitIdentifier
    )
    let query = CKQuery(recordType: "RaffleEntry", predicate: predicate)
    let (results, _) = try await db.records(matching: query)

    guard let existing = results.first?.1, let record = try? existing.get() else {
      throw NSError(
        domain: "RaffleEntryError",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "You have not entered this raffle."]
      )
    }

    // TODO: RaffleEntry from CKRecord init and vice-versa
    return RaffleEntry(
      name: record["name"] ?? "",
      identifier: record["cloudKitIdentifier"] ?? "",
      raffleIdentifier: record["raffle"] ?? "")
  }

  func setWinner(for raffleID: String, winnerID: String) async throws {
    let db = container.publicCloudDatabase
    let record = try await db.record(for: .init(recordName: raffleID))

    let predicate = NSPredicate(
      format: "raffle == %@ AND cloudKitIdentifier == %@",
      CKRecord.Reference(recordID: .init(recordName: raffleID), action: .none),
      winnerID
    )
    let query = CKQuery(recordType: "RaffleEntry", predicate: predicate)
    let (results, _) = try await db.records(matching: query)
    guard let winnerRecord = results.first?.0 else { return }  // TODO: Throw!
    record["winner"] = CKRecord.Reference(recordID: winnerRecord, action: .none)
    try await db.save(record)
  }

  func listenToEntries(for raffleID: String) -> AsyncStream<RaffleEntry> {
    AsyncStream { continuation in
      let predicate = NSPredicate(
        format: "raffle == %@",
        CKRecord.Reference(
          recordID: .init(
            recordName: raffleID
          ),
          action: .none
        )
      )

      let subscription = CKQuerySubscription(
        recordType: "RaffleEntry",
        predicate: predicate,
        subscriptionID: "entries-\(raffleID)",
        options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
      )

      let info = CKSubscription.NotificationInfo()
      info.shouldSendContentAvailable = true
      info.alertBody = ""
      subscription.notificationInfo = info

      container.publicCloudDatabase.save(subscription) { _, error in
        if let error {
          print("RaffleEntry subscription error: \(error)")
        }
      }

      NotificationCenter
        .default
        .addObserver(forName: .cloudKitRemoteNotificationReceived, object: nil, queue: .main) { [self] note in
          guard let entryID = (note.object as? CKQueryNotification)?.recordID else { return }
          Task {
            do {
              let record = try await container.publicCloudDatabase.record(for: entryID)

              guard
                let name = record["name"] as? String,
                let cloudKitIdentifier = record["cloudKitIdentifier"] as? String,
                let raffleRef = record["raffle"] as? CKRecord.Reference
              else { return }

              let entry = RaffleEntry(
                name: name,
                identifier: cloudKitIdentifier,
                raffleIdentifier: raffleRef.recordID.recordName
              )

              continuation.yield(entry)
            } catch {
              print("Failed to fetch record: \(error)")
            }
          }
        }
    }
  }

  func fetchEntries(for raffleId: String) async throws -> [RaffleEntry] {
    let db = container.publicCloudDatabase

    let predicate = NSPredicate(
      format: "raffle == %@", CKRecord.Reference(recordID: .init(recordName: raffleId), action: .none))
    let query = CKQuery(recordType: "RaffleEntry", predicate: predicate)
    let (results, _) = try await db.records(matching: query)

    return try results.compactMap { _, result in
      let record = try result.get()
      guard
        let name = record["name"] as? String,
        let cloudKitIdentifier = record["cloudKitIdentifier"] as? String,
        let raffleRef = record["raffle"] as? CKRecord.Reference
      else {
        return nil
      }

      return RaffleEntry(
        name: name,
        identifier: cloudKitIdentifier,
        raffleIdentifier: raffleRef.recordID.recordName
      )
    }
  }

  func stopListeningToEntries() {
    NotificationCenter.default.removeObserver(self)
  }

  func listenToRaffle(for raffleID: String) -> AsyncStream<Raffle> {
    AsyncStream { continuation in
      print("listening to ", raffleID)
      let predicate = NSPredicate(format: "recordID = %@", CKRecord.ID(recordName: raffleID))
      let subscription = CKQuerySubscription(
        recordType: "Raffle",
        predicate: predicate,
        subscriptionID: "raffle-\(raffleID)",
        options: [.firesOnRecordUpdate]
      )
      let info = CKSubscription.NotificationInfo()
      info.shouldSendContentAvailable = true
      info.alertBody = ""
      subscription.notificationInfo = info

      container.publicCloudDatabase.save(subscription) { _, error in
        if let error {
          print("Raffle subscription error: \(error)")
        }
      }

      NotificationCenter
        .default
        .addObserver(forName: .cloudKitRemoteNotificationReceived, object: nil, queue: .main) { [self] note in
          print("received listenToRaffle notification")
          Task {
            do {
              guard let raffle = try await fetchRaffle(id: raffleID) else { return }
              continuation.yield(raffle)
            } catch {
              print("Failed to fetch updated Raffle: \(error)")
            }
          }
        }
    }
  }
}

extension Notification.Name {
  static let cloudKitRemoteNotificationReceived = Notification.Name("CKRemoteNotificationReceived")
}
