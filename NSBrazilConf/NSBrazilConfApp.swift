import NSBrazilLib
import SwiftUI

@main
struct NSBrazilConfApp: App {
    var body: some Scene {
        WindowGroup {
          #if DEBUG
            HomeTabBar(model: .mock)
          #else
            HomeTabBar(model: FeedViewModel())
          #endif
        }
    }
}
