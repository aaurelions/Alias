import Foundation

/// Protocol for dictionary-related actions
protocol DictionaryActions {
    func handleDictionaryTap(_ dictionary: WordDictionary)
    func handleAIGeneration(prompt: String) async
}
