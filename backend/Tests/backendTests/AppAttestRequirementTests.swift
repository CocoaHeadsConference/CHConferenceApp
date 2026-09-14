import Testing
import VaporTesting

@testable import backend

@Suite("Route-scoped App Attest requirements")
struct AppAttestRequirementTests {
  private func withApp(
    requirement: AppAttestMiddleware.Requirement, disabled: Bool = false,
    environment: Environment = .production,
    _ test: (Application) async throws -> Void
  ) async throws {
    let app = try await Application.make(environment)
    do {
      app.authConfiguration = AuthConfiguration(
        appleBundleID: "com.cocoaheadsbr.conf", apiKeys: ["test-key"], accessTokenTTL: 900,
        refreshTokenTTL: 3600, accountPurgeGraceDays: 30, appleTeamID: nil,
        appleSignInKeyID: nil, appleSignInPrivateKey: nil, appAttestTeamID: "TEAMID1234",
        appAttestEnvironment: .production, appAttestDisabled: disabled)
      app.grouped(AppAttestMiddleware(requirement: requirement)).get("protected") { _ in "accepted" }
      try await test(app)
    } catch {
      try? await app.asyncShutdown()
      throw error
    }
    try await app.asyncShutdown()
  }

  @Test("Optional attestation accepts completely absent headers in production")
  func absentOptional() async throws {
    try await withApp(requirement: .whenPresent) { app in
      try await app.testing().test(
        .GET, "protected",
        afterResponse: { response in
          #expect(response.status == .ok)
          #expect(response.body.string == "accepted")
        })
    }
  }

  @Test("A required route still rejects absent headers")
  func absentRequired() async throws {
    try await withApp(requirement: .required) { app in
      try await app.testing().test(
        .GET, "protected",
        afterResponse: { response in
          #expect(response.status == .unauthorized)
        })
    }
  }

  @Test("Optional attestation rejects every incomplete or invalid header set", arguments: [1, 2, 3, 4, 5, 6, 7])
  func incompleteHeaders(mask: Int) async throws {
    try await withApp(requirement: .whenPresent) { app in
      var headers = HTTPHeaders()
      if mask & 1 != 0 { headers.add(name: "X-Attest-Key-Id", value: "unregistered-key") }
      if mask & 2 != 0 { headers.add(name: "X-Attest-Challenge", value: "Y2hhbGxlbmdl") }
      if mask & 4 != 0 { headers.add(name: "X-Attest-Assertion", value: "YXNzZXJ0aW9u") }
      try await app.testing().test(
        .GET, "protected", headers: headers,
        afterResponse: { response in
          #expect(response.status == .unauthorized)
        })
    }
  }

  @Test("An empty attestation header is still supplied and must be rejected")
  func emptyHeader() async throws {
    try await withApp(requirement: .whenPresent) { app in
      try await app.testing().test(
        .GET, "protected", headers: ["X-Attest-Key-Id": ""],
        afterResponse: { response in
          #expect(response.status == .unauthorized)
        })
    }
  }

  @Test("The global disable flag cannot bypass either policy in production", arguments: [false, true])
  func productionDisable(optional: Bool) async throws {
    try await withApp(requirement: optional ? .whenPresent : .required, disabled: true) { app in
      try await app.testing().test(
        .GET, "protected",
        afterResponse: { response in
          #expect(response.status == .serviceUnavailable)
        })
    }
  }

  @Test("Supplying a partial assertion never downgrades to the local development bypass")
  func suppliedWithLocalBypass() async throws {
    try await withApp(requirement: .whenPresent, disabled: true, environment: .testing) { app in
      try await app.testing().test(
        .GET, "protected", headers: ["X-Attest-Key-Id": "partial"],
        afterResponse: { response in
          #expect(response.status == .unauthorized)
        })
    }
  }
}
