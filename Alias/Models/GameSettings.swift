import Foundation

/// Game configuration settings
struct GameSettings {
    var selectedRoundTime: Int = 60
    var selectedPointsToWin: Int = 50
    var guesserPoints: Int = 6
    var explainerPoints: Int = 4
    var guesserPenalty: Int = -3
    var explainerPenalty: Int = -2
    var lastWordBonusEnabled: Bool = true
    var lastWordBonusPoints: Int = 7
}

/// UI state for the new game screen
struct UIState {
    var players: [Player] = []
    var dictionaries: [WordDictionary] = .initialGameDictionaries
    var selectedDictionaryIndex: Int? = 1
    var playerToEdit: Player?
    var showEditPlayerAlert: Bool = false
    var showCreateDictionaryAlert: Bool = false
    var isAdvancedSettingsExpanded: Bool = false
    var isGameStarted: Bool = false
}
