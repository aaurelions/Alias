import SwiftUI

// MARK: - Start Game Button

/// Action button specifically for starting a game with ripple animation
struct StartGameButton: View {
    var isEnabled: Bool = true
    let action: () -> Void
    @State private var isRippling = false

    var body: some View {
        Button(action: {
            guard isEnabled else { return }

            withAnimation(.easeOut(duration: AnimationDefaults.rippleDuration)) {
                isRippling = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + AnimationDefaults.rippleDuration) {
                isRippling = false
            }

            action()
        }) {
            Text(L.NewGame.startGame)
                .font(Theme.Typography.heading1(size: 28))
                .foregroundColor(Theme.current.interactivePrimary)
                .opacity(isEnabled ? 1.0 : 0.45)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .accessibilityLabel(L.Home.Accessibility.startGame)
        }
        .buttonStyle(.plain)
        .background(Theme.current.surfacePrimary.opacity(0.2))
        .cornerRadius(10)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Theme.current.borderPrimary.opacity(0.1), lineWidth: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Theme.current.borderPrimary.opacity(isRippling ? 0.0 : 0.1), lineWidth: isRippling ? 60 : 20)
                .scaleEffect(isRippling ? 2.5 : 1.0)
                .opacity(isRippling ? 0.0 : 1.0)
        )
        .rotationEffect(.degrees(-3))
    }
}

// MARK: - Previews

#Preview("Start Game Button") {
    VStack(spacing: 20) {
        StartGameButton(action: {})
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Theme.current.backgroundPrimary)
}
