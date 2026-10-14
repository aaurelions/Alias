import SwiftUI

struct TurnResultsScreen: View {
    @Environment(AppRouter.self) private var router
    @Environment(GameSession.self) private var session
    @State private var isTotalScoresRevealed = false
    @State private var resultsAwaitingBonusPlayer: [WordResult]?

    private var bonusCandidates: [Player] {
        guard let explainerID = session.lastTurn?.pairing.explainerID else { return [] }
        return session.players.filter { $0.id != explainerID }.map(\.player)
    }

    var body: some View {
        ZStack {
            if let turn = session.lastTurn {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 0) {
                            NavigationHeader(
                                title: L.TurnResults.turnOf(turn.numberInRound, session.turnsPerRound),
                                leftAction: .none,
                                rightAction: .none
                            )
                            .padding(.bottom, 15)

                            WordsListSection(wordResults: turn.wordResults) { result in
                                withAnimation(.easeInOut(duration: 0.2)) { toggle(result, in: turn) }
                            }
                            .padding(.bottom, 24)

                            TotalScoresSection(players: session.players, turn: turn, isRevealed: $isTotalScoresRevealed)
                        }
                        .padding(.horizontal)
                    }
                    .scrollIndicators(.hidden)

                    RippleButton(title: L.continue, action: continueGame)
                        .accessibilityLabel(L.Accessibility.next)
                        .padding()
                        .frame(height: 80)
                }
                .blur(radius: resultsAwaitingBonusPlayer == nil ? 0 : 10)
                .disabled(resultsAwaitingBonusPlayer != nil)
            }

            if let results = resultsAwaitingBonusPlayer {
                LastWordBonusSheet(players: bonusCandidates, bonusPoints: session.settings.lastWordBonusPoints) { player in
                    session.reviseLastTurn(wordResults: results, bonusPlayerID: player.id)
                    resultsAwaitingBonusPlayer = nil
                }
            }
        }
        .background(DarkBackgroundView(backgroundImage: "TurnResultsScreenBg"))
        .toolbar(.hidden, for: .navigationBar)
    }

    /// Flips a word between guessed and skipped. Marking the last word as guessed asks who earned the bonus.
    private func toggle(_ result: WordResult, in turn: Turn) {
        guard let index = turn.wordResults.firstIndex(where: { $0.id == result.id }) else { return }
        var results = turn.wordResults
        results[index].isGuessed.toggle()

        var bonusPlayerID = turn.bonusPlayerID
        if results[index].isLastWord {
            if results[index].isGuessed && session.settings.lastWordBonusEnabled && !bonusCandidates.isEmpty {
                resultsAwaitingBonusPlayer = results
                return
            }
            bonusPlayerID = nil
        }
        session.reviseLastTurn(wordResults: results, bonusPlayerID: bonusPlayerID)
    }

    private func continueGame() {
        if session.isGameOver {
            router.show(.winner)
        } else {
            session.beginNextTurn()
            router.show(.turnStart)
        }
    }
}

// MARK: - Words List Section

private struct WordsListSection: View {
    let wordResults: [WordResult]
    let onToggle: (WordResult) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(L.TurnResults.words)
                    .font(Theme.Typography.heading1(size: 20))
                    .foregroundStyle(Theme.current.textSecondary.opacity(0.8))

                Spacer()

                Text(L.TurnResults.guessedSkipped(guessedCount, wordResults.count - guessedCount))
                    .font(Theme.Typography.bodySmall(size: 14))
                    .foregroundStyle(Theme.current.textSecondary.opacity(0.6))
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(wordResults) { result in
                    WordResultRow(wordResult: result) { onToggle(result) }
                }
            }
        }
    }

    private var guessedCount: Int {
        wordResults.count { $0.isGuessed }
    }
}

// MARK: - Word Result Row

private struct WordResultRow: View {
    let wordResult: WordResult
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: wordResult.isGuessed ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(wordResult.isGuessed ? Theme.current.accentSuccess : Theme.current.accentDestructive)

                Text(wordResult.word)
                    .font(Theme.Typography.body(size: 16))
                    .foregroundStyle(Theme.current.textPrimary)
                    .strikethrough(!wordResult.isGuessed, color: Theme.current.accentDestructive)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(wordResult.isGuessed
                        ? Theme.current.accentSuccess.opacity(0.1)
                        : Theme.current.accentDestructive.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(wordResult.isGuessed
                                ? Theme.current.accentSuccess.opacity(0.3)
                                : Theme.current.accentDestructive.opacity(0.3),
                                lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Total Scores Section

private struct TotalScoresSection: View {
    let players: [GamePlayer]
    let turn: Turn
    @Binding var isRevealed: Bool

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: isRevealed ? "eye.fill" : "eye.slash.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Theme.current.textSecondary.opacity(0.8))

                Text(L.TurnResults.totalScores)
                    .font(Theme.Typography.heading1(size: 20))
                    .foregroundStyle(Theme.current.textSecondary.opacity(0.8))

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.current.textSecondary.opacity(0.6))
                    .rotationEffect(.degrees(isRevealed ? 180 : 0))
            }

            ZStack {
                VStack(spacing: 12) {
                    ForEach(players.sorted { $0.score > $1.score }) { player in
                        HStack(spacing: 16) {
                            Text(player.emoji)
                                .font(.system(size: 28))

                            Text(player.name)
                                .font(Theme.Typography.body(size: 18))
                                .foregroundStyle(Theme.current.textPrimary)

                            Spacer()

                            Text("\(player.score)")
                                .font(Theme.Typography.heading1(size: 22))
                                .foregroundStyle(Theme.current.textPrimary)
                                .overlay(alignment: .topTrailing) {
                                    PointsDeltaBadge(points: turnPoints(for: player.id))
                                        .offset(x: 14, y: -14)
                                }
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
                .blur(radius: isRevealed ? 0 : 10)

                if !isRevealed {
                    Text(L.TurnResults.tapToReveal)
                        .font(Theme.Typography.body(size: 16))
                        .foregroundStyle(Theme.current.textSecondary.opacity(0.8))
                        .allowsHitTesting(false)
                }
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isRevealed.toggle()
                }
            }
        }
    }

    private func turnPoints(for playerID: UUID) -> Int {
        var points = 0
        if playerID == turn.pairing.explainerID { points += turn.score.explainer }
        if playerID == turn.pairing.guesserID { points += turn.score.guesser }
        if playerID == turn.bonusPlayerID { points += turn.score.bonus }
        return points
    }
}

// MARK: - Points Delta Badge

private struct PointsDeltaBadge: View {
    let points: Int

    var body: some View {
        if points != 0 {
            Text(points > 0 ? "+\(points)" : "\(points)")
                .font(Theme.Typography.body(size: 12))
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(points > 0 ? Theme.current.accentSuccess : Theme.current.accentDestructive, in: .capsule)
                .fixedSize()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TurnResultsScreen()
    }
    .previewEnvironment(session: .preview(turnsPlayed: 1))
}
