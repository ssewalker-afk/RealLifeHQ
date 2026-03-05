import SwiftUI

// MARK: - More View
// Access Calendar, Recipes, Journal, Vault, and Settings

struct MoreView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationStack {
            List {
                Section("Features") {
                    NavigationLink(destination: CalendarView()) {
                        Label("Calendar", systemImage: "calendar")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                    
                    NavigationLink(destination: RecipesView()) {
                        Label("Recipes", systemImage: "fork.knife")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                    
                    NavigationLink(destination: JournalView()) {
                        Label("Journal", systemImage: "book.fill")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                    
                    NavigationLink(destination: VaultView()) {
                        Label("Vault", systemImage: "lock.shield.fill")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                }
                
                Section("App") {
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gear")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                }
                
                Section("Legal") {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("Privacy Policy", systemImage: "lock.shield.fill")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                    
                    NavigationLink(destination: TermsOfServiceView()) {
                        Label("Terms of Service", systemImage: "doc.text.fill")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                }
                
                Section {
                    HStack {
                        Text("Version")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("More")
        }
    }
}



