import Foundation
import Security

// MARK: - Keychain Manager
// Secure storage for sensitive vault data using iOS Keychain

class KeychainManager {
    static let shared = KeychainManager()
    
    private init() {}
    
    // MARK: - Save to Keychain
    
    /// Saves a string value securely to the Keychain
    /// - Parameters:
    ///   - value: The string to save
    ///   - key: The unique key identifier
    /// - Returns: True if successful, false otherwise
    @discardableResult
    func save(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            print("❌ KeychainManager: Failed to convert string to data")
            return false
        }
        
        // Delete any existing value first
        delete(forKey: key)
        
        // Build query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Add to keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            print("✅ KeychainManager: Saved '\(key)' to Keychain")
            return true
        } else {
            print("❌ KeychainManager: Failed to save '\(key)'. Status: \(status)")
            return false
        }
    }
    
    // MARK: - Retrieve from Keychain
    
    /// Retrieves a string value from the Keychain
    /// - Parameter key: The unique key identifier
    /// - Returns: The stored string, or nil if not found
    func retrieve(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            if let data = result as? Data,
               let string = String(data: data, encoding: .utf8) {
                print("✅ KeychainManager: Retrieved '\(key)' from Keychain")
                return string
            }
        } else if status == errSecItemNotFound {
            print("⚠️ KeychainManager: No item found for '\(key)'")
        } else {
            print("❌ KeychainManager: Failed to retrieve '\(key)'. Status: \(status)")
        }
        
        return nil
    }
    
    // MARK: - Delete from Keychain
    
    /// Deletes a value from the Keychain
    /// - Parameter key: The unique key identifier
    /// - Returns: True if successful or item didn't exist, false otherwise
    @discardableResult
    func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess {
            print("✅ KeychainManager: Deleted '\(key)' from Keychain")
            return true
        } else if status == errSecItemNotFound {
            // Item didn't exist, which is fine
            return true
        } else {
            print("❌ KeychainManager: Failed to delete '\(key)'. Status: \(status)")
            return false
        }
    }
    
    // MARK: - Update in Keychain
    
    /// Updates an existing value in the Keychain
    /// - Parameters:
    ///   - value: The new string value
    ///   - key: The unique key identifier
    /// - Returns: True if successful, false otherwise
    @discardableResult
    func update(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            print("❌ KeychainManager: Failed to convert string to data")
            return false
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        if status == errSecSuccess {
            print("✅ KeychainManager: Updated '\(key)' in Keychain")
            return true
        } else if status == errSecItemNotFound {
            // Item doesn't exist yet, save it instead
            return save(value, forKey: key)
        } else {
            print("❌ KeychainManager: Failed to update '\(key)'. Status: \(status)")
            return false
        }
    }
    
    // MARK: - Clear All Vault Items
    
    /// Deletes all vault-related items from the Keychain
    /// Use this when clearing all app data
    func clearAllVaultItems() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "vault_" // Prefix for all vault items
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess || status == errSecItemNotFound {
            print("✅ KeychainManager: Cleared all vault items")
        } else {
            print("❌ KeychainManager: Failed to clear vault items. Status: \(status)")
        }
    }
    
    // MARK: - Vault-Specific Helpers
    
    /// Saves vault item password securely
    func saveVaultPassword(_ password: String, forItemId itemId: UUID) -> Bool {
        return save(password, forKey: "vault_password_\(itemId.uuidString)")
    }
    
    /// Retrieves vault item password
    func retrieveVaultPassword(forItemId itemId: UUID) -> String? {
        return retrieve(forKey: "vault_password_\(itemId.uuidString)")
    }
    
    /// Deletes vault item password
    func deleteVaultPassword(forItemId itemId: UUID) -> Bool {
        return delete(forKey: "vault_password_\(itemId.uuidString)")
    }
    
    /// Saves vault item notes securely
    func saveVaultNotes(_ notes: String, forItemId itemId: UUID) -> Bool {
        return save(notes, forKey: "vault_notes_\(itemId.uuidString)")
    }
    
    /// Retrieves vault item notes
    func retrieveVaultNotes(forItemId itemId: UUID) -> String? {
        return retrieve(forKey: "vault_notes_\(itemId.uuidString)")
    }
    
    /// Deletes vault item notes
    func deleteVaultNotes(forItemId itemId: UUID) -> Bool {
        return delete(forKey: "vault_notes_\(itemId.uuidString)")
    }
}

// MARK: - Keychain Error Codes Reference
/*
 Common Security Framework error codes:
 
 errSecSuccess = 0          // No error
 errSecItemNotFound = -25300  // Item not found
 errSecDuplicateItem = -25299 // Item already exists
 errSecAuthFailed = -25293    // Authentication failed
 errSecInteractionNotAllowed = -25308 // User interaction required but not allowed
 
 For complete list, see: SecBase.h
 */
