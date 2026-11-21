import SwiftUI
import UnscrollCore

@main
struct UnscrollApp: App {
    var body: some Scene {
        WindowGroup {
            InstagramWebView(start: InstagramRules.inbox)
        }
    }
}
