import SwiftUI

struct RootView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(AppRouter.self) private var router
    @State private var isSplashVisible = true

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            HomeScreen()
                .navigationDestination(for: Route.self, destination: destination)
        }
        // Formatters (time, percent, lists) follow the in-app language. Strings come from `L`,
        // which observes `AppSettings.language`, so views refresh in place when it changes.
        .environment(\.locale, settings.language.locale)
        .overlay {
            if isSplashVisible {
                SplashScreen { isSplashVisible = false }
            }
        }
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .newGame: NewGameScreen()
        case .turnStart: TurnStartScreen()
        case .gameplay: GameplayScreen()
        case .turnResults: TurnResultsScreen()
        case .winner: WinnerScreen()
        }
    }
}
