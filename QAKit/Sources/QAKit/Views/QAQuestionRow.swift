//
//  QAQuestionRow.swift
//  QAKit
//
//  Created by Assistant on 7/28/25.
//

import SwiftUI

public struct QAQuestionRow: View {
  let question: Question

  public init(question: Question) {
    self.question = question
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(question.userName)
          .font(.subheadline)
          .fontWeight(.semibold)

        Spacer()

        Text(question.timestamp, style: .relative)
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Text(question.questionText)
        .font(.body)
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(.vertical, 8)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Pergunta de \(question.userName)")
    .accessibilityValue(
      "\(question.questionText). Feita \(question.timestamp.formatted(.relative(presentation: .named)))")
  }
}
