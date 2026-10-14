import SwiftUI

// MARK: - Badge

/// Small badge label for counts or status
struct Badge: View {
    let text: String
    var backgroundColor: Color = Theme.current.surfacePrimary.opacity(0.7)
    var foregroundColor: Color = Theme.current.textPrimary

    var body: some View {
        Text(text)
            .font(Theme.Typography.bodySmall(size: 12))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
            )
    }
}

// MARK: - Previews

#Preview("Badge") {
    HStack(spacing: 16) {
        Badge(text: "3")
        Badge(
            text: "NEW",
            backgroundColor: Theme.current.accentSuccess.opacity(0.3),
            foregroundColor: Theme.current.accentSuccess
        )
        Badge(
            text: "PRO",
            backgroundColor: Theme.current.accentWarning.opacity(0.3),
            foregroundColor: Theme.current.accentWarning
        )
        Badge(
            text: "99+",
            backgroundColor: Theme.current.accentDestructive.opacity(0.3),
            foregroundColor: Theme.current.accentDestructive
        )
    }
    .padding()
    .background(Theme.current.backgroundPrimary)
}
