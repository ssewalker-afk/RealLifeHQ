import SwiftUI

// MARK: - Settings View
// Configure app preferences and settings

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showThemeSelector = false
    @State private var showDeleteConfirmation = false
    @State private var showDeleteSuccess = false
    
    // App version and build number from Info.plist
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    var body: some View {
        Form {
            Section("Appearance") {
                Button {
                    showThemeSelector = true
                } label: {
                    HStack {
                        Label("Theme", systemImage: "paintbrush.fill")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(themeManager.currentTheme.primaryColor)
                                .frame(width: 16, height: 16)
                            
                            Circle()
                                .fill(themeManager.currentTheme.accentColor)
                                .frame(width: 16, height: 16)
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section("Integrations") {
                NavigationLink(destination: CalendarSyncSettingsView()) {
                    Label("Apple Calendar Sync", systemImage: "calendar.badge.clock")
                }
            }
            
            Section("Notifications") {
                Toggle(isOn: $dataManager.settings.enableNotifications) {
                    Label("Enable Notifications", systemImage: "bell.fill")
                }
                .onChange(of: dataManager.settings.enableNotifications) { newValue in
                    var settings = dataManager.settings
                    settings.enableNotifications = newValue
                    dataManager.updateSettings(settings)
                }
            }
            
            Section("Data") {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Clear All Data", systemImage: "trash.fill")
                        .foregroundColor(.red)
                }
            }
            
            Section("Legal") {
                NavigationLink(destination: PrivacyPolicyView()) {
                    Label("Privacy Policy", systemImage: "lock.shield.fill")
                }
                
                NavigationLink(destination: TermsOfServiceView()) {
                    Label("Terms of Service", systemImage: "doc.text.fill")
                }
                
                NavigationLink(destination: SupportView()) {
                    Label("Support & Help", systemImage: "lifepreserver.fill")
                }
            }
            
            Section("About") {
                HStack {
                    Text("App Version")
                    Spacer()
                    Text(appVersion)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text(buildNumber)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showThemeSelector) {
            ThemeSelectorView()
        }
        .confirmationDialog(
            "Clear All Data",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear All Data", role: .destructive) {
                clearAllData()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete all your events, habits, journal entries, recipes, meal plans, budget data, vault items, and reset all settings. This action cannot be undone.")
        }
        .alert("All Data Cleared", isPresented: $showDeleteSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("All your data has been permanently deleted and settings have been reset.")
        }
    }
    
    private func clearAllData() {
        // Cancel all habit notifications before clearing data
        for habit in dataManager.habits {
            NotificationManager.shared.cancelHabitReminders(identifiers: habit.notificationIdentifiers)
        }
        
        // Clear all data arrays
        dataManager.events.removeAll()
        dataManager.habits.removeAll()
        dataManager.journalEntries.removeAll()
        dataManager.transactions.removeAll()
        dataManager.recipes.removeAll()
        dataManager.mealPlans.removeAll()
        dataManager.shoppingItems.removeAll()
        dataManager.budgetCategories.removeAll()
        dataManager.expenses.removeAll()
        dataManager.recurringExpenses.removeAll()
        
        // Clear vault items (including Keychain data)
        dataManager.clearAllVaultData()
        
        // Reset budget setup
        dataManager.budgetSetup = BudgetSetup(monthlyIncome: 0)
        
        // Reset settings to defaults (but keep onboarding completed)
        let wasOnboardingCompleted = dataManager.settings.hasCompletedOnboarding
        dataManager.settings = UserSettings()
        dataManager.settings.hasCompletedOnboarding = wasOnboardingCompleted
        
        // Force save all cleared data by removing UserDefaults keys
        UserDefaults.standard.removeObject(forKey: "events")
        UserDefaults.standard.removeObject(forKey: "habits")
        UserDefaults.standard.removeObject(forKey: "journal")
        UserDefaults.standard.removeObject(forKey: "transactions")
        UserDefaults.standard.removeObject(forKey: "recipes")
        UserDefaults.standard.removeObject(forKey: "mealPlans")
        UserDefaults.standard.removeObject(forKey: "shoppingItems")
        UserDefaults.standard.removeObject(forKey: "vault")
        UserDefaults.standard.removeObject(forKey: "budgetSetup")
        UserDefaults.standard.removeObject(forKey: "budgetCategories")
        UserDefaults.standard.removeObject(forKey: "expenses")
        UserDefaults.standard.removeObject(forKey: "recurringExpenses")
        
        // Save the reset settings
        if let encoded = try? JSONEncoder().encode(dataManager.settings) {
            UserDefaults.standard.set(encoded, forKey: "settings")
        }
        
        // Show success message
        showDeleteSuccess = true
    }
}

// MARK: - Theme Selector View

struct ThemeSelectorView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(ThemeManager.AppTheme.allCases) { theme in
                    Button {
                        themeManager.setTheme(theme)
                        dismiss()
                    } label: {
                        HStack {
                            // Color Preview
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(theme.primaryColor)
                                    .frame(width: 30, height: 30)
                                
                                Circle()
                                    .fill(theme.accentColor)
                                    .frame(width: 30, height: 30)
                            }
                            
                            // Theme Name
                            Text(theme.rawValue)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            // Selected Indicator
                            if themeManager.currentTheme == theme {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(theme.primaryColor)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Choose Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Widget Settings View

struct WidgetSettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var enabledWidgets: Set<String> = []
    
    let availableWidgets = [
        ("events", "Events", "calendar"),
        ("habits", "Habits", "target"),
        ("journal", "Journal", "book.fill"),
        ("budget", "Budget", "dollarsign.circle.fill"),
        ("recipes", "Recipes", "fork.knife")
    ]
    
    var body: some View {
        Form {
            Section {
                Text("Choose which widgets appear on your home dashboard")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section("Available Widgets") {
                ForEach(availableWidgets, id: \.0) { widget in
                    Toggle(isOn: Binding(
                        get: { enabledWidgets.contains(widget.0) },
                        set: { enabled in
                            if enabled {
                                enabledWidgets.insert(widget.0)
                            } else {
                                enabledWidgets.remove(widget.0)
                            }
                            saveWidgetSettings()
                        }
                    )) {
                        Label(widget.1, systemImage: widget.2)
                    }
                }
            }
        }
        .navigationTitle("Dashboard Widgets")
        .onAppear {
            enabledWidgets = Set(dataManager.settings.dashboardWidgets)
        }
    }
    
    private func saveWidgetSettings() {
        var settings = dataManager.settings
        settings.dashboardWidgets = Array(enabledWidgets)
        dataManager.updateSettings(settings)
    }
}
