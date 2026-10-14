import SwiftUI

// MARK: - Stepper Buttons

struct IncrementButton: View {
    let action: () -> Void
    var color: Color = Theme.current.accentSuccess.opacity(0.8)
    var size: CGFloat = 36

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Theme.current.accentSuccess.opacity(0.2))
                    .frame(width: size, height: size)
                Image(systemName: "plus")
                    .font(Theme.Typography.body(size: 16))
                    .foregroundStyle(color)
            }
        }
        .buttonStyle(.plain)
    }
}

struct DecrementButton: View {
    let action: () -> Void
    var color: Color = Theme.current.accentDestructive.opacity(0.8)
    var size: CGFloat = 36

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Theme.current.accentDestructive.opacity(0.2))
                    .frame(width: size, height: size)
                Image(systemName: "minus")
                    .font(Theme.Typography.body(size: 16))
                    .foregroundStyle(color)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Option Button

struct OptionButton: View {
    let option: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(option)
                .font(Theme.Typography.body(size: 14))
                .foregroundStyle(Theme.current.textSecondary)
                .fontWeight(selected ? .bold : .regular)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 5)
                .padding(.vertical, 10)
                .background(buttonBackground)
                .scaleEffect(selected ? 1.1 : 1.0)
                .animation(
                    .spring(response: 0.2, dampingFraction: 0.8),
                    value: selected
                )
        }
        .buttonStyle(.plain)
    }

    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: Theme.BorderRadius.lg.value)
            .fill(
                selected
                    ? Theme.current.interactivePrimary.opacity(0.6)
                    : Theme.current.surfacePrimary.opacity(0.5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.BorderRadius.lg.value)
                    .stroke(
                        selected
                            ? Theme.current.interactivePrimary
                            : Theme.current.borderPrimary,
                        lineWidth: selected ? 2 : 1
                    )
            )
    }
}

// MARK: - Previews

#Preview("Stepper Buttons") {
    HStack(spacing: 40) {
        DecrementButton(action: {})
        IncrementButton(action: {})
    }
    .padding()
    .background(Theme.current.backgroundPrimary)
}

#Preview("Option Buttons") {
    HStack(spacing: 12) {
        OptionButton(option: "30s", selected: false, action: {})
        OptionButton(option: "60s", selected: true, action: {})
        OptionButton(option: "90s", selected: false, action: {})
    }
    .padding()
    .background(Theme.current.backgroundPrimary)
}
