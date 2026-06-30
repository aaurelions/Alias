import Foundation
import Combine

/// Central game state manager that orchestrates the entire game lifecycle
@MainActor
class GameManager: ObservableObject {
    // MARK: - Published Properties

    @Published private(set) var players: [GamePlayer] = []
    @Published private(set) var settings: GameSettings = GameSettings()
    @Published private(set) var turnHistory: [Turn] = []
    @Published private(set) var currentRound: Int = 1
    @Published private(set) var currentTurnInRound: Int = 0
    @Published private(set) var turnQueue: [PlayerPairing] = []
    @Published private(set) var usedWords: Set<String> = []
    @Published private(set) var selectedDictionary: WordDictionary?

    // Current turn state
    @Published private(set) var currentPairing: PlayerPairing?
    @Published private(set) var currentTurnWords: [WordResult] = []

    // MARK: - Computed Properties

    var currentExplainer: GamePlayer? {
        guard let pairing = currentPairing else { return nil }
        return players.first { $0.id == pairing.explainerId }
    }

    var currentGuesser: GamePlayer? {
        guard let pairing = currentPairing else { return nil }
        return players.first { $0.id == pairing.guesserId }
    }

    var turnsPerRound: Int {
        players.count * (players.count - 1)
    }

    var totalTurnsPlayed: Int {
        turnHistory.count
    }

    var winner: GamePlayer? {
        guard isRoundComplete(), let maxScore = players.map({ $0.score }).max() else { return nil }
        if maxScore >= settings.selectedPointsToWin {
            return players.first { $0.score == maxScore }
        }
        return nil
    }

    /// Returns all winners in case of a tie
    var winners: [GamePlayer] {
        guard isRoundComplete(), let maxScore = players.map({ $0.score }).max() else { return [] }
        if maxScore >= settings.selectedPointsToWin {
            return players.filter { $0.score == maxScore }
        }
        return []
    }

    // MARK: - Singleton

    static let shared = GameManager()

    private init() {}

    // MARK: - Game Initialization

    /// Starts a new game with the given players, dictionary, and settings
    func startNewGame(
        players: [Player],
        dictionary: WordDictionary,
        settings: GameSettings
    ) {
        guard players.count >= 2 else { return }

        // Reset all state
        self.turnHistory = []
        self.currentRound = 1
        self.currentTurnInRound = 0
        self.turnQueue = []
        self.usedWords = []
        self.currentPairing = nil
        self.currentTurnWords = []
        self.settings = settings
        self.selectedDictionary = dictionary

        // Load and distribute words
        let allWords = loadDictionaryWords(dictionary: dictionary)
        let gamePlayers = distributeWords(to: players, from: allWords)
        self.players = gamePlayers

        // Generate first round's turn queue
        generateRoundQueue()

        // Set up first turn
        advanceToNextTurn()
    }

    /// Resets the game with the same players and settings but new scores
    func resetGame() {
        guard let dictionary = selectedDictionary else { return }

        // Keep player names and emojis, reset scores and word pools
        let playerTemplates = players.map { Player(emoji: $0.emoji, name: $0.name) }

        // Restart the game
        startNewGame(players: playerTemplates, dictionary: dictionary, settings: settings)
    }

    // MARK: - Turn Management

    /// Advances to the next turn in the queue
    func advanceToNextTurn() {
        if currentTurnInRound >= turnQueue.count {
            // End of round - don't increment round here, it will be handled by caller
            // Just generate new queue for the next round
            generateRoundQueue()
            currentTurnInRound = 0
        }

        if currentTurnInRound < turnQueue.count {
            currentPairing = turnQueue[currentTurnInRound]
            currentTurnWords = []
        }
    }

    /// Starts a new round (called from TurnResultsScreen after checking winner)
    func startNewRound() {
        currentRound += 1
        generateRoundQueue()
        currentTurnInRound = 0

        // Update current pairing for the first turn of new round
        if !turnQueue.isEmpty {
            currentPairing = turnQueue[currentTurnInRound]
            currentTurnWords = []
        }
    }

    /// Gets the next word for the current guesser
    func getNextWord() -> String? {
        guard !isRoundComplete() else { return nil }
        guard let guesser = currentGuesser else { return nil }
        guard let playerIndex = players.firstIndex(where: { $0.id == guesser.id }) else { return nil }

        // Check if guesser's pool is empty
        if players[playerIndex].wordPool.isEmpty {
            // Try to replenish from unused words in the dictionary
            if let dictionary = selectedDictionary {
                replenishWordPool(for: playerIndex, from: dictionary)
            }
        }

        // Get word from guesser's pool (may still be empty after replenishment)
        guard !players[playerIndex].wordPool.isEmpty else { return nil }

        let word = players[playerIndex].wordPool.removeFirst()
        usedWords.insert(word.lowercased())

        return word
    }

