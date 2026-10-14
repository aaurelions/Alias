import SwiftUI

struct RoundTimePicker: View {
    @Binding var selectedRoundTime: Int

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            RowTitle(icon: "clock.fill", color: Theme.current.textPrimary, text: L.Settings.roundTime)

            OptionsRow(options: GameSettings.roundTimeOptions, selection: $selectedRoundTime, label: L.Settings.seconds)
        }
    }
}

struct PointsToWinPicker: View {
    @Binding var selectedPointsToWin: Int

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            RowTitle(icon: "trophy.fill", color: Theme.current.textPrimary, text: L.Settings.pointsToWin)

            OptionsRow(options: GameSettings.pointsToWinOptions, selection: $selectedPointsToWin) { "\($0)" }
        }
    }
}

/// Points (or, for skipped words, penalties) awarded to the guesser and the explainer.
struct PointsRow: View {
    let title: String
    @Binding var guesserValue: Int
    @Binding var explainerValue: Int
    let isPenalty: Bool

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            RowTitle(
                icon: isPenalty ? "xmark.circle.fill" : "checkmark.circle.fill",
                color: isPenalty ? Theme.current.accentDestructive : Theme.current.accentSuccess,
                text: title
            )

            HStack(alignment: .top, spacing: 20) {
                AdjustableValueColumn(title: L.Role.guesser, value: $guesserValue, isPenalty: isPenalty)
                Spacer()
                AdjustableValueColumn(title: L.Role.explainer, value: $explainerValue, isPenalty: isPenalty)
            }
        }
    }
}

struct LastWordBonusRow: View {
    @Binding var isEnabled: Bool
    @Binding var points: Int

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            ToggleRow(
                icon: "star.circle.fill",
                title: L.Settings.lastWordBonus,
                isOn: $isEnabled.animation(.spring(response: 0.4, dampingFraction: 0.8)),
                color: Theme.current.accentWarning
            )

            HStack(spacing: 16) {
                Text(L.Settings.bonusPoints)
                    .font(Theme.Typography.body(size: 14))
                    .foregroundStyle(Theme.current.textSecondary)
                    .accessibilityHidden(true)

                Spacer()

                ValueStepper(
                    title: L.Settings.bonusPoints,
                    value: $points,
                    bounds: 0 ... GameSettings.maximumPoints,
                    caption: L.Settings.bonus
                )
            }
            .opacity(isEnabled ? 1 : 0.4)
            .disabled(!isEnabled)
        }
    }
}
