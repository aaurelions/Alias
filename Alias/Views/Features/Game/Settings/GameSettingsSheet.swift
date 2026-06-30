import SwiftUI

// MARK: - Game Settings Sheet

/// Bottom sheet containing game-specific settings
/// Uses the generic BottomSheet component with custom content
struct GameSettingsSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedRoundTime: Int
    @Binding var selectedPointsToWin: Int
    @Binding var guesserPoints: Int
    @Binding var explainerPoints: Int
    @Binding var guesserPenalty: Int
    @Binding var explainerPenalty: Int
    @Binding var lastWordBonusEnabled: Bool
    @Binding var lastWordBonusPoints: Int

    var body: some View {
        BottomSheet(isPresented: $isPresented) {
            VStack(spacing: 24) {
                RoundTimePicker(selectedRoundTime: $selectedRoundTime)
                PointsToWinPicker(selectedPointsToWin: $selectedPointsToWin)
                GuessedWordPointsRow(
                    guesserValue: $guesserPoints,
                    explainerValue: $explainerPoints
                )
                SkippedWordPenaltyRow(
                    guesserValue: $guesserPenalty,
                    explainerValue: $explainerPenalty
                )
                LastWordBonusRow(
                    enabled: $lastWordBonusEnabled,
                    points: $lastWordBonusPoints
                )
            }
        }
    }
}

// MARK: - Previews

#Preview("Game Settings Sheet") {
    struct PreviewWrapper: View {
        @State private var isPresented = true
        @State private var roundTime = 60
        @State private var pointsToWin = 100
        @State private var guesserPoints = 1
        @State private var explainerPoints = 1
        @State private var guesserPenalty = -1
        @State private var explainerPenalty = -1
        @State private var bonusEnabled = true
        @State private var bonusPoints = 3

        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()

                if isPresented {
                    GameSettingsSheet(
                        isPresented: $isPresented,
                        selectedRoundTime: $roundTime,
                        selectedPointsToWin: $pointsToWin,
                        guesserPoints: $guesserPoints,
                        explainerPoints: $explainerPoints,
                        guesserPenalty: $guesserPenalty,
                        explainerPenalty: $explainerPenalty,
                        lastWordBonusEnabled: $bonusEnabled,
                        lastWordBonusPoints: $bonusPoints
                    )
                }
            }
        }
    }
    return PreviewWrapper()
}
