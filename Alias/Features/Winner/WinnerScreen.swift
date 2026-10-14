import SwiftUI

struct WinnerScreen: View {
    @Environment(AppRouter.self) private var router
    @Environment(GameSession.self) private var session

    var body: some View {
        let winners = session.winners
        let winnerIDs = Set(winners.map(\.id))
        let otherPlayers = session.players.filter { !winnerIDs.contains($0.id) }.sorted { $0.score > $1.score }

        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    if winners.count > 1 {
                        TiedWinnersDisplaySection(winners: winners.map(\.player), score: winners[0].score)
                            .padding(.bottom, 160)
                    } else if let winner = winners.first {
                        WinnerDisplaySection(winner: winner.player, score: winner.score)
                            .padding(.bottom, 160)
                    }

                    OtherPlayersSection(players: otherPlayers, firstRank: winners.count + 1)
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)

            HStack(spacing: 12) {
                RippleButton(title: L.home, systemImage: "house.fill", fontSize: 22, fillsWidth: true) {
                    router.goHome()
                }

                Spacer()

                RippleButton(title: L.again, systemImage: "arrow.clockwise", fontSize: 22, fillsWidth: true) {
                    session.restart()
                    router.startGame()
                }
            }
            .padding()
            .frame(height: 80)
        }
        .background(DarkBackgroundView(backgroundImage: "WinnerScreenBg"))
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { FeedbackService.shared.gameWon() }
    }
}

// MARK: - Winner Display Section

private struct WinnerDisplaySection: View {
    let winner: Player
    let score: Int
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 24) {
            Text(winner.emoji)
                .font(.system(size: 120))
                .foregroundStyle(Theme.current.accentHighlight)
                .shadow(color: Theme.current.accentHighlight.opacity(0.5), radius: 15)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                .onAppear {
                    isAnimating = true
                }

            VStack(spacing: 8) {
                Text(winner.name)
                    .font(Theme.Typography.logo(size: 40))
                    .foregroundStyle(Theme.current.textPrimary)
                Text("\(score)")
                    .font(Theme.Typography.heading3(size: 32))
                    .foregroundStyle(Theme.current.textSecondary.opacity(0.7))
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
            Text(L.Winner.itsTie)
                .font(Theme.Typography.logo(size: 48))
                .foregroundStyle(Theme.current.accentHighlight)
                .tracking(2)
                .padding(.top, 60)

            HStack(spacing: 20) {
                ForEach(Array(winners.enumerated()), id: \.offset) { index, winner in
                    Text(winner.emoji)
                        .font(.system(size: 80))
                        .foregroundStyle(Theme.current.accentHighlight)
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

            VStack(spacing: 8) {
                Text(winners.map(\.name).joined(separator: " & "))
                    .font(Theme.Typography.logo(size: 32))
                    .foregroundStyle(Theme.current.textPrimary)
                    .multilineTextAlignment(.center)
                Text("\(score)")
                    .font(Theme.Typography.heading3(size: 32))
                    .foregroundStyle(Theme.current.textSecondary.opacity(0.7))
                    .tracking(2)
            }
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Other Players Section

private struct OtherPlayersSection: View {
    let players: [GamePlayer]
    let firstRank: Int

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                ForEach(Array(players.enumerated()), id: \.element.id) { index, player in
                    HStack(spacing: 16) {
                        Text("\(firstRank + index)")
                            .font(Theme.Typography.heading1(size: 20))
                            .foregroundStyle(Theme.current.textSecondary.opacity(0.6))
                            .frame(width: 30)

                        Text(player.emoji)
                            .font(.system(size: 28))

                        Text(player.name)
                            .font(Theme.Typography.body(size: 18))
                            .foregroundStyle(Theme.current.textPrimary)

                        Spacer()

                        Text("\(player.score)")
                            .font(Theme.Typography.heading1(size: 20))
                            .foregroundStyle(Theme.current.textSecondary.opacity(0.8))
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

// MARK: - Preview

#Preview {
    NavigationStack {
        WinnerScreen()
    }
    .previewEnvironment(session: .preview(turnsPlayed: 6))
}