    /// Replenishes a player's word pool from unused dictionary words
    private func replenishWordPool(for playerIndex: Int, from dictionary: WordDictionary) {
        // Load all words from dictionary
        let allDictionaryWords = loadDictionaryWords(dictionary: dictionary)

        // Filter out words that have already been used
        let unusedWords = allDictionaryWords.filter { word in
            !usedWords.contains(word.lowercased())
        }

        // If there are unused words, assign them to this player
        if !unusedWords.isEmpty {
            // Shuffle and assign to player
            let shuffledUnusedWords = unusedWords.shuffled()
            players[playerIndex].wordPool = shuffledUnusedWords
        }
    }

    /// Records a word action (guessed or skipped)
    func recordWord(_ word: String, isGuessed: Bool, isBonusWord: Bool = false) {
        let wordResult = WordResult(word: word, isGuessed: isGuessed, isBonusWord: isBonusWord)
        currentTurnWords.append(wordResult)
    }

    /// Completes the current turn and calculates scores
    func completeTurn(bonusPlayerId: UUID? = nil) {
        guard let pairing = currentPairing else { return }
        guard currentTurnInRound < turnQueue.count else { return }

        // Calculate points based on word results
        // Exclude bonus words that were skipped from penalty calculation
        let guessedCount = currentTurnWords.filter { $0.isGuessed }.count
        let skippedCount = currentTurnWords.filter { !$0.isGuessed && !$0.isBonusWord }.count

        let explainerPoints = guessedCount * settings.explainerPoints + skippedCount * settings.explainerPenalty
        let guesserPoints = guessedCount * settings.guesserPoints + skippedCount * settings.guesserPenalty
        let bonusPoints = bonusPlayerId != nil ? settings.lastWordBonusPoints : 0

        // Create turn record
        let turn = Turn(
            roundNumber: currentRound,
            turnNumberInRound: currentTurnInRound + 1,
            explainerId: pairing.explainerId,
            guesserId: pairing.guesserId,
            wordResults: currentTurnWords,
            bonusPlayerId: bonusPlayerId,
            explainerPoints: explainerPoints,
            guesserPoints: guesserPoints,
            bonusPoints: bonusPoints
        )

        turnHistory.append(turn)

        // Update player scores
        if let explainerIndex = players.firstIndex(where: { $0.id == pairing.explainerId }) {
            players[explainerIndex].score += explainerPoints
        }

        if let guesserIndex = players.firstIndex(where: { $0.id == pairing.guesserId }) {
            players[guesserIndex].score += guesserPoints
        }

        if let bonusId = bonusPlayerId,
           let bonusIndex = players.firstIndex(where: { $0.id == bonusId }) {
            players[bonusIndex].score += bonusPoints
        }

        // Move to next turn
        currentTurnInRound += 1
    }

    /// Updates the most recent turn with new word results (for the review screen)
    func updateLastTurn(wordResults: [WordResult], bonusPlayerId: UUID?) {
        guard let lastIndex = turnHistory.indices.last else { return }

        let oldTurn = turnHistory[lastIndex]

        // Recalculate points
        // Exclude bonus words that were skipped from penalty calculation
        let guessedCount = wordResults.filter { $0.isGuessed }.count
        let skippedCount = wordResults.filter { !$0.isGuessed && !$0.isBonusWord }.count

        let newExplainerPoints = guessedCount * settings.explainerPoints + skippedCount * settings.explainerPenalty
        let newGuesserPoints = guessedCount * settings.guesserPoints + skippedCount * settings.guesserPenalty
        let newBonusPoints = bonusPlayerId != nil ? settings.lastWordBonusPoints : 0

        // Calculate deltas
        let explainerDelta = newExplainerPoints - oldTurn.explainerPoints
        let guesserDelta = newGuesserPoints - oldTurn.guesserPoints

        // Handle bonus player changes
        var bonusDelta = 0
        if oldTurn.bonusPlayerId != bonusPlayerId {
            // Remove old bonus
            if let oldBonusId = oldTurn.bonusPlayerId,
               let oldBonusIndex = players.firstIndex(where: { $0.id == oldBonusId }) {
                players[oldBonusIndex].score -= oldTurn.bonusPoints
            }
            // Add new bonus
            bonusDelta = newBonusPoints
        } else if oldTurn.bonusPlayerId == bonusPlayerId && bonusPlayerId != nil {
            bonusDelta = newBonusPoints - oldTurn.bonusPoints
        }

        // Update player scores
        if let explainerIndex = players.firstIndex(where: { $0.id == oldTurn.explainerId }) {
            players[explainerIndex].score += explainerDelta
        }

        if let guesserIndex = players.firstIndex(where: { $0.id == oldTurn.guesserId }) {
            players[guesserIndex].score += guesserDelta
        }

        if let bonusId = bonusPlayerId,
           let bonusIndex = players.firstIndex(where: { $0.id == bonusId }) {
            players[bonusIndex].score += bonusDelta
        }

        // Update turn record
        turnHistory[lastIndex] = Turn(
            id: oldTurn.id,
            roundNumber: oldTurn.roundNumber,
            turnNumberInRound: oldTurn.turnNumberInRound,
            explainerId: oldTurn.explainerId,
            guesserId: oldTurn.guesserId,
            wordResults: wordResults,
            bonusPlayerId: bonusPlayerId,
            explainerPoints: newExplainerPoints,
            guesserPoints: newGuesserPoints,
            bonusPoints: newBonusPoints
        )
    }

