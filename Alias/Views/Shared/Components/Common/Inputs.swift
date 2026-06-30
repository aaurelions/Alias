import SwiftUI

// MARK: - Form Text Field

/// Styled text input field with label
struct FormTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var isFocused: FocusState<Bool>.Binding? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(Theme.Typography.bodySmall(size: 14))
                .foregroundColor(Theme.current.textSecondary)

            if let isFocused = isFocused {
                TextField(placeholder, text: $text)
                    .font(Theme.Typography.body(size: 20))
                    .padding(12)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(Theme.current.textPrimary)
                    .focused(isFocused)
            } else {
                TextField(placeholder, text: $text)
                    .font(Theme.Typography.body(size: 20))
                    .padding(12)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(Theme.current.textPrimary)
            }
        }
    }
}

// MARK: - Form Text Editor

/// Styled multi-line text editor with label
struct FormTextEditor: View {
    let label: String?
    @Binding var text: String
    var height: CGFloat = 100
    var isFocused: FocusState<Bool>.Binding? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let label = label {
                Text(label)
                    .font(Theme.Typography.bodySmall(size: 14))
                    .foregroundColor(Theme.current.textSecondary)
            }

            if let isFocused = isFocused {
                TextEditor(text: $text)
                    .font(Theme.Typography.body(size: 16))
                    .foregroundColor(Theme.current.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(height: height)
                    .padding(10)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
                    .focused(isFocused)
            } else {
                TextEditor(text: $text)
                    .font(Theme.Typography.body(size: 16))
                    .foregroundColor(Theme.current.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(height: height)
                    .padding(10)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
            }
        }
    }
}

// MARK: - Adjustable Value Control

/// Control with increment/decrement buttons for numeric values
struct AdjustableValueControl: View {
    let title: String
    @Binding var value: Int
    let positiveStyle: Bool
    var minValue: Int? = nil
    var maxValue: Int? = nil

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text(title)
                .font(Theme.Typography.body(size: 14))
                .foregroundColor(Theme.current.textSecondary)

            HStack(spacing: 16) {
                DecrementButton {
                    withAnimation(.spring(response: 0.1, dampingFraction: 0.9))
                    {
                        if positiveStyle {
                            if let minValue = minValue {
                                value = max(minValue, value - 1)
                            } else {
                                value = max(0, value - 1)
                            }
                        } else {
                            if let minValue = minValue {
                                value = max(minValue, value - 1)
                            } else {
                                value -= 1
                            }
                        }
                    }
                }

                VStack(spacing: 4) {
                    Text(positiveStyle ? "+\(value)" : "\(value)")
                        .font(Theme.Typography.body(size: 18))
                        .foregroundColor(Theme.current.textPrimary)
                        .frame(width: 50)

                    Text(positiveStyle ? "points" : "penalty")
                        .font(Theme.Typography.bodySmall(size: 10))
                        .foregroundColor(Theme.current.textSecondary)
                }

                IncrementButton {
                    withAnimation(.spring(response: 0.1, dampingFraction: 0.9))
                    {
                        if let maxValue = maxValue {
                            value = min(maxValue, value + 1)
                        } else {
                            value += 1
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Segmented Control

/// Generic segmented control with selectable options
struct SegmentedControl<T: Hashable>: View {
    let options: [T]
    @Binding var selection: T
    let label: (T) -> String

    var body: some View {
        HStack(spacing: 12) {
            ForEach(options, id: \.self) { option in
                OptionButton(
                    option: label(option),
                    selected: selection == option,
                    action: {
                        withAnimation(
                            .spring(response: 0.2, dampingFraction: 0.8)
                        ) {
                            selection = option
                        }
                    }
                )
            }
        }
    }
}

// MARK: - Previews

#Preview("Form Text Field") {
    struct PreviewWrapper: View {
        @State private var text = "Sample text"

        var body: some View {
            VStack(spacing: 20) {
                FormTextField(
                    label: "Player Name",
                    text: $text,
                    placeholder: "Enter name..."
                )
                FormTextField(
                    label: "Team Name",
                    text: .constant(""),
                    placeholder: "Enter team..."
                )
            }
            .padding()
            .background(Theme.current.backgroundPrimary)
        }
    }
    return PreviewWrapper()
}

#Preview("Form Text Editor") {
    struct PreviewWrapper: View {
        @State private var text =
            "This is a multi-line text editor for longer content."

        var body: some View {
            VStack(spacing: 20) {
                FormTextEditor(label: "Description", text: $text, height: 100)
                FormTextEditor(
                    label: nil,
                    text: .constant("No label editor"),
                    height: 80
                )
            }
            .padding()
            .background(Theme.current.backgroundPrimary)
        }
    }
    return PreviewWrapper()
}

#Preview("Adjustable Value Control") {
    struct PreviewWrapper: View {
        @State private var points = 5
        @State private var penalty = -2

        var body: some View {
            VStack(spacing: 30) {
                AdjustableValueControl(
                    title: "Points",
                    value: $points,
                    positiveStyle: true,
                    minValue: 0,
                    maxValue: 10
                )

                AdjustableValueControl(
                    title: "Penalty",
                    value: $penalty,
                    positiveStyle: false
                )
            }
            .padding()
            .background(Theme.current.backgroundPrimary)
        }
    }
    return PreviewWrapper()
}

#Preview("Segmented Control") {
    struct PreviewWrapper: View {
        @State private var selectedTime = 60

        var body: some View {
            VStack(spacing: 20) {
                Text("Round Time: \(selectedTime)s")
                    .font(Theme.Typography.body(size: 16))
                    .foregroundColor(Theme.current.textPrimary)

                SegmentedControl(
                    options: [30, 60, 90, 120],
                    selection: $selectedTime,
                    label: { "\($0)s" }
                )
            }
            .padding()
            .background(Theme.current.backgroundPrimary)
        }
    }
    return PreviewWrapper()
}
