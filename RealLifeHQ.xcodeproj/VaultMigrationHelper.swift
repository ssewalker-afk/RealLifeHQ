import Foundation

// MARK: - Vault Migration Helper
// Migrates existing vault data from UserDefaults to Keychain (one-time migration)

class VaultMigrationHelper {
    static let shared = VaultMigrationHelper()
    
    private let migrationKey = "vault_keychain_migration_completed"
    
    private init() {}
    
    // MARK: - Check and Perform Migration
    
    /// Checks if migration is needed and performs it
    /// Should be called once when the app launches
    func migrateIfNeeded() {
        // Check if migration has already been completed
        if UserDefaults.standard.bool(forKey: migrationKey) {
            print("ℹ️ Vault migration: Already completed")
            return
        }
        
        print("🔄 Starting vault data migration to Keychain...")
        
        // Load existing vault items from UserDefaults
        guard let data = UserDefaults.standard.data(forKey: "vault"),
              let oldVaultItems = try? JSONDecoder().decode([OldVaultItem].self, from: data) else {
            print("ℹ️ No existing vault items to migrate")
            markMigrationComplete()
            return
        }
        
        var migratedCount = 0
        var errorCount = 0
        
        // Migrate each item's password and notes to Keychain
        for oldItem in oldVaultItems {
            var success = true
            
            // Migrate password if it exists
            if let password = oldItem.password, !password.isEmpty {
                if KeychainManager.shared.saveVaultPassword(password, forItemId: oldItem.id) {
                    print("✅ Migrated password for: \(oldItem.title)")
                } else {
                    print("❌ Failed to migrate password for: \(oldItem.title)")
                    success = false
                }
            }
            
            // Migrate notes if they exist
            if let notes = oldItem.notes, !notes.isEmpty {
                if KeychainManager.shared.saveVaultNotes(notes, forItemId: oldItem.id) {
                    print("✅ Migrated notes for: \(oldItem.title)")
                } else {
                    print("❌ Failed to migrate notes for: \(oldItem.title)")
                    success = false
                }
            }
            
            if success {
                migratedCount += 1
            } else {
                errorCount += 1
            }
        }
        
        // Now update the vault items in UserDefaults to the new format
        let newVaultItems = oldVaultItems.map { oldItem -> VaultItem in
            var newItem = VaultItem(
                id: oldItem.id,
                title: oldItem.title,
                username: oldItem.username,
                url: oldItem.url,
                category: oldItem.category,
                imageData: oldItem.imageData,
                hasPassword: oldItem.password != nil && !oldItem.password!.isEmpty,
                hasNotes: oldItem.notes != nil && !oldItem.notes!.isEmpty
            )
            return newItem
        }
        
        // Save the new format back to UserDefaults
        if let encoded = try? JSONEncoder().encode(newVaultItems) {
            UserDefaults.standard.set(encoded, forKey: "vault")
            print("✅ Updated vault items to new format")
        }
        
        print("✅ Vault migration complete: \(migratedCount) items migrated, \(errorCount) errors")
        markMigrationComplete()
    }
    
    private func markMigrationComplete() {
        UserDefaults.standard.set(true, forKey: migrationKey)
        print("✅ Vault migration marked as complete")
    }
    
    // MARK: - Force Re-migration (for testing)
    
    /// Resets migration flag - USE ONLY FOR TESTING
    func resetMigrationFlag() {
        UserDefaults.standard.removeObject(forKey: migrationKey)
        print("⚠️ Migration flag reset")
    }
}

// MARK: - Old VaultItem Structure (for migration)

private struct OldVaultItem: Codable {
    var id: UUID
    var title: String
    var username: String?
    var password: String?    // Old location (will be migrated to Keychain)
    var url: String?
    var notes: String?       // Old location (will be migrated to Keychain)
    var category: VaultItem.VaultCategory
    var imageData: Data?
}
