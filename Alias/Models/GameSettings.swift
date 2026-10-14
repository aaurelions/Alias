import Foundation

struct GameSettings: Equatable, Sendable {
    static let roundTimeOptions = [30, 45, 60, 90, 120]
    static let pointsToWinOptions = [25, 50, 75, 100, 150]
    /// Upper bound for per-word points, penalties and the last-word bonus.
    static let maximumPoints = 99

    var roundTime = 60
    var pointsToWin = 50
    var guesserPoints = 6
    var explainerPoints = 4
    var guesserPenalty = -3
    var explainerPenalty = -2
    var lastWordBonusEnabled = true
    var lastWordBonusPoints = 7

    func score(for results: [WordResult], bonusPlayerID: UUID?) -> TurnScore {
        let guessed = results.count { $0.isGuessed }
        let penalized = results.count { !$0.isGuessed && !$0.isLastWord }
        return TurnScore(
            explainer: guessed * explainerPoints + penalized * explainerPenalty,
            guesser: guessed * guesserPoints + penalized * guesserPenalty,
            bonus: bonusPlayerID == nil ? 0 : lastWordBonusPoints
        )
    }
}

struct TurnScore: Hashable, Sendable {
    var explainer: Int
    var guesser: Int
    var bonus: Int
}
