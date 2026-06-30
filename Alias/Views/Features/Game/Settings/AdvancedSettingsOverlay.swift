import SwiftUI

/// Overlay for advanced game settings
struct AdvancedSettingsOverlay: View {
    @Binding var isExpanded: Bool
    @Binding var selectedRoundTime: Int
    @Binding var selectedPointsToWin: Int
    @Binding var guesserPoints: Int
    @Binding var explainerPoints: Int
    @Binding var guesserPenalty: Int
    @Binding var explainerPenalty: Int
    @Binding var lastWordBonusEnabled: Bool
    @Binding var lastWordBonusPoints: Int

    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Dimming background for tap-to-dismiss
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            isExpanded = false
                        }
                    }

                // Settings panel
                VStack(spacing: 0) {
                    AdvancedSettingsContent(
                        isExpanded: isExpanded,
                        selectedRoundTime: $selectedRoundTime,
                        selectedPointsToWin: $selectedPointsToWin,
                        guesserPoints: $guesserPoints,
                        explainerPoints: $explainerPoints,
                        guesserPenalty: $guesserPenalty,
                        explainerPenalty: $explainerPenalty,
                        lastWordBonusEnabled: $lastWordBonusEnabled,
                        lastWordBonusPoints: $lastWordBonusPoints
                    )
                }
                .padding(.bottom, 0)
                .offset(y: dragOffset)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = max(0, value.translation.height)
                        }
                        .onEnded { value in
                            if value.translation.height > 100 {
                                isExpanded = false
                            }
                        }
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .transition(.move(edge: .bottom))
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isExpanded)
        .animation(.interactiveSpring(), value: dragOffset)
    }
}

/// Content of the advanced settings
private struct AdvancedSettingsContent: View {
    let isExpanded: Bool
    @Binding var selectedRoundTime: Int
    @Binding var selectedPointsToWin: Int
    @Binding var guesserPoints: Int
    @Binding var explainerPoints: Int
    @Binding var guesserPenalty: Int
    @Binding var explainerPenalty: Int
    @Binding var lastWordBonusEnabled: Bool
    @Binding var lastWordBonusPoints: Int

    var body: some View {
        if isExpanded {
            SettingsSection {
                VStack(spacing: 24) {
                    SettingsHandle()
                    RoundTimePicker(selectedRoundTime: $selectedRoundTime)
                    PointsToWinPicker(selectedPointsToWin: $selectedPointsToWin)
                    GuessedWordPointsRow(
                        guesserValue: $guesserPoints,
                        explainerValue: $explainerPoints
                    )
                    SkippedWordPenaltyRow(
                        guesserValue: $guesserPenalty,
                        explainerValue: $explainerPenalty
                    )
                    LastWordBonusRow(
                        enabled: $lastWordBonusEnabled,
                        points: $lastWordBonusPoints
                    )
                }
            }
            .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
            .zIndex(-1)
        }
    }
}

/// Handle for dragging the settings panel
private struct SettingsHandle: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Theme.current.textPrimary.opacity(0.8))
            .frame(width: 70, height: 5)
    }
}

/// Section wrapper for settings
private struct SettingsSection<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(.all, 20)
            .padding(.bottom, 40)
            .background(
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color.black.opacity(0.8))
            )
    }
}
