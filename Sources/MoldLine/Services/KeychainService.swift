import Foundation
import Security

enum KeychainService {
    private static let service = "com.moldline.chat"

    private enum Key: String {
        case authToken = "auth_token"
        case userId = "user_id"
    }

    // MARK: - Token

    @discardableResult
    static func saveToken(_ token: String) -> Bool {
        save(key: .authToken, value: token)
    }

    static func loadToken() -> String? {
        load(key: .authToken)
    }

    @discardableResult
    static func deleteToken() -> Bool {
        delete(key: .authToken)
    }

    // MARK: - User ID

    @discardableResult
    static func saveUserId(_ userId: String) -> Bool {
        save(key: .userId, value: userId)
    }

    static func loadUserId() -> String? {
        load(key: .userId)
    }

    @discardableResult
    static func deleteUserId() -> Bool {
        delete(key: .userId)
    }

    // MARK: - Clear All

    static func clearAll() {
        deleteToken()
        deleteUserId()
    }

    // MARK: - Private Helpers

    private static func save(key: Key, value: String) -> Bool {
        delete(key: key)

        guard let data = value.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    private static func load(key: Key) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }

        return string
    }

    @discardableResult
    private static func delete(key: Key) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
