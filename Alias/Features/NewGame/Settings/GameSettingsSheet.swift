import SwiftUI

struct GameSettingsSheet: View {
    @Binding var isPresented: Bool
    @Binding var settings: GameSettings

    var body: some View {
        BottomSheet(isPresented: $isPresented) {
            VStack(spacing: 24) {
                RoundTimePicker(selectedRoundTime: $settings.roundTime)
                PointsToWinPicker(selectedPointsToWin: $settings.pointsToWin)
                GuessedWordPointsRow(guesserValue: $settings.guesserPoints, explainerValue: $settings.explainerPoints)
                SkippedWordPenaltyRow(guesserValue: $settings.guesserPenalty, explainerValue: $settings.explainerPenalty)
                LastWordBonusRow(enabled: $settings.lastWordBonusEnabled, points: $settings.lastWordBonusPoints)
            }
        }
    }
}

#Preview {
    @Previewable @State var settings = GameSettings()

    GameSettingsSheet(isPresented: .constant(true), settings: $settings)
        .background(Color.black)
}
