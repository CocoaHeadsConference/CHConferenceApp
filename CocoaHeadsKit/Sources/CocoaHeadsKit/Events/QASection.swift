//
//  QASection.swift
//  CocoaHeadsKit
//
//  Created by Assistant on 7/28/25.
//

import QAKit
import SwiftUI

struct QASection: View {
  let sessionID: String
  @State private var showQAList = false

  var body: some View {
    Button {
      showQAList = true
    } label: {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text("Perguntas")
            .font(.headline)
            .foregroundStyle(.primary)

          Text("Faça perguntas e interaja com outros participantes")
            .font(.caption)
            .foregroundStyle(.secondary)
        }

        Spacer()

        Image(systemName: "bubble.left.and.bubble.right")
          .font(.title2)
          .foregroundStyle(.tint)
      }
      .padding()
      .background(Color(.secondarySystemGroupedBackground))
      .cornerRadius(12)
    }
    .buttonStyle(.plain)
    .sheet(isPresented: $showQAList) {
      QAListView(sessionID: sessionID)
    }
  }
}
