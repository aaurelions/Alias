import SwiftUI

struct RootView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(AppRouter.self) private var router
    @State private var isSplashVisible = true
    @State private var splashOpacity = 1.0
    @State private var splashLogoOffset: CGFloat = 0

    var body: some View {
        @Bindable var router = router

        GeometryReader { geometry in
            ZStack {
                NavigationStack(path: $router.path) {
                    HomeScreen()
                        .navigationDestination(for: Route.self, destination: destination)
                }
                .id(settings.language)

                if isSplashVisible {
                    SplashScreen(logoOffset: splashLogoOffset)
                        .opacity(splashOpacity)
                }
            }
            .task {
                try? await Task.sleep(for: .seconds(3))
                withAnimation(.easeInOut(duration: 1)) {
                    splashLogoOffset = -geometry.size.height / 2
                    splashOpacity = 0
                } completion: {
                    isSplashVisible = false
                }
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
