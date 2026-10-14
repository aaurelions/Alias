import Foundation
import Observation

@Observable
final class NewGameModel {
    enum GenerationState: Equatable {
        case idle
        case generating(received: Int, target: Int)
        case failed(message: String)

        var isGenerating: Bool {
            if case .generating = self { true } else { false }
        }
    }

    var players: [Player] = []
    var settings = GameSettings()
    var selectedDictionaryID: WordDictionary.ID?
    var playerBeingEdited: Player?
    var isGameSettingsPresented = false
    var isDictionaryGeneratorPresented = false
    let builtInDictionaries: [WordDictionary]
    private(set) var generatedDictionary: WordDictionary?
    private(set) var generationState = GenerationState.idle
    private(set) var hasRevealedInitialPlayers = false

    @ObservationIgnored private let playerFactory: PlayerFactory
    @ObservationIgnored private let generator: DictionaryGenerator
    @ObservationIgnored private var generationTask: Task<Void, Never>?

    init(language: Language, generator: DictionaryGenerator = DictionaryGenerator()) {
        playerFactory = PlayerFactory(language: language)
        self.generator = generator
        builtInDictionaries = Difficulty.allCases.map { WordDictionary.builtIn($0, language: language) }
        selectedDictionaryID = Difficulty.allCases.firstIndex(of: .medium).map { builtInDictionaries[$0].id }
    }

    var selectedDictionary: WordDictionary? {
        ([generatedDictionary].compactMap(\.self) + builtInDictionaries).first { $0.id == selectedDictionaryID }
    }

    var canStartGame: Bool {
        players.count >= 2 && selectedDictionary != nil && !generationState.isGenerating
    }

    // MARK: - Players

    /// The default players, returned only once so they are revealed a single time per setup.
    func takeInitialPlayers() -> [Player] {
        guard !hasRevealedInitialPlayers else { return [] }
        hasRevealedInitialPlayers = true
        return playerFactory.initialPlayers
    }

    func addPlayer() {
        players.append(playerFactory.makePlayer(avoiding: players))
    }

    func deletePlayer(_ player: Player) {
        players.removeAll { $0.id == player.id }
    }

    func updatePlayer(_ player: Player) {
        guard let index = players.firstIndex(where: { $0.id == player.id }) else { return }
        players[index] = player
    }

    // MARK: - Dictionaries

    func selectBuiltInDictionary(_ dictionary: WordDictionary) {
        selectedDictionaryID = dictionary.id
    }

    func tapGeneratedDictionary() {
        if let generatedDictionary, selectedDictionaryID != generatedDictionary.id {
            selectedDictionaryID = generatedDictionary.id
        } else {
            generationState = .idle
            isDictionaryGeneratorPresented = true
        }
    }

    func generateDictionary(topic: String, configuration: OpenRouterConfiguration) {
        generationTask?.cancel()
        let target = DictionaryGenerator.targetWordCount(playerCount: max(players.count, 2))
        generationState = .generating(received: 0, target: target)

        generationTask = Task {
            do {
                let dictionary = try await generator.generate(topic: topic, wordCount: target, configuration: configuration) { received in
                    generationState = .generating(received: received, target: target)
                }
                generatedDictionary = dictionary
                selectedDictionaryID = dictionary.id
                generationState = .idle
                isDictionaryGeneratorPresented = false
            } catch is CancellationError {
                generationState = .idle
            } catch let error as URLError where error.code == .cancelled {
                generationState = .idle
            } catch {
                generationState = .failed(message: error.localizedDescription)
            }
        }
    }

    func cancelGeneration() {
        generationTask?.cancel()
        generationTask = nil
        if generationState.isGenerating { generationState = .idle }
    }
}
