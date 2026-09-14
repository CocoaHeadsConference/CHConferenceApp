import Foundation

public enum AccountError: Error, Equatable, Sendable, LocalizedError {
  case notConfigured
  case authenticationRequired
  case refreshUncertain
  case invalidResponse
  case invalidRequest
  case secureStorage
  case appAttestUnsupported
  case appAttestFailed
  case mockSignInRequired
  case mockEndpointUnavailable
  case httpStatus(Int, reason: String? = nil)

  public var statusCode: Int? {
    if case .httpStatus(let status, _) = self { return status }
    return nil
  }

  public var reason: String? {
    if case .httpStatus(_, let reason) = self { return reason }
    return nil
  }

  public var errorDescription: String? {
    if case .httpStatus(let status, let reason) = self,
      [400, 403, 409, 422].contains(status), let reason,
      !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    {
      return reason
    }
    return switch self {
    case .notConfigured:
      "O acesso à conta ainda não está configurado neste ambiente."
    case .authenticationRequired:
      "Entre com sua conta para continuar."
    case .refreshUncertain:
      "Não foi possível confirmar a renovação da sessão. Entre novamente para continuar."
    case .invalidResponse:
      "O servidor retornou uma resposta que não conseguimos ler. Tente novamente."
    case .invalidRequest:
      "Não foi possível preparar esta solicitação."
    case .secureStorage:
      "Não foi possível acessar os dados seguros da conta neste dispositivo."
    case .appAttestUnsupported:
      "Este dispositivo não oferece a verificação necessária para acessar a conta."
    case .appAttestFailed:
      "Não foi possível verificar este dispositivo. Tente novamente."
    case .mockSignInRequired:
      "Use a conta de demonstração neste ambiente."
    case .mockEndpointUnavailable:
      "Esta ação ainda não está disponível na demonstração."
    case .httpStatus(401, _):
      "Não foi possível autorizar a solicitação. Entre novamente ou tente mais tarde."
    case .httpStatus(403, _):
      "Sua conta não tem permissão para realizar esta ação."
    case .httpStatus(404, _):
      "O conteúdo solicitado não foi encontrado."
    case .httpStatus(409, _):
      "Os dados foram alterados. Atualize e tente novamente."
    case .httpStatus(429, _):
      "Muitas tentativas em pouco tempo. Aguarde um momento e tente novamente."
    case .httpStatus:
      "Não foi possível concluir a solicitação. Tente novamente."
    }
  }
}

public typealias AccountClientError = AccountError

/// A FIFO gate keeps a complete operation exclusive across actor suspension points.
/// In particular, two windows cannot rotate the same refresh token or reorder assertions.
actor AccountOperationGate {
  private var isRunning = false
  private var waiting: [CheckedContinuation<Void, Never>] = []

  func run<Value: Sendable>(
    _ operation: @Sendable () async throws -> Value
  ) async throws -> Value {
    if isRunning {
      await withCheckedContinuation { waiting.append($0) }
    } else {
      isRunning = true
    }
    defer {
      if waiting.isEmpty {
        isRunning = false
      } else {
        waiting.removeFirst().resume()
      }
    }
    try Task.checkCancellation()
    return try await operation()
  }
}
