import Fluent
import Vapor

func routes(_ app: Application) throws {
  try app.register(collection: PublicCatalogController())
  // Public reading is above these gates. Account operations also support Mac clients
  // without device attestation; any supplied assertion is still fully verified.
  let apiKeyGated = app.grouped(APIKeyMiddleware())
  let identityRoutes = apiKeyGated.grouped(AppAttestMiddleware(requirement: .whenPresent))
  let attestedRoutes = apiKeyGated.grouped(AppAttestMiddleware())

  // App Attest registration sits behind the API key only — a device cannot
  // assert before it has registered a key.
  try apiKeyGated.register(collection: AttestController())

  try identityRoutes.register(collection: OrganizerController())

  let appleAuth = AppleAuthService()
  try identityRoutes.register(collection: AuthController(appleAuth: appleAuth))
  try identityRoutes.register(collection: MeController(appleAuth: appleAuth))
  try attestedRoutes.register(
    collection: ScrapingController(firecrawl: FirecrawlService())
  )
}
