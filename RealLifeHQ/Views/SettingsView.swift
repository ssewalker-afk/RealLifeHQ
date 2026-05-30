import SwiftUI

// MARK: - Settings View
// Configure app preferences and settings

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(SubscriptionManager.self) private var subscriptionManager

    @State private var showThemeSelector = false
    @State private var showDeleteConfirmation = false
    @State private var showDeleteSuccess = false
    @State private var showPaywall = false
    @State private var showLifeReminders = false

    // App version and build number from Info.plist
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }

    var body: some View {
        Form {
            // MARK: My Plan
            Section("My Plan") {
                planRow

                if subscriptionManager.currentPlan == .free {
                    Button {
                        showPaywall = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                                .font(.title3)
                            Text("Upgrade to Premium")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    Button {
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.up.right.circle.fill")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                                .font(.title3)
                            Text("Manage Subscription")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

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

            Section("Notifications") {
                Toggle(isOn: $dataManager.settings.enableNotifications) {
                    Label("Enable Notifications", systemImage: "bell.fill")
                }
                .onChange(of: dataManager.settings.enableNotifications) { newValue in
                    var settings = dataManager.settings
                    settings.enableNotifications = newValue
                    dataManager.updateSettings(settings)
                }

                Button {
                    showLifeReminders = true
                } label: {
                    HStack {
                        Label("Life Reminders", systemImage: "bolt.fill")
                            .foregroundColor(.primary)
                        Spacer()
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
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showLifeReminders) {
            ReminderWizardView()
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
            Text("This will permanently delete all your events, habits, journal entries, budget data, and reset all settings. This action cannot be undone.")
        }
        .alert("All Data Cleared", isPresented: $showDeleteSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("All your data has been permanently deleted and settings have been reset.")
        }
    }

    // MARK: - Plan Row

    @ViewBuilder
    private var planRow: some View {
        HStack(spacing: 14) {
            // Plan icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                themeManager.currentTheme.primaryColor,
                                themeManager.currentTheme.accentColor
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)

                Image(systemName: planIcon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Plan name + description
            VStack(alignment: .leading, spacing: 2) {
                Text(planTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(planSubtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Status badge — only shown for paid plans
            if subscriptionManager.currentPlan != .free {
                Text("ACTIVE")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
    }

    private var planIcon: String {
        switch subscriptionManager.currentPlan {
        case .free:     return "person.fill"
        case .monthly:  return "star.fill"
        case .lifetime: return "crown.fill"
        }
    }

    private var planTitle: String {
        switch subscriptionManager.currentPlan {
        case .free:     return "Free Plan"
        case .monthly:  return "Monthly Premium"
        case .lifetime: return "Lifetime Access"
        }
    }

    private var planSubtitle: String {
        switch subscriptionManager.currentPlan {
        case .free:     return "3 habits · 3 journal entries"
        case .monthly:  return "All premium features · Renews monthly"
        case .lifetime: return "All premium features · One-time purchase"
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

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    private var lightThemes: [ThemeManager.AppTheme] {
        ThemeManager.AppTheme.allCases.filter { $0.category == .light }
    }
    private var darkThemes: [ThemeManager.AppTheme] {
        ThemeManager.AppTheme.allCases.filter { $0.category == .dark }
    }
    private var vibrantThemes: [ThemeManager.AppTheme] {
        ThemeManager.AppTheme.allCases.filter { $0.category == .vibrant }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    categorySection(title: "Light", icon: "sun.max.fill", themes: lightThemes)
                    categorySection(title: "Dark", icon: "moon.fill", themes: darkThemes)
                    categorySection(title: "Vibrant", icon: "sparkles", themes: vibrantThemes)
                }
                .padding()
            }
            .navigationTitle("Choose Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func categorySection(title: String, icon: String, themes: [ThemeManager.AppTheme]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 2)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(themes) { theme in
                    ThemePreviewCard(
                        theme: theme,
                        isSelected: themeManager.currentTheme == theme
                    ) {
                        themeManager.setTheme(theme)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Theme Preview Card

struct ThemePreviewCard: View {
    let theme: ThemeManager.AppTheme
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 0) {
                // Mini app UI preview
                ZStack {
                    theme.backgroundColor

                    VStack(spacing: 6) {
                        // Simulated nav bar
                        HStack {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(theme.primaryColor)
                                .frame(height: 6)
                                .frame(maxWidth: .infinity)
                            Circle()
                                .fill(theme.accentColor)
                                .frame(width: 14, height: 14)
                        }
                        .padding(.horizontal, 10)

                        // Simulated card 1
                        RoundedRectangle(cornerRadius: 6)
                            .fill(theme.cardColor)
                            .frame(height: 28)
                            .overlay(
                                HStack(spacing: 5) {
                                    Circle()
                                        .fill(theme.primaryColor)
                                        .frame(width: 9, height: 9)
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(theme.primaryColor.opacity(0.45))
                                        .frame(height: 5)
                                    Spacer()
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(theme.accentColor.opacity(0.7))
                                        .frame(width: 18, height: 5)
                                }
                                .padding(.horizontal, 8)
                            )
                            .padding(.horizontal, 10)

                        // Simulated card 2
                        RoundedRectangle(cornerRadius: 6)
                            .fill(theme.cardColor)
                            .frame(height: 18)
                            .overlay(
                                HStack(spacing: 5) {
                                    Circle()
                                        .fill(theme.accentColor)
                                        .frame(width: 7, height: 7)
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(theme.accentColor.opacity(0.4))
                                        .frame(height: 4)
                                    Spacer()
                                }
                                .padding(.horizontal, 8)
                            )
                            .padding(.horizontal, 10)
                    }
                    .padding(.vertical, 10)
                }
                .frame(height: 88)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                // Label row
                HStack(spacing: 6) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(theme.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        HStack(spacing: 3) {
                            Circle().fill(theme.primaryColor).frame(width: 9, height: 9)
                            Circle().fill(theme.accentColor).frame(width: 9, height: 9)
                        }
                    }
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(theme.primaryColor)
                            .font(.callout)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        isSelected ? theme.primaryColor : Color(.systemGray4),
                        lineWidth: isSelected ? 2.5 : 1
                    )
            )
            .shadow(color: .black.opacity(isSelected ? 0.12 : 0.05), radius: isSelected ? 6 : 3, y: 2)
        }
        .buttonStyle(.plain)
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
