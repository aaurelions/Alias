import SwiftUI

struct TurnResultView: View {
    let count: Int

    var body: some View {
        if count != 0 {
            Text(count > 0 ? "+\(count)" : "\(count)")
                .font(Theme.Typography.body(size: 12))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(count > 0 ? Color.green : Theme.current.accentDestructive)
                .clipShape(Capsule())
                .fixedSize()
        }
    }
}

// MARK: - Turn Results Screen

struct TurnResultsScreen: View {
    @Binding var navigationPath: NavigationPath
    @Environment(\.dismiss) var dismiss
    @StateObject private var gameManager = GameManager.shared

    @State private var wordResults: [WordResult] = []
    @State private var isTotalScoresRevealed = false
    @State private var showLastWordBonus = false
    @State private var lastWordBonusPlayerId: UUID? = nil
    @State private var hasAppliedScores = false
    @State private var hasInitializedFromTurn = false
    @State private var initialWordResultsSnapshot: [WordResult] = []

    private var turnNumber: Int {
        // Get the current turn number within the round (not total historical turns)
        gameManager.currentTurnInRound
    }

    private var totalTurns: Int {
        gameManager.getTotalTurnsInRound()
    }

    private var pointsToWin: Int {
        gameManager.settings.selectedPointsToWin
    }

    private var lastWordBonusEnabled: Bool {
        gameManager.settings.lastWordBonusEnabled
    }

    private var lastWordBonusPoints: Int {
        gameManager.settings.lastWordBonusPoints
    }

    private var turnsPerRound: Int {
        gameManager.getTotalTurnsInRound()
    }

    private var currentExplainer: GamePlayer? {
        guard let turn = gameManager.getLastTurn() else { return nil }
        return gameManager.players.first { $0.id == turn.explainerId }
    }

    private var currentGuesser: GamePlayer? {
        guard let turn = gameManager.getLastTurn() else { return nil }
        return gameManager.players.first { $0.id == turn.guesserId }
    }

    // Calculate turn points dynamically based on current word results
    private var explainerTurnPoints: Int {
        let guessedCount = wordResults.filter { $0.isGuessed }.count
        // Exclude bonus words that were skipped from penalty calculation
        let skippedCount = wordResults.filter { !$0.isGuessed && !$0.isBonusWord }.count
        return guessedCount * gameManager.settings.explainerPoints + skippedCount * gameManager.settings.explainerPenalty
    }

    private var guesserTurnPoints: Int {
        let guessedCount = wordResults.filter { $0.isGuessed }.count
        // Exclude bonus words that were skipped from penalty calculation
        let skippedCount = wordResults.filter { !$0.isGuessed && !$0.isBonusWord }.count
        return guessedCount * gameManager.settings.guesserPoints + skippedCount * gameManager.settings.guesserPenalty
    }

    private var bonusTurnPoints: Int {
        return lastWordBonusPlayerId != nil ? gameManager.settings.lastWordBonusPoints : 0
    }

