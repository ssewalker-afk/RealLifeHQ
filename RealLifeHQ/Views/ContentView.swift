import SwiftUI

// MARK: - Main Content View
// This is the first screen users see - it shows tabs at the bottom

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    @State private var storeManager = StoreManager.shared
    @State private var showPaywall = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        Group {
            if shouldShowPaywall {
                // Show paywall if not subscribed or first launch
                SubscriptionView()
            } else {
                // Show main app content - different layout for iPad vs iPhone
                if horizontalSizeClass == .regular {
                    // iPad: Use sidebar navigation
                    iPadLayout
                } else {
                    // iPhone: Use tab bar
                    mainAppContent
                }
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
    
    // iPad Layout with Sidebar Navigation
    private var iPadLayout: some View {
        NavigationSplitView {
            // Sidebar
            List {
                Section {
                    NavigationLink(destination: HomeView()) {
                        Label("Home", systemImage: "house.fill")
                    }
                    NavigationLink(destination: CalendarView()) {
                        Label("Calendar", systemImage: "calendar")
                    }
                    NavigationLink(destination: HabitsView()) {
                        Label("Habits", systemImage: "target")
                    }
                }
                
                Section("Productivity") {
                    NavigationLink(destination: JournalView()) {
                        Label("Journal", systemImage: "book.closed.fill")
                    }
                    NavigationLink(destination: BudgetView()) {
                        Label("Budget", systemImage: "dollarsign.circle.fill")
                    }
                }
                
                Section("Lifestyle") {
                    // Recipes temporarily hidden - work in progress
                    // NavigationLink(destination: RecipesView()) {
                    //     Label("Recipes", systemImage: "fork.knife")
                    // }
                    NavigationLink(destination: VaultView()) {
                        Label("Vault", systemImage: "lock.shield.fill")
                    }
                }
                
                Section {
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .navigationTitle("RealLifeHQ")
            .listStyle(.sidebar)
        } detail: {
            // Default detail view
            HomeView()
        }
        .accentColor(themeManager.currentTheme.primaryColor)
    }
    
    // iPhone Layout with Tab Bar
    private var mainAppContent: some View {
        TabView {
            // Home Dashboard Tab
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // Calendar Tab
            NavigationStack {
                CalendarView()
            }
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }
            
            // Habits Tab
            HabitsView()
                .tabItem {
                    Label("Habits", systemImage: "target")
                }
            
            // Budget Tab
            NavigationStack {
                BudgetView()
            }
            .tabItem {
                Label("Budget", systemImage: "dollarsign.circle.fill")
            }
            
            // Journal Tab
            NavigationStack {
                JournalView()
            }
            .tabItem {
                Label("Journal", systemImage: "book.fill")
            }
            
            // Vault Tab
            NavigationStack {
                VaultView()
            }
            .tabItem {
                Label("Vault", systemImage: "lock.shield.fill")
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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // State for showing add screens
    @State private var showingAddExpense = false
    @State private var showingAddJournalEntry = false
    // Removed selectedRecipesTab and navigateToShoppingList - recipes temporarily hidden
    
    // Animation state for greeting icon
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                Group {
                    if horizontalSizeClass == .regular {
                        // iPad layout with grid
                        iPadLayout
                    } else {
                        // iPhone layout with vertical stack
                        iPhoneLayout
                    }
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
        .navigationViewStyle(.stack) // Prevents unwanted split view behavior
    }
    
    // iPhone Layout - Vertical Stack
    private var iPhoneLayout: some View {
        VStack(spacing: 20) {
            greetingHeader
            todaysEventsWidget
            habitsWidget
            journalPromptWidget
            budgetWidget
            
            // Vault Quick Link at bottom
            vaultQuickLink
        }
    }
    
    // iPad Layout - Two-Column Grid
    private var iPadLayout: some View {
        VStack(spacing: 20) {
            greetingHeader
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20)
            ], spacing: 20) {
                todaysEventsWidget
                habitsWidget
                journalPromptWidget
                budgetWidget
            }
            
            // Vault Quick Link at bottom
            vaultQuickLink
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
            
            // SF Symbol with gradient background and pulse animation
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            greetingColor.opacity(0.3),
                            greetingColor.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 70, height: 70)
                .overlay(
                    Image(systemName: greetingSFSymbol)
                        .font(.system(size: 32))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    greetingColor,
                                    greetingColor.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                )
                .shadow(color: greetingColor.opacity(0.3), radius: 8, x: 0, y: 4)
                .onAppear {
                    isAnimating = true
                }
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
    
    // SF Symbol name based on time of day
    private var greetingSFSymbol: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "sun.max.fill"
        case 12..<17: return "cloud.sun.fill"
        default: return "moon.stars.fill"
        }
    }
    
    // Color based on time of day
    private var greetingColor: Color {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return .orange
        case 12..<17: return .blue
        default: return .purple
        }
    }
    
    // Image name based on time of day
    private var greetingImageName: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "morning-icon"
        case 12..<17: return "afternoon-icon"
        default: return "evening-icon"
        }
    }
    
    // Keep this if you want to fall back to emojis
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
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                Spacer()
                NavigationLink(destination: CalendarView()) {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
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
                    .foregroundColor(themeManager.currentTheme.accentColor)
                Text("Today's Habits")
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.accentColor)
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
    
    // MARK: - Journal Prompt Widget
    
    private var journalPromptWidget: some View {
        Button {
            showingAddJournalEntry = true
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "book.closed.fill")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    Text("Journal")
                        .font(.headline)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Prompt")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text(todaysJournalPrompt)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .padding(.top, 4)
                
                HStack {
                    Spacer()
                    Text("Tap to write")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
            .padding()
            .background(themeManager.currentTheme.cardColor)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingAddJournalEntry) {
            AddJournalEntryView()
        }
    }
    
    // MARK: - Budget Widget
    
    private var budgetWidget: some View {
        Button {
            showingAddExpense = true
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(themeManager.currentTheme.accentColor)
                    Text("Budget")
                        .font(.headline)
                        .foregroundColor(themeManager.currentTheme.accentColor)
                    Spacer()
                }
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Remaining This Month")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        Text(budgetRemainingText)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(budgetRemainingColor)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(themeManager.currentTheme.accentColor)
                            Text("Add Expense")
                                .font(.caption)
                                .foregroundColor(themeManager.currentTheme.accentColor)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .padding()
            .background(themeManager.currentTheme.cardColor)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingAddExpense) {
            NavigationStack {
                AddExpenseView()
            }
        }
    }
    
    // Get color based on budget status
    private var budgetRemainingColor: Color {
        let currentMonth = getCurrentMonthKey()
        let monthBudget = dataManager.getMonthlyBudget(for: currentMonth)
        let remaining = monthBudget.remaining
        
        if remaining >= monthBudget.totalBudget * 0.5 {
            return .green
        } else if remaining >= 0 {
            return .orange
        } else {
            return .red
        }
    }
    
    // Generate a journal prompt based on the day of the year
    private var todaysJournalPrompt: String {
        let prompts = [
            "What are you grateful for today?",
            "What's one thing you learned recently?",
            "What made you smile today?",
            "What's your biggest goal right now?",
            "What would your ideal day look like?",
            "What's something you're proud of?",
            "What challenge are you facing?",
            "Who made a positive impact on you today?",
            "What do you want to remember about today?",
            "What's one thing you want to improve?",
            "What's bringing you joy lately?",
            "What are you looking forward to?",
            "What's a recent accomplishment?",
            "How did you take care of yourself today?",
            "What's something new you want to try?",
            "What's a happy memory from this week?",
            "What values are most important to you?",
            "What's one way you helped someone?",
            "What's something you love about yourself?",
            "What would you tell your younger self?",
            "What makes you feel most alive?",
            "What's your favorite part of your routine?",
            "What's a dream you have for your future?",
            "What surprised you today?",
            "What's something you're curious about?",
            "How did you show kindness today?",
            "What's a lesson you've learned the hard way?",
            "What energizes you?",
            "What peaceful moment did you experience?",
            "What's something you want to let go of?"
        ]
        
        // Use day of year to get consistent prompt for the day
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return prompts[dayOfYear % prompts.count]
    }
    
    // MARK: - Vault Quick Link
    
    private var vaultQuickLink: some View {
        NavigationLink(destination: VaultView()) {
            HStack {
                Spacer()
                
                VStack(spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 32))
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    
                    Text("Vault")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(themeManager.currentTheme.cardColor)
                .cornerRadius(12)
                
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Calculate budget remaining for current month
    private var budgetRemainingText: String {
        let currentMonth = getCurrentMonthKey()
        let monthBudget = dataManager.getMonthlyBudget(for: currentMonth)
        
        if monthBudget.totalBudget == 0 {
            return "$0" // No budget setup yet
        }
        
        let remaining = monthBudget.remaining
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        
        if remaining >= 0 {
            // Positive - money left
            if let formattedNumber = formatter.string(from: NSNumber(value: remaining)) {
                return "$\(formattedNumber)"
            }
            return "$\(Int(remaining))"
        } else {
            // Negative - over budget
            if let formattedNumber = formatter.string(from: NSNumber(value: abs(remaining))) {
                return "-$\(formattedNumber)"
            }
            return "-$\(Int(abs(remaining)))"
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
                .lineLimit(1)
                .minimumScaleFactor(0.5)
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
// MARK: - Action Card (for Quick Actions)

struct ActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

