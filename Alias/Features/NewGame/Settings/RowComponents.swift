import SwiftUI

// MARK: - Options Row

/// A full-width row of mutually exclusive options.
struct OptionsRow<Value: Hashable>: View {
    let options: [Value]
    @Binding var selection: Value
    let label: (Value) -> String

    var body: some View {
        HStack(spacing: 12) {
            ForEach(options, id: \.self) { option in
                OptionButton(option: label(option), selected: selection == option) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                        selection = option
                    }
                }
                .accessibilityAddTraits(selection == option ? .isSelected : [])
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Value Stepper

/// Minus / value / plus control clamped to `bounds`, exposed to VoiceOver as one adjustable element.
struct ValueStepper: View {
    let title: String
    @Binding var value: Int
    let bounds: ClosedRange<Int>
    let caption: String
    var showsPlusSign = true

    private var formattedValue: String {
        showsPlusSign ? "+\(value)" : "\(value)"
    }

    var body: some View {
        HStack(spacing: 16) {
            DecrementButton { adjust(by: -1) }
                .disabled(value <= bounds.lowerBound)

            VStack(spacing: 4) {
                Text(verbatim: formattedValue)
                    .font(Theme.Typography.body(size: 18))
                    .foregroundStyle(Theme.current.textPrimary)
                    .monospacedDigit()
                    .frame(width: 50)

                Text(caption)
                    .font(Theme.Typography.bodySmall(size: 10))
                    .foregroundStyle(Theme.current.textSecondary)
            }

            IncrementButton { adjust(by: 1) }
                .disabled(value >= bounds.upperBound)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue("\(formattedValue) \(caption)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: adjust(by: 1)
            case .decrement: adjust(by: -1)
            @unknown default: break
            }
        }
    }

    private func adjust(by delta: Int) {
        withAnimation(.spring(response: 0.1, dampingFraction: 0.9)) {
            value = min(max(value + delta, bounds.lowerBound), bounds.upperBound)
        }
    }
}

// MARK: - Adjustable Value Column

/// A captioned stepper for one role (guesser or explainer).
struct AdjustableValueColumn: View {
    let title: String
    @Binding var value: Int
    let isPenalty: Bool

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text(title)
                .font(Theme.Typography.body(size: 14))
                .foregroundStyle(Theme.current.textSecondary)
                .accessibilityHidden(true)

            ValueStepper(
                title: title,
                value: $value,
                bounds: isPenalty ? -GameSettings.maximumPoints ... 0 : 0 ... GameSettings.maximumPoints,
                caption: isPenalty ? L.Settings.penaltyUnit : L.Settings.pointsUnit,
                showsPlusSign: !isPenalty
            )
        }
        .frame(maxWidth: .infinity)
    }
}
