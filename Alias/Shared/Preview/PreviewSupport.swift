import SwiftUI

extension GameSession {
    /// A three-player game on the medium dictionary with `turnsPlayed` turns already completed.
    static func preview(turnsPlayed: Int = 0) -> GameSession {
        let session = GameSession()
        session.start(
            players: [
                Player(emoji: "🦊", name: "Nova"),
                Player(emoji: "🐸", name: "Rex"),
                Player(emoji: "🦄", name: "Luna"),
            ],
            dictionary: .builtIn(.medium, language: .english),
            settings: GameSettings(roundTime: 45, pointsToWin: 20)
        )

        for turn in 0 ..< turnsPlayed {
            if turn > 0 { session.beginNextTurn() }
            for isGuessed in [true, true, true, false] {
                if let word = session.nextWord() { session.record(word, isGuessed: isGuessed) }
            }
            session.completeTurn(bonusPlayerID: nil)
        }
        return session
    }
}

extension View {
    func previewEnvironment(session: GameSession = .preview()) -> some View {
        environment(AppSettings.shared)
            .environment(AppRouter())
            .environment(session)
    }
}
