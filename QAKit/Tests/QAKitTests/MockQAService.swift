//
//  MockQAService.swift
//  QAKit
//
//  Created by Assistant on 7/28/25.
//

import CloudKit
import Foundation

@testable import QAKit

actor MockQAService: QAServiceProtocol {
  private var questions: [Question] = []
  private var shouldThrowError = false
  private var errorToThrow: Error = MockError.genericError

  enum MockError: Error, LocalizedError {
    case genericError
    case networkError
    case permissionDenied

    var errorDescription: String? {
      switch self {
      case .genericError:
        return "Mock generic error"
      case .networkError:
        return "Mock network error"
      case .permissionDenied:
        return "Mock permission denied"
      }
    }
  }

  init() {}

  func fetchQuestions(for sessionID: String) async throws -> [Question] {
    if shouldThrowError {
      throw errorToThrow
    }

    return
      questions
      .filter { $0.sessionID == sessionID }
      .sorted { $0.timestamp > $1.timestamp }
  }

  func createQuestion(_ question: Question) async throws {
    if shouldThrowError {
      throw errorToThrow
    }

    questions.append(question)
  }

  // Test helper methods
  func setError(_ error: Error?) {
    if let error = error {
      shouldThrowError = true
      errorToThrow = error
    } else {
      shouldThrowError = false
    }
  }

  func addMockQuestion(_ question: Question) {
    questions.append(question)
  }

  func clearQuestions() {
    questions.removeAll()
  }

  func getQuestionsCount() -> Int {
    return questions.count
  }

  func getQuestions(for sessionID: String) -> [Question] {
    return questions.filter { $0.sessionID == sessionID }
  }
}
