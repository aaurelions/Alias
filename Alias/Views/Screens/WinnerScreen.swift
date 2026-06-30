import SwiftUI

// MARK: - Winner Screen

struct WinnerScreen: View {
    @Binding var navigationPath: NavigationPath
    @StateObject private var gameManager = GameManager.shared
    private let feedbackManager = FeedbackManager.shared

    private var winners: [Player] {
        gameManager.winners.map { $0.toPlayer() }
    }

    private var winnerScore: Int {
        gameManager.winners.first?.score ?? 0
    }

    private var isTied: Bool {
        winners.count > 1
    }

    private var otherPlayers: [(Player, Int)] {
        let winnerIds = Set(gameManager.winners.map { $0.id })
        return gameManager.players
            .filter { !winnerIds.contains($0.id) }
            .sorted { $0.score > $1.score }
            .map { ($0.toPlayer(), $0.score) }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    // Winner Display (single or tied)
                    if isTied {
                        TiedWinnersDisplaySection(winners: winners, score: winnerScore)
                            .padding(.bottom, 160)
                    } else {
                        WinnerDisplaySection(winner: winners.first ?? Player(emoji: "🏆", name: "Winner"), score: winnerScore)
                            .padding(.bottom, 160)
                    }

                    // Other Players Section
                    OtherPlayersSection(players: otherPlayers)
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)

            Spacer()

            // Action Buttons (Always at bottom)
            HStack(spacing: 12) {
                // Return to Home Button
                ActionButton(
                    title: L.home,
                    icon: "house.fill",
                    action: {
                        navigationPath.removeLast(navigationPath.count)
                    }
                )

                Spacer()

                // Play Again Button
                ActionButton(
                    title: L.again,
                    icon: "arrow.clockwise",
                    action: {
                        // Reset game and start new game
                        gameManager.resetGame()
                        navigationPath.removeLast(navigationPath.count)
                        navigationPath.append(NavigationDestination.turnStartConfirm)
                    }
                )
            }
            .padding()
            .frame(height: 80)
        }
        .background(DarkBackgroundView(backgroundImage: "WinnerScreenBg"))
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Play victory feedback when winner screen appears
            feedbackManager.gameWonFeedback()
        }
    }
}

// MARK: - Winner Display Section

private struct WinnerDisplaySection: View {
    let winner: Player
    let score: Int
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 24) {
            // Winner Emoji
            Text(winner.emoji)
                .font(.system(size: 120))
                .foregroundColor(Theme.current.accentHighlight)
                .shadow(color: Theme.current.accentHighlight.opacity(0.5), radius: 15)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                .onAppear {
                    isAnimating = true
                }

            // Winner Name
            VStack(spacing: 8) {
                Text(winner.name)
                    .font(Theme.Typography.logo(size: 40))
                    .foregroundColor(Theme.current.textPrimary)
                Text("\(score)")
                    .font(Theme.Typography.heading3(size: 32))
                    .foregroundColor(Theme.current.textSecondary.opacity(0.7))
                    .tracking(2)
            }
        }
        .padding(.top, 80)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Tied Winners Display Section

private struct TiedWinnersDisplaySection: View {
    let winners: [Player]
    let score: Int
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 24) {
            // "It's a Tie!" message
            Text(L.Winner.itsTie)
                .font(Theme.Typography.logo(size: 48))
                .foregroundColor(Theme.current.accentHighlight)
                .tracking(2)
                .padding(.top, 60)

            // All winner emojis in a row
            HStack(spacing: 20) {
                ForEach(Array(winners.enumerated()), id: \.offset) { index, winner in
                    Text(winner.emoji)
                        .font(.system(size: 80))
                        .foregroundColor(Theme.current.accentHighlight)
                        .shadow(color: Theme.current.accentHighlight.opacity(0.5), radius: 15)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
            }
            .onAppear {
                isAnimating = true
            }

            // Winner names
            VStack(spacing: 8) {
                Text(winners.map { $0.name }.joined(separator: " & "))
                    .font(Theme.Typography.logo(size: 32))
                    .foregroundColor(Theme.current.textPrimary)
                    .multilineTextAlignment(.center)
                Text("\(score)")
                    .font(Theme.Typography.heading3(size: 32))
                    .foregroundColor(Theme.current.textSecondary.opacity(0.7))
                    .tracking(2)
            }
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Other Players Section

private struct OtherPlayersSection: View {
    let players: [(Player, Int)]

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                ForEach(Array(players.enumerated()), id: \.offset) { index, playerData in
                    HStack(spacing: 16) {
                        // Rank
                        Text("\(index + 2)")
                            .font(Theme.Typography.heading1(size: 20))
                            .foregroundColor(Theme.current.textSecondary.opacity(0.6))
                            .frame(width: 30)

                        // Emoji
                        Text(playerData.0.emoji)
                            .font(.system(size: 28))

                        // Name
                        Text(playerData.0.name)
                            .font(Theme.Typography.body(size: 18))
                            .foregroundColor(Theme.current.textPrimary)

                        Spacer()

                        // Score
                        Text("\(playerData.1)")
                            .font(Theme.Typography.heading1(size: 20))
                            .foregroundColor(Theme.current.textSecondary.opacity(0.8))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Theme.current.surfacePrimary.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Theme.current.borderPrimary.opacity(0.6), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
}

// MARK: - Action Button

private struct ActionButton: View {
    let title: String
    let icon: String
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
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))

                Text(title)
                    .font(Theme.Typography.heading1(size: 22))
            }
            .foregroundColor(Theme.current.interactivePrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
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

// MARK: - Preview

#Preview("Winner - Close Game") {
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
        WinnerScreen(navigationPath: .constant(NavigationPath()))
    }
}

#Preview("Winner - Dominant Victory") {
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
            lastWordBonusPoints: 10
        )
        manager.startNewGame(players: testPlayers, dictionary: testDict, settings: testSettings)
    }()

    NavigationStack {
        WinnerScreen(navigationPath: .constant(NavigationPath()))
    }
}

#Preview("Winner - 2 Players") {
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
        WinnerScreen(navigationPath: .constant(NavigationPath()))
    }
}
