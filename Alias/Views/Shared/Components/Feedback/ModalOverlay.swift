import SwiftUI

// MARK: - Modal Overlay

/// A flexible modal overlay component for displaying alerts, forms, and dialogs
/// Fully customizable with any content type
struct ModalOverlay<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content

    var backgroundColor: Color
    var dimBackgroundColor: Color = Color.black.opacity(0.75)
    var cornerRadius: CGFloat = 20
    var maxWidth: CGFloat = 500
    var allowsDismissOnBackgroundTap: Bool = true

    init(
        isPresented: Binding<Bool>,
        backgroundColor: Color? = nil,
        cornerRadius: CGFloat = 20,
        maxWidth: CGFloat = 500,
        allowsDismissOnBackgroundTap: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.content = content()
        self.backgroundColor = backgroundColor ?? Theme.current.surfacePrimary.opacity(0.2)
        self.cornerRadius = cornerRadius
        self.maxWidth = maxWidth
        self.allowsDismissOnBackgroundTap = allowsDismissOnBackgroundTap
    }

    var body: some View {
        ZStack {
            // Blurred background layer
            Color.clear
                .background(.ultraThinMaterial)
                .ignoresSafeArea()

            // Semi-transparent black overlay
            dimBackgroundColor
                .ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture {
                    if allowsDismissOnBackgroundTap {
                        isPresented = false
                    }
                }

            ScrollView {
                content
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(backgroundColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(Theme.current.interactiveSecondary.opacity(0.6), lineWidth: 1)
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .shadow(color: .black.opacity(0.5), radius: 20)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: maxWidth)
            }
            .transition(.scale(scale: 0.95).combined(with: .opacity))
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isPresented)
    }
}

// MARK: - Alert Dialog

/// Pre-configured modal for alert-style dialogs with title, message, and actions
struct AlertDialog: View {
    let title: String
    let message: String?
    let primaryButton: AlertButton
    let secondaryButton: AlertButton?
    @Binding var isPresented: Bool

