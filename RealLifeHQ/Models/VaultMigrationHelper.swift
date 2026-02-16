//
//  VaultMigrationHelper.swift
//  RealLifeHQ
//
//  Handles one-time migration of vault data from UserDefaults to Keychain
//

import Foundation

class VaultMigrationHelper {
    
    private static let migrationKey = "hasCompletedVaultKeychainMigration"
    
    /// Perform one-time migration from UserDefaults to Keychain
    static func migrateVaultDataIfNeeded() {
        // Check if migration has already been completed
        guard !UserDefaults.standard.bool(forKey: migrationKey) else {
            print("✅ Vault migration already completed - skipping")
            return
        }
        
        print("🔄 Starting vault data migration to Keychain...")
        
        // Load existing vault items from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "vaultItems"),
           let items = try? JSONDecoder().decode([VaultItem].self, from: data) {
            
            var migratedCount = 0
            
            for item in items {
                // Migrate password if it exists in the old format
                if let oldPassword = UserDefaults.standard.string(forKey: "vault_password_\(item.id.uuidString)") {
                    KeychainManager.shared.saveVaultPassword(oldPassword, forItemId: item.id)
                    UserDefaults.standard.removeObject(forKey: "vault_password_\(item.id.uuidString)")
                    migratedCount += 1
                    print("  ✓ Migrated password for: \(item.title)")
                }
                
                // Migrate notes if they exist in the old format
                if let oldNotes = UserDefaults.standard.string(forKey: "vault_notes_\(item.id.uuidString)") {
                    KeychainManager.shared.saveVaultNotes(oldNotes, forItemId: item.id)
                    UserDefaults.standard.removeObject(forKey: "vault_notes_\(item.id.uuidString)")
                    migratedCount += 1
                    print("  ✓ Migrated notes for: \(item.title)")
                }
            }
            
            print("✅ Migration complete - migrated \(migratedCount) items to Keychain")
        } else {
            print("ℹ️ No existing vault items found - fresh install")
        }
        
        // Mark migration as completed
        UserDefaults.standard.set(true, forKey: migrationKey)
    }
    
    /// Reset migration flag (for testing purposes only)
    static func resetMigrationFlag() {
        UserDefaults.standard.removeObject(forKey: migrationKey)
        print("⚠️ Migration flag reset - migration will run again on next launch")
    }
}
