@testable import Alias
import Foundation
import Testing

@MainActor
struct GameSessionTests {
    private let players = [
        Player(emoji: "🦊", name: "A"),
        Player(emoji: "🐸", name: "B"),
        Player(emoji: "🦄", name: "C"),
    ]
    private let dictionary = WordDictionary(emoji: "🧪", name: "Test", words: (1 ... 60).map { "word\($0)" })
    private let settings = GameSettings(
        roundTime: 30,
        pointsToWin: 1_000,
        guesserPoints: 6,
        explainerPoints: 4,
        guesserPenalty: -3,
        explainerPenalty: -2,
        lastWordBonusEnabled: true,
        lastWordBonusPoints: 7
    )

    private func makeSession(settings: GameSettings? = nil) -> GameSession {
        let session = GameSession()
        session.start(players: players, dictionary: dictionary, settings: settings ?? self.settings)
        return session
    }

    private func playTurn(_ session: GameSession, guessed: Int, skipped: Int, bonusPlayerID: UUID? = nil) {
        for _ in 0 ..< guessed { session.record(session.nextWord()!, isGuessed: true) }
        for _ in 0 ..< skipped { session.record(session.nextWord()!, isGuessed: false) }
        session.completeTurn(bonusPlayerID: bonusPlayerID)
    }

    @Test func startBuildsEveryOrderedPairingOnce() {
        let session = makeSession()

        #expect(session.turnsPerRound == 6)
        #expect(session.currentRound == 1)
        #expect(session.turnNumberInRound == 1)
        #expect(session.currentExplainer != nil)
        #expect(session.currentGuesser != nil)
        #expect(session.currentExplainer?.id != session.currentGuesser?.id)
        #expect(session.players.map(\.wordPool.count) == [20, 20, 20])
    }

    @Test func startRequiresTwoPlayers() {
        let session = GameSession()
        session.start(players: [players[0]], dictionary: dictionary, settings: settings)

        #expect(session.players.isEmpty)
        #expect(session.currentPairing == nil)
    }

    @Test func completeTurnScoresExplainerAndGuesser() throws {
        let session = makeSession()
        let pairing = try #require(session.currentPairing)

        playTurn(session, guessed: 3, skipped: 2)

        #expect(session.player(id: pairing.explainerID)?.score == 3 * 4 + 2 * -2)
        #expect(session.player(id: pairing.guesserID)?.score == 3 * 6 + 2 * -3)
        #expect(session.lastTurn?.wordResults.count == 5)
        #expect(session.currentTurnWords.isEmpty)
    }

    @Test func skippedLastWordIsNotPenalizedAndBonusGoesToChosenPlayer() throws {
        let session = makeSession()
        let pairing = try #require(session.currentPairing)
        let bystander = try #require(session.players.first { $0.id != pairing.explainerID && $0.id != pairing.guesserID })

        session.record(session.nextWord()!, isGuessed: false, isLastWord: true)
        session.completeTurn(bonusPlayerID: bystander.id)

        #expect(session.player(id: pairing.explainerID)?.score == 0)
        #expect(session.player(id: pairing.guesserID)?.score == 0)
        #expect(session.player(id: bystander.id)?.score == 7)
    }

    @Test func bonusIsIgnoredWhenDisabled() throws {
        var settings = settings
        settings.lastWordBonusEnabled = false
        let session = makeSession(settings: settings)
        let guesserID = try #require(session.currentPairing?.guesserID)

        session.record(session.nextWord()!, isGuessed: true, isLastWord: true)
        session.completeTurn(bonusPlayerID: guesserID)

        #expect(session.lastTurn?.bonusPlayerID == nil)
        #expect(session.player(id: guesserID)?.score == 6)
    }

