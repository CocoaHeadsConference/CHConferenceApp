import NSBrazilLib
import SwiftUI

@main
struct NSBrazilConfApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            HomeTabBar(model: FeedViewModel())
        }
    }
}
