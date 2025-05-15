import CocoaHeadsKit
import SwiftUI

@main
struct NSBrazilConfApp: App {

  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    WindowGroup {
      HomePage()
    }
  }
}
