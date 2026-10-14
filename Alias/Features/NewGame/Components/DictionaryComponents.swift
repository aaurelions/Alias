import SwiftUI

struct BuiltInDictionaryGrid: View {
    let dictionaries: [WordDictionary]
    let selectedID: WordDictionary.ID?
    let onSelect: (WordDictionary) -> Void

    var body: some View {
        HStack(spacing: 12) {
            ForEach(dictionaries) { dictionary in
                let isSelected = selectedID == dictionary.id
                Button {
                    onSelect(dictionary)
                } label: {
                    ZStack {
                        DictionaryCardBackground(isSelected: isSelected, isPlaceholder: false, height: 80, cornerRadius: 16)
                        VStack(spacing: 4) {
                            Text(dictionary.emoji)
                                .font(.system(size: 24))
                                .scaleEffect(isSelected ? 1.1 : 1)
                            Text(dictionary.name)
                                .font(Theme.Typography.bodyLarge(size: 20))
                                .foregroundStyle(isSelected ? Theme.current.textPrimary.opacity(0.8) : Theme.current.textSecondary)
                                .shadow(color: isSelected ? .black.opacity(0.8) : .clear, radius: 1, x: 1, y: 1)
                                .lineLimit(1)
                        }
                        .opacity(isSelected ? 0.9 : 0.4)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}

/// Card for the AI-generated dictionary; shows a "create" placeholder until one has been generated.
struct GeneratedDictionaryCard: View {
    let dictionary: WordDictionary?
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                DictionaryCardBackground(
                    isSelected: isSelected,
                    isPlaceholder: dictionary == nil,
                    height: 120,
                    cornerRadius: 20,
                    shadowRadius: (12, 8),
                    shadowOffset: (6, 4)
                )

                if let dictionary {
                    WordCountPill(wordCount: dictionary.wordCount, isSelected: isSelected)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(8)
                }

                VStack(spacing: 8) {
                    Text(dictionary?.emoji ?? "✨")
                        .font(.system(size: 30))
                        .scaleEffect(isSelected ? 1.1 : 1)
                    Text(dictionary?.name ?? L.Dictionary.custom)
                        .font(Theme.Typography.bodyLarge(size: 16))
                        .foregroundStyle(isSelected ? Theme.current.textPrimary : Theme.current.textSecondary)
                        .shadow(color: isSelected ? .black.opacity(0.8) : .clear, radius: 2, x: 1, y: 1)
                        .lineLimit(1)
                }
                .opacity(isSelected || dictionary == nil ? 0.9 : 0.4)
            }
            .frame(maxWidth: .infinity, maxHeight: 120)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct WordCountPill: View {
    let wordCount: Int
    let isSelected: Bool

    var body: some View {
        Text("\(wordCount)")
            .font(Theme.Typography.bodySmall(size: 12))
            .foregroundStyle(Theme.current.textPrimary)
            .padding(.horizontal, 8)
            .frame(minWidth: 35, minHeight: 20)
            .background(Theme.current.surfacePrimary.opacity(0.7), in: .rect(cornerRadius: 8))
            .opacity(isSelected ? 0.9 : 0.4)
    }
}

private struct DictionaryCardBackground: View {
    let isSelected: Bool
    let isPlaceholder: Bool
    let height: CGFloat
    let cornerRadius: CGFloat
    var shadowRadius: (selected: CGFloat, unselected: CGFloat) = (8, 4)
    var shadowOffset: (selected: CGFloat, unselected: CGFloat) = (4, 2)

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Theme.current.surfaceSecondary.opacity(isSelected ? 0.2 : 0.05))
            .frame(height: height)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        Theme.current.borderPrimary.opacity(isSelected ? 0.9 : 0.4),
                        style: isPlaceholder ? StrokeStyle(lineWidth: 2, dash: [8, 6]) : StrokeStyle(lineWidth: isSelected ? 1 : 2)
                    )
            }
            .shadow(
                color: isSelected ? Theme.current.surfaceSecondary.opacity(0.3) : .black.opacity(0.3),
                radius: isSelected ? shadowRadius.selected : shadowRadius.unselected,
                y: isSelected ? shadowOffset.selected : shadowOffset.unselected
            )
            .scaleEffect(isSelected ? 1.05 : 1)
            .opacity(isSelected || isPlaceholder ? 0.9 : 0.4)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    @Previewable @State var selectedID: WordDictionary.ID?
    let dictionaries = Difficulty.allCases.map { WordDictionary.builtIn($0, language: .english) }
    let generated = WordDictionary(emoji: "🚀", name: "Space", words: ["Orbit", "Comet"])

    VStack(spacing: 24) {
        BuiltInDictionaryGrid(dictionaries: dictionaries, selectedID: selectedID) { selectedID = $0.id }
        GeneratedDictionaryCard(dictionary: nil, isSelected: false) {}
        GeneratedDictionaryCard(dictionary: generated, isSelected: selectedID == generated.id) { selectedID = generated.id }
    }
    .padding()
    .background(DarkBackgroundView(backgroundImage: "NewGameScreenBg"))
}
