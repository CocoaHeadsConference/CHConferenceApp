import CocoaHeadsKit
import SwiftUI

@main
struct NSBrazilConfApp: App {

  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @State private var services = CocoaHeadsAppServices()

  var body: some Scene {
    WindowGroup {
      CocoaHeadsAppView(services: services)
    }
  }
}
