import SwiftUI

// MARK: - Generic Card

/// A reusable card component with customizable content and selection state
struct Card<Content: View>: View {
    let content: Content
    var isSelected: Bool = false
    var cornerRadius: CGFloat = 16
    var onTap: (() -> Void)? = nil

    init(
        isSelected: Bool = false,
        cornerRadius: CGFloat = 16,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.isSelected = isSelected
        self.cornerRadius = cornerRadius
        self.onTap = onTap
    }

    var body: some View {
        content
            .background(cardBackground)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.7),
                value: isSelected
            )
            .onTapGesture {
                onTap?()
            }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                isSelected
                    ? Theme.current.surfaceSecondary.opacity(0.2)
                    : Theme.current.surfaceSecondary.opacity(0.05)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        isSelected
                            ? Theme.current.borderPrimary.opacity(0.9)
                            : Theme.current.borderPrimary.opacity(0.4),
                        lineWidth: isSelected ? 1 : 2
                    )
            )
            .shadow(
                color: isSelected
                    ? Theme.current.surfaceSecondary.opacity(0.3)
                    : .black.opacity(0.3),
                radius: isSelected ? 12 : 8,
                x: 0,
                y: isSelected ? 6 : 4
            )
    }
}

// MARK: - List Item Card

/// Card styled for use in lists with consistent padding
struct ListItemCard<Content: View>: View {
    let content: Content
    var onTap: (() -> Void)? = nil

    init(
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.onTap = onTap
    }

    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.current.surfacePrimary.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                Theme.current.surfacePrimary.opacity(0.9),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.9), radius: 5, x: 0, y: 3)
            )
            .onTapGesture {
                onTap?()
            }
    }
}

// MARK: - Previews

#Preview("Generic Card") {
    VStack(spacing: 20) {
        Card(isSelected: false) {
            VStack(spacing: 8) {
                Text("Unselected Card")
                    .font(Theme.Typography.heading2(size: 18))
                    .foregroundColor(Theme.current.textPrimary)
                Text("Tap to select")
                    .font(Theme.Typography.bodySmall(size: 14))
                    .foregroundColor(Theme.current.textSecondary)
            }
            .padding()
        }

        Card(isSelected: true, onTap: {}) {
            VStack(spacing: 8) {
                Text("Selected Card")
                    .font(Theme.Typography.heading2(size: 18))
                    .foregroundColor(Theme.current.textPrimary)
                Text("Currently active")
                    .font(Theme.Typography.bodySmall(size: 14))
                    .foregroundColor(Theme.current.textSecondary)
            }
            .padding()
        }
    }
    .padding()
    .background(Theme.current.backgroundPrimary)
}

#Preview("List Item Card") {
    VStack(spacing: 16) {
        ListItemCard {
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(Theme.current.interactivePrimary)
                Text("Player Name")
                    .font(Theme.Typography.body(size: 16))
                    .foregroundColor(Theme.current.textPrimary)
                Spacer()
                Text("Score: 42")
                    .font(Theme.Typography.bodySmall(size: 14))
                    .foregroundColor(Theme.current.textSecondary)
            }
        }

        ListItemCard(onTap: {}) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(Theme.current.accentSuccess)
                Text("Dictionary Item")
                    .font(Theme.Typography.body(size: 16))
                    .foregroundColor(Theme.current.textPrimary)
                Spacer()
            }
        }
    }
    .padding()
    .background(Theme.current.backgroundPrimary)
}
