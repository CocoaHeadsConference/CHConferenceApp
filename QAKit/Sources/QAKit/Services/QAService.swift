//
//  QAService.swift
//  QAKit
//
//  Created by Assistant on 7/28/25.
//

import CloudKit
import Foundation
import SwiftUI

public protocol QAServiceProtocol: Sendable {
  func fetchQuestions(for sessionID: String) async throws -> [Question]
  func createQuestion(_ question: Question) async throws
}

extension EnvironmentValues {
  @Entry public var qaService: QAServiceProtocol = QAService.live
}

extension QAService {
  public static let live: QAServiceProtocol = QAService()
}

public actor QAService: QAServiceProtocol, Sendable {
  package let container = CKContainer(identifier: "iCloud.br.com.cocoaHeads.conf")

  fileprivate init() {}

  public func fetchQuestions(for sessionID: String) async throws -> [Question] {
    let database = container.publicCloudDatabase
    let predicate = NSPredicate(format: "sessionID == %@", sessionID)
    let query = CKQuery(recordType: "Question", predicate: predicate)
    query.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

    let (results, _) = try await database.records(matching: query)

    var questions: [Question] = []
    for (_, result) in results {
      switch result {
      case .success(let record):
        if let question = Question(from: record) {
          questions.append(question)
        }
      case .failure(let error):
        print("Error fetching question: \(error.localizedDescription)")
      }
    }

    return questions
  }

  public func createQuestion(_ question: Question) async throws {
    let database = container.publicCloudDatabase
    let record = question.toCKRecord()

    _ = try await database.save(record)
  }

}
