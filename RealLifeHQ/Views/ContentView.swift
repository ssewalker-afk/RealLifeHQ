import SwiftUI

// MARK: - Main Content View
// This is the first screen users see - it shows tabs at the bottom

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    @State private var storeManager = StoreManager.shared
    @State private var showPaywall = false
    
    var body: some View {
        Group {
            if shouldShowPaywall {
                // Show paywall if not subscribed or first launch
                SubscriptionView()
            } else {
                // Show main app content
                mainAppContent
            }
        }
        .onAppear {
            checkSubscriptionStatus()
        }
    }
    
    private var shouldShowPaywall: Bool {
        // Show paywall if not onboarded OR not subscribed
        return !dataManager.settings.hasCompletedOnboarding || !storeManager.isSubscribed
    }
    
    private func checkSubscriptionStatus() {
        Task {
            await storeManager.updateSubscriptionStatus()
        }
    }
    
    private var mainAppContent: some View {
        TabView {
            // Home Dashboard Tab
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // Calendar Tab
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            
            // Habits Tab
            HabitsView()
                .tabItem {
                    Label("Habits", systemImage: "target")
                }
            
            // More Tab (Journal, Budget, Recipes, Vault, Settings)
            MoreView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle.fill")
                }
        }
        .accentColor(themeManager.currentTheme.primaryColor)
    }
}

// MARK: - Home Dashboard View
// Shows widgets for quick access to everything

struct HomeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Greeting Header
                    greetingHeader
                    
                    // Today's Events Widget
                    todaysEventsWidget
                    
                    // Habits Widget
                    habitsWidget
                    
                    // Quick Stats
                    quickStatsWidget
                }
                .padding()
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("RealLifeHQ")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                }
            }
        }
    }
    
    // MARK: - Greeting Header
    
    private var greetingHeader: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(greeting)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Here's what's happening today")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Circle()
                .fill(themeManager.currentTheme.primaryColor.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(greetingEmoji)
                        .font(.largeTitle)
                )
        }
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
    
    private var greetingEmoji: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "☀️"
        case 12..<17: return "🌤️"
        default: return "🌙"
        }
    }
    
    // MARK: - Today's Events Widget
    
    private var todaysEventsWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                Text("Today's Events")
                    .font(.headline)
                Spacer()
                NavigationLink(destination: CalendarView()) {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.accentColor)
                }
            }
            
            if dataManager.todaysEvents().isEmpty {
                Text("No events scheduled")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(dataManager.todaysEvents().prefix(3)) { event in
                    EventRow(event: event)
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
    
    // MARK: - Habits Widget
    
    private var habitsWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                Text("Today's Habits")
                    .font(.headline)
                Spacer()
                NavigationLink(destination: HabitsView()) {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.accentColor)
                }
            }
            
            if dataManager.habits.isEmpty {
                Text("No habits yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(dataManager.habits.prefix(3)) { habit in
                    HabitRow(habit: habit)
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
    
    // MARK: - Quick Stats Widget
    
    private var quickStatsWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Stats")
                .font(.headline)
            
            HStack(spacing: 15) {
                NavigationLink(destination: BudgetView()) {
                    StatCard(
                        icon: "dollarsign.circle.fill",
                        value: budgetRemainingText,
                        label: "Budget",
                        color: .green
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: JournalView()) {
                    StatCard(
                        icon: "book.closed.fill",
                        value: "\(dataManager.journalEntries.count)",
                        label: "Entries",
                        color: themeManager.currentTheme.accentColor
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: RecipesView()) {
                    StatCard(
                        icon: "fork.knife",
                        value: "\(dataManager.recipes.count)",
                        label: "Recipes",
                        color: themeManager.currentTheme.primaryColor
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
    
    // Calculate budget remaining for current month
    private var budgetRemainingText: String {
        let currentMonth = getCurrentMonthKey()
        let monthBudget = dataManager.getMonthlyBudget(for: currentMonth)
        
        if monthBudget.totalBudget == 0 {
            return "$0" // No budget setup yet
        }
        
        let remaining = monthBudget.remaining
        if remaining >= 0 {
            return "$\(Int(remaining))" // Positive - money left
        } else {
            return "-$\(Int(abs(remaining)))" // Negative - over budget
        }
    }
    
    private func getCurrentMonthKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }
    
    // MARK: - Settings Widget
}

// MARK: - Supporting Components

struct EventRow: View {
    let event: Event
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Circle()
                .fill(themeManager.currentTheme.primaryColor)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if let time = event.timeString {
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if event.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

struct HabitRow: View {
    let habit: Habit
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Image(systemName: habit.icon)
                .foregroundColor(Color(habit.color))
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(habit.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(habit.currentStreak()) day streak")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                dataManager.toggleHabit(habit)
            } label: {
                Image(systemName: habit.isCompletedToday() ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(habit.isCompletedToday() ? .green : .gray)
                    .font(.title3)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}
