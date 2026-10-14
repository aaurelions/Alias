import Foundation
import Observation

/// Owns the state of a running game: players, scores, the turn order and the words played.
///
/// A turn moves through `beginNextTurn()` → `nextWord()`/`record(...)` → `completeTurn(...)`,
/// after which `reviseLastTurn(...)` may adjust the results and `returnToLastTurn()` undoes `beginNextTurn()`.
@Observable
final class GameSession {
    private struct Cursor {
        var round: Int
        var turnIndex: Int
        var queue: [PlayerPairing]
    }

    private(set) var players: [GamePlayer] = []
    private(set) var settings = GameSettings()
    private(set) var dictionary: WordDictionary?
    private(set) var turnHistory: [Turn] = []
    private(set) var currentTurnWords: [WordResult] = []
    private var cursor = Cursor(round: 1, turnIndex: 0, queue: [])
    private var cursorBeforeNextTurn: Cursor?
    private var usedWordKeys = Set<String>()

    var currentRound: Int { cursor.round }
    var turnNumberInRound: Int { cursor.turnIndex + 1 }
    var turnsPerRound: Int { cursor.queue.count }
    var lastTurn: Turn? { turnHistory.last }
    var isRoundComplete: Bool { !cursor.queue.isEmpty && cursor.turnIndex >= cursor.queue.count }
    var canReturnToLastTurn: Bool { cursorBeforeNextTurn != nil && currentTurnWords.isEmpty }

    var currentPairing: PlayerPairing? {
        cursor.queue.indices.contains(cursor.turnIndex) ? cursor.queue[cursor.turnIndex] : nil
    }

    var currentExplainer: GamePlayer? { currentPairing.flatMap { player(id: $0.explainerID) } }
    var currentGuesser: GamePlayer? { currentPairing.flatMap { player(id: $0.guesserID) } }

    /// Players sharing the highest score once a round is complete and that score reaches the target.
    var winners: [GamePlayer] {
        guard isRoundComplete, let topScore = players.map(\.score).max(), topScore >= settings.pointsToWin else {
            return []
        }
        return players.filter { $0.score == topScore }
    }

    var isGameOver: Bool { !winners.isEmpty }

    func player(id: UUID) -> GamePlayer? {
        players.first { $0.id == id }
    }

    // MARK: - Lifecycle

    func start(players: [Player], dictionary: WordDictionary, settings: GameSettings) {
        guard players.count >= 2 else { return }

        let pools = WordList.distribute(dictionary.words, among: players.count)
        self.players = zip(players, pools).map { GamePlayer($0, wordPool: $1) }
        self.settings = settings
        self.dictionary = dictionary
        turnHistory = []
        currentTurnWords = []
        usedWordKeys = []
        cursorBeforeNextTurn = nil
        cursor = Cursor(round: 1, turnIndex: 0, queue: makeRoundQueue())
    }

    func restart() {
        guard let dictionary else { return }
        start(players: players.map(\.player), dictionary: dictionary, settings: settings)
    }

    // MARK: - Turn

    func nextWord() -> String? {
        guard let guesserID = currentPairing?.guesserID,
              let index = players.firstIndex(where: { $0.id == guesserID }) else { return nil }

        if players[index].wordPool.isEmpty, let dictionary {
            players[index].wordPool = WordList.unique(dictionary.words)
                .filter { !usedWordKeys.contains(WordList.key(for: $0)) }
                .shuffled()
        }

        guard !players[index].wordPool.isEmpty else { return nil }
        let word = players[index].wordPool.removeFirst()
        usedWordKeys.insert(WordList.key(for: word))
        return word
    }

    func record(_ word: String, isGuessed: Bool, isLastWord: Bool = false) {
        guard currentPairing != nil else { return }
        currentTurnWords.append(WordResult(word: word, isGuessed: isGuessed, isLastWord: isLastWord))
    }

    func completeTurn(bonusPlayerID: UUID?) {
        guard let pairing = currentPairing else { return }

        let bonusPlayerID = settings.lastWordBonusEnabled ? bonusPlayerID : nil
        let turn = Turn(
            round: cursor.round,
            numberInRound: turnNumberInRound,
            pairing: pairing,
            wordResults: currentTurnWords,
            bonusPlayerID: bonusPlayerID,
            score: settings.score(for: currentTurnWords, bonusPlayerID: bonusPlayerID)
        )
        apply(turn, sign: 1)
        turnHistory.append(turn)
        currentTurnWords = []
        cursorBeforeNextTurn = nil
        cursor.turnIndex += 1
    }

    /// Replaces the results of the most recent turn and re-scores it.
    func reviseLastTurn(wordResults: [WordResult], bonusPlayerID: UUID?) {
        guard var turn = turnHistory.popLast() else { return }
        apply(turn, sign: -1)
        turn.wordResults = wordResults
        turn.bonusPlayerID = settings.lastWordBonusEnabled ? bonusPlayerID : nil
        turn.score = settings.score(for: wordResults, bonusPlayerID: turn.bonusPlayerID)
        apply(turn, sign: 1)
        turnHistory.append(turn)
    }

    /// Moves to the next pairing, starting a new round when the current one is complete.
    func beginNextTurn() {
        guard !isGameOver, !turnHistory.isEmpty else { return }
        cursorBeforeNextTurn = cursor
        currentTurnWords = []
        if isRoundComplete {
            cursor = Cursor(round: cursor.round + 1, turnIndex: 0, queue: makeRoundQueue())
        }
    }

    /// Undoes `beginNextTurn()` so the last turn's results can be reviewed again.
    func returnToLastTurn() {
        guard canReturnToLastTurn, let previous = cursorBeforeNextTurn else { return }
        cursor = previous
        cursorBeforeNextTurn = nil
    }

    // MARK: - Private

    private func apply(_ turn: Turn, sign: Int) {
        adjustScore(of: turn.pairing.explainerID, by: sign * turn.score.explainer)
        adjustScore(of: turn.pairing.guesserID, by: sign * turn.score.guesser)
        if let bonusPlayerID = turn.bonusPlayerID {
            adjustScore(of: bonusPlayerID, by: sign * turn.score.bonus)
        }
    }

    private func adjustScore(of playerID: UUID, by points: Int) {
        guard let index = players.firstIndex(where: { $0.id == playerID }) else { return }
        players[index].score += points
    }

    /// Every ordered explainer/guesser pair once, shuffled to alternate each player's role as much as possible.
    private func makeRoundQueue() -> [PlayerPairing] {
        let pairings = players.flatMap { explainer in
            players.filter { $0.id != explainer.id }.map { PlayerPairing(explainerID: explainer.id, guesserID: $0.id) }
        }
        return (0 ..< 20)
            .map { _ in pairings.shuffled() }
            .max { Self.roleAlternation(in: $0) < Self.roleAlternation(in: $1) } ?? pairings
    }

    private static func roleAlternation(in queue: [PlayerPairing]) -> Int {
        var lastRoleIsExplainer: [UUID: Bool] = [:]
        var changes = 0
        for pairing in queue {
            if lastRoleIsExplainer[pairing.explainerID] == false { changes += 1 }
            if lastRoleIsExplainer[pairing.guesserID] == true { changes += 1 }
            lastRoleIsExplainer[pairing.explainerID] = true
            lastRoleIsExplainer[pairing.guesserID] = false
        }
        return changes
    }
}
