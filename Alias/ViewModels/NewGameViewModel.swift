import SwiftUI
import Combine

/// ViewModel for the New Game screen
class NewGameViewModel: ObservableObject, PlayerActions, DictionaryActions, GameActions, AnimationActions {
    @Published private(set) var uiState = UIState()
    @Published private(set) var gameSettings = GameSettings()
    @Published private(set) var generationProgress: (current: Int, total: Int)? = nil
    @Published private(set) var generationError: String? = nil

    private let playerManager = PlayerManager()
    private let dictionaryManager = DictionaryManager()
    private let animationManager = AnimationManager()
    private var cancellables = Set<AnyCancellable>()

    var players: [Player] { uiState.players }
    var dictionaries: [WordDictionary] { uiState.dictionaries }
    var isGameStarted: Bool { uiState.isGameStarted }
    var canStartGame: Bool {
        uiState.players.count >= 2 &&
        uiState.selectedDictionaryIndex != nil &&
        uiState.dictionaries.contains { $0.id == uiState.selectedDictionaryIndex && !$0.isCustomPlaceholder }
    }

    // MARK: - PlayerActions

    func addNewPlayer() {
        let newPlayer = playerManager.createRandomPlayer(existingPlayers: uiState.players)
        withAnimation(.spring()) {
            uiState.players.append(newPlayer)
        }
    }

    func deletePlayer(_ player: Player) {
        withAnimation(.spring()) {
            uiState.players.removeAll { $0.id == player.id }
        }
    }

    func startEditingPlayer(_ player: Player) {
        uiState.playerToEdit = player
        withAnimation(.spring()) {
            uiState.showEditPlayerAlert = true
        }
    }

    func saveEditedPlayer(_ updatedPlayer: Player) {
        if let index = uiState.players.firstIndex(where: { $0.id == updatedPlayer.id }) {
            withAnimation {
                uiState.players[index] = updatedPlayer
            }
        }
        uiState.playerToEdit = nil
    }

    // MARK: - DictionaryActions

