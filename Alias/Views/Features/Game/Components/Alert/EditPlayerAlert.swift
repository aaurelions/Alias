import SwiftUI

/// Alert for editing player details
struct EditPlayerAlert: View {
    let player: Player
    @Binding var isPresented: Bool
    let onSave: (Player) -> Void

    var body: some View {
        FormModal(
            title: L.Player.Edit.title,
            isPresented: $isPresented
        ) {
            EditPlayerAlertContent(
                player: player,
                isPresented: $isPresented,
                onSave: onSave
            )
        }
        .presentationBackground(Color.clear)
    }
}

/// Content of the edit player alert
private struct EditPlayerAlertContent: View {
    let player: Player
    @Binding var isPresented: Bool
    let onSave: (Player) -> Void

    @State private var editedName: String
    @State private var editedEmoji: String
    @FocusState private var isNameFieldFocused: Bool

    let availableEmojis = ["😉", "🤖", "🧑🏽‍🌾", "🦊", "🦁", "🐸", "🐙", "🦄", "🐲", "👽", "🤠", "🥷", "👻", "👾", "🎃", "🧜‍♀️"]

    init(player: Player, isPresented: Binding<Bool>, onSave: @escaping (Player) -> Void) {
        self.player = player
        self._isPresented = isPresented
        self.onSave = onSave
        _editedName = State(initialValue: player.name)
        _editedEmoji = State(initialValue: player.emoji)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            PlayerNameInputField(name: $editedName, isFocused: $isNameFieldFocused)
            PlayerEmojiSelector(availableEmojis: availableEmojis, selectedEmoji: $editedEmoji)
            EditPlayerActionButtons(
                isPresented: $isPresented,
                player: player,
                editedName: editedName,
                editedEmoji: editedEmoji,
                onSave: onSave
            )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                isNameFieldFocused = true
            }
        }
    }
}

/// Input field for player name
private struct PlayerNameInputField: View {
    @Binding var name: String
    let isFocused: FocusState<Bool>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(L.Player.Edit.nameLabel)
                .font(Theme.Typography.bodySmall(size: 14))
                .foregroundColor(Theme.current.textSecondary)

            TextField("", text: $name)
                .font(Theme.Typography.body(size: 20))
                .padding(12)
                .background(Color.black.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(Theme.current.textPrimary)
                .focused(isFocused)
        }
    }
}

/// Emoji selector for player
private struct PlayerEmojiSelector: View {
    let availableEmojis: [String]
    @Binding var selectedEmoji: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(L.Player.Edit.chooseIcon)
                .font(Theme.Typography.bodySmall(size: 14))
                .foregroundColor(Theme.current.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(availableEmojis, id: \.self) { emoji in
                        EmojiOptionButton(
                            emoji: emoji,
                            isSelected: selectedEmoji == emoji,
                            action: {
                                withAnimation(.spring()) {
                                    selectedEmoji = emoji
                                }
                            }
                        )
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

/// Individual emoji option button
private struct EmojiOptionButton: View {
    let emoji: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Text(emoji)
            .font(.system(size: 32))
            .padding(8)
            .background(
                Circle()
                    .fill(Theme.current.interactiveSecondary.opacity(isSelected ? 0.5 : 0.1))
                    .overlay(
                        Circle()
                            .stroke(Theme.current.interactivePrimary, lineWidth: isSelected ? 2 : 0)
                    )
            )
            .onTapGesture(perform: action)
    }
}

/// Action buttons for edit player alert
private struct EditPlayerActionButtons: View {
    @Binding var isPresented: Bool
    let player: Player
    let editedName: String
    let editedEmoji: String
    let onSave: (Player) -> Void

    var body: some View {
        HStack(spacing: 12) {
            AlertActionButton(title: L.cancel, style: .secondary) {
                isPresented = false
            }

            AlertActionButton(title: L.save, style: .primary) {
                var updatedPlayer = player
                updatedPlayer.name = editedName
                updatedPlayer.emoji = editedEmoji
                onSave(updatedPlayer)
                isPresented = false
            }
        }
        .padding(.top, 10)
    }
}
