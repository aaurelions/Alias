import SwiftUI

// MARK: - Turn Start Confirm Screen

struct TurnStartConfirmScreen: View {
    @Binding var navigationPath: NavigationPath
    @Environment(\.dismiss) var dismiss
    @State private var showInstructions = false
    @StateObject private var gameManager = GameManager.shared

    private var guesserPlayer: Player {
        gameManager.currentGuesser?.toPlayer() ?? Player(emoji: "🦄", name: "Unknown")
    }

    private var explainerPlayer: Player {
        gameManager.currentExplainer?.toPlayer() ?? Player(emoji: "🎭", name: "Unknown")
    }

    private var roundTime: Int {
        gameManager.settings.selectedRoundTime
    }

    private var pointsToWin: Int {
        gameManager.settings.selectedPointsToWin
    }

    private var guesserPoints: Int {
        gameManager.settings.guesserPoints
    }

    private var explainerPoints: Int {
        gameManager.settings.explainerPoints
    }

    private var guesserPenalty: Int {
        gameManager.settings.guesserPenalty
    }

    private var explainerPenalty: Int {
        gameManager.settings.explainerPenalty
    }

    private var lastWordBonusEnabled: Bool {
        gameManager.settings.lastWordBonusEnabled
    }

    private var lastWordBonusPoints: Int {
        gameManager.settings.lastWordBonusPoints
    }

    private var roundNumber: String {
        "\(L.TurnStart.round) \(gameManager.currentRound)"
    }

    private var turnInfo: String {
        L.TurnStart.turnOf(gameManager.currentTurnInRound + 1, gameManager.getTotalTurnsInRound())
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        NavigationHeader(
                            title: roundNumber,
                            leftAction: .back {
                                // Rewind game state if possible
                                if gameManager.canRewind() {
                                    gameManager.rewindToPreviousTurn()
                                }
                                dismiss()
                            },
                            rightAction: .custom(
                                icon: "questionmark.circle",
                                accessibilityLabel: L.TurnStart.howToPlay
                            ) {
                                withAnimation {
                                    showInstructions = true
                                }
                            }
                        )

                        // Game Metadata
                        GameMetadata(
                            roundTime: roundTime,
                            pointsToWin: pointsToWin,
                            guesserPoints: guesserPoints,
                            explainerPoints: explainerPoints,
                            guesserPenalty: guesserPenalty,
                            explainerPenalty: explainerPenalty,
                            lastWordBonusEnabled: lastWordBonusEnabled,
                            lastWordBonusPoints: lastWordBonusPoints
                        )
                        .padding(.vertical)

                        // Guesser Player (Top)
                        PlayerCard(player: guesserPlayer, role: L.Role.guesser, isTop: true)
                            .padding(.bottom, 40)

                        TurnDivider(turnInfo: turnInfo)

                        // Explainer Player (Bottom)
                        PlayerCard(player: explainerPlayer, role: L.Role.explainer, isTop: false)
                            .padding(.top, 40)
                    }
                    .padding(.horizontal)
                }
                .scrollIndicators(.hidden)

                Spacer()

                // Action Button
                HStack(spacing: 12) {
                    StartTurnButton(action: {
                        // Navigate to gameplay
                        navigationPath.append(NavigationDestination.gameplay)
                    })
                }
                .padding(.horizontal)
                .padding(.vertical)
                .frame(height: 80)
            }

            // Instructions Sheet
            if showInstructions {
                InstructionsSheet(isPresented: $showInstructions)
            }
        }
        .background(DarkBackgroundView(backgroundImage: "TurnStartConfirmScreenBg"))
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Player Card

private struct PlayerCard: View {
    let player: Player
    let role: String
    let isTop: Bool
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 16) {
            Spacer()
            
            if (isTop) {
                Text(player.emoji)
                    .font(.system(size: 120))
                    .scaleEffect(isAnimating ? 1.1 : 1.0, anchor: .center)
                    .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                    .onAppear() {
                        isAnimating = true
                    }

                Spacer()
            }

            VStack(spacing: 8) {
                Text(player.name)
                    .font(Theme.Typography.logo(size: 32))
                    .foregroundColor(Theme.current.textPrimary)

                Text(role)
                    .font(Theme.Typography.bodySmall(size: 20))
                    .foregroundColor(Theme.current.textSecondary.opacity(0.7))
            }
            
            if (!isTop) {
                Spacer()

                Text(player.emoji)
                    .font(.system(size: 120))
                    .scaleEffect(isAnimating ? 1.1 : 1.0, anchor: .center)
                    .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                    .onAppear() {
                        isAnimating = true
                    }
            }
            
            Spacer()
        }
    }
}

// MARK: - Turn Divider

private struct TurnDivider: View {
    let turnInfo: String

    var body: some View {
        HStack {
            // Horizontal line
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
            .foregroundColor(Theme.current.textPrimary.opacity(0.5))
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
    let roundTime: Int
    let pointsToWin: Int
    let guesserPoints: Int
    let explainerPoints: Int
    let guesserPenalty: Int
    let explainerPenalty: Int
    let lastWordBonusEnabled: Bool
    let lastWordBonusPoints: Int

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                MetadataItem(icon: "timer", value: "\(roundTime)s")
                MetadataItem(icon: "flag.checkered", value: "\(pointsToWin)")
                MetadataItem(icon: "arrow.up.circle.fill", value: "+\(guesserPoints)/+\(explainerPoints)", color: Theme.current.accentSuccess)
                MetadataItem(icon: "arrow.down.circle.fill", value: "\(guesserPenalty)/\(explainerPenalty)", color: Theme.current.accentDestructive)
                if lastWordBonusEnabled {
                    MetadataItem(icon: "star.fill", value: "+\(lastWordBonusPoints)", color: Theme.current.accentHighlight)
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.current.surfacePrimary.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Theme.current.borderPrimary.opacity(0.6), lineWidth: 1)
                )
        )
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
                .foregroundColor(color.opacity(0.8))
                .shadow(radius: 5)

