import SwiftUI

struct TurnStartScreen: View {
    @Environment(AppRouter.self) private var router
    @Environment(GameSession.self) private var session
    @State private var isInstructionsPresented = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    NavigationHeader(
                        title: L.TurnStart.round(session.currentRound),
                        leftAction: .back(action: goBack),
                        rightAction: .custom(icon: "questionmark.circle", accessibilityLabel: L.TurnStart.howToPlay) {
                            isInstructionsPresented = true
                        }
                    )

                    GameMetadata(settings: session.settings)
                        .padding(.vertical)

                    if let guesser = session.currentGuesser {
                        PlayerCard(player: guesser.player, role: L.Role.guesser, isEmojiLeading: true)
                            .padding(.bottom, 40)
                    }

                    TurnDivider(turnInfo: L.TurnStart.turnOf(session.turnNumberInRound, session.turnsPerRound))

                    if let explainer = session.currentExplainer {
                        PlayerCard(player: explainer.player, role: L.Role.explainer, isEmojiLeading: false)
                            .padding(.top, 40)
                    }
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)

            RippleButton(title: L.TurnStart.letsGo) {
                router.show(.gameplay)
            }
            .accessibilityLabel(L.Accessibility.play)
            .disabled(session.currentPairing == nil)
            .padding()
            .frame(height: 80)
        }
        .screenBackground(.turnStartConfirmScreenBg)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isInstructionsPresented) {
            InstructionsSheet()
        }
    }

    /// Before the first turn this returns to game setup; afterwards it reopens the previous turn's results.
    private func goBack() {
        if session.canReturnToLastTurn {
            session.returnToLastTurn()
            router.show(.turnResults)
        } else {
            router.back()
        }
    }
}

// MARK: - Player Card

private struct PlayerCard: View {
    let player: Player
    let role: String
    let isEmojiLeading: Bool
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 16) {
            Spacer()
            if isEmojiLeading {
                emoji
                Spacer()
            }

            VStack(spacing: 8) {
                Text(player.name)
                    .font(Theme.Typography.logo(size: 32))
                    .foregroundStyle(Theme.current.textPrimary)

                Text(role)
                    .font(Theme.Typography.bodySmall(size: 20))
                    .foregroundStyle(Theme.current.textSecondary.opacity(0.7))
            }

            if !isEmojiLeading {
                Spacer()
                emoji
            }
            Spacer()
        }
        .onAppear { isAnimating = true }
    }

    private var emoji: some View {
        Text(player.emoji)
            .font(.system(size: 120))
            .scaleEffect(isAnimating ? 1.1 : 1)
            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
    }
}

// MARK: - Turn Divider

private struct TurnDivider: View {
    let turnInfo: String

    var body: some View {
        HStack {
            Rectangle()
                .fill(Theme.current.borderPrimary.opacity(0.6))
                .frame(height: 1)

            TurnInfoLabel(turnInfo: turnInfo)

            Rectangle()
                .fill(Theme.current.borderPrimary.opacity(0.6))
                .frame(height: 1)
        }
        .padding(.horizontal)
    }
}

// MARK: - Turn Info Label

private struct TurnInfoLabel: View {
    let turnInfo: String

    var body: some View {
        Text(turnInfo)
            .font(Theme.Typography.logo(size: 36))
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .foregroundStyle(Theme.current.textPrimary.opacity(0.5))
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.current.surfacePrimary.opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.current.borderPrimary.opacity(0.6), lineWidth: 1)
            )
    }
}

// MARK: - Game Metadata

private struct GameMetadata: View {
    let settings: GameSettings

    var body: some View {
        HStack(spacing: 20) {
            MetadataItem(icon: "timer", value: L.Settings.seconds(settings.roundTime))
            MetadataItem(icon: "flag.checkered", value: "\(settings.pointsToWin)")
            MetadataItem(
                icon: "arrow.up.circle.fill",
                value: "+\(settings.guesserPoints)/+\(settings.explainerPoints)",
                color: Theme.current.accentSuccess
            )
            MetadataItem(
                icon: "arrow.down.circle.fill",
                value: "\(settings.guesserPenalty)/\(settings.explainerPenalty)",
                color: Theme.current.accentDestructive
            )
            if settings.lastWordBonusEnabled {
                MetadataItem(icon: "star.fill", value: "+\(settings.lastWordBonusPoints)", color: Theme.current.accentHighlight)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.current.surfacePrimary.opacity(0.2))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Theme.current.borderPrimary.opacity(0.6), lineWidth: 1)
                }
        }
    }
}

// MARK: - Metadata Item

private struct MetadataItem: View {
    let icon: String
    let value: String
    var color: Color = Theme.current.textSecondary

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color.opacity(0.8))
                .shadow(radius: 5)

            Text(value)
                .font(Theme.Typography.bodySmall(size: 12))
                .foregroundStyle(Theme.current.textSecondary.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Instructions Sheet

private struct InstructionsSheet: View {
    private let instructions = [
        L.TurnStart.instruction1,
        L.TurnStart.instruction2,
        L.TurnStart.instruction3,
        L.TurnStart.instruction4,
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SheetTitle(L.TurnStart.howToPlay)

            ForEach(Array(instructions.enumerated()), id: \.offset) { index, text in
                InstructionRow(number: index + 1, text: text)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .themedSheet()
    }
}

// MARK: - Instruction Row

private struct InstructionRow: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(number, format: .number)
                .font(Theme.Typography.heading1(size: 24))
                .foregroundStyle(Theme.current.interactivePrimary)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Theme.current.interactivePrimary.opacity(0.2))
                )

            Text(text)
                .font(Theme.Typography.body(size: 16))
                .foregroundStyle(Theme.current.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TurnStartScreen()
    }
    .previewEnvironment()
}
