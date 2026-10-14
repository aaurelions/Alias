import SwiftUI

/// Asks for a topic and shows streaming progress while the dictionary is generated.
/// Present it with `.sheet`; dismissing it cancels a running generation.
struct CreateDictionarySheet: View {
    let state: NewGameModel.GenerationState
    let onGenerate: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var topic = ""
    @FocusState private var isTopicFocused: Bool

    private var trimmedTopic: String {
        topic.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(spacing: 16) {
            SheetTitle(L.Dictionary.Create.title)

            GenerationStatusView(state: state)

            TextEditor(text: $topic)
                .font(Theme.Typography.body(size: 16))
                .foregroundStyle(Theme.current.textPrimary)
                .scrollContentBackground(.hidden)
                .frame(height: 100)
                .padding(10)
                .background(.black.opacity(0.2), in: .rect(cornerRadius: 10))
                .focused($isTopicFocused)
                .disabled(state.isGenerating)
                .opacity(state.isGenerating ? 0.5 : 1)

            HStack(spacing: 12) {
                ActionButton(title: L.cancel, role: .secondary) { dismiss() }

                ActionButton(title: L.Dictionary.Create.generate, isLoading: state.isGenerating) {
                    isTopicFocused = false
                    onGenerate(trimmedTopic)
                }
                .disabled(trimmedTopic.isEmpty)
            }
            .padding(.top, 10)
        }
        .themedSheet()
        .onAppear { isTopicFocused = true }
    }
}

private struct GenerationStatusView: View {
    let state: NewGameModel.GenerationState

    var body: some View {
        VStack(spacing: 8) {
            switch state {
            case .idle:
                Text(L.Dictionary.Create.instruction)
                    .font(Theme.Typography.bodySmall(size: 14))
                    .foregroundStyle(Theme.current.textPrimary)

                Text(L.Dictionary.Create.example)
                    .font(Theme.Typography.bodySmall(size: 12))
                    .foregroundStyle(Theme.current.textSecondary)
                    .lineSpacing(4)

            case .generating(let received, let target):
                Text(L.Dictionary.Create.generating)
                    .font(Theme.Typography.bodySmall(size: 14))
                    .foregroundStyle(Theme.current.textPrimary)

                GenerationProgressBar(received: received, target: target)

            case .failed(let message):
                Text(L.Dictionary.Create.failed)
                    .font(Theme.Typography.bodySmall(size: 14))
                    .foregroundStyle(Theme.current.accentDestructive)

                Text(message)
                    .font(Theme.Typography.bodySmall(size: 12))
                    .foregroundStyle(Theme.current.textSecondary)
            }
        }
        .multilineTextAlignment(.center)
    }
}

private struct GenerationProgressBar: View {
    let received: Int
    let target: Int

    private var fraction: Double {
        target > 0 ? min(1, Double(received) / Double(target)) : 0
    }

    var body: some View {
        VStack(spacing: 6) {
            ProgressView(value: fraction)
                .tint(Theme.current.accentSuccess)
                .animation(.linear(duration: 0.3), value: received)

            HStack {
                Text(L.Dictionary.Create.progress(received, target))
                    .foregroundStyle(Theme.current.textSecondary)
                Spacer()
                Text(fraction, format: .percent.precision(.fractionLength(0)))
                    .foregroundStyle(Theme.current.accentSuccess)
                    .monospacedDigit()
            }
            .font(Theme.Typography.bodySmall(size: 12))
        }
    }
}

#Preview {
    Color.black
        .sheet(isPresented: .constant(true)) {
            CreateDictionarySheet(state: .generating(received: 120, target: 300)) { _ in }
        }
        .previewEnvironment()
}