    private var eligibleBonusPlayers: [Player] {
        // IMPORTANT: Exclude ONLY the explainer from bonus selection
        // All other players (including the guesser) can receive the bonus
        let explainerId = currentExplainer?.id
        return gameManager.players.filter { $0.id != explainerId }.map { $0.toPlayer() }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        // Header without side buttons
                        NavigationHeader(
                            title: L.TurnResults.turnOf(turnNumber, totalTurns),
                            leftAction: .none,
                            rightAction: .none
                        )
                        .padding(.bottom, 15)

                        // Words List Section
                        WordsListSection(
                            wordResults: $wordResults,
                            guesserPoints: gameManager.settings.guesserPoints,
                            explainerPoints: gameManager.settings.explainerPoints,
                            guesserPenalty: gameManager.settings.guesserPenalty,
                            explainerPenalty: gameManager.settings.explainerPenalty,
                            onWordToggle: handleWordToggle
                        )
                        .padding(.bottom, 24)

                        // Total Scores Section (Blurred)
                        TotalScoresSection(
                            explainer: currentExplainer,
                            guesser: currentGuesser,
                            players: gameManager.players,
                            explainerTurnPoints: explainerTurnPoints,
                            guesserTurnPoints: guesserTurnPoints,
                            bonusPlayerId: lastWordBonusPlayerId,
                            bonusTurnPoints: bonusTurnPoints,
                            isRevealed: $isTotalScoresRevealed
                        )
                    }
                    .padding(.horizontal)
                }
                .scrollIndicators(.hidden)
                .blur(radius: showLastWordBonus ? 10 : 0)
                .disabled(showLastWordBonus)

                Spacer()

                // Continue Button (Always at bottom)
                HStack(spacing: 12) {
                    ContinueButton(action: {
                        continueGame()
                    })
                }
                .padding(.horizontal)
                .padding(.vertical)
                .frame(height: 80)
                .blur(radius: showLastWordBonus ? 10 : 0)
                .disabled(showLastWordBonus)
            }
            .background(DarkBackgroundView(backgroundImage: "TurnResultsScreenBg"))

            // Last Word Bonus Sheet
            if showLastWordBonus {
                LastWordBonusSheet(
                    isPresented: $showLastWordBonus,
                    players: eligibleBonusPlayers,
                    bonusPoints: lastWordBonusPoints,
                    onPlayerSelected: { player in
                        handleBonusPlayerSelected(player)
                    }
                )
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Only initialize once to prevent duplicate score application on navigation back/forth
            guard !hasInitializedFromTurn else { return }

            // Load word results from the last turn
            if let lastTurn = gameManager.getLastTurn() {
                wordResults = lastTurn.wordResults
                lastWordBonusPlayerId = lastTurn.bonusPlayerId
                initialWordResultsSnapshot = lastTurn.wordResults
                hasInitializedFromTurn = true
            }
        }
    }

    private func handleWordToggle(index: Int) {
        let wasLastWordSkipped = !wordResults[index].isGuessed
        let isLastWord = index == wordResults.count - 1
        let isLastWordBonus = wordResults[index].isBonusWord

        // Toggle the word state
        wordResults[index].isGuessed.toggle()

        // IMPORTANT: Only show bonus sheet if:
        // 1. It's the last word
        // 2. The word was skipped and is now being marked as guessed
        // 3. The word is marked as a bonus word
        // 4. The Last Word Bonus feature is ENABLED in settings
        // 5. There is at least one eligible player. The guesser is eligible; only the explainer is excluded.
        if isLastWord && wasLastWordSkipped && wordResults[index].isGuessed &&
           isLastWordBonus && lastWordBonusEnabled && !eligibleBonusPlayers.isEmpty {
            showLastWordBonus = true
        } else if isLastWord && !wordResults[index].isGuessed {
            // If last word changed from guessed to skipped, remove bonus
            lastWordBonusPlayerId = nil
            updateGameManager()
        } else {
            updateGameManager()
        }
    }

    private func handleBonusPlayerSelected(_ player: Player) {
        lastWordBonusPlayerId = player.id
        showLastWordBonus = false
        updateGameManager()
    }

    private func updateGameManager() {
        // Only update if word results have actually changed from initial state
        // This prevents redundant recalculations when navigating back and forth
        let hasChanges = wordResults != initialWordResultsSnapshot ||
                        lastWordBonusPlayerId != gameManager.getLastTurn()?.bonusPlayerId

        if hasChanges {
            // Update the game manager with the modified word results
            gameManager.updateLastTurn(wordResults: wordResults, bonusPlayerId: lastWordBonusPlayerId)
            // Update snapshot to reflect current state
            initialWordResultsSnapshot = wordResults
        }
    }

    private func continueGame() {
        updateGameManager()

        // Check if current round is complete
        if gameManager.isRoundComplete() {
            // Check if anyone has won (including ties)
            // Use winners (plural) to handle both single winner and tie scenarios
            if !gameManager.winners.isEmpty {
                // Navigate to winner screen (handles both single winner and ties)
                replaceCurrentScreen(with: .winner)
            } else {
                // No winner yet - start next round
                gameManager.startNewRound()
                replaceCurrentScreen(with: .turnStartConfirm)
            }
        } else {
            // Continue to next turn in current round
            gameManager.advanceToNextTurn()
            replaceCurrentScreen(with: .turnStartConfirm)
        }
    }

    private func replaceCurrentScreen(with destination: NavigationDestination) {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
        navigationPath.append(destination)
    }
}

