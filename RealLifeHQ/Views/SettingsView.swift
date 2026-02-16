import SwiftUI

// MARK: - Settings View
// Configure app preferences and settings

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showThemeSelector = false
    
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
                
                NavigationLink(destination: GoogleCalendarSyncSettingsView()) {
                    HStack {
                        Label("Google Calendar Sync", systemImage: "g.circle.fill")
                        Spacer()
                        if GoogleCalendarManager.shared.isAuthenticated {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
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
            }
            
            Section("Data") {
                Button(role: .destructive) {
                    // Implement data export
                } label: {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                }
                
                Button(role: .destructive) {
                    // Implement data clear with confirmation
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
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text("1")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showThemeSelector) {
            ThemeSelectorView()
        }
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
