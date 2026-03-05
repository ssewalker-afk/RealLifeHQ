import SwiftUI

// MARK: - Main Content View
// This is the first screen users see - it shows tabs at the bottom

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                iPadLayout
            } else {
                mainAppContent
            }
        }
        .preferredColorScheme(themeManager.currentTheme.colorScheme)
        .fontDesign(themeManager.currentTheme.fontDesign)
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
                    NavigationLink(destination: CleaningTrackerView()) {
                        Label("Cleaning", systemImage: "sparkles")
                    }
                }
                
                Section("Productivity") {
                    NavigationLink(destination: BudgetView()) {
                        Label("Budget", systemImage: "dollarsign.circle.fill")
                    }
                }
                
                // MARK: - HIDDEN FEATURES
                // Recipes, Meal Plans, Shopping List - hidden (too complex for multi-feature app)
                // Vault - hidden (password management should be separate app/use iCloud Keychain)
                
                // Section("Lifestyle") {
                //     NavigationLink(destination: RecipesView()) {
                //         Label("Recipes", systemImage: "fork.knife")
                //     }
                //     NavigationLink(destination: VaultView()) {
                //         Label("Vault", systemImage: "lock.shield.fill")
                //     }
                // }
                
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

            // Cleaning Tracker Tab
            CleaningTrackerView()
                .tabItem {
                    Label("Cleaning", systemImage: "sparkles")
                }

            // Budget Tab
            NavigationStack {
                BudgetView()
            }
            .tabItem {
                Label("Budget", systemImage: "dollarsign.circle.fill")
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
            cleaningWidget
            budgetWidget

            // Vault Quick Link at bottom
            // vaultQuickLink // HIDDEN - password management should be separate
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
                cleaningWidget
                budgetWidget
            }

            // Vault Quick Link at bottom
            // vaultQuickLink // HIDDEN - password management should be separate
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
                NavigationLink(destination: HabitsView()) {
                    HomeSetupPrompt(
                        emoji: "🌱",
                        headline: "Your habit journey starts here!",
                        subtext: "Build powerful routines, one day at a time.",
                        cta: "Create Your First Habit",
                        color: themeManager.currentTheme.accentColor
                    )
                }
                .buttonStyle(PlainButtonStyle())
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

    private var hasTodaysJournalEntry: Bool {
        dataManager.journalEntries.contains { Calendar.current.isDateInToday($0.date) }
    }

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
                    if hasTodaysJournalEntry {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                            .font(.subheadline)
                    }
                }

                if hasTodaysJournalEntry {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Today's Entry: Done!")
                            .font(.caption)
                            .foregroundColor(.green)
                            .textCase(.uppercase)
                            .fontWeight(.semibold)

                        Text("You showed up for yourself today. That's worth celebrating! 🎉")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.top, 4)

                    HStack {
                        Spacer()
                        Text("Tap to read")
                            .font(.caption)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.caption)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                } else {
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
        Group {
            if dataManager.budgetSetup.monthlyIncome == 0 {
                NavigationLink(destination: BudgetView()) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(themeManager.currentTheme.accentColor)
                            Text("Budget")
                                .font(.headline)
                                .foregroundColor(themeManager.currentTheme.accentColor)
                            Spacer()
                        }
                        HomeSetupPrompt(
                            emoji: "💰",
                            headline: "Take charge of your finances!",
                            subtext: "Set your income, plan your spending, and keep more of what you earn.",
                            cta: "Set Up Budget",
                            color: themeManager.currentTheme.accentColor
                        )
                    }
                    .padding()
                    .background(themeManager.currentTheme.cardColor)
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
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
    
    // MARK: - Cleaning Widget
    
    private var cleaningWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(themeManager.currentTheme.accentColor)
                Text("Cleaning")
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.accentColor)
                Spacer()
                NavigationLink(destination: CleaningTrackerView()) {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.accentColor)
                }
            }
            
            if dataManager.cleaningProfile == nil {
                NavigationLink(destination: CleaningTrackerView()) {
                    HomeSetupPrompt(
                        emoji: "🧹",
                        headline: "A tidy home, a clear mind!",
                        subtext: "Set up your cleaning schedule and make sparkling easy.",
                        cta: "Set Up Cleaning",
                        color: themeManager.currentTheme.accentColor
                    )
                }
                .buttonStyle(PlainButtonStyle())
            } else if let todaySession = dataManager.getTodaySession() {
                // Today's cleaning task
                NavigationLink(destination: CleaningTrackerView()) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Today's Task")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            
                            Text(todaySession.taskTitle)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.caption2)
                                if let task = dataManager.cleaningTasks.first(where: { $0.id == todaySession.taskId }) {
                                    Text("\(task.estimatedDuration) min")
                                        .font(.caption)
                                }
                            }
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(themeManager.currentTheme.accentColor.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                // No task today
                NavigationLink(destination: CleaningTrackerView()) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("✨ All caught up!")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("No cleaning scheduled for today")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Streak info
            if dataManager.cleaningProfile != nil && dataManager.cleaningStatistics.currentStreak > 0 {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("\(dataManager.cleaningStatistics.currentStreak) day streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
    
    // MARK: - Recipes Widget (HIDDEN)
    
    // Recipes are hidden - they're a whole separate app's worth of features
    /*
    private var recipesWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "fork.knife")
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                Text("Recipes")
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                Spacer()
                NavigationLink(destination: RecipesView()) {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
            
            if dataManager.recipes.isEmpty {
                // No recipes yet
                NavigationLink(destination: RecipesView()) {
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        Text("Add your first recipe")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                // Show recipe count and quick actions
                VStack(spacing: 8) {
                    HStack(spacing: 16) {
                        // Recipe count
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(dataManager.recipes.count)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                            Text("Recipes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                            .frame(height: 30)
                        
                        // Meal plan count
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(dataManager.mealPlans.count)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.currentTheme.accentColor)
                            Text("Planned")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: RecipesView()) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title2)
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                    }
                    
                    // Shopping list indicator
                    if !dataManager.shoppingItems.isEmpty {
                        HStack {
                            Image(systemName: "cart.fill")
                                .font(.caption)
                                .foregroundColor(themeManager.currentTheme.accentColor)
                            Text("\(dataManager.shoppingItems.filter { !$0.isChecked }.count) items on shopping list")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
    */
    
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
    
    // MARK: - Vault Quick Link (HIDDEN)
    
    // Vault is hidden - password management should be a separate app or use iCloud Keychain
    /*
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
    */
    
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
// MARK: - Home Setup Prompt

struct HomeSetupPrompt: View {
    let emoji: String
    let headline: String
    let subtext: String
    let cta: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            Text(emoji)
                .font(.largeTitle)
            Text(headline)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            Text(subtext)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Text("\(cta) →")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
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

