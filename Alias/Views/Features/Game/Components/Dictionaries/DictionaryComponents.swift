import SwiftUI

/// Grid displaying dictionary options
struct DictionariesGrid: View {
    let dictionaries: [WordDictionary]
    @Binding var selectedIndex: Int?
    let onDictionaryTap: (WordDictionary) -> Void

    var body: some View {
        HStack(spacing: 12) {
            ForEach(dictionaries.prefix(3)) { dictionary in
                SmallDictionaryCard(
                    dictionary: dictionary,
                    isSelected: selectedIndex == dictionary.id
                )
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    onDictionaryTap(dictionary)
                }
            }
        }
    }
}

/// Centered dictionary card for custom creation
struct CenteredCreateDictionaryCard: View {
    let dictionary: WordDictionary
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        ZStack {
            DictionaryCardBackground(isSelected: isSelected, dictionary: dictionary)
            DictionaryContent(dictionary: dictionary, isSelected: isSelected)
        }
        .frame(maxWidth: .infinity, maxHeight: 120)
        .onTapGesture {
            onTap()
        }
    }
}

/// Small dictionary card
private struct SmallDictionaryCard: View {
    let dictionary: WordDictionary
    let isSelected: Bool

    var body: some View {
        ZStack {
            SmallDictionaryCardBackground(isSelected: isSelected, dictionary: dictionary)
            SmallDictionaryContent(dictionary: dictionary, isSelected: isSelected)
        }
        .frame(height: 80)
    }
}

/// Background for small dictionary card
private struct SmallDictionaryCardBackground: View {
    let isSelected: Bool
    let dictionary: WordDictionary

    var body: some View {
        MysticalCardBackground(
            isSelected: isSelected,
            height: 80,
            cornerRadius: 16,
            isCustomPlaceholder: dictionary.isCustomPlaceholder
        )
    }
}

/// Content for small dictionary card
private struct SmallDictionaryContent: View {
    let dictionary: WordDictionary
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            SmallDictionaryEmoji(emoji: dictionary.emoji, isSelected: isSelected)
            SmallDictionaryName(name: dictionary.name, isSelected: isSelected)
        }
    }
}

/// Emoji for small dictionary card
private struct SmallDictionaryEmoji: View {
    let emoji: String
    let isSelected: Bool

    var body: some View {
        Text(emoji)
            .font(.system(size: 24))
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .opacity(isSelected ? 0.9 : 0.4)
    }
}

/// Name for small dictionary card
private struct SmallDictionaryName: View {
    let name: String
    let isSelected: Bool

    var body: some View {
        Text(name)
            .font(Theme.Typography.bodyLarge(size: 20))
            .foregroundColor(isSelected ? Theme.current.textPrimary.opacity(0.8) : Theme.current.textSecondary)
            .shadow(color: isSelected ? .black.opacity(0.8) : .clear, radius: isSelected ? 1 : 0, x: isSelected ? 1 : 0, y: isSelected ? 1 : 0)
            .lineLimit(1)
            .multilineTextAlignment(.center)
            .opacity(isSelected ? 0.9 : 0.4)
    }
}

/// Full dictionary card
private struct DictionaryCard: View {
    let dictionary: WordDictionary
    let isSelected: Bool

    var body: some View {
        ZStack {
            DictionaryCardBackground(isSelected: isSelected, dictionary: dictionary)
            DictionaryWordCountBadge(dictionary: dictionary, isSelected: isSelected)
            DictionaryContent(dictionary: dictionary, isSelected: isSelected)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Background for dictionary card
private struct DictionaryCardBackground: View {
    let isSelected: Bool
    let dictionary: WordDictionary

    var body: some View {
        MysticalCardBackground(
            isSelected: isSelected,
            height: 120,
            cornerRadius: 20,
            isCustomPlaceholder: dictionary.isCustomPlaceholder,
            shadowRadius: (12, 8),
            shadowOffset: (6, 4)
        )
    }
}

/// Word count badge for dictionary
private struct DictionaryWordCountBadge: View {
    let dictionary: WordDictionary
    let isSelected: Bool

    var body: some View {
        if !dictionary.isCustomPlaceholder {
            VStack {
                HStack {
                    Spacer()
                    DictionaryWordCountPill(wordCount: dictionary.wordCount, isSelected: isSelected)
                }
                Spacer()
            }
            .padding(8)
        }
    }
}

/// Pill showing word count
private struct DictionaryWordCountPill: View {
    let wordCount: Int
    let isSelected: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Theme.current.surfacePrimary.opacity(0.7))
                .frame(width: 35, height: 20)
                .opacity(isSelected ? 0.9 : 0.4)

            Text("\(wordCount)")
                .font(Theme.Typography.bodySmall(size: 12))
                .foregroundColor(Theme.current.textPrimary)
                .opacity(isSelected ? 0.9 : 0.4)
        }
    }
}

