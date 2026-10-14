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
        GeometryReader { _ in
            ZStack(alignment: .bottom) {
                if allowsDismiss {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                isPresented = false
                            }
                        }
                }

                VStack(spacing: 0) {
                    if showsHandle {
                        BottomSheetHandle()
                            .padding(.top, 12)
                    }

                    content
                        .padding(.horizontal, 20)
                        .padding(.top, showsHandle ? 12 : 20)
                        .padding(.bottom, 40)
                }
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .offset(y: dragOffset)
                .gesture(
                    allowsDismiss ?
                        DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = max(0, value.translation.height)
                        }
                        .onEnded { value in
                            if value.translation.height > dismissThreshold {
                                isPresented = false
                            }
                        }
                        : nil
                )
            }
        }
        .ignoresSafeArea()
        .transition(.move(edge: .bottom))
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isPresented)
        .animation(.interactiveSpring(), value: dragOffset)
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
