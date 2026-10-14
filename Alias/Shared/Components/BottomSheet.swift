import SwiftUI

// MARK: - Bottom Sheet

/// A reusable bottom sheet overlay that can display any content
/// Supports drag-to-dismiss, tap background to dismiss, and customizable appearance
struct BottomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content

    var backgroundColor: Color = .black.opacity(0.9)
    var cornerRadius: CGFloat = 20
    var showsHandle: Bool = true
    var allowsDismiss: Bool = true
    var dismissThreshold: CGFloat = 100

    @GestureState private var dragOffset: CGFloat = 0

    init(
        isPresented: Binding<Bool>,
        backgroundColor: Color = Color.black.opacity(0.9),
        cornerRadius: CGFloat = 20,
        showsHandle: Bool = true,
        allowsDismiss: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        _isPresented = isPresented
        self.content = content()
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.showsHandle = showsHandle
        self.allowsDismiss = allowsDismiss
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                if allowsDismiss {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture(perform: dismiss)
                }

                VStack(spacing: 0) {
                    if showsHandle {
                        BottomSheetHandle()
                            .padding(.top, 12)
                            .padding(.bottom, 12)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            // The handle always wins the drag, even when the content scrolls.
                            .highPriorityGesture(dragToDismiss)
                            .accessibilityElement()
                            .accessibilityAddTraits(.isButton)
                            .accessibilityAction(named: Text(L.close), dismiss)
                    }

                    content
                        .padding(.horizontal, 20)
                        .padding(.top, showsHandle ? 0 : 20)
                        .padding(.bottom, 40)
                }
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .offset(y: dragOffset)
                .gesture(dragToDismiss)
                // Never cover the whole screen so the backdrop stays tappable.
                .padding(.top, geometry.size.height * (1 - maxHeightFraction))
            }
        }
        .ignoresSafeArea()
        .transition(.move(edge: .bottom))
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isPresented)
        .animation(.interactiveSpring(), value: dragOffset)
    }

    private var maxHeightFraction: CGFloat { 0.85 }

    private var dragToDismiss: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                guard allowsDismiss else { return }
                state = max(0, value.translation.height)
            }
            .onEnded { value in
                guard allowsDismiss else { return }
                if value.translation.height > dismissThreshold || value.predictedEndTranslation.height > dismissThreshold * 2 {
                    dismiss()
                }
            }
    }

    private func dismiss() {
        guard allowsDismiss else { return }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            isPresented = false
        }
    }
}

// MARK: - Bottom Sheet Handle

struct BottomSheetHandle: View {
    var color: Color = .white.opacity(0.6)
    var width: CGFloat = 70
    var height: CGFloat = 5

    var body: some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(color)
            .frame(width: width, height: height)
    }
}

// MARK: - Previews
