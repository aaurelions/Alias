import SwiftUI

/// App-wide preferences. Present it with `.sheet`; keyboard avoidance is handled by the system sheet.
struct AppSettingsSheet: View {
    @Environment(AppSettings.self) private var settings

    var body: some View {
        @Bindable var settings = settings

        VStack(spacing: 24) {
            LanguageSelector(selectedLanguage: $settings.language)
            ToggleRow(icon: "speaker.wave.2.fill", title: L.Settings.sound, isOn: $settings.soundEnabled)
            ToggleRow(icon: "iphone.radiowaves.left.and.right", title: L.Settings.vibration, isOn: $settings.vibrationEnabled)
            LLMSettingsSection(
                baseURL: $settings.llmBaseURL,
                apiKey: $settings.llmAPIKey,
                model: $settings.llmModel,
                configuration: settings.llmConfiguration
            )
        }
        .themedSheet()
    }
}

// MARK: - LLM Settings

/// Connection to the OpenAI-compatible service that generates custom dictionaries.
private struct LLMSettingsSection: View {
    private enum Field: Hashable {
        case baseURL, apiKey, model
    }

    @Binding var baseURL: String
    @Binding var apiKey: String
    @Binding var model: String
    /// The effective configuration, including development environment fallbacks.
    let configuration: LLMConfiguration

    @FocusState private var focusedField: Field?
    @State private var isAPIKeyVisible = false

    private static func prompt(_ text: String) -> Text {
        Text(text).foregroundStyle(Theme.current.textSecondary.opacity(0.7))
    }

    /// Flags a malformed URL once the player has left the field, not while they are typing it.
    private var baseURLMessage: String? {
        let trimmed = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, focusedField != .baseURL,
              LLMConfiguration(baseURL: trimmed, apiKey: "", model: "").endpoint == nil
        else { return nil }
        return L.Settings.LLM.baseURLInvalid
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    RowTitle(icon: "sparkles", color: Theme.current.accentHighlight, text: L.Settings.LLM.title)
                    Spacer()
                    StatusBadge(isReady: configuration.issues.isEmpty)
                }

                Text(L.Settings.LLM.subtitle)
                    .font(Theme.Typography.bodySmall(size: 12))
                    .foregroundStyle(Theme.current.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            LabeledInput(title: L.Settings.LLM.baseURL, icon: "link", message: baseURLMessage) {
                TextField(text: $baseURL, prompt: Self.prompt(L.Settings.LLM.baseURLPlaceholder)) { Text(L.Settings.LLM.baseURL) }
                    .keyboardType(.URL)
                    .textContentType(.URL)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .baseURL)
                    .onSubmit { focusedField = .apiKey }
            }

            LabeledInput(title: L.Settings.LLM.apiKey, icon: "key.fill") {
                HStack(spacing: 8) {
                    Group {
                        if isAPIKeyVisible {
                            TextField(text: $apiKey, prompt: Self.prompt(L.Settings.LLM.apiKeyPlaceholder)) { Text(L.Settings.LLM.apiKey) }
                        } else {
                            SecureField(text: $apiKey, prompt: Self.prompt(L.Settings.LLM.apiKeyPlaceholder)) { Text(L.Settings.LLM.apiKey) }
                        }
                    }
                    .textContentType(.password)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .apiKey)
                    .onSubmit { focusedField = .model }

                    Button {
                        isAPIKeyVisible.toggle()
                    } label: {
                        Image(systemName: isAPIKeyVisible ? "eye.slash" : "eye")
                            .font(.system(size: 16))
                            .foregroundStyle(Theme.current.textSecondary)
                            .frame(width: 28, height: 28)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isAPIKeyVisible ? L.Settings.LLM.hideAPIKey : L.Settings.LLM.showAPIKey)
                }
            }

            LabeledInput(title: L.Settings.LLM.model, icon: "cpu") {
                TextField(text: $model, prompt: Self.prompt(L.Settings.LLM.modelPlaceholder)) { Text(L.Settings.LLM.model) }
                    .submitLabel(.done)
                    .focused($focusedField, equals: .model)
                    .onSubmit { focusedField = nil }
            }

            Label {
                Text(L.Settings.LLM.help)
                    .fixedSize(horizontal: false, vertical: true)
            } icon: {
                Image(systemName: "lock.fill")
            }
            .font(Theme.Typography.bodySmall(size: 12))
            .foregroundStyle(Theme.current.textSecondary)
        }
        .padding(16)
        .background(Theme.current.surfacePrimary.opacity(0.08), in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.current.borderPrimary.opacity(0.3), lineWidth: 1)
        }
        .animation(.easeInOut(duration: 0.2), value: baseURLMessage)
    }
}

/// A captioned input row: title above, icon and field inside a dark rounded box, optional error below.
private struct LabeledInput<Field: View>: View {
    let title: String
    let icon: String
    var message: String?
    @ViewBuilder let field: Field

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(Theme.Typography.bodySmall(size: 13))
                .foregroundStyle(Theme.current.textSecondary)
                .accessibilityHidden(true)

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.current.textSecondary.opacity(0.8))
                    .frame(width: 20)
                    .accessibilityHidden(true)

                field
                    .font(Theme.Typography.body(size: 16))
                    .foregroundStyle(Theme.current.textPrimary)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .accessibilityLabel(title)
                    .accessibilityHint(message ?? "")
            }
            .padding(.horizontal, 12)
            .frame(minHeight: 46)
            .background(.black.opacity(0.25), in: .rect(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(message == nil ? Theme.current.borderPrimary.opacity(0.2) : Theme.current.accentDestructive, lineWidth: 1)
            }

            if let message {
                Text(message)
                    .font(Theme.Typography.bodySmall(size: 12))
                    .foregroundStyle(Theme.current.accentDestructive)
                    .transition(.opacity)
            }
        }
    }
}

private struct StatusBadge: View {
    let isReady: Bool

    var body: some View {
        Label(
            isReady ? L.Settings.LLM.statusReady : L.Settings.LLM.statusIncomplete,
            systemImage: isReady ? "checkmark.circle.fill" : "exclamationmark.circle"
        )
        .font(Theme.Typography.bodySmall(size: 12))
        .foregroundStyle(isReady ? Theme.current.accentSuccess : Theme.current.textSecondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background((isReady ? Theme.current.accentSuccess : Theme.current.textSecondary).opacity(0.15), in: .capsule)
    }
}

// MARK: - Language Selector

private struct LanguageSelector: View {
    @Binding var selectedLanguage: Language

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            RowTitle(icon: "globe", color: Theme.current.textPrimary, text: L.Settings.language)

            HStack(spacing: 12) {
                ForEach(Language.allCases) { language in
                    LanguageButton(language: language, isSelected: selectedLanguage == language) {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                            selectedLanguage = language
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Language Button

private struct LanguageButton: View {
    let language: Language
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(language.flag)
                    .font(.system(size: 36))
                    .accessibilityHidden(true)

                Text(language.displayName)
                    .font(Theme.Typography.bodySmall(size: 12))
                    .foregroundStyle(isSelected ? Theme.current.textPrimary : Theme.current.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.current.interactiveSecondary.opacity(isSelected ? 0.5 : 0.1))
                    .stroke(Theme.current.interactivePrimary, lineWidth: isSelected ? 2 : 0)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Previews

#Preview {
    Color.black
        .sheet(isPresented: .constant(true)) {
            AppSettingsSheet()
        }
        .previewEnvironment()
}
