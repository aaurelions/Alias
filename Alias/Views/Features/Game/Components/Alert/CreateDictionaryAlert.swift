import SwiftUI

/// Alert for creating AI-generated dictionary
struct CreateDictionaryAlert: View {
    @Binding var isPresented: Bool
    let onGenerate: (String) async -> Void
    var generationProgress: (current: Int, total: Int)? = nil
    var generationError: String? = nil

    var body: some View {
        FormModal(
            title: L.Dictionary.Create.title,
            isPresented: $isPresented
        ) {
            CreateDictionaryAlertContent(
                isPresented: $isPresented,
                onGenerate: onGenerate,
                generationProgress: generationProgress,
                generationError: generationError
            )
        }
        .presentationBackground(Color.clear)
    }
}

/// Content of the create dictionary alert
private struct CreateDictionaryAlertContent: View {
    @Binding var isPresented: Bool
    let onGenerate: (String) async -> Void
    var generationProgress: (current: Int, total: Int)? = nil
    var generationError: String? = nil

    @State private var prompt: String = ""
    @State private var isGenerating: Bool = false
    @FocusState private var isPromptEditorFocused: Bool

    var body: some View {
        VStack(spacing: 16) {
            CreateDictionaryInstructions(
                isGenerating: isGenerating,
                generationProgress: generationProgress,
                generationError: generationError
            )
            CreateDictionaryPromptEditor(prompt: $prompt, isFocused: $isPromptEditorFocused, isGenerating: isGenerating)
            CreateDictionaryActionButtons(
                isPresented: $isPresented,
                prompt: prompt,
                isGenerating: $isGenerating,
                isPromptEditorFocused: _isPromptEditorFocused,
                onGenerate: onGenerate
            )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                isPromptEditorFocused = true
            }
        }
        .onChange(of: generationProgress?.current) { oldValue, newValue in
            // Update generating state based on progress
            isGenerating = generationProgress != nil
        }
        .onChange(of: generationError) { _, newValue in
            if newValue != nil {
                isGenerating = false
            }
        }
    }
}

/// Instructions for creating dictionary
private struct CreateDictionaryInstructions: View {
    let isGenerating: Bool
    var generationProgress: (current: Int, total: Int)? = nil
    var generationError: String? = nil

    var body: some View {
        VStack(spacing: 8) {
            if let generationError {
                VStack(spacing: 8) {
                    Text(L.Dictionary.Create.failed)
                        .font(Theme.Typography.bodySmall(size: 14))
                        .foregroundColor(Theme.current.accentDestructive)
                        .multilineTextAlignment(.center)

                    Text(generationError)
                        .font(Theme.Typography.bodySmall(size: 12))
                        .foregroundColor(Theme.current.textSecondary)
                        .multilineTextAlignment(.center)
                }
            } else if let progress = generationProgress {
                // Show progress with word count
                VStack(spacing: 12) {
                    Text(L.Dictionary.Create.generating)
                        .font(Theme.Typography.bodySmall(size: 14))
                        .foregroundColor(Theme.current.textPrimary)
                        .multilineTextAlignment(.center)

                    // Progress bar
                    VStack(spacing: 6) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Theme.current.surfacePrimary.opacity(0.3))
                                    .frame(height: 8)

                                // Progress
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Theme.current.accentSuccess)
                                    .frame(width: geometry.size.width * progressFraction, height: 8)
                                    .animation(.linear(duration: 0.3), value: progress.current)
                            }
                        }
                        .frame(height: 8)

                        // Word count text
                        HStack {
                            Text("\(progress.current) / \(progress.total) \(L.Dictionary.Create.words)")
                                .font(Theme.Typography.bodySmall(size: 12))
                                .foregroundColor(Theme.current.textSecondary)

                            Spacer()

                            Text("\(Int(progressFraction * 100))%")
                                .font(Theme.Typography.bodySmall(size: 12))
                                .foregroundColor(Theme.current.accentSuccess)
                                .monospacedDigit()
                        }
                    }
                }
            } else if !isGenerating {
                Text(L.Dictionary.Create.instruction)
                    .font(Theme.Typography.bodySmall(size: 14))
                    .foregroundColor(Theme.current.textPrimary)
                    .multilineTextAlignment(.center)

                Text(L.Dictionary.Create.example)
                    .font(Theme.Typography.bodySmall(size: 12))
                    .foregroundColor(Theme.current.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            } else {
                // Loading state without progress
                Text(L.Dictionary.Create.generating)
                    .font(Theme.Typography.bodySmall(size: 14))
                    .foregroundColor(Theme.current.textPrimary)
                    .multilineTextAlignment(.center)

                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Theme.current.textSecondary)
                            .frame(width: 6, height: 6)
                            .scaleEffect(isGenerating ? 1.0 : 0.5)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                value: isGenerating
                            )
                    }
                }
                .padding(.top, 4)
            }
        }
    }

    private var progressFraction: Double {
        guard let progress = generationProgress, progress.total > 0 else { return 0 }
        return min(1, max(0, Double(progress.current) / Double(progress.total)))
    }
}

/// Text editor for dictionary prompt
private struct CreateDictionaryPromptEditor: View {
    @Binding var prompt: String
    let isFocused: FocusState<Bool>.Binding
    let isGenerating: Bool

    var body: some View {
        TextEditor(text: $prompt)
            .font(Theme.Typography.body(size: 16))
            .foregroundColor(Theme.current.textPrimary)
            .scrollContentBackground(.hidden)
            .frame(height: 100)
            .padding(10)
            .background(Color.black.opacity(0.2))
            .cornerRadius(10)
            .focused(isFocused)
            .disabled(isGenerating)
            .opacity(isGenerating ? 0.5 : 1.0)
    }
}

/// Action buttons for create dictionary alert
private struct CreateDictionaryActionButtons: View {
    @Binding var isPresented: Bool
    let prompt: String
    @Binding var isGenerating: Bool
    @FocusState var isPromptEditorFocused: Bool
    let onGenerate: (String) async -> Void

    var body: some View {
        HStack(spacing: 12) {
            AlertActionButton(title: L.cancel, style: .secondary) {
                isPresented = false
            }
            .disabled(isGenerating)

            AlertActionButton(title: L.Dictionary.Create.generate, style: .primary, isLoading: isGenerating) {
                isPromptEditorFocused = false
                Task {
                    isGenerating = true
                    await onGenerate(prompt)
                }
            }
            .disabled(isGenerating || prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
        }
        .padding(.top, 10)
    }
}
