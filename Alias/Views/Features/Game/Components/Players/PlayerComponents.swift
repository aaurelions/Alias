import SwiftUI

/// Section displaying all players
struct PlayersSection: View {
    let players: [Player]
    let onAdd: () -> Void
    let onDelete: (Player) -> Void
    let onEdit: (Player) -> Void

    var body: some View {
        VStack {
            VStack(spacing: 5) {
                ForEach(players) { player in
                    PlayerRow(player: player, onDelete: onDelete, onEdit: onEdit)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.5).combined(with: .opacity),
                            removal: .scale(scale: 0.5).combined(with: .opacity)
                        ))
                }
            }

            AddPlayerRow(action: onAdd)
        }
    }
}

/// Individual player row
private struct PlayerRow: View {
    let player: Player
    let onDelete: (Player) -> Void
    let onEdit: (Player) -> Void

    var body: some View {
        HStack {
            PlayerInfoSection(player: player, onEdit: onEdit)
            PlayerDeleteButton(player: player, onDelete: onDelete)
        }
    }
}

/// Player info section (avatar and name)
private struct PlayerInfoSection: View {
    let player: Player
    let onEdit: (Player) -> Void

    var body: some View {
        HStack {
            PlayerAvatar(emoji: player.emoji)
            Spacer()
            PlayerNameLabel(name: player.name)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit(player)
        }
    }
}

/// Player avatar with emoji
private struct PlayerAvatar: View {
    let emoji: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Theme.current.surfacePrimary.opacity(0.1))
                .frame(width: 60, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Theme.current.surfacePrimary.opacity(0.9), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.9), radius: 5, x: 0, y: 3)

            Text(emoji)
                .font(.system(size: 40, weight: .bold, design: .default))
        }
    }
}

/// Player name label
private struct PlayerNameLabel: View {
    let name: String

    var body: some View {
        ZStack {
            Text(name)
                .font(Theme.Typography.body(size: 20))
                .foregroundColor(Theme.current.textPrimary.opacity(0.9))

            PlayerNameDecoration()
        }
    }
}

/// Decorative underline for player name
private struct PlayerNameDecoration: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Theme.current.textSecondary.opacity(0.5))
                .frame(height: 1)
                .frame(width: 50)
                .padding(.top, 40)

            Circle()
                .fill(Theme.current.textSecondary)
                .frame(width: 10, height: 10)
                .rotationEffect(.degrees(45))
                .padding(.top, 40)
        }
    }
}

/// Delete button for player
private struct PlayerDeleteButton: View {
    let player: Player
    let onDelete: (Player) -> Void

    var body: some View {
        Button(action: {
            onDelete(player)
        }) {
            ZStack {
                Image(systemName: "xmark.seal.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.current.accentDestructive.opacity(0.6))
                    .padding(.horizontal, 10)
                    .frame(width: 60, height: 60)
            }
        }
        .buttonStyle(.plain)
    }
}

/// Add new player row
private struct AddPlayerRow: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Theme.current.surfacePrimary.opacity(0.1))
                    .frame(height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Theme.current.surfacePrimary.opacity(0.9), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.9), radius: 5, x: 0, y: 3)

                HStack {
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                        .foregroundColor(Theme.current.textSecondary)
                        .padding(.leading, 16)

                    Spacer()

                    Text(L.NewGame.addPlayer)
                        .font(Theme.Typography.bodyLarge(size: 20))
                        .foregroundColor(Theme.current.textSecondary)

                    Spacer()
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Players Section") {
    struct PreviewWrapper: View {
        @State private var players = [
            Player(emoji: "😉", name: "Alice"),
            Player(emoji: "🤖", name: "Bob"),
            Player(emoji: "🦊", name: "Charlie")
        ]

        var body: some View {
            PlayersSection(
                players: players,
                onAdd: {},
                onDelete: { _ in },
                onEdit: { _ in }
            )
            .padding()
            .background(Theme.current.backgroundPrimary)
        }
    }
    return PreviewWrapper()
}