// MARK: - Words List Section

private struct WordsListSection: View {
    @Binding var wordResults: [WordResult]
    let guesserPoints: Int
    let explainerPoints: Int
    let guesserPenalty: Int
    let explainerPenalty: Int
    let onWordToggle: (Int) -> Void

    // 1. Define the columns for the grid
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(L.TurnResults.words)
                    .font(Theme.Typography.heading1(size: 20))
                    .foregroundColor(Theme.current.textSecondary.opacity(0.8))

                Spacer()

                Text(L.TurnResults.guessedSkipped(guessedCount, skippedCount))
                    .font(Theme.Typography.bodySmall(size: 14))
                    .foregroundColor(Theme.current.textSecondary.opacity(0.6))
            }

            // 2. Use LazyVGrid to create the two-column layout
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(wordResults.enumerated()), id: \.element.id) { index, result in
                    WordResultRow(
                        wordResult: result,
                        onToggle: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                onWordToggle(index)
                            }
                        }
                    )
                }
            }
        }
    }

    private var guessedCount: Int {
        wordResults.filter { $0.isGuessed }.count
    }

    private var skippedCount: Int {
        wordResults.filter { !$0.isGuessed }.count
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
                    .foregroundColor(wordResult.isGuessed ? Theme.current.accentSuccess : Theme.current.accentDestructive)

                Text(wordResult.word)
                    .font(Theme.Typography.body(size: 16))
                    .foregroundColor(Theme.current.textPrimary)
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
    let explainer: GamePlayer?
    let guesser: GamePlayer?
    let players: [GamePlayer]
    let explainerTurnPoints: Int
    let guesserTurnPoints: Int
    let bonusPlayerId: UUID?
    let bonusTurnPoints: Int
    @Binding var isRevealed: Bool

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: isRevealed ? "eye.fill" : "eye.slash.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Theme.current.textSecondary.opacity(0.8))

                Text(L.TurnResults.totalScores)
                    .font(Theme.Typography.heading1(size: 20))
                    .foregroundColor(Theme.current.textSecondary.opacity(0.8))

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.current.textSecondary.opacity(0.6))
                    .rotationEffect(.degrees(isRevealed ? 180 : 0))
            }

            ZStack {
                VStack(spacing: 12) {
                    ForEach(players.sorted(by: { $0.score > $1.score })) { player in
                        HStack(spacing: 16) {
                            Text(player.emoji)
                                .font(.system(size: 28))

                            Text(player.name)
                                .font(Theme.Typography.body(size: 18))
                                .foregroundColor(Theme.current.textPrimary)

                            Spacer()

                            Text("\(player.score)")
                                .font(Theme.Typography.heading1(size: 22))
                                .foregroundColor(Theme.current.textPrimary)
                                .overlay(alignment: .topTrailing) {
                                    TurnResultView(count: getTurnPoints(for: player))
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
                        .foregroundColor(Theme.current.textSecondary.opacity(0.8))
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

    private func getTurnPoints(for player: GamePlayer) -> Int {
        var points = 0

        if player.id == explainer?.id {
            points += explainerTurnPoints
        }

        if player.id == guesser?.id {
            points += guesserTurnPoints
        }

        if player.id == bonusPlayerId {
            points += bonusTurnPoints
        }

        return points
    }
}

// MARK: - Last Word Bonus Sheet

private struct LastWordBonusSheet: View {
    @Binding var isPresented: Bool
    let players: [Player]
    let bonusPoints: Int
    let onPlayerSelected: (Player) -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    // Title
                    VStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Theme.current.accentHighlight)

                        Text(L.Gameplay.lastWordBonus)
                            .font(Theme.Typography.heading1(size: 28))
                            .foregroundColor(Theme.current.textPrimary)

                        Text(L.Gameplay.whoGetsPoints(bonusPoints))
                            .font(Theme.Typography.body(size: 16))
                            .foregroundColor(Theme.current.textSecondary)
                    }
                    .padding(.top, 30)

                    // Players List
                    VStack(spacing: 12) {
                        ForEach(players, id: \.name) { player in
                            Button(action: {
                                onPlayerSelected(player)
                            }) {
                                HStack(spacing: 16) {
                                    Text(player.emoji)
                                        .font(.system(size: 32))

                                    Text(player.name)
                                        .font(Theme.Typography.body(size: 20))
                                        .foregroundColor(Theme.current.textPrimary)

                                    Spacer()

                                    Text("+\(bonusPoints)")
                                        .font(Theme.Typography.heading1(size: 20))
                                        .foregroundColor(Theme.current.accentHighlight)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Theme.current.surfacePrimary.opacity(0.3))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Theme.current.borderPrimary.opacity(0.6), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Theme.current.borderPrimary.opacity(0.6), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Continue Button

private struct ContinueButton: View {
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
            Text(L.continue)
                .font(Theme.Typography.heading1(size: 28))
                .foregroundColor(Theme.current.interactivePrimary)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .accessibilityLabel(L.Accessibility.next)
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

#Preview("Turn Results - Mixed Words") {
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

        // Simulate a completed turn with mixed results
        manager.recordWord("Apple", isGuessed: true)
        manager.recordWord("Banana", isGuessed: false)
        manager.recordWord("Cherry", isGuessed: true)
        manager.recordWord("Dragon", isGuessed: true)
        manager.recordWord("Elephant", isGuessed: false)
        manager.recordWord("Forest", isGuessed: true, isBonusWord: true)
        manager.completeTurn(bonusPlayerId: testPlayers[2].id)
    }()

    NavigationStack {
        TurnResultsScreen(navigationPath: .constant(NavigationPath()))
    }
}

#Preview("Turn Results - All Guessed") {
    let _ = {
        let manager = GameManager.shared
        let testPlayers = [
            Player(emoji: "🦄", name: "Unicorn"),
            Player(emoji: "🐉", name: "Dragon")
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

        // Perfect turn - all words guessed
        manager.recordWord("Cat", isGuessed: true)
        manager.recordWord("Dog", isGuessed: true)
        manager.recordWord("Bird", isGuessed: true)
        manager.recordWord("Fish", isGuessed: true)
        manager.completeTurn(bonusPlayerId: nil)
    }()

    NavigationStack {
        TurnResultsScreen(navigationPath: .constant(NavigationPath()))
    }
}

#Preview("Turn Results - With Penalties") {
    let _ = {
        let manager = GameManager.shared
        let testPlayers = [
            Player(emoji: "🎮", name: "Gamer"),
            Player(emoji: "🎨", name: "Artist"),
            Player(emoji: "🎭", name: "Actor")
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

        // Tough turn with many skips
        manager.recordWord("Photosynthesis", isGuessed: false)
        manager.recordWord("Quantum", isGuessed: false)
        manager.recordWord("Tree", isGuessed: true)
        manager.recordWord("Mountain", isGuessed: false)
        manager.recordWord("Ocean", isGuessed: true)
        manager.recordWord("Philosophy", isGuessed: false, isBonusWord: true)
        manager.completeTurn(bonusPlayerId: nil)
    }()

    NavigationStack {
        TurnResultsScreen(navigationPath: .constant(NavigationPath()))
    }
}
