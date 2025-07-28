//
//  QuestionTests.swift
//  QAKit
//
//  Created by Assistant on 7/28/25.
//

import CloudKit
import XCTest

@testable import QAKit

final class QuestionTests: XCTestCase {

  func testQuestionInitialization() {
    let sessionID = "test-session-123"
    let userName = "João Silva"
    let questionText = "Qual é a melhor forma de usar SwiftUI?"
    let timestamp = Date()

    let question = Question(
      sessionID: sessionID,
      userName: userName,
      questionText: questionText,
      timestamp: timestamp
    )

    XCTAssertNotNil(question.id)
    XCTAssertEqual(question.sessionID, sessionID)
    XCTAssertEqual(question.userName, userName)
    XCTAssertEqual(question.questionText, questionText)
    XCTAssertEqual(question.timestamp, timestamp)
  }

  func testQuestionDefaultTimestamp() {
    let sessionID = "test-session-456"
    let question = Question(
      sessionID: sessionID,
      userName: "Maria",
      questionText: "Como funciona o Combine?"
    )

    XCTAssertNotNil(question.timestamp)
    XCTAssertTrue(question.timestamp <= Date())
  }

  func testQuestionToCKRecord() {
    let sessionID = "test-session-789"
    let questionID = UUID()
    let userName = "Pedro"
    let questionText = "Como usar async/await?"
    let timestamp = Date()

    let question = Question(
      id: questionID,
      sessionID: sessionID,
      userName: userName,
      questionText: questionText,
      timestamp: timestamp
    )

    let record = question.toCKRecord()

    XCTAssertEqual(record.recordID.recordName, questionID.uuidString)
    XCTAssertEqual(record.recordType, "Question")
    XCTAssertEqual(record["sessionID"] as? String, sessionID)
    XCTAssertEqual(record["userName"] as? String, userName)
    XCTAssertEqual(record["questionText"] as? String, questionText)
    XCTAssertEqual(record["timestamp"] as? Date, timestamp)
  }

  func testQuestionFromCKRecord() {
    let questionID = UUID()
    let sessionID = "test-session-abc"
    let userName = "Carlos"
    let questionText = "O que é TCA?"
    let timestamp = Date()

    let recordID = CKRecord.ID(recordName: questionID.uuidString)
    let record = CKRecord(recordType: "Question", recordID: recordID)
    record["sessionID"] = sessionID
    record["userName"] = userName
    record["questionText"] = questionText
    record["timestamp"] = timestamp

    let question = Question(from: record)

    XCTAssertNotNil(question)
    XCTAssertEqual(question?.id, questionID)
    XCTAssertEqual(question?.sessionID, sessionID)
    XCTAssertEqual(question?.userName, userName)
    XCTAssertEqual(question?.questionText, questionText)
    XCTAssertEqual(question?.timestamp, timestamp)
  }

  func testQuestionFromInvalidCKRecord() {
    // Test with missing sessionID
    let recordID = CKRecord.ID(recordName: UUID().uuidString)
    let record = CKRecord(recordType: "Question", recordID: recordID)
    record["userName"] = "Test"
    record["questionText"] = "Test question"
    record["timestamp"] = Date()

    let question = Question(from: record)
    XCTAssertNil(question)
  }

  func testQuestionFromRecordWithInvalidUUID() {
    // Test with invalid UUID for recordName
    let recordID = CKRecord.ID(recordName: "invalid-uuid")
    let record = CKRecord(recordType: "Question", recordID: recordID)
    record["sessionID"] = "test-session"
    record["userName"] = "Test"
    record["questionText"] = "Test question"
    record["timestamp"] = Date()

    let question = Question(from: record)
    XCTAssertNil(question)
  }

  func testQuestionRoundTripSerialization() {
    let originalQuestion = Question(
      sessionID: "test-session-round-trip",
      userName: "Lucia",
      questionText: "Como implementar testes unitários?",
      timestamp: Date()
    )

    let record = originalQuestion.toCKRecord()
    let deserializedQuestion = Question(from: record)

    XCTAssertNotNil(deserializedQuestion)
    XCTAssertEqual(originalQuestion.id, deserializedQuestion?.id)
    XCTAssertEqual(originalQuestion.sessionID, deserializedQuestion?.sessionID)
    XCTAssertEqual(originalQuestion.userName, deserializedQuestion?.userName)
    XCTAssertEqual(originalQuestion.questionText, deserializedQuestion?.questionText)
    XCTAssertEqual(
      originalQuestion.timestamp.timeIntervalSince1970,
      deserializedQuestion?.timestamp.timeIntervalSince1970 ?? 0,
      accuracy: 0.001)
  }
}
