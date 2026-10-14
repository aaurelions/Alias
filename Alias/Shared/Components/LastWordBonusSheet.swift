import SwiftUI

/// Asks who guessed the last word after time ran out.
struct LastWordBonusSheet: View {
    let players: [Player]
    let bonusPoints: Int
    let onPlayerSelected: (Player) -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Theme.current.accentHighlight)

                        Text(L.Gameplay.lastWordBonus)
                            .font(Theme.Typography.heading1(size: 28))
                            .foregroundStyle(Theme.current.textPrimary)

                        Text(L.Gameplay.whoGetsPoints(bonusPoints))
                            .font(Theme.Typography.body(size: 16))
                            .foregroundStyle(Theme.current.textSecondary)
                    }
                    .padding(.top, 30)

                    VStack(spacing: 12) {
                        ForEach(players) { player in
                            Button {
                                onPlayerSelected(player)
                            } label: {
                                HStack(spacing: 16) {
                                    Text(player.emoji)
                                        .font(.system(size: 32))

                                    Text(player.name)
                                        .font(Theme.Typography.body(size: 20))
                                        .foregroundStyle(Theme.current.textPrimary)

                                    Spacer()

                                    Text("+\(bonusPoints)")
                                        .font(Theme.Typography.heading1(size: 20))
                                        .foregroundStyle(Theme.current.accentHighlight)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Theme.current.surfacePrimary.opacity(0.3))
                                .clipShape(.rect(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Theme.current.borderPrimary.opacity(0.6), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Theme.current.borderPrimary.opacity(0.6), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    LastWordBonusSheet(
        players: [Player(emoji: "🦊", name: "Nova"), Player(emoji: "🐸", name: "Rex")],
        bonusPoints: 7
    ) { _ in }
}
