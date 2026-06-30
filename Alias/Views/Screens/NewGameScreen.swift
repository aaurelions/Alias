import SwiftUI

// MARK: - Main New Game Screen

struct NewGameScreen: View {
    @Binding var navigationPath: NavigationPath
    @StateObject private var viewModel = NewGameViewModel()

    var body: some View {
        ZStack {
            NewGameContentView(navigationPath: $navigationPath, viewModel: viewModel)

            // Game Settings Sheet
            if viewModel.isAdvancedSettingsExpanded.wrappedValue {
                GameSettingsSheet(
                    isPresented: viewModel.isAdvancedSettingsExpanded,
                    selectedRoundTime: viewModel.selectedRoundTime,
                    selectedPointsToWin: viewModel.selectedPointsToWin,
                    guesserPoints: viewModel.guesserPoints,
                    explainerPoints: viewModel.explainerPoints,
                    guesserPenalty: viewModel.guesserPenalty,
                    explainerPenalty: viewModel.explainerPenalty,
                    lastWordBonusEnabled: viewModel.lastWordBonusEnabled,
                    lastWordBonusPoints: viewModel.lastWordBonusPoints
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DarkBackgroundView(backgroundImage: "NewGameScreenBg"))
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Reset state for a fresh new game
            viewModel.resetForNewGame()
            // Animate player appearance
            viewModel.animatePlayerAndDictionaryAppearance()
        }
        .fullScreenCover(isPresented: viewModel.showEditPlayerAlert) {
            if let player = viewModel.playerToEdit {
                EditPlayerAlert(
                    player: player,
                    isPresented: viewModel.showEditPlayerAlert,
                    onSave: viewModel.saveEditedPlayer
                )
            }
        }
        .fullScreenCover(isPresented: viewModel.showCreateDictionaryAlert) {
            CreateDictionaryAlert(
                isPresented: viewModel.showCreateDictionaryAlert,
                onGenerate: viewModel.handleAIGeneration,
                generationProgress: viewModel.generationProgress,
                generationError: viewModel.generationError
            )
        }
        .ignoresSafeArea(.keyboard)
    }
}

private struct NewGameContentView: View {
    @Binding var navigationPath: NavigationPath
    @ObservedObject var viewModel: NewGameViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        // Parent VStack to hold both the ScrollView and the button
        VStack {
            ScrollView {
                VStack(spacing: 0) {
                    NavigationHeader(
                        title: L.NewGame.title,
                        leftAction: .back { dismiss() },
                        rightAction: .settings(
                            isExpanded: viewModel.isAdvancedSettingsExpanded.wrappedValue,
                            action: {
                                withAnimation {
                                    viewModel.isAdvancedSettingsExpanded.wrappedValue.toggle()
                                }
                            }
                        )
                    )
                    .padding(.bottom, 15)

                    PlayersSection(
                        players: viewModel.players,
                        onAdd: viewModel.addNewPlayer,
                        onDelete: viewModel.deletePlayer,
                        onEdit: viewModel.startEditingPlayer
                    )
                    .padding(.vertical, 15)

                    DictionariesGrid(
                        dictionaries: viewModel.dictionaries,
                        selectedIndex: viewModel.selectedDictionaryIndexBinding,
                        onDictionaryTap: viewModel.handleDictionaryTap
                    )
                    .padding(.vertical, 15)

                    if viewModel.dictionaries.count > 3 {
                        CenteredCreateDictionaryCard(
                            dictionary: viewModel.dictionaries[3],
                            isSelected: viewModel.selectedDictionaryIndexBinding.wrappedValue == viewModel.dictionaries[3].id,
                            onTap: { viewModel.handleDictionaryTap(viewModel.dictionaries[3]) }
                        )
                        .padding(.vertical, 15)
                    }
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)

            // This Spacer pushes the button to the bottom of the screen
            Spacer()

            // The button is outside the ScrollView
            HStack(spacing: 12) {
                StartGameButton(isEnabled: viewModel.canStartGame) {
                    viewModel.startGame()
                    if viewModel.isGameStarted {
                        navigationPath.append(NavigationDestination.turnStartConfirm)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical)
            .frame(height: 80)
        }
    }
}

// MARK: - Preview

#Preview("Default New Game") {
    NavigationStack {
        NewGameScreen(navigationPath: .constant(NavigationPath()))
    }
}
