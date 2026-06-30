import SwiftUI

// MARK: - Icon Label

/// Label with icon and text
struct IconLabel: View {
    let icon: String
    let text: String
    var iconColor: Color = Theme.current.textPrimary
    var textColor: Color = Theme.current.textSecondary
    var spacing: CGFloat = 8

    var body: some View {
        HStack(spacing: spacing) {
            Image(systemName: icon)
                .font(Theme.Typography.body(size: 18))
                .foregroundColor(iconColor.opacity(0.8))
            Text(text).font(Theme.Typography.heading2(size: 18))
                .foregroundColor(textColor)
        }
    }
}

// MARK: - Badge

/// Small badge label for counts or status
struct Badge: View {
    let text: String
    var backgroundColor: Color = Theme.current.surfacePrimary.opacity(0.7)
    var foregroundColor: Color = Theme.current.textPrimary

    var body: some View {
        Text(text)
            .font(Theme.Typography.bodySmall(size: 12))
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
            )
    }
}

// MARK: - Section Header

/// Section header with title and optional action
struct SectionHeader: View {
    let title: String
    var action: (() -> Void)? = nil
    var actionTitle: String? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(Theme.Typography.heading2(size: 20))
                .foregroundColor(Theme.current.textPrimary)

            Spacer()

            if let action = action, let actionTitle = actionTitle {
                TextButton(title: actionTitle, action: action)
            }
        }
    }
}

// MARK: - Previews

#Preview("Icon Label") {
    VStack(spacing: 20) {
        IconLabel(icon: "clock.fill", text: "Round Time")
        IconLabel(
            icon: "trophy.fill",
            text: "Points to Win",
            iconColor: Theme.current.accentWarning,
            textColor: Theme.current.textPrimary
        )
        IconLabel(
            icon: "checkmark.circle.fill",
            text: "Completed",
            iconColor: Theme.current.accentSuccess,
            spacing: 12
        )
    }
    .padding()
    .background(Theme.current.backgroundPrimary)
}

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

#Preview("Section Header") {
    VStack(spacing: 20) {
        SectionHeader(title: "Players")

        SectionHeader(
            title: "Dictionaries",
            action: {},
            actionTitle: "Add New"
        )

        SectionHeader(
            title: "Settings",
            action: {},
            actionTitle: "Reset"
        )
    }
    .padding()
    .background(Theme.current.backgroundPrimary)
}
