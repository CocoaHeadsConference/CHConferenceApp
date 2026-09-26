//
//  APIKeyMiddleware.swift
//  backend
//
//  Created by Mauricio Cardozo on 8/7/26.
//

import Vapor

/// Coarse first gate of the app-authentication layer: checks `X-API-Key`
/// against the static keys configured via `API_KEYS`.
///
/// Caveat (intentional, per spec §6): a key baked into a shipped app is
/// extractable from the binary, so this identifies the client but is not an
/// integrity guarantee. Fails closed when no keys are configured.
struct APIKeyMiddleware: AsyncMiddleware {
  static let header = HTTPHeaders.Name("X-API-Key")

  func respond(
    to request: Request,
    chainingTo next: any AsyncResponder
  ) async throws -> Response {
    let keys = request.authConfiguration.apiKeys
    guard !keys.isEmpty else {
      request.logger.error("API_KEYS is not configured; rejecting request.")
      throw Abort(.serviceUnavailable, reason: "API keys are not configured.")
    }
    guard let key = request.headers.first(name: Self.header), keys.contains(key) else {
      throw Abort(.unauthorized, reason: "Missing or invalid API key.")
    }
    return try await next.respond(to: request)
  }
}
