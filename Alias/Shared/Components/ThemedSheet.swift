import SwiftUI

extension View {
    /// Styles the root view of a `.sheet` with the app's dark look and a detent that fits the content.
    ///
    /// The content scrolls when it is taller than the space available, for example on small
    /// screens or while the keyboard is up; keyboard avoidance is left to the system sheet.
    func themedSheet() -> some View {
        modifier(ThemedSheetModifier())
    }
}

private struct ThemedSheetModifier: ViewModifier {
    @State private var contentHeight: CGFloat?

    func body(content: Content) -> some View {
        ScrollView {
            content
                .padding(.horizontal, 20)
                .padding(.top, 32)
                .padding(.bottom, 20)
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.height
                } action: { height in
                    contentHeight = height
                }
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
        .presentationDetents(contentHeight.map { [.height($0)] } ?? [.medium])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(20)
        .presentationBackground(.black.opacity(0.9))
    }
}

/// Centered title at the top of a themed sheet.
struct SheetTitle: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(Theme.Typography.heading1(size: 22))
            .foregroundStyle(Theme.current.textPrimary.opacity(0.8))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .accessibilityAddTraits(.isHeader)
    }
}
