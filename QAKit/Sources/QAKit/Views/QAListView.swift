//
//  QAListView.swift
//  QAKit
//
//  Created by Assistant on 7/28/25.
//

import CloudKit
import SwiftUI

public struct QAListView: View {
  @Environment(\.qaService) private var qaService

  let sessionID: String
  @State private var questions: [Question] = []
  @State private var isLoading = true
  @State private var showError = false
  @State private var errorMessage = ""
  @State private var showEntrySheet = false
  @State private var pollingTask: Task<Void, Never>?

  public init(sessionID: String) {
    self.sessionID = sessionID
  }

  public var body: some View {
    NavigationStack {
      Group {
        if isLoading {
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if questions.isEmpty {
          emptyStateView
        } else {
          questionsList
        }
      }
      .navigationTitle("Perguntas")
      #if os(iOS) || os(visionOS)
        .navigationBarTitleDisplayMode(.inline)
      #endif
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button {
            showEntrySheet = true
          } label: {
            Label("Fazer Pergunta", systemImage: "plus.bubble")
          }
          .accessibilityLabel("Fazer pergunta")
          .accessibilityHint("Abre a tela para fazer uma nova pergunta")
        }
      }
      .sheet(isPresented: $showEntrySheet) {
        QAEntryView(sessionID: sessionID)
      }
      .alert("Erro", isPresented: $showError) {
        Button("Tentar Novamente") {
          Task {
            await loadQuestions()
          }
        }
        Button("OK") {}
      } message: {
        Text(errorMessage)
      }
      .task {
        await loadQuestions()
        await startPolling()
      }
      .onDisappear {
        Task {
          await stopPolling()
        }
      }
      .refreshable {
        await loadQuestions()
      }
      .onReceive(NotificationCenter.default.publisher(for: .localQuestionPosted)) { notification in
        guard let question = notification.object as? Question,
          question.sessionID == sessionID
        else { return }

        // Add question immediately to the top of the list
        withAnimation {
          questions.append(question)
        }
      }
    }
  }

  private var emptyStateView: some View {
    VStack(spacing: 20) {
      Image(systemName: "bubble.left.and.bubble.right")
        .font(.system(size: 60))
        .foregroundStyle(.secondary)

      Text("Ainda não há perguntas")
        .font(.title2)
        .fontWeight(.semibold)

      Text("Seja o primeiro a fazer uma pergunta!")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      Button("Fazer uma Pergunta") {
        showEntrySheet = true
      }
      .buttonStyle(.borderedProminent)
      .accessibilityLabel("Fazer uma pergunta")
      .accessibilityHint("Seja o primeiro a fazer uma pergunta neste evento")
    }
    .padding()
  }

  private var questionsList: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 0) {
        ForEach(questions) { question in
          QAQuestionRow(question: question)
            .padding(.horizontal)

          if question.id != questions.last?.id {
            Divider()
              .padding(.horizontal)
          }
        }
      }
    }
    .defaultScrollAnchor(.bottom)
  }

  private func loadQuestions() async {
    do {
      let fetchedQuestions = try await qaService.fetchQuestions(for: sessionID)
      await MainActor.run {
        self.questions = fetchedQuestions
        self.isLoading = false
      }
    } catch {
      await MainActor.run {
        self.errorMessage = error.localizedDescription
        self.showError = true
        self.isLoading = false
      }
    }
  }

  private func startPolling() async {
    pollingTask = Task {
      while !Task.isCancelled {
        try? await Task.sleep(for: .seconds(3))
        await refreshQuestions()
      }
    }
  }

  private func stopPolling() async {
    pollingTask?.cancel()
    pollingTask = nil
  }

  private func refreshQuestions() async {
    do {
      let fetchedQuestions = try await qaService.fetchQuestions(for: sessionID)
      await MainActor.run {
        // Filter out questions that already exist (including locally posted ones)
        let newQuestions = fetchedQuestions.filter { fetchedQ in
          !self.questions.contains { existingQ in existingQ.id == fetchedQ.id }
        }

        if !newQuestions.isEmpty {
          withAnimation {
            // Add new questions from server, maintaining chronological order
            for newQuestion in newQuestions.reversed() {
              self.questions.append(newQuestion)
            }
          }
        }
      }
    } catch {
      // Silently fail for polling to avoid spam
    }
  }
}
