import SwiftUI
import UIKit

// MARK: - Settings View
// Configure app preferences and settings

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var showThemeSelector = false
    @State private var showDeleteConfirmation = false
    @State private var showDeleteSuccess = false
    @State private var showingReminderWizard = false
    @State private var showingPaywall = false
    @State private var navigateToCalendarSync = false
    // App version and build number from Info.plist
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    var body: some View {
        Form {
            // ── My Plan ───────────────────────────────────────────────────
            // Shows the user's current subscription tier with a coloured badge.
            // Free users see an Upgrade button; monthly users see Manage Subscription.
            Section("My Plan") {
                // Status row — icon, plan name, description, badge pill
                HStack(spacing: 14) {
                    Image(systemName: planIcon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(planAccentColor)
                        .frame(width: 40, height: 40)
                        .background(planAccentColor.opacity(0.12))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(planName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text(planDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // Coloured pill badge: FREE / ACTIVE / LIFETIME
                    Text(planBadgeText)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .tracking(0.3)
                        .foregroundColor(planAccentColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(planAccentColor.opacity(0.12))
                        .cornerRadius(20)
                }
                .padding(.vertical, 4)

                // Action row — depends on the current plan
                switch subscriptionManager.currentPlan {
                case .free:
                    // Free users: show an Upgrade button that opens the paywall
                    Button {
                        showingPaywall = true
                    } label: {
                        HStack {
                            Label("Upgrade to Premium", systemImage: "star.fill")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                case .monthly:
                    // Monthly users: let them manage or cancel via the App Store
                    Button {
                        if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Label("Manage Subscription", systemImage: "arrow.right.circle.fill")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                case .lifetime:
                    // Lifetime users have nothing to manage — highest tier
                    EmptyView()
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
                    if subscriptionManager.isPremium {
                        showingReminderWizard = true
                    } else {
                        showingPaywall = true
                    }
                } label: {
                    HStack {
                        Label("Life Reminders", systemImage: "sparkles")
                            .foregroundColor(.primary)
                        Spacer()
                        if !subscriptionManager.isPremium {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Section("Integrations") {
                // Hidden link — activated programmatically when the user is premium.
                NavigationLink(destination: CalendarSyncSettingsView(), isActive: $navigateToCalendarSync) {
                    EmptyView()
                }
                .hidden()

                Button {
                    if subscriptionManager.isPremium {
                        navigateToCalendarSync = true
                    } else {
                        showingPaywall = true
                    }
                } label: {
                    HStack {
                        Label("Apple Calendar Sync", systemImage: "calendar.badge.clock")
                            .foregroundColor(.primary)
                        Spacer()
                        if !subscriptionManager.isPremium {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Section("Support") {
                NavigationLink(destination: SupportView()) {
                    Label("Help & Support", systemImage: "lifepreserver.fill")
                }
            }

            Section("Legal") {
                NavigationLink(destination: PrivacyPolicyView()) {
                    Label("Privacy Policy", systemImage: "lock.shield.fill")
                }

                NavigationLink(destination: TermsOfServiceView()) {
                    Label("Terms of Service", systemImage: "doc.text.fill")
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

            Section("About") {
                HStack {
                    Text("Version")
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
        .sheet(isPresented: $showingReminderWizard) {
            ReminderWizardView()
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
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
    
    // MARK: - Plan display helpers
    // These computed properties translate currentPlan into the strings and colours
    // used by the "My Plan" section above.

    private var planIcon: String {
        switch subscriptionManager.currentPlan {
        case .free:     return "lock.fill"
        case .monthly:  return "star.circle.fill"
        case .lifetime: return "crown.fill"
        }
    }

    private var planName: String {
        switch subscriptionManager.currentPlan {
        case .free:     return "Free Plan"
        case .monthly:  return "Monthly Premium"
        case .lifetime: return "Lifetime Access"
        }
    }

    private var planDescription: String {
        switch subscriptionManager.currentPlan {
        case .free:     return "Upgrade to unlock all features"
        case .monthly:  return "All premium features · Renews monthly"
        case .lifetime: return "All premium features · Yours forever"
        }
    }

    private var planBadgeText: String {
        switch subscriptionManager.currentPlan {
        case .free:     return "FREE"
        case .monthly:  return "ACTIVE"
        case .lifetime: return "LIFETIME"
        }
    }

    // Gray for free, theme primary for monthly, orange/gold for lifetime
    private var planAccentColor: Color {
        switch subscriptionManager.currentPlan {
        case .free:     return Color(.systemGray)
        case .monthly:  return themeManager.currentTheme.primaryColor
        case .lifetime: return Color.orange
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
        // HIDDEN FEATURES - Recipe data (keeping for potential future use)
        // dataManager.recipes.removeAll()
        // dataManager.mealPlans.removeAll()
        // dataManager.shoppingItems.removeAll()
        dataManager.budgetCategories.removeAll()
        dataManager.expenses.removeAll()
        dataManager.recurringExpenses.removeAll()
        
        // HIDDEN FEATURE - Vault (keeping KeychainManager files for now)
        // Clear vault items (including Keychain data)
        // dataManager.clearAllVaultData()
        
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
        // HIDDEN FEATURES - Recipe data keys
        // UserDefaults.standard.removeObject(forKey: "recipes")
        // UserDefaults.standard.removeObject(forKey: "mealPlans")
        // UserDefaults.standard.removeObject(forKey: "shoppingItems")
        // UserDefaults.standard.removeObject(forKey: "vault")
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
            ScrollView {
                VStack(spacing: 28) {
                    themePreviewCard
                    ForEach(ThemeManager.ThemeCategory.allCases, id: \.self) { category in
                        themeSectionView(for: category)
                    }
                }
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Choose Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var themePreviewCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Preview", systemImage: "eye.fill")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)

            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.currentTheme.backgroundColor)
                .frame(height: 190)
                .overlay(
                    VStack(spacing: 0) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Good Morning!")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .fontDesign(themeManager.currentTheme.fontDesign)
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                                Text("Let's tackle today")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Circle()
                                .fill(LinearGradient(
                                    colors: [themeManager.currentTheme.primaryColor, themeManager.currentTheme.accentColor],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ))
                                .frame(width: 36, height: 36)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 14)

                        HStack(spacing: 10) {
                            ForEach([
                                ("calendar", true), ("target", false),
                                ("book.fill", true), ("sparkles", false)
                            ], id: \.0) { icon, isPrimary in
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(themeManager.currentTheme.cardColor)
                                    .frame(height: 66)
                                    .overlay(
                                        VStack(spacing: 6) {
                                            Image(systemName: icon)
                                                .font(.system(size: 18))
                                                .foregroundColor(isPrimary
                                                    ? themeManager.currentTheme.primaryColor
                                                    : themeManager.currentTheme.accentColor)
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill((isPrimary
                                                    ? themeManager.currentTheme.primaryColor
                                                    : themeManager.currentTheme.accentColor).opacity(0.3))
                                                .frame(height: 4)
                                                .padding(.horizontal, 8)
                                        }
                                    )
                                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal, 16)
                        Spacer()
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [themeManager.currentTheme.primaryColor, themeManager.currentTheme.accentColor],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: themeManager.currentTheme.primaryColor.opacity(0.2), radius: 14, x: 0, y: 6)
                .padding(.horizontal, 20)
                .animation(.easeInOut(duration: 0.25), value: themeManager.currentTheme.rawValue)
        }
    }

    private func themeSectionView(for category: ThemeManager.ThemeCategory) -> some View {
        let themes = ThemeManager.AppTheme.allCases.filter { $0.category == category }
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: categoryIcon(for: category))
                    .font(.caption)
                Text(category.rawValue.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .tracking(1)
            }
            .foregroundColor(.secondary)
            .padding(.horizontal, 20)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(themes) { theme in
                    ThemeCardView(theme: theme, isSelected: themeManager.currentTheme == theme) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            themeManager.setTheme(theme)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func categoryIcon(for category: ThemeManager.ThemeCategory) -> String {
        switch category {
        case .light:   return "sun.max.fill"
        case .dark:    return "moon.fill"
        case .vibrant: return "sparkles"
        }
    }
}

// MARK: - Theme Card View

struct ThemeCardView: View {
    let theme: ThemeManager.AppTheme
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(theme.backgroundColor)
                        .frame(height: 54)
                        .overlay(
                            HStack(spacing: 0) {
                                Rectangle()
                                    .fill(theme.primaryColor)
                                Rectangle()
                                    .fill(theme.accentColor)
                            }
                            .opacity(0.80)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        )

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white, theme.primaryColor)
                            .shadow(radius: 2)
                    }
                }

                Text(theme.rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .frame(height: 28)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? theme.primaryColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
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
        ("budget", "Budget", "dollarsign.circle.fill")
        // HIDDEN - Recipes feature removed
        // ("recipes", "Recipes", "fork.knife")
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

