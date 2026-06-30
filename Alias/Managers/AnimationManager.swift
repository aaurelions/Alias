import SwiftUI

/// Manages animation logic for UI elements
struct AnimationManager {
    /// Animates the appearance of initial players and dictionaries
    func animatePlayersAndDictionaries(
        initialPlayers: [Player],
        dictionaries: [WordDictionary],
        onAddPlayer: @escaping (Player) -> Void,
        onSelectDictionary: @escaping (Int) -> Void
    ) {
        Task {
            let playerDelay = 0.5 / Double(initialPlayers.count)
            for player in initialPlayers {
                try? await Task.sleep(for: .seconds(playerDelay))
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    onAddPlayer(player)
                }
            }
        }
    }
}
