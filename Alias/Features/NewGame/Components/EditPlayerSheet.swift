import SwiftUI

/// Edits a player's name and avatar. Present it with `.sheet(item:)`.
struct EditPlayerSheet: View {
    static let availableEmojis = ["😉", "🤖", "🧑🏽‍🌾", "🦊", "🦁", "🐸", "🐙", "🦄", "🐲", "👽", "🤠", "🥷", "👻", "👾", "🎃", "🧜‍♀️"]

    let player: Player
    let onSave: (Player) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var emoji: String
    @FocusState private var isNameFieldFocused: Bool

    init(player: Player, onSave: @escaping (Player) -> Void) {
        self.player = player
        self.onSave = onSave
        _name = State(initialValue: player.name)
        _emoji = State(initialValue: player.emoji)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SheetTitle(L.Player.Edit.title)

            VStack(alignment: .leading, spacing: 4) {
                FieldLabel(L.Player.Edit.nameLabel)

                TextField(L.Player.Edit.nameLabel, text: $name)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .focused($isNameFieldFocused)
                    .onSubmit(save)
                    .themedTextField(fontSize: 20)
            }

            VStack(alignment: .leading, spacing: 4) {
                FieldLabel(L.Player.Edit.chooseIcon)
                EmojiSelector(emojis: Self.availableEmojis, selection: $emoji)
            }

            HStack(spacing: 12) {
                ActionButton(title: L.cancel, role: .secondary) { dismiss() }
                ActionButton(title: L.save, action: save)
            }
            .padding(.top, 10)
        }
        .themedSheet()
        .onAppear { isNameFieldFocused = true }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        var updatedPlayer = player
        updatedPlayer.name = trimmedName.isEmpty ? player.name : trimmedName
        updatedPlayer.emoji = emoji
        onSave(updatedPlayer)
        dismiss()
    }
}

private struct FieldLabel: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(Theme.Typography.bodySmall(size: 14))
            .foregroundStyle(Theme.current.textSecondary)
            .accessibilityHidden(true)
    }
}

private struct EmojiSelector: View {
    let emojis: [String]
    @Binding var selection: String

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(emojis, id: \.self) { emoji in
                    let isSelected = selection == emoji

                    Button {
                        withAnimation(.spring()) { selection = emoji }
                    } label: {
                        Text(emoji)
                            .font(.system(size: 32))
                            .padding(8)
                            .background {
                                Circle()
                                    .fill(Theme.current.interactiveSecondary.opacity(isSelected ? 0.5 : 0.1))
                                    .stroke(Theme.current.interactivePrimary, lineWidth: isSelected ? 2 : 0)
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
            .padding(.vertical, 4)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    Color.black
        .sheet(isPresented: .constant(true)) {
            EditPlayerSheet(player: Player(emoji: "🦊", name: "Nova")) { _ in }
        }
        .previewEnvironment()
}
