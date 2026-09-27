import Fluent
import FluentPostgresDriver
import JWT
import NIOSSL
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
  // uncomment to serve files from /Public folder
  // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

  app.databases.use(
    DatabaseConfigurationFactory.postgres(
      configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

  app.migrations.add(CreateUser())
  app.migrations.add(CreateRefreshToken())
  app.migrations.add(CreateAppAttestKey())
  app.migrations.add(DropAppAttestKeys())

  try await configureAuth(app)

  app.lifecycle.use(AccountPurgeService())

  // register routes
  try routes(app)
}

/// Sets up the auth configuration, JWT signing keys, and secret encryption.
func configureAuth(_ app: Application) async throws {
  let config = AuthConfiguration.load(from: app.environment)
  app.authConfiguration = config

  // Expected `aud` for Apple identity tokens.
  app.jwt.apple.applicationIdentifier = config.appleBundleID

  // Backend access-token signing key: an ES256 private-key PEM (recommended)
  // or a plain HS256 secret.
  if let signingKey = Environment.get("JWT_SIGNING_KEY") {
    if signingKey.contains("BEGIN") {
      try await app.jwt.keys.add(ecdsa: ES256PrivateKey(pem: signingKey))
    } else {
      await app.jwt.keys.add(hmac: HMACKey(from: signingKey), digestAlgorithm: .sha256)
    }
  } else if app.environment == .production {
    app.logger.critical("JWT_SIGNING_KEY must be set in production.")
    throw AuthError.missingSigningKey
  } else {
    app.logger.warning("JWT_SIGNING_KEY not set — using an insecure development key.")
    await app.jwt.keys.add(hmac: "insecure-development-key", digestAlgorithm: .sha256)
  }

  if Environment.get("TOKEN_ENCRYPTION_KEY") != nil || Environment.get("JWT_SIGNING_KEY") != nil {
    app.tokenEncryption = try TokenEncryption.load()
  } else {
    app.tokenEncryption = TokenEncryption(
      key: .init(data: Array("insecure-development-encryption-".utf8))
    )
  }
}
