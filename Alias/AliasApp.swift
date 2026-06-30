import SwiftUI

enum AppState {
    case splash
    case main
}

@main
struct AliasApp: App {
    @StateObject private var settingsManager = SettingsManager.shared
    @State private var appState: AppState = .splash
    @State private var splashOpacity: Double = 1.0
    @State private var logoOffset: CGFloat = 0
    @State private var navigationPath = NavigationPath()
    @State private var showHomeScreen = false
    @State private var languageChangeId = UUID()

    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                ZStack {
                    // HomeScreen is ALWAYS shown underneath from the start
                    NavigationStack(path: $navigationPath) {
                        HomeScreen(navigationPath: $navigationPath, showAnimation: $showHomeScreen)
                            .navigationDestination(for: NavigationDestination.self) { destination in
                                switch destination {
                                    case .home:
                                        HomeScreen(navigationPath: $navigationPath)
                                    case .newGame:
                                        NewGameScreen(navigationPath: $navigationPath)
                                    case .turnStartConfirm:
                                        TurnStartConfirmScreen(navigationPath: $navigationPath)
                                    case .gameplay:
                                        GameplayScreen(navigationPath: $navigationPath)
                                    case .turnResults:
                                        TurnResultsScreen(navigationPath: $navigationPath)
                                    case .winner:
                                        WinnerScreen(navigationPath: $navigationPath)
                                }
                            }
                            .environmentObject(settingsManager)
                            .id(languageChangeId)
                    }

                    // Splash screen overlay with mysterious fade and logo animation
                    if appState == .splash {
                        SplashScreen(logoOffset: logoOffset, logoScale: 1.0)
                            .opacity(splashOpacity)
                            .animation(.easeInOut(duration: 1.0), value: logoOffset)
                            .animation(.easeInOut(duration: 1.0), value: splashOpacity)
                    }
                }
                .onAppear {
                    // Set up language change notification observer
                    NotificationCenter.default.addObserver(
                        forName: .languageDidChange,
                        object: nil,
                        queue: .main
                    ) { _ in
                        // Force UI refresh by changing the ID
                        languageChangeId = UUID()
                    }

                    // Phase 1: Letter appearance (1.5 seconds)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        // Phase 2: Wait (1.5 seconds)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            // Phase 3: Fly up animation (1 second)
                            let targetOffset = -(geometry.size.height / 2)

                            // Start offset and opacity animation (1 second)
                            logoOffset = targetOffset
                            splashOpacity = 0.0

                            // Wait for animation to complete BEFORE removing splash
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                appState = .main
                                showHomeScreen = true
                            }
                        }
                    }
                }
            }
        }
    }
}
