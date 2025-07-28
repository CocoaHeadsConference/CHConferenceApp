//
//  QAEntryView.swift
//  QAKit
//
//  Created by Assistant on 7/28/25.
//

import SwiftUI

#if canImport(UIKit)
  import UIKit
#endif

extension Notification.Name {
  public static let localQuestionPosted = Notification.Name("LocalQuestionPosted")
}

public struct QAEntryView: View {
  @Environment(\.qaService) private var qaService
  @Environment(\.dismiss) private var dismiss
  @AppStorage("qakit_user_name") private var storedUserName: String = ""

  let sessionID: String
  @State private var userName: String = ""
  @State private var questionText: String = ""
  @State private var isSubmitting = false
  @State private var showError = false
  @State private var errorMessage = ""

  enum EntryStep {
    case name
    case question
  }

  @State private var currentStep: EntryStep = .name

  public init(sessionID: String) {
    self.sessionID = sessionID
  }

  public var body: some View {
    NavigationStack {
      VStack(spacing: 20) {
        switch currentStep {
        case .name:
          nameEntryView
        case .question:
          questionEntryView
        }
      }
      .padding()
      .navigationTitle("Perguntas")
      #if os(iOS) || os(visionOS)
        .navigationBarTitleDisplayMode(.inline)
      #endif
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancelar") {
            dismiss()
          }
        }
      }
      .alert("Erro", isPresented: $showError) {
        Button("OK") {}
      } message: {
        Text(errorMessage)
      }
      .onAppear {
        if !storedUserName.isEmpty {
          userName = storedUserName
          currentStep = .question
        }
      }
    }
  }

  private var nameEntryView: some View {
    VStack(spacing: 20) {
      Text("Digite seu nome")
        .font(.title2)
        .fontWeight(.semibold)

      TextField("Seu nome", text: $userName)
        .textFieldStyle(.roundedBorder)
        .autocorrectionDisabled()
        #if os(iOS) || os(visionOS)
          .textInputAutocapitalization(.words)
        #endif
        .accessibilityLabel("Nome do usuário")
        .accessibilityHint("Digite seu nome para participar das perguntas")
        .onSubmit {
          let trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
          if !trimmedName.isEmpty {
            storedUserName = trimmedName
            withAnimation {
              currentStep = .question
            }
          }
        }

      Spacer()

      Button("Continuar") {
        let trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
          storedUserName = trimmedName
          withAnimation {
            currentStep = .question
          }
        }
      }
      .buttonStyle(.borderedProminent)
      .disabled(userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
      .accessibilityLabel("Continuar para próxima etapa")
      .accessibilityHint("Avança para a tela de pergunta após inserir seu nome")
    }
  }

  private var questionEntryView: some View {
    VStack(spacing: 20) {
      HStack {
        Text("Olá, \(userName)!")
          .font(.title2)
          .fontWeight(.semibold)

        Spacer()

        Button("Alterar Nome") {
          withAnimation {
            currentStep = .name
          }
        }
        .font(.caption)
        .buttonStyle(.bordered)
        .accessibilityLabel("Alterar nome")
        .accessibilityHint("Permite trocar o nome usado para fazer perguntas")
      }

      Text("O que você gostaria de perguntar?")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)

      TextField("Digite sua pergunta aqui...", text: $questionText, axis: .vertical)
        .textFieldStyle(.roundedBorder)
        .lineLimit(5...10)
        .accessibilityLabel("Campo de pergunta")
        .accessibilityHint("Digite sua pergunta para enviar para outros participantes")
        .onSubmit {
          if !questionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSubmitting {
            submitQuestion()
          }
        }

      Spacer()

      Button("Enviar") {
        submitQuestion()
      }
      .buttonStyle(.borderedProminent)
      .disabled(questionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting)
      .accessibilityLabel("Enviar pergunta")
      .accessibilityHint("Envia sua pergunta para todos os participantes do evento")
    }
    .disabled(isSubmitting)
    .overlay {
      if isSubmitting {
        ProgressView()
          .padding()
          .background(.regularMaterial)
          .cornerRadius(10)
      }
    }
  }

  private func submitQuestion() {
    let trimmedQuestion = questionText.trimmingCharacters(in: .whitespacesAndNewlines)
    let trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !trimmedQuestion.isEmpty && !trimmedName.isEmpty else { return }

    isSubmitting = true

    Task {
      do {
        let question = Question(
          sessionID: sessionID,
          userName: trimmedName,
          questionText: trimmedQuestion
        )

        // Immediately notify that question was posted locally
        await MainActor.run {
          NotificationCenter.default.post(
            name: .localQuestionPosted,
            object: question
          )
        }

        try await qaService.createQuestion(question)

        await MainActor.run {
          isSubmitting = false

          // Haptic feedback for successful submission
          #if canImport(UIKit) && os(iOS)
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
          #endif

          dismiss()
        }
      } catch {
        await MainActor.run {
          errorMessage = error.localizedDescription
          showError = true
          isSubmitting = false
        }
      }
    }
  }
}