/// Content for dictionary card
private struct DictionaryContent: View {
    let dictionary: WordDictionary
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            DictionaryEmoji(emoji: dictionary.emoji, isSelected: isSelected, isCustomPlaceholder: dictionary.isCustomPlaceholder)
            DictionaryName(name: dictionary.name, isSelected: isSelected, isCustomPlaceholder: dictionary.isCustomPlaceholder)
        }
    }
}

/// Emoji for dictionary card
private struct DictionaryEmoji: View {
    let emoji: String
    let isSelected: Bool
    let isCustomPlaceholder: Bool

    var body: some View {
        Text(emoji)
            .font(.system(size: 30))
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .opacity(isSelected || isCustomPlaceholder ? 0.9 : 0.4)
    }
}

/// Name for dictionary card
private struct DictionaryName: View {
    let name: String
    let isSelected: Bool
    let isCustomPlaceholder: Bool

    var body: some View {
        Text(name)
            .font(Theme.Typography.bodyLarge(size: 16))
            .foregroundColor(isSelected ? Theme.current.textPrimary : Theme.current.textSecondary)
            .shadow(color: isSelected ? .black.opacity(0.8) : .clear, radius: isSelected ? 2 : 0, x: isSelected ? 1 : 0, y: isSelected ? 1 : 0)
            .lineLimit(1)
            .opacity(isSelected || isCustomPlaceholder ? 0.9 : 0.4)
    }
}

/// Mystical card background with gradients and shadows
private struct MysticalCardBackground: View {
    let isSelected: Bool
    let height: CGFloat
    let cornerRadius: CGFloat
    let isCustomPlaceholder: Bool
    let shadowRadius: (selected: CGFloat, unselected: CGFloat)
    let shadowOffset: (selected: CGFloat, unselected: CGFloat)

    init(isSelected: Bool, height: CGFloat = 120, cornerRadius: CGFloat = 20, isCustomPlaceholder: Bool = false,
         shadowRadius: (selected: CGFloat, unselected: CGFloat) = (8, 4),
         shadowOffset: (selected: CGFloat, unselected: CGFloat) = (4, 2)) {
        self.isSelected = isSelected
        self.height = height
        self.cornerRadius = cornerRadius
        self.isCustomPlaceholder = isCustomPlaceholder
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(isSelected ? Theme.current.surfaceSecondary.opacity(0.2) : Theme.current.surfaceSecondary.opacity(0.05))
            .frame(height: height)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(isSelected ? Theme.current.borderPrimary.opacity(0.9) : Theme.current.borderPrimary.opacity(0.4),
                            style: isCustomPlaceholder ? StrokeStyle(lineWidth: 2, dash: [8, 6]) : StrokeStyle(lineWidth: isSelected ? 1 : 2))
            )
            .shadow(color: isSelected ? Theme.current.surfaceSecondary.opacity(0.3) : .black.opacity(0.3),
                    radius: isSelected ? shadowRadius.selected : shadowRadius.unselected,
                    x: 0,
                    y: isSelected ? shadowOffset.selected : shadowOffset.unselected)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .opacity(isSelected || isCustomPlaceholder ? 0.9 : 0.4)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Previews

#Preview("Dictionaries Grid") {
    struct PreviewWrapper: View {
        @State private var selectedIndex: Int?
        let dictionaries = [
            WordDictionary(id: 1, emoji: "🦁", name: "Animals", wordCount: 150, isCustomPlaceholder: false),
            WordDictionary(id: 2, emoji: "💻", name: "Tech", wordCount: 200, isCustomPlaceholder: false),
            WordDictionary(id: 3, emoji: "🍕", name: "Food", wordCount: 180, isCustomPlaceholder: false)
        ]

        var body: some View {
            DictionariesGrid(
                dictionaries: dictionaries,
                selectedIndex: $selectedIndex,
                onDictionaryTap: { dict in selectedIndex = dict.id }
            )
            .padding()
            .background(Theme.current.backgroundPrimary)
        }
    }
    return PreviewWrapper()
}

#Preview("Dictionary Card") {
    VStack(spacing: 16) {
        DictionaryCard(
            dictionary: WordDictionary(id: 1, emoji: "🦁", name: "Animals", wordCount: 150, isCustomPlaceholder: false),
            isSelected: false
        )

        DictionaryCard(
            dictionary: WordDictionary(id: 2, emoji: "💻", name: "Technology", wordCount: 200, isCustomPlaceholder: false),
            isSelected: true
        )
    }
    .padding()
    .background(Theme.current.backgroundPrimary)
}

#Preview("Centered Create Dictionary Card") {
    struct PreviewWrapper: View {
        @State private var isSelected = false
        let customDict = WordDictionary(id: 4, emoji: "✨", name: "Create AI Dictionary", wordCount: 0, isCustomPlaceholder: true)

        var body: some View {
            CenteredCreateDictionaryCard(
                dictionary: customDict,
                isSelected: isSelected,
                onTap: { isSelected.toggle() }
            )
            .padding()
            .background(Theme.current.backgroundPrimary)
        }
    }
    return PreviewWrapper()
}
