import SwiftUI

// MARK: - Row Title

/// Icon and title shown at the top of a settings row.
struct RowTitle: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        Label {
            Text(text)
                .font(Theme.Typography.heading2(size: 18))
                .foregroundStyle(Theme.current.textSecondary)
        } icon: {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color.opacity(0.8))
        }
    }
}

// MARK: - Toggle Row

/// A settings switch whose title is also its accessibility label.
struct ToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    var color: Color = Theme.current.accentSuccess

    var body: some View {
        Toggle(isOn: $isOn) {
            RowTitle(icon: icon, color: color, text: title)
        }
        .tint(color)
        .padding(.horizontal, 4)
    }
}

#Preview {
    @Previewable @State var isOn = true

    ToggleRow(icon: "speaker.wave.2.fill", title: "Sound", isOn: $isOn)
        .padding()
        .background(Theme.current.backgroundPrimary)
}
