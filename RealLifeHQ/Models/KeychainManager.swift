//
//  KeychainManager.swift
//  RealLifeHQ
//
//  Secure storage for sensitive vault data using iOS Keychain
//

import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    
    private init() {}
    
    // MARK: - Configuration
    
    private let service = "com.reallifehq.vault"
    
    // MARK: - Public API for Vault Items
    
    /// Save a password to the Keychain
    @discardableResult
    func saveVaultPassword(_ password: String, forItemId itemId: UUID) -> Bool {
        let account = "\(itemId.uuidString)-password"
        return save(password, for: account)
    }
    
    /// Retrieve a password from the Keychain
    func retrieveVaultPassword(forItemId itemId: UUID) -> String? {
        let account = "\(itemId.uuidString)-password"
        return retrieve(for: account)
    }
    
    /// Delete a password from the Keychain
    @discardableResult
    func deleteVaultPassword(forItemId itemId: UUID) -> Bool {
        let account = "\(itemId.uuidString)-password"
        return delete(for: account)
    }
    
    /// Save notes to the Keychain
    @discardableResult
    func saveVaultNotes(_ notes: String, forItemId itemId: UUID) -> Bool {
        let account = "\(itemId.uuidString)-notes"
        return save(notes, for: account)
    }
    
    /// Retrieve notes from the Keychain
    func retrieveVaultNotes(forItemId itemId: UUID) -> String? {
        let account = "\(itemId.uuidString)-notes"
        return retrieve(for: account)
    }
    
    /// Delete notes from the Keychain
    @discardableResult
    func deleteVaultNotes(forItemId itemId: UUID) -> Bool {
        let account = "\(itemId.uuidString)-notes"
        return delete(for: account)
    }
    
    /// Delete all items from the Keychain (use with caution)
    @discardableResult
    func deleteAll() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    // MARK: - AI API Key Management (DEPRECATED)
    // AI integration methods removed - external AI providers deprecated
    // See AIServiceManager.swift for deprecation details
    
    // MARK: - Private Core Keychain Operations
    
    private func save(_ value: String, for account: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            return false
        }
        
        // Delete existing item first (if any)
        delete(for: account)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    private func retrieve(for account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
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
    private func delete(for account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
