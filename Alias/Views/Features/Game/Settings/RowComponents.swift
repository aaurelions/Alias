import SwiftUI

// MARK: - Row Title

/// Title with icon for settings rows
struct RowTitle: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color.opacity(0.8))
            Text(text)
                .font(Theme.Typography.heading2(size: 18))
                .foregroundColor(Theme.current.textSecondary)
        }
    }
}

// MARK: - Options Row

/// Horizontal row of options that fills the entire width
struct OptionsRow: View {
    let options: [String]
    let isSelected: (String) -> Bool
    let onTap: (String) -> Void

    var body: some View {
        HStack(spacing: 12) {
            ForEach(options, id: \.self) { option in
                OptionButton(
                    option: option,
                    selected: isSelected(option),
                    action: { onTap(option) }
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Adjustable Value Column

/// Column layout for adjustable value controls
struct AdjustableValueColumn: View {
    let title: String
    @Binding var value: Int
    let positiveStyle: Bool

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text(title)
                .font(Theme.Typography.body(size: 14))
                .foregroundColor(Theme.current.textSecondary)

            HStack(spacing: 16) {
                DecrementButton(
                    action: {
                        withAnimation(.spring(response: 0.1, dampingFraction: 0.9)) {
                            if positiveStyle {
                                value = max(0, value - 1)
                            } else {
                                value -= 1
                            }
                        }
                    }
                )

                VStack(spacing: 4) {
                    Text(positiveStyle ? "+\(value)" : "\(value)")
                        .font(Theme.Typography.body(size: 18))
                        .foregroundColor(Theme.current.textPrimary)
                        .frame(width: 50)

                    Text(positiveStyle ? "points" : "penalty")
                        .font(Theme.Typography.bodySmall(size: 10))
                        .foregroundColor(Theme.current.textSecondary)
                }

                IncrementButton(
                    action: {
                        withAnimation(.spring(response: 0.1, dampingFraction: 0.9)) {
                            value += 1
                        }
                    }
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
}
