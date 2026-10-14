import SwiftUI

struct HomeScreen: View {
    @Environment(AppRouter.self) private var router
    @State private var isRippling = false
    @State private var isSettingsPresented = false
    @State private var buttonRotation: Double = -3
    @State private var buttonScale: CGFloat = 1

    private static let title = Array("Alias")

    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 0) {
                    ForEach(Self.title.indices, id: \.self) { index in
                        OutlinedLetter(letter: Self.title[index])
                            .rotationEffect(.degrees(2))
                            .scaleEffect(x: 1, y: 2)
                            .opacity(0.2)
                    }
                }
                .rotationEffect(.degrees(2))
                .padding(.top, 40)

                Spacer()

                newGameButton

                Spacer()

                Button {
                    FeedbackService.shared.haptic(.light)
                    withAnimation { isSettingsPresented = true }
                } label: {
                    Label {
                        Text(L.Home.settings)
                            .font(Theme.Typography.heading1(size: 24))
                    } icon: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 38))
                    }
                    .opacity(0.3)
                    .foregroundStyle(Theme.current.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L.Home.Accessibility.openSettings)
            }
            .padding(.horizontal, 40)
            .background(DarkBackgroundView(backgroundImage: "HomeScreenBg"))

            if isSettingsPresented {
                AppSettingsSheet(isPresented: $isSettingsPresented)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            isRippling = false
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                buttonRotation = 3
                buttonScale = 1.1
            }
        }
    }

    private var newGameButton: some View {
        Button {
            FeedbackService.shared.buttonTap()
            withAnimation(.easeOut(duration: AnimationDefaults.rippleDuration)) {
                isRippling = true
            } completion: {
                isRippling = false
            }
            router.showNewGame()
        } label: {
            Text(L.Home.newGame)
                .font(Theme.Typography.heading1(size: 48))
                .foregroundStyle(Theme.current.interactivePrimary)
                .opacity(0.8)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L.Home.Accessibility.startGame)
        .background(Theme.current.surfacePrimary.opacity(0.2))
        .clipShape(.rect(cornerRadius: Theme.BorderRadius.lg.value))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.BorderRadius.lg.value)
                .stroke(Theme.current.borderPrimary.opacity(0.1), lineWidth: 20)
        }
        .overlay {
            RoundedRectangle(cornerRadius: Theme.BorderRadius.lg.value)
                .stroke(Theme.current.borderPrimary.opacity(isRippling ? 0 : 0.1), lineWidth: isRippling ? 60 : 20)
                .scaleEffect(isRippling ? 2.5 : 1)
                .opacity(isRippling ? 0 : 1)
        }
        .rotationEffect(.degrees(buttonRotation))
        .scaleEffect(buttonScale)
    }
}

#Preview {
    NavigationStack {
        HomeScreen()
    }
    .previewEnvironment()
}
