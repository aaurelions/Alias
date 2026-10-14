import SwiftUI

struct AppSettingsSheet: View {
    @Binding var isPresented: Bool
    @Environment(AppSettings.self) private var settings

    var body: some View {
        @Bindable var settings = settings

        BottomSheet(isPresented: $isPresented) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    LanguageSelector(selectedLanguage: $settings.language)
                    SoundToggleRow(isEnabled: $settings.soundEnabled)
                    VibrationToggleRow(isEnabled: $settings.vibrationEnabled)
                    OpenRouterSettingsSection(apiKey: $settings.openRouterAPIKey, modelName: $settings.openRouterModel)
                }
            }
        }
    }
}

// MARK: - OpenRouter Settings

private struct OpenRouterSettingsSection: View {
    @Binding var apiKey: String
    @Binding var modelName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18))
                    .foregroundStyle(Theme.current.accentHighlight.opacity(0.8))

                Text(L.Settings.openRouter)
                    .font(Theme.Typography.heading2(size: 18))
                    .foregroundStyle(Theme.current.textSecondary)
            }

            SecureField(L.Settings.openRouterAPIKeyPlaceholder, text: $apiKey)
                .font(Theme.Typography.body(size: 16))
                .textContentType(.password)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(12)
                .background(Color.black.opacity(0.2))
                .clipShape(.rect(cornerRadius: 10))
                .foregroundStyle(Theme.current.textPrimary)
                .accessibilityLabel(L.Settings.openRouterAPIKey)

            TextField(L.Settings.openRouterModelPlaceholder, text: $modelName)
                .font(Theme.Typography.body(size: 16))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(12)
                .background(Color.black.opacity(0.2))
                .clipShape(.rect(cornerRadius: 10))
                .foregroundStyle(Theme.current.textPrimary)
                .accessibilityLabel(L.Settings.openRouterModel)

            Text(L.Settings.openRouterHelp)
                .font(Theme.Typography.bodySmall(size: 12))
                .foregroundStyle(Theme.current.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Language Selector

private struct LanguageSelector: View {
    @Binding var selectedLanguage: Language

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "globe")
                    .font(.system(size: 18))
                    .foregroundStyle(Theme.current.textPrimary.opacity(0.8))
                Text(L.Settings.language)
                    .font(Theme.Typography.heading2(size: 18))
                    .foregroundStyle(Theme.current.textSecondary)
            }

            HStack(spacing: 12) {
                ForEach(Language.allCases) { language in
                    LanguageButton(
                        language: language,
                        isSelected: selectedLanguage == language,
                        action: {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                selectedLanguage = language
                            }
                        }
                    )
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

                Text(language.displayName)
                    .font(Theme.Typography.bodySmall(size: 12))
                    .foregroundStyle(isSelected ? Theme.current.textPrimary : Theme.current.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.current.interactiveSecondary.opacity(isSelected ? 0.5 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.current.interactivePrimary, lineWidth: isSelected ? 2 : 0)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Sound Toggle Row

private struct SoundToggleRow: View {
    @Binding var isEnabled: Bool

    var body: some View {
        ToggleRow(
            icon: "speaker.wave.2.fill",
            title: L.Settings.sound,
            isEnabled: $isEnabled,
            color: Theme.current.accentSuccess
        )
    }
}

// MARK: - Vibration Toggle Row

private struct VibrationToggleRow: View {
    @Binding var isEnabled: Bool

    var body: some View {
        ToggleRow(
            icon: "iphone.radiowaves.left.and.right",
            title: L.Settings.vibration,
            isEnabled: $isEnabled,
            color: Theme.current.accentSuccess
        )
    }
}

// MARK: - Generic Toggle Row

private struct ToggleRow: View {
    let icon: String
    let title: String
    @Binding var isEnabled: Bool
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color.opacity(0.8))
                .frame(width: 24)

            Text(title)
                .font(Theme.Typography.heading2(size: 18))
                .foregroundStyle(Theme.current.textSecondary)

            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isEnabled ? color.opacity(0.3) : Theme.current.surfaceSecondary.opacity(0.5))
                    .frame(width: 60, height: 32)

                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .tint(color)
                    .scaleEffect(0.8)
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Previews

#Preview {
    AppSettingsSheet(isPresented: .constant(true))
        .previewEnvironment()
}
