import Fluent
import Vapor

func routes(_ app: Application) throws {
  // App-authentication layer (§6): every route requires the API key.
  let apiKeyGated = app.grouped(APIKeyMiddleware())

  let appleAuth = AppleAuthService()
  try apiKeyGated.register(collection: AuthController(appleAuth: appleAuth))
  try apiKeyGated.register(collection: MeController(appleAuth: appleAuth))
  try apiKeyGated.register(
    collection: ScrapingController(firecrawl: FirecrawlService())
  )
}
