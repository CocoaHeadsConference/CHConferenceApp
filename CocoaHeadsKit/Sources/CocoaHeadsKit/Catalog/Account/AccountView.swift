import CocoaHeadsCore
import SwiftUI

struct AccountView: View {
  let onOpenOrganization: () -> Void

  @Environment(CocoaHeadsAppServices.self) private var services
  @State private var confirmsDeletion = false
  @State private var showsSignIn = false

  private var session: AccountSession { services.session }

  var body: some View {
    NavigationStack {
      Form {
        if let user = session.user {
          signedInContent(user)
        } else {
          signedOutContent
        }
        if let error = session.errorMessage {
          Section {
            Text(error).foregroundStyle(.red)
            if session.user == nil {
              Button("Tentar novamente") { showsSignIn = true }
            }
          }
        }
        if session.isBusy {
          ProgressView("Aguarde…").frame(maxWidth: .infinity)
        }
      }
      .navigationTitle("Perfil")
      .disabled(session.isBusy)
      .confirmationDialog("Excluir sua conta?", isPresented: $confirmsDeletion, titleVisibility: .visible) {
        Button("Excluir conta", role: .destructive) { Task { await session.deleteAccount() } }
      } message: {
        Text("Seu acesso à organização será removido. Os eventos publicados continuam disponíveis para a comunidade.")
      }
      .navigationDestination(isPresented: $showsSignIn) {
        CocoaHeadsPlaceholder("Entrar")
          .navigationTitle("Entrar")
          .navigationBarTitleDisplayMode(.inline)
      }
      .onChange(of: session.user?.id) { _, userID in
        if userID != nil { showsSignIn = false }
      }
    }
  }

  @ViewBuilder
  private func signedInContent(_ user: UserDTO) -> some View {
    Section {
      Label {
        VStack(alignment: .leading, spacing: 4) {
          Text(user.fullName?.isEmpty == false ? user.fullName! : "Sua conta")
            .font(.headline)
          Text(user.role.localizedTitle).font(.subheadline).foregroundStyle(.secondary)
        }
      } icon: {
        Image(systemName: "person.crop.circle.fill")
          .font(.largeTitle).foregroundStyle(MataTheme.accent)
      }
      if let email = user.email { LabeledContent("E-mail", value: email) }
    }

    Section("Organização") {
      if user.role == .organizer || user.role == .admin {
        Button(action: onOpenOrganization) {
          Label("Área de organização", systemImage: "calendar.badge.plus")
        }
      } else {
        Text("Sua conta está pronta. Um administrador precisa liberar seu acesso para organizar eventos.")
        ShareLink(item: user.id.uuidString) {
          Label("Compartilhar meu identificador", systemImage: "square.and.arrow.up")
        }
      }
      LabeledContent("Identificador") {
        Text(user.id.uuidString).font(.caption).textSelection(.enabled)
      }
      Button("Atualizar meu acesso") { Task { await session.refresh() } }
    }
    Section {
      Button("Sair") { Task { await session.signOut() } }
      Button("Excluir conta", role: .destructive) { confirmsDeletion = true }
    }
  }

  private var signedOutContent: some View {
    Section {
      VStack(alignment: .leading, spacing: 12) {
        Image(systemName: "cup.and.saucer.fill")
          .font(.largeTitle).foregroundStyle(MataTheme.accent)
        HStack(alignment: .firstTextBaseline, spacing: 0) {
          Button("Entre") {
            showsSignIn = true
          }
          .buttonStyle(.plain)
          .fixedSize()
          .accessibilityHint("Abre a tela de entrada")
          Text(" para organizar")
            .fixedSize(horizontal: false, vertical: true)
        }
        .font(.title2.bold())
        .foregroundStyle(.primary)
        Text(
          "Use sua conta Apple para acessar a organização do seu capítulo. Seu acesso é liberado por um administrador."
        )
        .foregroundStyle(.secondary)
      }
      .padding(.vertical, 12)
    } footer: {
      Text(
        "Os eventos são públicos. Não é preciso entrar para descobrir encontros ou se inscrever pela página do evento.")
    }
  }
}
