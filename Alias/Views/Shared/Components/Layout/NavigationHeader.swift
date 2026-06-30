import SwiftUI

// MARK: - Navigation Header

/// A flexible, reusable navigation header component
/// Supports optional left/right actions, customizable title, and styling
struct NavigationHeader: View {
    let title: String
    var leftAction: HeaderAction?
    var rightAction: HeaderAction?
    var showUnderline: Bool = true
    var titleOpacity: Double = 1

    var body: some View {
        ZStack {
            // Side actions
            HStack {
                if let leftAction = leftAction {
                    HeaderActionButton(action: leftAction)
                }

                Spacer()

                if let rightAction = rightAction {
                    HeaderActionButton(action: rightAction)
                }
            }

            // Centered title
            HStack {
                Spacer()

                VStack(spacing: 0) {
                    Text(title)
                        .font(Theme.Typography.logo(size: 32))
                        .foregroundColor(Theme.current.textPrimary)
                        .opacity(titleOpacity)

                    if showUnderline {
                        HeaderUnderline()
                    }
                }

                Spacer()
            }
        }
    }
}

// MARK: - Header Action

/// Defines an action that can be placed in a header
struct HeaderAction {
    let icon: String
    let action: () -> Void
    var accessibilityLabel: String?

    init(icon: String, accessibilityLabel: String? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    // Predefined actions
    static func back(action: @escaping () -> Void) -> HeaderAction {
        HeaderAction(icon: "chevron.left", accessibilityLabel: "Go Back", action: action)
    }

    static func close(action: @escaping () -> Void) -> HeaderAction {
        HeaderAction(icon: "xmark", accessibilityLabel: "Close", action: action)
    }

    static func settings(isExpanded: Bool, action: @escaping () -> Void) -> HeaderAction {
        HeaderAction(
            icon: isExpanded ? "gear.badge.checkmark" : "gear",
            accessibilityLabel: isExpanded ? "Close Settings" : "Open Settings",
            action: action
        )
    }

    static func custom(icon: String, accessibilityLabel: String, action: @escaping () -> Void) -> HeaderAction {
        HeaderAction(icon: icon, accessibilityLabel: accessibilityLabel, action: action)
    }
}

// MARK: - Header Action Button

/// Renders a header action as a button
private struct HeaderActionButton: View {
    let action: HeaderAction
    @State private var isPressed = false

    var body: some View {
        Button(action: action.action) {
            Image(systemName: action.icon)
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(Theme.current.textPrimary.opacity(0.4))
                .scaleEffect(isPressed ? 1.1 : 1.0)
        }
        .buttonStyle(.plain)
        .padding(.bottom, 10)
        .accessibilityLabel(action.accessibilityLabel ?? "")
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}

// MARK: - Header Underline

/// Decorative underline for header titles
struct HeaderUnderline: View {
    var color: Color = Theme.current.interactivePrimary
    var width: CGFloat = 100
    var thickness: CGFloat = 1
    var diamondSize: CGFloat = 15

    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
                .frame(height: thickness)
                .frame(width: width)

            Rectangle()
                .fill(color)
                .frame(width: diamondSize, height: diamondSize)
                .rotationEffect(.degrees(45))
        }
        .padding(.top, 10)
    }
}

// MARK: - Convenience Initializer with Dismiss

extension NavigationHeader {
    /// Creates a header with automatic back button using environment dismiss
    static func withBackButton(
        title: String,
        dismiss: DismissAction,
        rightAction: HeaderAction? = nil,
        showUnderline: Bool = true
    ) -> some View {
        NavigationHeader(
            title: title,
            leftAction: .back { dismiss() },
            rightAction: rightAction,
            showUnderline: showUnderline
        )
    }
}

// MARK: - Previews

#Preview("Navigation Header - Basic") {
    VStack(spacing: 0) {
        NavigationHeader(title: "Screen Title")
        Spacer()
    }
    .background(Theme.current.backgroundPrimary)
}

#Preview("Navigation Header - With Back") {
    VStack(spacing: 0) {
        NavigationHeader(
            title: "New Game",
            leftAction: .back {}
        )
        Spacer()
    }
    .background(Theme.current.backgroundPrimary)
}

#Preview("Navigation Header - With Settings") {
    struct PreviewWrapper: View {
        @State private var isExpanded = false

        var body: some View {
            VStack(spacing: 0) {
                NavigationHeader(
                    title: "Game Settings",
                    leftAction: .back {},
                    rightAction: .settings(
                        isExpanded: isExpanded,
                        action: { isExpanded.toggle() }
                    )
                )
                Spacer()
            }
            .background(Theme.current.backgroundPrimary)
        }
    }
    return PreviewWrapper()
}

#Preview("Navigation Header - Custom Actions") {
    VStack(spacing: 0) {
        NavigationHeader(
            title: "Edit Profile",
            leftAction: HeaderAction(icon: "xmark", action: {}),
            rightAction: HeaderAction(icon: "checkmark", action: {})
        )
        Spacer()
    }
    .background(Theme.current.backgroundPrimary)
}

#Preview("Navigation Header - No Underline") {
    VStack(spacing: 0) {
        NavigationHeader(
            title: "Clean Look",
            leftAction: .back { },
            showUnderline: false
        )
        Spacer()
    }
    .background(Theme.current.backgroundPrimary)
}
