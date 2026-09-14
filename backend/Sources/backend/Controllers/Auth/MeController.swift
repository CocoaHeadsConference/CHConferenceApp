//
//  MeController.swift
//  backend
//
//  Created by Mauricio Cardozo on 8/7/26.
//

import CocoaHeadsCore
import Vapor

/// User-scoped routes behind the Bearer JWT gate.
struct MeController: RouteCollection {
  let appleAuth: any AppleAuthServiceProtocol

  func boot(routes: any RoutesBuilder) throws {
    let me =
      routes
      .grouped(AccessTokenPayload.authenticator(), AccessTokenPayload.guardMiddleware())
      .grouped("me")
    me.get(use: current)
    me.delete(use: delete)
  }

  @Sendable
  func current(req: Request) async throws -> UserDTO {
    try await req.authenticatedUser().dto
  }

  /// Account deletion, required by App Review Guideline 5.1.1(v). Soft-deletes
  /// with immediate PII scrub and Apple grant revocation; the row is
  /// hard-purged after the grace period (§8).
  @Sendable
  func delete(req: Request) async throws -> HTTPStatus {
    let user = try await req.authenticatedUser()
    try await AccountDeletionService(appleAuth: appleAuth).delete(user, on: req)
    return .noContent
  }
}

extension UserDTO: @retroactive RequestDecodable {}
extension UserDTO: @retroactive ResponseEncodable {}
extension UserDTO: @retroactive AsyncRequestDecodable {}
extension UserDTO: @retroactive AsyncResponseEncodable {}
extension UserDTO: @retroactive Content {}
