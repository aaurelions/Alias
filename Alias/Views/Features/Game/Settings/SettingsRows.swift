import SwiftUI

/// Picker for round time
struct RoundTimePicker: View {
    @Binding var selectedRoundTime: Int
    private let times: [Int] = [10, 45, 60, 90, 120]

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            RowTitle(icon: "clock.fill", color: Theme.current.textPrimary, text: L.Settings.roundTime)

            OptionsRow(options: times.map { "\($0)s" },
                       isSelected: { option in
                           Int(option.dropLast()) == selectedRoundTime
                       },
                       onTap: { option in
                           if let value = Int(option.dropLast()) {
                               withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                   selectedRoundTime = value
                               }
                           }
                       })
        }
    }
}

/// Picker for points to win
struct PointsToWinPicker: View {
    @Binding var selectedPointsToWin: Int
    private let options: [Int] = [10, 75, 100, 125, 150]

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            RowTitle(icon: "trophy.fill", color: Theme.current.textPrimary, text: L.Settings.pointsToWin)

            OptionsRow(options: options.map(String.init),
                       isSelected: { option in
                           Int(option) == selectedPointsToWin
                       },
                       onTap: { option in
                           if let value = Int(option) {
                               withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                   selectedPointsToWin = value
                               }
                           }
                       })
        }
    }
}

/// Row for guessed word points
struct GuessedWordPointsRow: View {
    @Binding var guesserValue: Int
    @Binding var explainerValue: Int

    var body: some View {
        PointsRow(
            title: L.Settings.pointsForGuessed,
            guesserValue: $guesserValue,
            explainerValue: $explainerValue,
            positiveStyle: true
        )
    }
}

/// Row for skipped word penalty
struct SkippedWordPenaltyRow: View {
    @Binding var guesserValue: Int
    @Binding var explainerValue: Int

    var body: some View {
        PointsRow(
            title: L.Settings.penaltyForSkipped,
            guesserValue: $guesserValue,
            explainerValue: $explainerValue,
            positiveStyle: false
        )
    }
}

/// Generic points row with two columns
struct PointsRow: View {
    let title: String
    @Binding var guesserValue: Int
    @Binding var explainerValue: Int
    let positiveStyle: Bool

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            RowTitle(
                icon: positiveStyle ? "checkmark.circle.fill" : "xmark.circle.fill",
                color: positiveStyle ? Theme.current.accentSuccess : Theme.current.accentDestructive,
                text: title
            )

            HStack(alignment: .top, spacing: 20) {
                AdjustableValueColumn(title: "Guesser",
                                      value: $guesserValue,
                                      positiveStyle: positiveStyle)
                Spacer()
                AdjustableValueColumn(title: "Explainer",
                                      value: $explainerValue,
                                      positiveStyle: positiveStyle)
            }
        }
    }
}

/// Row for last word bonus
struct LastWordBonusRow: View {
    @Binding var enabled: Bool
    @Binding var points: Int

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Theme.current.accentWarning.opacity(0.8))
                Text(L.Settings.lastWordBonus)
                    .font(Theme.Typography.heading2(size: 18))
                    .foregroundColor(Theme.current.textSecondary)

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(enabled ? Theme.current.accentSuccess.opacity(0.3) : Theme.current.surfaceSecondary.opacity(0.5))
                        .frame(width: 60, height: 32)

                    Toggle("", isOn: $enabled)
                        .labelsHidden()
                        .tint(Theme.current.accentSuccess)
                        .scaleEffect(0.8)
                }
            }

            HStack(spacing: 16) {
                Text(L.Settings.bonusPoints)
                    .font(Theme.Typography.body(size: 14))
                    .foregroundColor(Theme.current.textSecondary)

                Spacer()

                DecrementButton(
                    action: {
                        withAnimation(.spring(response: 0.1, dampingFraction: 0.9)) {
                            points = max(0, points - 1)
                        }
                    },
                    color: Theme.current.accentDestructive.opacity(0.8)
                )

                VStack(spacing: 4) {
                    Text("+\(points)")
                        .font(Theme.Typography.body(size: 18))
                        .foregroundColor(Theme.current.textPrimary)
                        .frame(width: 50)

                    Text(L.Settings.bonus)
                        .font(Theme.Typography.bodySmall(size: 10))
                        .foregroundColor(Theme.current.textSecondary)
                }

                IncrementButton(
                    action: {
                        withAnimation(.spring(response: 0.1, dampingFraction: 0.9)) {
                            points += 1
                        }
                    },
                    color: Theme.current.accentSuccess.opacity(0.8)
                )
            }
            // Make the view transparent and non-interactive when disabled
            .opacity(enabled ? 1.0 : 0.4)
            .disabled(!enabled)
            // The view now animates its properties instead of transitioning in/out
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: enabled)
        }
    }
}
