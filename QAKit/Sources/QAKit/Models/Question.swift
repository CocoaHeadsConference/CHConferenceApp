//
//  Question.swift
//  QAKit
//
//  Created by Assistant on 7/28/25.
//

import CloudKit
import Foundation

public struct Question: Identifiable, Sendable, Hashable {
  public let id: UUID
  public let sessionID: String
  public let userName: String
  public let questionText: String
  public let timestamp: Date

  public init(
    id: UUID = UUID(),
    sessionID: String,
    userName: String,
    questionText: String,
    timestamp: Date = Date()
  ) {
    self.id = id
    self.sessionID = sessionID
    self.userName = userName
    self.questionText = questionText
    self.timestamp = timestamp
  }
}

extension Question {
  init?(from record: CKRecord) {
    guard let id = UUID(uuidString: record.recordID.recordName),
      let sessionID = record["sessionID"] as? String,
      let userName = record["userName"] as? String,
      let questionText = record["questionText"] as? String,
      let timestamp = record["timestamp"] as? Date
    else {
      return nil
    }

    self.id = id
    self.sessionID = sessionID
    self.userName = userName
    self.questionText = questionText
    self.timestamp = timestamp
  }

  func toCKRecord() -> CKRecord {
    let recordID = CKRecord.ID(recordName: id.uuidString)
    let record = CKRecord(recordType: "Question", recordID: recordID)

    record["sessionID"] = sessionID
    record["userName"] = userName
    record["questionText"] = questionText
    record["timestamp"] = timestamp

    return record
  }
}