    // MARK: - Round Queue Generation

    /// Generates all possible player pairings and shuffles them intelligently
    private func generateRoundQueue() {
        var pairings: [PlayerPairing] = []

        // Generate all unique explainer-guesser combinations
        for explainer in players {
            for guesser in players where guesser.id != explainer.id {
                pairings.append(PlayerPairing(explainerId: explainer.id, guesserId: guesser.id))
            }
        }

        // Smart shuffle to avoid consecutive same roles
        turnQueue = smartShuffle(pairings)
    }

    /// Intelligently shuffles pairings to minimize consecutive same roles for players
    private func smartShuffle(_ pairings: [PlayerPairing]) -> [PlayerPairing] {
        var bestShuffle = pairings.shuffled()
        var bestScore = calculateShuffleScore(bestShuffle)

        // Try multiple shuffles and pick the best one
        for _ in 0..<20 {
            let candidate = pairings.shuffled()
            let score = calculateShuffleScore(candidate)

            if score > bestScore {
                bestScore = score
                bestShuffle = candidate
            }
        }

        return bestShuffle
    }

    /// Calculates a score for a shuffle based on role variety
    private func calculateShuffleScore(_ pairings: [PlayerPairing]) -> Int {
        var score = 0
        var lastRoles: [UUID: String] = [:] // playerId -> "explainer" or "guesser"

        for pairing in pairings {
            // Check explainer
            if let lastRole = lastRoles[pairing.explainerId], lastRole != "explainer" {
                score += 1 // Role changed
            }
            lastRoles[pairing.explainerId] = "explainer"

            // Check guesser
            if let lastRole = lastRoles[pairing.guesserId], lastRole != "guesser" {
                score += 1 // Role changed
            }
            lastRoles[pairing.guesserId] = "guesser"
        }

        return score
    }

    // MARK: - Word Management

    /// Loads words from a dictionary
    private func loadDictionaryWords(dictionary: WordDictionary) -> [String] {
        return WordManager.loadWords(from: dictionary)
    }

    /// Distributes words evenly among players
    private func distributeWords(to players: [Player], from allWords: [String]) -> [GamePlayer] {
        let playerPools = WordManager.distributeWords(allWords, playerCount: players.count)

        var gamePlayers: [GamePlayer] = []
        for (index, player) in players.enumerated() {
            let wordPool = index < playerPools.count ? playerPools[index] : []
            gamePlayers.append(GamePlayer(from: player, wordPool: wordPool))
        }

        return gamePlayers
    }

    // MARK: - Helper Methods

    /// Checks if the current round has ended
    func isRoundComplete() -> Bool {
        return currentTurnInRound >= turnsPerRound
    }

    /// Gets the total number of turns in the current round
    func getTotalTurnsInRound() -> Int {
        return turnsPerRound
    }

    /// Gets the most recent turn
    func getLastTurn() -> Turn? {
        return turnHistory.last
    }

    /// Rewinds to the previous turn (used when going back from TurnStartConfirmScreen)
    /// Only available if we haven't started the current turn yet
    /// NOTE: Does not support rewinding across round boundaries to prevent state corruption
    func rewindToPreviousTurn() {
        // Only allow rewinding if current turn hasn't been played yet
        // (i.e., currentTurnWords is empty)
        guard currentTurnWords.isEmpty else { return }

        // Only allow rewinding within the current round (not across round boundaries)
        // This prevents state corruption from regenerating shuffled queues
        guard currentTurnInRound > 0 else { return }

        // Decrement turn counter within the current round
        currentTurnInRound -= 1

        // Update current pairing
        if currentTurnInRound < turnQueue.count {
            currentPairing = turnQueue[currentTurnInRound]
        }
    }

    /// Checks if we can rewind (only within current round)
    func canRewind() -> Bool {
        return currentTurnInRound > 0 && currentTurnWords.isEmpty
    }
}
