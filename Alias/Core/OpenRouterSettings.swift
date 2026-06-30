import Foundation
import Security

enum OpenRouterSettings {
    static let defaultModel = "google/gemini-3.1-flash-lite"
    static let modelNameKey = "openRouterModelName"

    private static let apiKeyAccount = "openrouter-api-key"
    private static let service = Bundle.main.bundleIdentifier ?? "Alias.OpenRouter"

    static var apiKey: String {
        get { KeychainStore.string(service: service, account: apiKeyAccount) ?? "" }
        set {
            let trimmedKey = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedKey.isEmpty {
                KeychainStore.delete(service: service, account: apiKeyAccount)
            } else {
                KeychainStore.set(trimmedKey, service: service, account: apiKeyAccount)
            }
        }
    }

    static var modelName: String {
        let savedModel = UserDefaults.standard.string(forKey: modelNameKey) ?? ""
        let trimmedModel = savedModel.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedModel.isEmpty ? defaultModel : trimmedModel
    }
}

private enum KeychainStore {
    static func string(service: String, account: String) -> String? {
        var query = baseQuery(service: service, account: account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let data = item as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    static func set(_ value: String, service: String, account: String) {
        let data = Data(value.utf8)
        var query = baseQuery(service: service, account: account)

        let attributes: [String: Any] = [kSecValueData as String: data]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if status == errSecItemNotFound {
            query[kSecValueData as String] = data
            SecItemAdd(query as CFDictionary, nil)
        }
    }

    static func delete(service: String, account: String) {
        SecItemDelete(baseQuery(service: service, account: account) as CFDictionary)
    }

    private static func baseQuery(service: String, account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }
}
