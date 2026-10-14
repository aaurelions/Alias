import SwiftUI

/// Round rules for the game being set up. Present it with `.sheet`.
struct GameSettingsSheet: View {
    @Binding var settings: GameSettings

    var body: some View {
        VStack(spacing: 24) {
            RoundTimePicker(selectedRoundTime: $settings.roundTime)
            PointsToWinPicker(selectedPointsToWin: $settings.pointsToWin)
            PointsRow(
                title: L.Settings.pointsForGuessed,
                guesserValue: $settings.guesserPoints,
                explainerValue: $settings.explainerPoints,
                isPenalty: false
            )
            PointsRow(
                title: L.Settings.penaltyForSkipped,
                guesserValue: $settings.guesserPenalty,
                explainerValue: $settings.explainerPenalty,
                isPenalty: true
            )
            LastWordBonusRow(isEnabled: $settings.lastWordBonusEnabled, points: $settings.lastWordBonusPoints)
        }
        .themedSheet()
    }
}

#Preview {
    @Previewable @State var settings = GameSettings()

    Color.black
        .sheet(isPresented: .constant(true)) {
            GameSettingsSheet(settings: $settings)
        }
        .previewEnvironment()
}