    @Test func reviseLastTurnReplacesPreviousScoreInsteadOfAddingToIt() throws {
        let session = makeSession()
        let pairing = try #require(session.currentPairing)
        let bystander = try #require(session.players.first { $0.id != pairing.explainerID && $0.id != pairing.guesserID })

        playTurn(session, guessed: 2, skipped: 1, bonusPlayerID: bystander.id)
        var results = try #require(session.lastTurn?.wordResults)
        results[2].isGuessed = true

        session.reviseLastTurn(wordResults: results, bonusPlayerID: nil)
        session.reviseLastTurn(wordResults: results, bonusPlayerID: nil)

        #expect(session.player(id: pairing.explainerID)?.score == 12)
        #expect(session.player(id: pairing.guesserID)?.score == 18)
        #expect(session.player(id: bystander.id)?.score == 0)
        #expect(session.turnHistory.count == 1)
    }

    @Test func turnsAdvanceThroughRoundAndIntoNextRound() {
        let session = makeSession()
        var seenPairings = Set<PlayerPairing>()

        for turn in 1 ... 6 {
            #expect(session.turnNumberInRound == turn)
            seenPairings.insert(session.currentPairing!)
            playTurn(session, guessed: 1, skipped: 0)
            if turn < 6 { session.beginNextTurn() }
        }

        #expect(seenPairings.count == 6)
        #expect(session.isRoundComplete)
        #expect(!session.isGameOver)

        session.beginNextTurn()
        #expect(session.currentRound == 2)
        #expect(session.turnNumberInRound == 1)
        #expect(!session.isRoundComplete)
    }

    @Test func returnToLastTurnRestoresStateAcrossRoundBoundary() {
        let session = makeSession()
        for turn in 1 ... 6 {
            playTurn(session, guessed: 1, skipped: 0)
            if turn < 6 { session.beginNextTurn() }
        }
        let scores = session.players.map(\.score)

        session.beginNextTurn()
        #expect(session.canReturnToLastTurn)
        session.returnToLastTurn()

        #expect(session.currentRound == 1)
        #expect(session.isRoundComplete)
        #expect(session.players.map(\.score) == scores)
        #expect(!session.canReturnToLastTurn)
    }

    @Test func cannotReturnBeforeFirstTurnOrAfterWordsWerePlayed() {
        let session = makeSession()
        #expect(!session.canReturnToLastTurn)

        playTurn(session, guessed: 1, skipped: 0)
        session.beginNextTurn()
        session.record(session.nextWord()!, isGuessed: true)

        #expect(!session.canReturnToLastTurn)
    }

    @Test func winnersAreDecidedOnlyAtRoundEnd() {
        var settings = settings
        settings.pointsToWin = 6
        let session = makeSession(settings: settings)

        playTurn(session, guessed: 1, skipped: 0)
        #expect(session.winners.isEmpty)

        for _ in 2 ... 6 {
            session.beginNextTurn()
            playTurn(session, guessed: 0, skipped: 0)
        }

        #expect(session.isGameOver)
        #expect(session.winners.count == 1)
        #expect(session.winners.first?.score == 6)

        session.beginNextTurn()
        #expect(session.currentRound == 1)
    }

    @Test func tiedPlayersAllWin() {
        var settings = settings
        settings.pointsToWin = 1
        settings.explainerPoints = 1
        settings.guesserPoints = 1
        let session = makeSession(settings: settings)

        for turn in 1 ... 6 {
            playTurn(session, guessed: 1, skipped: 0)
            if turn < 6 { session.beginNextTurn() }
        }

        #expect(session.winners.count == 3)
    }

    @Test func wordsAreNeverRepeatedAndRunOutGracefully() {
        let session = GameSession()
        let small = WordDictionary(emoji: "🧪", name: "Small", words: ["a", "b", "c", "d"])
        session.start(players: Array(players.prefix(2)), dictionary: small, settings: settings)

        var drawn: [String] = []
        while let word = session.nextWord() { drawn.append(word) }

        #expect(drawn.sorted() == ["a", "b", "c", "d"])
    }

    @Test func restartKeepsPlayersAndResetsScores() {
        let session = makeSession()
        playTurn(session, guessed: 3, skipped: 0)

        session.restart()

        #expect(session.players.map(\.name) == players.map(\.name))
        #expect(session.players.allSatisfy { $0.score == 0 })
        #expect(session.turnHistory.isEmpty)
        #expect(session.turnNumberInRound == 1)
    }
}
