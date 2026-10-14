import SwiftUI

struct NewGameScreen: View {
    @Environment(AppSettings.self) private var appSettings
    @Environment(AppRouter.self) private var router
    @Environment(GameSession.self) private var session
    @State private var model = NewGameModel(language: AppSettings.shared.language)

    var body: some View {
        @Bindable var model = model

        VStack {
            ScrollView {
                VStack(spacing: 0) {
                    NavigationHeader(
                        title: L.NewGame.title,
                        leftAction: .back { router.back() },
                        rightAction: .settings(isExpanded: model.isGameSettingsPresented) {
                            model.isGameSettingsPresented.toggle()
                        }
                    )
                    .padding(.bottom, 15)

                    PlayersSection(
                        players: model.players,
                        onAdd: { withAnimation(.spring()) { model.addPlayer() } },
                        onDelete: { player in withAnimation(.spring()) { model.deletePlayer(player) } },
                        onEdit: { model.playerBeingEdited = $0 }
                    )
                    .padding(.vertical, 15)

                    BuiltInDictionaryGrid(
                        dictionaries: model.builtInDictionaries,
                        selectedID: model.selectedDictionaryID
                    ) { dictionary in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            model.selectBuiltInDictionary(dictionary)
                        }
                    }
                    .padding(.vertical, 15)

                    GeneratedDictionaryCard(
                        dictionary: model.generatedDictionary,
                        isSelected: model.generatedDictionary.map { $0.id == model.selectedDictionaryID } ?? false
                    ) {
                        withAnimation(.spring()) { model.tapGeneratedDictionary() }
                    }
                    .padding(.vertical, 15)
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)

            RippleButton(title: L.NewGame.startGame, isEnabled: model.canStartGame, action: startGame)
                .padding()
                .frame(height: 80)
        }
        .screenBackground(.newGameScreenBg)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $model.isGameSettingsPresented) {
            GameSettingsSheet(settings: $model.settings)
        }
        .sheet(item: $model.playerBeingEdited) { player in
            EditPlayerSheet(player: player) { updated in
                withAnimation { model.updatePlayer(updated) }
            }
        }
        .sheet(isPresented: $model.isDictionaryGeneratorPresented, onDismiss: model.cancelGeneration) {
            CreateDictionarySheet(state: model.generationState) { topic in
                model.generateDictionary(topic: topic, configuration: appSettings.llmConfiguration)
            }
        }
        .task { await revealInitialPlayers() }
    }

    private func revealInitialPlayers() async {
        let players = model.takeInitialPlayers()
        let delay = Duration.seconds(0.5) / max(players.count, 1)
        for player in players {
            try? await Task.sleep(for: delay)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                model.players.append(player)
            }
        }
    }

    private func startGame() {
        guard model.canStartGame, let dictionary = model.selectedDictionary else { return }
        session.start(players: model.players, dictionary: dictionary, settings: model.settings)
        router.startGame()
    }
}

#Preview {
    NavigationStack {
        NewGameScreen()
    }
    .previewEnvironment()
}
