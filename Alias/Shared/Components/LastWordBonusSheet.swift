import SwiftUI

/// Asks who guessed the last word after time ran out. Present it with `.sheet`.
struct LastWordBonusSheet: View {
    let players: [Player]
    let bonusPoints: Int
    let onPlayerSelected: (Player) -> Void

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.current.accentHighlight)
                    .accessibilityHidden(true)

                SheetTitle(L.Gameplay.lastWordBonus)

                Text(L.Gameplay.whoGetsPoints(bonusPoints))
                    .font(Theme.Typography.body(size: 16))
                    .foregroundStyle(Theme.current.textSecondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                ForEach(players) { player in
                    Button {
                        onPlayerSelected(player)
                    } label: {
                        HStack(spacing: 16) {
                            Text(player.emoji)
                                .font(.system(size: 32))
                                .accessibilityHidden(true)

                            Text(player.name)
                                .font(Theme.Typography.body(size: 20))
                                .foregroundStyle(Theme.current.textPrimary)

                            Spacer()

                            Text(verbatim: "+\(bonusPoints)")
                                .font(Theme.Typography.heading1(size: 20))
                                .foregroundStyle(Theme.current.accentHighlight)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Theme.current.surfacePrimary.opacity(0.3), in: .rect(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Theme.current.borderPrimary.opacity(0.6), lineWidth: 1)
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .themedSheet()
    }
}

#Preview {
    Color.black
        .sheet(isPresented: .constant(true)) {
            LastWordBonusSheet(
                players: [Player(emoji: "🦊", name: "Nova"), Player(emoji: "🐸", name: "Rex")],
                bonusPoints: 7
            ) { _ in }
        }
        .previewEnvironment()
}
