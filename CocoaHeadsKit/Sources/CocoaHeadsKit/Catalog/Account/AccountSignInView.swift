import AuthenticationServices
import CocoaHeadsCore
import SwiftUI

/// Shared sign-in presentation; mock builds keep their account choices inside this flow.
struct AccountSignInView: View {
  @Environment(CocoaHeadsAppServices.self) private var services
  @Environment(\.colorScheme) private var colorScheme

  private var session: AccountSession { services.session }

  var body: some View {
    Form {
      Section {
        VStack(alignment: .leading, spacing: 12) {
          Image(systemName: "cup.and.saucer.fill")
            .font(.largeTitle).foregroundStyle(MataTheme.accent)
          Text("Entre para organizar").font(.title2.bold())
          Text(
            "Use sua conta Apple para acessar a organização do seu capítulo. Seu acesso é liberado por um administrador."
          )
          .foregroundStyle(.secondary)
        }
        .padding(.vertical, 12)

        if !session.client.isMock {
          SignInWithAppleButton(.signIn) { request in
            session.prepareAppleRequest(request)
          } onCompletion: { result in
            Task { await session.completeAppleRequest(result) }
          }
          .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
          .frame(height: 50)
          .disabled(session.client.availabilityError != nil)
          if let error = session.client.availabilityError {
            Text("\(error.localizedDescription) Você pode continuar explorando os eventos.")
              .font(.footnote).foregroundStyle(.secondary)
          }
        }
      }

      #if DEBUG
        if session.client.isMock {
          Section {
            ForEach([UserRole.admin, .organizer, .user], id: \.rawValue) { role in
              Button("Entrar como \(role.localizedTitle.lowercased())") {
                Task { await session.signInMock(role: role) }
              }
            }
          } header: {
            Text("Prévia local")
          } footer: {
            Text("Contas e publicações de demonstração ficam apenas neste app de desenvolvimento.")
          }
        }
      #endif

      if let error = session.errorMessage {
        Section { Text(error).foregroundStyle(.red) }
      }
      if session.isBusy {
        ProgressView("Aguarde…").frame(maxWidth: .infinity)
      }
    }
    .disabled(session.isBusy)
    .navigationTitle("Entrar")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden(session.isBusy)
  }
}