    func handleDictionaryTap(_ dictionary: WordDictionary) {
        if dictionary.isCustomPlaceholder {
            withAnimation(.spring()) {
                uiState.showCreateDictionaryAlert = true
            }
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                uiState.selectedDictionaryIndex = dictionary.id
            }
        }
    }

    func handleAIGeneration(prompt: String) async {
        let playerCount = uiState.players.count > 0 ? uiState.players.count : 2 // Default to 2 if no players yet
        let totalWordsNeeded = max(300, playerCount * 100)

        // Reset progress
        generationProgress = (current: 0, total: totalWordsNeeded)
        generationError = nil

        // Use streaming API
        dictionaryManager.streamDictionaryGeneration(from: prompt, playerCount: playerCount)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    // Clear progress and close the alert on successful completion
                    self.generationProgress = nil
                    withAnimation(.spring()) {
                        self.uiState.showCreateDictionaryAlert = false
                    }
                case .failure(let error):
                    self.generationProgress = nil
                    self.generationError = error.localizedDescription
                }
            }, receiveValue: { [weak self] partialDictionary in
                guard let self = self else { return }
                // Update UI with streaming progress
                self.generationProgress = (current: partialDictionary.wordCount, total: totalWordsNeeded)
                self.generationError = nil
                self.uiState.dictionaries = self.dictionaryManager.replacePlaceholder(with: partialDictionary, in: self.uiState.dictionaries)
                self.uiState.selectedDictionaryIndex = partialDictionary.id
            })
            .store(in: &cancellables)
    }

    // MARK: - GameActions

    /// Resets the view model to initial state
    func resetForNewGame() {
        // Clear players to trigger animation on next appear
        uiState.players = []
        uiState.selectedDictionaryIndex = 1
        uiState.isGameStarted = false
        uiState.showEditPlayerAlert = false
        uiState.showCreateDictionaryAlert = false
        uiState.isAdvancedSettingsExpanded = false
        uiState.playerToEdit = nil

        // Reset game settings to defaults
        gameSettings = GameSettings()

        // Reset dictionaries to initial state (removes any custom dictionaries)
        uiState.dictionaries = .initialGameDictionaries
    }

    func startGame() {
        // Get selected dictionary
        guard let selectedIndex = uiState.selectedDictionaryIndex,
              let selectedDictionary = uiState.dictionaries.first(where: { $0.id == selectedIndex }) else {
            return
        }

        // Ensure we have at least 2 players
        guard uiState.players.count >= 2 else {
            return
        }

        // Initialize the game with GameManager
        GameManager.shared.startNewGame(
            players: uiState.players,
            dictionary: selectedDictionary,
            settings: gameSettings
        )

        uiState.isGameStarted = true
    }

    // MARK: - AnimationActions

    func animatePlayerAndDictionaryAppearance() {
        guard uiState.players.isEmpty else { return }

        animationManager.animatePlayersAndDictionaries(
            initialPlayers: playerManager.getInitialPlayers(),
            dictionaries: uiState.dictionaries
        ) { [weak self] player in
            self?.uiState.players.append(player)
        } onSelectDictionary: { [weak self] dictionaryId in
            self?.uiState.selectedDictionaryIndex = dictionaryId
        }
    }

    // MARK: - UI State Accessors

    var playerToEdit: Player? { uiState.playerToEdit }

    var showEditPlayerAlert: Binding<Bool> {
        Binding(
            get: { self.uiState.showEditPlayerAlert },
            set: { self.uiState.showEditPlayerAlert = $0 }
        )
    }

    var showCreateDictionaryAlert: Binding<Bool> {
        Binding(
            get: { self.uiState.showCreateDictionaryAlert },
            set: { self.uiState.showCreateDictionaryAlert = $0 }
        )
    }

    var isAdvancedSettingsExpanded: Binding<Bool> {
        Binding(
            get: { self.uiState.isAdvancedSettingsExpanded },
            set: { self.uiState.isAdvancedSettingsExpanded = $0 }
        )
    }

    var selectedRoundTime: Binding<Int> {
        Binding(
            get: { self.gameSettings.selectedRoundTime },
            set: { self.gameSettings.selectedRoundTime = $0 }
        )
    }

    var selectedPointsToWin: Binding<Int> {
        Binding(
            get: { self.gameSettings.selectedPointsToWin },
            set: { self.gameSettings.selectedPointsToWin = $0 }
        )
    }

    var guesserPoints: Binding<Int> {
        Binding(
            get: { self.gameSettings.guesserPoints },
            set: { self.gameSettings.guesserPoints = $0 }
        )
    }

    var explainerPoints: Binding<Int> {
        Binding(
            get: { self.gameSettings.explainerPoints },
            set: { self.gameSettings.explainerPoints = $0 }
        )
    }

    var guesserPenalty: Binding<Int> {
        Binding(
            get: { self.gameSettings.guesserPenalty },
            set: { self.gameSettings.guesserPenalty = $0 }
        )
    }

    var explainerPenalty: Binding<Int> {
        Binding(
            get: { self.gameSettings.explainerPenalty },
            set: { self.gameSettings.explainerPenalty = $0 }
        )
    }

    var lastWordBonusEnabled: Binding<Bool> {
        Binding(
            get: { self.gameSettings.lastWordBonusEnabled },
            set: { self.gameSettings.lastWordBonusEnabled = $0 }
        )
    }

    var lastWordBonusPoints: Binding<Int> {
        Binding(
            get: { self.gameSettings.lastWordBonusPoints },
            set: { self.gameSettings.lastWordBonusPoints = $0 }
        )
    }

    var selectedDictionaryIndexBinding: Binding<Int?> {
        Binding(
            get: { self.uiState.selectedDictionaryIndex },
            set: { self.uiState.selectedDictionaryIndex = $0 }
        )
    }
}
