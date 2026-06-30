import Foundation

/// Protocol for player-related actions
protocol PlayerActions {
    func addNewPlayer()
    func deletePlayer(_ player: Player)
    func startEditingPlayer(_ player: Player)
    func saveEditedPlayer(_ updatedPlayer: Player)
}
