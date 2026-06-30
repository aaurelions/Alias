import SwiftUI

struct HomeScreen: View {
    @Binding var navigationPath: NavigationPath
    var showAnimation: Binding<Bool>? = nil
    @State private var isRippling = false
    @State private var isSettingsPresented = false
    @State private var buttonRotation: Double = -3
    @State private var buttonScale: CGFloat = 1.0
    private let feedbackManager = FeedbackManager.shared

    let strokeColor = Color.black.opacity(0.9)
    let strokeWidth: CGFloat = 1

    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 0) {
                    ForEach(Array("Alias".enumerated()), id: \.offset) { index, letter in
                        Text(String(letter))
                            .font(Theme.Typography.logo(size: 72))
                            .foregroundColor(Theme.current.textPrimary)
                            .rotationEffect(.degrees(2))
                            .background(
                                ZStack {
                                    Text(String(letter)).offset(x:  strokeWidth, y:  strokeWidth)
                                    Text(String(letter)).offset(x: -strokeWidth, y:  strokeWidth)
                                    Text(String(letter)).offset(x: -strokeWidth, y: -strokeWidth)
                                }
                                .font(Theme.Typography.logo(size: 72))
                                .foregroundColor(strokeColor)
                            )
                            .scaleEffect(x: 1, y: 2)
                            .opacity(0.2)
                    }
                }
                .rotationEffect(.degrees(2))
                .padding(.top, 40)

                Spacer()

                Button(action: {
                    // Play feedback
                    feedbackManager.buttonTapFeedback()

                    // Trigger ripple effect
                    withAnimation(.easeOut(duration: 0.8)) {
                        isRippling = true
                    }

                    // Reset ripple state after animation completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        isRippling = false
                    }

                    // Navigate to New Game screen
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        navigationPath.append(NavigationDestination.newGame)
                    }
                }) {
                    Text(L.Home.newGame)
                        .font(Theme.Typography.heading1(size: 48))
                        .foregroundColor(Theme.current.interactivePrimary)
                        .opacity(0.8)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .accessibilityLabel(L.Home.Accessibility.startGame)
                }
                .buttonStyle(.plain)
                .background(Theme.current.surfacePrimary.opacity(0.2))
                .cornerRadius(Theme.BorderRadius.lg.value)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.BorderRadius.lg.value)
                        .stroke(Theme.current.borderPrimary.opacity(0.1), lineWidth: 20)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.BorderRadius.lg.value)
                        .stroke(Theme.current.borderPrimary.opacity(isRippling ? 0.0 : 0.1), lineWidth: isRippling ? 60 : 20)
                        .scaleEffect(isRippling ? 2.5 : 1.0)
                        .opacity(isRippling ? 0.0 : 1.0)
                )
                .rotationEffect(.degrees(buttonRotation))
                .scaleEffect(buttonScale)

                Spacer()

                HStack {
                    Button(action: {
                        feedbackManager.triggerHaptic(.light)
                        withAnimation {
                            isSettingsPresented = true
                        }
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 38, weight: .regular))
                            .opacity(0.3)
                            .foregroundColor(Theme.current.textSecondary)
                            .accessibilityLabel(L.Home.Accessibility.openSettings)
                        Text(L.Home.settings)
                            .font(Theme.Typography.heading1(size: 24))
                            .opacity(0.3)
                            .foregroundColor(Theme.current.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .safeAreaInset(edge: .leading) {
                Color.clear.frame(width: 40)
            }
            .safeAreaInset(edge: .trailing) {
                Color.clear.frame(width: 40)
            }
            .background(DarkBackgroundView(backgroundImage: "HomeScreenBg"))

            // App Settings Sheet - In separate ZStack layer to avoid layout interference
            if isSettingsPresented {
                AppSettingsSheet(isPresented: $isSettingsPresented)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            isRippling = false
            startButtonAnimation()
        }
    }

    private func startButtonAnimation() {
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            buttonRotation = 3
            buttonScale = 1.1
        }
    }
}

#Preview("Default Home Screen") {
    NavigationStack {
        HomeScreen(navigationPath: .constant(NavigationPath()))
    }
}

#Preview("Home Screen (Dark Mode)") {
    NavigationStack {
        HomeScreen(navigationPath: .constant(NavigationPath()))
    }
    .preferredColorScheme(.dark)
}

#Preview("Home Screen (Light Mode)") {
    NavigationStack {
        HomeScreen(navigationPath: .constant(NavigationPath()))
    }
    .preferredColorScheme(.light)
}
