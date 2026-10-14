import SwiftUI

@main
struct AliasApp: App {
    @State private var settings = AppSettings.shared
    @State private var router = AppRouter()
    @State private var session = GameSession()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(settings)
                .environment(router)
                .environment(session)
        }
    }
}