            Text(value)
                .font(Theme.Typography.bodySmall(size: 12))
                .foregroundColor(Theme.current.textSecondary.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Start Turn Button

private struct StartTurnButton: View {
    let action: () -> Void
    @State private var isRippling = false

    var body: some View {
        Button(action: {
            withAnimation(.easeOut(duration: AnimationDefaults.rippleDuration)) {
                isRippling = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + AnimationDefaults.rippleDuration) {
                isRippling = false
            }

            action()
        }) {
            Text(L.TurnStart.letsGo)
                .font(Theme.Typography.heading1(size: 28))
                .foregroundColor(Theme.current.interactivePrimary)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .accessibilityLabel(L.Accessibility.play)
        }
        .buttonStyle(.plain)
        .frame(height: 60)
        .background(Theme.current.surfacePrimary.opacity(0.2))
        .cornerRadius(10)
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

// MARK: - Instructions Sheet

private struct InstructionsSheet: View {
    @Binding var isPresented: Bool

    var body: some View {
        BottomSheet(isPresented: $isPresented) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Spacer()
                    Text(L.TurnStart.howToPlay)
                        .font(Theme.Typography.heading1(size: 24))
                        .foregroundColor(Theme.current.textPrimary)
                    Spacer()
                }

                InstructionRow(
                    number: "1",
                    text: L.TurnStart.instruction1
                )

                InstructionRow(
                    number: "2",
                    text: L.TurnStart.instruction2
                )

                InstructionRow(
                    number: "3",
                    text: L.TurnStart.instruction3
                )

                InstructionRow(
                    number: "4",
                    text: L.TurnStart.instruction4
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Instruction Row

private struct InstructionRow: View {
    let number: String
    let text: String

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(number)
                .font(Theme.Typography.heading1(size: 24))
                .foregroundColor(Theme.current.interactivePrimary)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Theme.current.interactivePrimary.opacity(0.2))
                )

            Text(text)
                .font(Theme.Typography.body(size: 16))
                .foregroundColor(Theme.current.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Preview

#Preview("Turn 1 - Round 1") {
    let _ = {
        let manager = GameManager.shared
        let testPlayers = [
            Player(emoji: "👨", name: "Alice"),
            Player(emoji: "👩", name: "Bob"),
            Player(emoji: "🧑", name: "Charlie")
        ]
        let testDict = WordDictionary(
            id: 1,
            emoji: "🟠",
            name: "Medium",
            wordCount: 90
        )
        let testSettings = GameSettings(
            selectedRoundTime: 45,
            selectedPointsToWin: 50,
            guesserPoints: 2,
            explainerPoints: 1,
            guesserPenalty: -1,
            explainerPenalty: -1,
            lastWordBonusEnabled: true,
            lastWordBonusPoints: 5
        )
        manager.startNewGame(players: testPlayers, dictionary: testDict, settings: testSettings)
    }()

    NavigationStack {
        TurnStartConfirmScreen(navigationPath: .constant(NavigationPath()))
    }
}

#Preview("Turn 3 - Round 2") {
    let _ = {
        let manager = GameManager.shared
        let testPlayers = [
            Player(emoji: "🦄", name: "Unicorn"),
            Player(emoji: "🐉", name: "Dragon"),
            Player(emoji: "🦁", name: "Lion"),
            Player(emoji: "🐼", name: "Panda")
        ]
        let testDict = WordDictionary(
            id: 2,
            emoji: "🔴",
            name: "Hard",
            wordCount: 120
        )
        let testSettings = GameSettings(
            selectedRoundTime: 60,
            selectedPointsToWin: 100,
            guesserPoints: 6,
            explainerPoints: 4,
            guesserPenalty: -3,
            explainerPenalty: -2,
            lastWordBonusEnabled: true,
            lastWordBonusPoints: 7
        )
        manager.startNewGame(players: testPlayers, dictionary: testDict, settings: testSettings)
    }()

    NavigationStack {
        TurnStartConfirmScreen(navigationPath: .constant(NavigationPath()))
    }
}

#Preview("Bonus Disabled") {
    let _ = {
        let manager = GameManager.shared
        let testPlayers = [
            Player(emoji: "🎮", name: "Gamer"),
            Player(emoji: "🎨", name: "Artist")
        ]
        let testDict = WordDictionary(
            id: 0,
            emoji: "🟢",
            name: "Easy",
            wordCount: 60
        )
        let testSettings = GameSettings(
            selectedRoundTime: 30,
            selectedPointsToWin: 20,
            guesserPoints: 3,
            explainerPoints: 2,
            guesserPenalty: -1,
            explainerPenalty: -1,
            lastWordBonusEnabled: false,
            lastWordBonusPoints: 0
        )
        manager.startNewGame(players: testPlayers, dictionary: testDict, settings: testSettings)
    }()

    NavigationStack {
        TurnStartConfirmScreen(navigationPath: .constant(NavigationPath()))
    }
}
