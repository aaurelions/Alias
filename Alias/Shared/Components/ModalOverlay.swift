import SwiftUI

// MARK: - Modal Overlay

/// A flexible modal overlay component for displaying alerts, forms, and dialogs
struct ModalOverlay<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content

    var backgroundColor: Color
    var dimBackgroundColor: Color = .black.opacity(0.75)
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
        _isPresented = isPresented
        self.content = content()
        self.backgroundColor = backgroundColor ?? Theme.current.surfacePrimary.opacity(0.2)
        self.cornerRadius = cornerRadius
        self.maxWidth = maxWidth
        self.allowsDismissOnBackgroundTap = allowsDismissOnBackgroundTap
    }

    var body: some View {
        ZStack {
            Color.clear
                .background(.ultraThinMaterial)
                .ignoresSafeArea()

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
        _isPresented = isPresented
        self.content = content()
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }

    var body: some View {
        ModalOverlay(isPresented: $isPresented, allowsDismissOnBackgroundTap: false) {
            VStack(spacing: 0) {
                ZStack {
                    Text(title)
                        .font(Theme.Typography.heading1(size: 20))
                        .foregroundStyle(Theme.current.textPrimary.opacity(0.8))

                    HStack {
                        Spacer()
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Theme.current.textPrimary.opacity(0.5))
                                .padding(8)
                                .background(Color.black.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding()
                .background(Theme.current.interactiveSecondary.opacity(0.1))

                content
                    .padding()

                if primaryAction != nil || secondaryAction != nil {
                    HStack(spacing: 12) {
                        if let secondaryAction {
                            AlertActionButton(
                                title: secondaryAction.title,
                                style: .secondary,
                                isLoading: secondaryAction.isLoading,
                                action: secondaryAction.action
                            )
                            .disabled(secondaryAction.isDisabled)
                        }

                        if let primaryAction {
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
        case .primary: Theme.current.interactivePrimary
        case .secondary: Theme.current.surfaceSecondary.opacity(0.5)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: Theme.current.backgroundPrimary
        case .secondary: Theme.current.textPrimary.opacity(0.7)
        }
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(Theme.Typography.bodyLarge(size: 18))
                    .fontWeight(.bold)
                    .foregroundStyle(foregroundColor)
                    .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                }
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .clipShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

// MARK: - Previews