    init(
        title: String,
        message: String? = nil,
        primaryButton: AlertButton,
        secondaryButton: AlertButton? = nil,
        isPresented: Binding<Bool>
    ) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
        self._isPresented = isPresented
    }

    var body: some View {
        ModalOverlay(isPresented: $isPresented) {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Text(title)
                        .font(Theme.Typography.heading1(size: 20))
                        .foregroundColor(Theme.current.textPrimary)
                        .multilineTextAlignment(.center)

                    if let message = message {
                        Text(message)
                            .font(Theme.Typography.body(size: 16))
                            .foregroundColor(Theme.current.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)

                HStack(spacing: 12) {
                    if let secondaryButton = secondaryButton {
                        AlertActionButton(
                            title: secondaryButton.title,
                            style: .secondary,
                            action: {
                                secondaryButton.action()
                                isPresented = false
                            }
                        )
                    }

                    AlertActionButton(
                        title: primaryButton.title,
                        style: .primary,
                        action: {
                            primaryButton.action()
                            isPresented = false
                        }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Alert Button

struct AlertButton {
    let title: String
    let action: () -> Void

    static func `default`(_ title: String, action: @escaping () -> Void) -> AlertButton {
        AlertButton(title: title, action: action)
    }

    static func cancel(_ title: String = "Cancel", action: @escaping () -> Void = {}) -> AlertButton {
        AlertButton(title: title, action: action)
    }

    static func destructive(_ title: String, action: @escaping () -> Void) -> AlertButton {
        AlertButton(title: title, action: action)
    }
}

// MARK: - Form Modal

/// Pre-configured modal for form-style content with header and actions
struct FormModal<Content: View>: View {
    let title: String
    @Binding var isPresented: Bool
    let content: Content
    let primaryAction: FormAction?
    let secondaryAction: FormAction?

    init(
        title: String,
        isPresented: Binding<Bool>,
        primaryAction: FormAction? = nil,
        secondaryAction: FormAction? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self._isPresented = isPresented
        self.content = content()
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }

    var body: some View {
        ModalOverlay(isPresented: $isPresented, allowsDismissOnBackgroundTap: false) {
            VStack(spacing: 0) {
                // Header
                ZStack {
                    Text(title)
                        .font(Theme.Typography.heading1(size: 20))
                        .foregroundColor(Theme.current.textPrimary.opacity(0.8))

                    HStack {
                        Spacer()
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Theme.current.textPrimary.opacity(0.5))
                                .padding(8)
                                .background(Color.black.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding()
                .background(Theme.current.interactiveSecondary.opacity(0.1))

                // Content
                content
                    .padding()

                // Actions
                if primaryAction != nil || secondaryAction != nil {
                    HStack(spacing: 12) {
                        if let secondaryAction = secondaryAction {
                            AlertActionButton(
                                title: secondaryAction.title,
                                style: .secondary,
                                isLoading: secondaryAction.isLoading,
                                action: secondaryAction.action
                            )
                            .disabled(secondaryAction.isDisabled)
                        }

                        if let primaryAction = primaryAction {
                            AlertActionButton(
                                title: primaryAction.title,
                                style: .primary,
                                isLoading: primaryAction.isLoading,
                                action: primaryAction.action
                            )
                            .disabled(primaryAction.isDisabled)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
    }
}

// MARK: - Form Action

struct FormAction {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false

    init(title: String, isLoading: Bool = false, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
}

// MARK: - Alert Action Button Style

enum AlertActionButtonStyle {
    case primary
    case secondary
}

// MARK: - Alert Action Button

struct AlertActionButton: View {
    let title: String
    let style: AlertActionButtonStyle
    var isLoading: Bool = false
    let action: () -> Void

    private var backgroundColor: Color {
        switch style {
        case .primary: return Theme.current.interactivePrimary
        case .secondary: return Theme.current.surfaceSecondary.opacity(0.5)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return Theme.current.backgroundPrimary
        case .secondary: return Theme.current.textPrimary.opacity(0.7)
        }
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(Theme.Typography.bodyLarge(size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(foregroundColor)
                    .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                }
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

// MARK: - Previews

#Preview("Modal Overlay") {
    struct PreviewWrapper: View {
        @State private var isPresented = true

        var body: some View {
            ZStack {
                if isPresented {
                    ModalOverlay(isPresented: $isPresented) {
                        VStack(spacing: 16) {
                            Text("Custom Modal")
                                .font(Theme.Typography.heading1(size: 22))
                                .foregroundColor(Theme.current.textPrimary)

                            Text("This is a custom modal with any content you want.")
                                .font(Theme.Typography.body(size: 16))
                                .foregroundColor(Theme.current.textSecondary)
                                .multilineTextAlignment(.center)

                            PrimaryButton(title: "Close", action: { isPresented = false })
                        }
                        .padding(20)
                    }
                }
            }
        }
    }
    return PreviewWrapper()
}

#Preview("Alert Dialog") {
    struct PreviewWrapper: View {
        @State private var isPresented = true

        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()

                if isPresented {
                    AlertDialog(
                        title: "Delete Player?",
                        message: "This action cannot be undone. Are you sure you want to delete this player?",
                        primaryButton: .default("Delete") {},
                        secondaryButton: .cancel("Cancel") {},
                        isPresented: $isPresented
                    )
                }
            }
        }
    }
    return PreviewWrapper()
}

#Preview("Form Modal") {
    struct PreviewWrapper: View {
        @State private var isPresented = true
        @State private var text = ""

        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()

                if isPresented {
                    FormModal(
                        title: "Edit Item",
                        isPresented: $isPresented
                    ) {
                        VStack(spacing: 16) {
                            FormTextField(label: "Name", text: $text, placeholder: "Enter name...")
                            FormTextField(label: "Description", text: $text, placeholder: "Enter description...")
                        }
                    }
                }
            }
        }
    }
    return PreviewWrapper()
}
