import Foundation
import SwiftUI
import Combine

// MARK: - Data Manager
// This handles saving and loading all your app data

class DataManager: ObservableObject {
    // @Published properties automatically update the UI when changed
    @Published var events: [Event] = []
    @Published var habits: [Habit] = []
    @Published var journalEntries: [JournalEntry] = []
    @Published var transactions: [Transaction] = []
    @Published var recipes: [Recipe] = []
    @Published var mealPlans: [MealPlan] = []
    @Published var shoppingItems: [ShoppingItem] = []
    @Published var vaultItems: [VaultItem] = []
    @Published var settings: UserSettings = UserSettings()
    
    // Budget data
    @Published var budgetSetup: BudgetSetup = BudgetSetup(monthlyIncome: 0)
    @Published var budgetCategories: [BudgetCategory] = []
    @Published var expenses: [Expense] = []
    @Published var recurringExpenses: [RecurringExpense] = []
    
    // Cleaning Tracker data
    @Published var cleaningProfile: CleaningProfile?
    @Published var cleaningTasks: [CleaningTask] = []
    @Published var cleaningSessions: [CleaningSession] = []
    @Published var cleaningAchievements: [CleaningAchievement] = []
    @Published var cleaningStatistics: CleaningStatistics = CleaningStatistics()
    
    // Keys for saving data
    private let eventsKey = "events"
    private let habitsKey = "habits"
    private let journalKey = "journal"
    private let transactionsKey = "transactions"
    private let recipesKey = "recipes"
    private let mealPlansKey = "mealPlans"
    private let shoppingItemsKey = "shoppingItems"
    private let vaultKey = "vault"
    private let settingsKey = "settings"
    private let budgetSetupKey = "budgetSetup"
    private let budgetCategoriesKey = "budgetCategories"
    private let expensesKey = "expenses"
    private let recurringExpensesKey = "recurringExpenses"
    private let cleaningProfileKey = "cleaningProfile"
    private let cleaningTasksKey = "cleaningTasks"
    private let cleaningSessionsKey = "cleaningSessions"
    private let cleaningAchievementsKey = "cleaningAchievements"
    private let cleaningStatisticsKey = "cleaningStatistics"
    
    init() {
        // Migrate existing vault data to Keychain if needed
        VaultMigrationHelper.migrateVaultDataIfNeeded()
        
        // Load all data
        loadAllData()
    }
    
    // MARK: - Events Methods
    
    func addEvent(_ event: Event) {
        events.append(event)
        saveEvents()
        
        // Sync to Apple Calendar if enabled
        Task {
            let appleCalendarManager = await AppleCalendarManager.shared
            try? await appleCalendarManager.syncEventToAppleCalendar(event)
        }
    }
    
    func updateEvent(_ event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
            saveEvents()
            
            // Sync to Apple Calendar if enabled
            Task {
                let appleCalendarManager = await AppleCalendarManager.shared
                try? await appleCalendarManager.syncEventToAppleCalendar(event)
            }
        }
    }
    
    func deleteEvent(_ event: Event) {
        // Sync deletion to Apple Calendar if enabled
        Task {
            let appleCalendarManager = await AppleCalendarManager.shared
            try? await appleCalendarManager.deleteEventFromAppleCalendar(event)
        }
        
        events.removeAll { $0.id == event.id }
        saveEvents()
    }
    
    func todaysEvents() -> [Event] {
        let today = Calendar.current.startOfDay(for: Date())
        return events.filter { event in
            Calendar.current.isDate(event.date, inSameDayAs: today)
        }.sorted { $0.date < $1.date }
    }
    
    // MARK: - Habits Methods
    
    func addHabit(_ habit: Habit) {
        var habitWithNotifications = habit
        habits.append(habitWithNotifications)
        
        // Schedule notifications if enabled
        if habit.reminderEnabled {
            Task {
                let identifiers = await NotificationManager.shared.scheduleHabitReminders(for: habitWithNotifications)
                await MainActor.run {
                    if let index = habits.firstIndex(where: { $0.id == habitWithNotifications.id }) {
                        habits[index].notificationIdentifiers = identifiers
                        saveHabits()
                    }
                }
            }
        } else {
            saveHabits()
        }
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            // Cancel old notifications
            let oldIdentifiers = habits[index].notificationIdentifiers
            NotificationManager.shared.cancelHabitReminders(identifiers: oldIdentifiers)
            
            // Update habit
            habits[index] = habit
            
            // Schedule new notifications if enabled
            if habit.reminderEnabled {
                Task {
                    let identifiers = await NotificationManager.shared.scheduleHabitReminders(for: habit)
                    await MainActor.run {
                        if let idx = habits.firstIndex(where: { $0.id == habit.id }) {
                            habits[idx].notificationIdentifiers = identifiers
                            saveHabits()
                        }
                    }
                }
            } else {
                saveHabits()
            }
        }
    }
    
    private func scheduleHabitNotifications(habit: Habit) async {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            let identifiers = await NotificationManager.shared.scheduleHabitReminders(for: habits[index])
            await MainActor.run {
                habits[index].notificationIdentifiers = identifiers
                saveHabits()
            }
        }
    }
    
    func toggleHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            let today = Calendar.current.startOfDay(for: Date())
            if habits[index].isCompletedToday() {
                habits[index].completedDates.removeAll { date in
                    Calendar.current.isDate(date, inSameDayAs: today)
                }
            } else {
                habits[index].completedDates.append(Date())
            }
            saveHabits()
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        // Cancel notifications
        NotificationManager.shared.cancelHabitReminders(identifiers: habit.notificationIdentifiers)
        
        habits.removeAll { $0.id == habit.id }
        saveHabits()
    }
    
    // MARK: - Journal Methods
    
    func addJournalEntry(_ entry: JournalEntry) {
        journalEntries.append(entry)
        saveJournal()
    }
    
    func updateJournalEntry(_ entry: JournalEntry) {
        if let index = journalEntries.firstIndex(where: { $0.id == entry.id }) {
            journalEntries[index] = entry
            saveJournal()
        }
    }
    
    func deleteJournalEntry(_ entry: JournalEntry) {
        journalEntries.removeAll { $0.id == entry.id }
        saveJournal()
    }
    
    // MARK: - Budget Methods
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        saveTransactions()
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
        saveTransactions()
    }
    
    func totalIncome() -> Double {
        transactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    func totalExpenses() -> Double {
        transactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    func balance() -> Double {
        totalIncome() - totalExpenses()
    }
    
    // MARK: - Recipe Methods
    
    func addRecipe(_ recipe: Recipe) {
        recipes.append(recipe)
        saveRecipes()
    }
    
    func updateRecipe(_ recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index] = recipe
            saveRecipes()
        }
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        recipes.removeAll { $0.id == recipe.id }
        saveRecipes()
    }
    
    func toggleFavorite(_ recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index].isFavorite.toggle()
            saveRecipes()
        }
    }
    
    // MARK: - Meal Plan Methods
    
    func addMealPlan(_ mealPlan: MealPlan) {
        mealPlans.append(mealPlan)
        saveMealPlans()
    }
    
    func updateMealPlan(_ mealPlan: MealPlan) {
        if let index = mealPlans.firstIndex(where: { $0.id == mealPlan.id }) {
            mealPlans[index] = mealPlan
            saveMealPlans()
        }
    }
    
    func deleteMealPlan(_ mealPlan: MealPlan) {
        mealPlans.removeAll { $0.id == mealPlan.id }
        saveMealPlans()
    }
    
    // MARK: - Shopping List Methods
    
    func addShoppingItem(_ item: ShoppingItem) {
        shoppingItems.append(item)
        saveShoppingItems()
    }
    
    func updateShoppingItem(_ item: ShoppingItem) {
        if let index = shoppingItems.firstIndex(where: { $0.id == item.id }) {
            shoppingItems[index] = item
            saveShoppingItems()
        }
    }
    
    func deleteShoppingItem(_ item: ShoppingItem) {
        shoppingItems.removeAll { $0.id == item.id }
        saveShoppingItems()
    }
    
    func toggleShoppingItemChecked(_ item: ShoppingItem) {
        if let index = shoppingItems.firstIndex(where: { $0.id == item.id }) {
            shoppingItems[index].isChecked.toggle()
            saveShoppingItems()
        }
    }
    
    func clearCheckedItems() {
        shoppingItems.removeAll { $0.isChecked }
        saveShoppingItems()
    }
    
    func addIngredientsToShoppingList(from recipe: Recipe, servings: Int? = nil) {
        let scaledRecipe = servings != nil ? recipe.scaled(toServings: servings!) : recipe
        
        for ingredient in scaledRecipe.ingredients {
            let item = ShoppingItem(
                name: ingredient.name,
                quantity: "\(ingredient.amount) \(ingredient.unit)".trimmingCharacters(in: .whitespaces),
                category: categorizeIngredient(ingredient.name)
            )
            addShoppingItem(item)
        }
    }
    
    // Smart categorization based on ingredient name
    private func categorizeIngredient(_ ingredient: String) -> ShoppingItem.ShoppingCategory {
        let lowercased = ingredient.lowercased()
        
        // Produce
        let produceKeywords = ["lettuce", "tomato", "onion", "garlic", "potato", "carrot", "celery", "pepper", "cucumber", "spinach", "kale", "broccoli", "cauliflower", "mushroom", "zucchini", "squash", "apple", "banana", "orange", "lemon", "lime", "berry", "berries", "fruit", "vegetable", "avocado", "cilantro", "parsley", "basil", "herb", "salad"]
        if produceKeywords.contains(where: { lowercased.contains($0) }) {
            return .produce
        }
        
        // Dairy
        let dairyKeywords = ["milk", "cheese", "yogurt", "cream", "butter", "sour cream", "cottage cheese", "parmesan", "mozzarella", "cheddar", "swiss cheese", "whipped cream", "half and half"]
        if dairyKeywords.contains(where: { lowercased.contains($0) }) {
            return .dairy
        }
        
        // Meat & Seafood
        let meatKeywords = ["chicken", "beef", "pork", "turkey", "fish", "salmon", "tuna", "shrimp", "steak", "ground beef", "bacon", "sausage", "ham", "lamb", "duck", "meat", "seafood", "crab", "lobster"]
        if meatKeywords.contains(where: { lowercased.contains($0) }) {
            return .meat
        }
        
        // Bakery
        let bakeryKeywords = ["bread", "bun", "roll", "bagel", "croissant", "muffin", "donut", "cake", "pie", "pastry", "tortilla", "pita"]
        if bakeryKeywords.contains(where: { lowercased.contains($0) }) {
            return .bakery
        }
        
        // Frozen
        let frozenKeywords = ["frozen", "ice cream", "popsicle", "frozen pizza", "frozen vegetable"]
        if frozenKeywords.contains(where: { lowercased.contains($0) }) {
            return .frozen
        }
        
        // Beverages
        let beverageKeywords = ["water", "juice", "soda", "coffee", "tea", "beer", "wine", "drink", "beverage", "lemonade", "smoothie"]
        if beverageKeywords.contains(where: { lowercased.contains($0) }) {
            return .beverages
        }
        
        // Snacks
        let snackKeywords = ["chips", "popcorn", "crackers", "pretzels", "cookies", "candy", "chocolate", "snack", "nuts", "trail mix"]
        if snackKeywords.contains(where: { lowercased.contains($0) }) {
            return .snacks
        }
        
        // Pantry (dry goods, canned items, condiments, spices)
        let pantryKeywords = ["flour", "sugar", "salt", "pepper", "spice", "rice", "pasta", "spaghetti", "noodle", "beans", "oil", "vinegar", "sauce", "ketchup", "mustard", "mayo", "mayonnaise", "can", "canned", "cereal", "oats", "honey", "syrup", "peanut butter", "jelly", "jam", "seasoning", "italian seasoning", "garlic powder", "onion powder", "paprika", "cumin", "oregano", "thyme", "cinnamon"]
        if pantryKeywords.contains(where: { lowercased.contains($0) }) {
            return .pantry
        }
        
        // Default to Other if no match
        return .other
    }
    
    // MARK: - Budget Methods
    
    func saveBudgetSetup(_ setup: BudgetSetup) {
        budgetSetup = setup
        save(budgetSetup, forKey: budgetSetupKey)
    }
    
    func addBudgetCategory(_ category: BudgetCategory) {
        budgetCategories.append(category)
        save(budgetCategories, forKey: budgetCategoriesKey)
    }
    
    func updateBudgetCategory(_ category: BudgetCategory) {
        if let index = budgetCategories.firstIndex(where: { $0.id == category.id }) {
            budgetCategories[index] = category
            save(budgetCategories, forKey: budgetCategoriesKey)
        }
    }
    
    func deleteBudgetCategory(_ category: BudgetCategory) {
        budgetCategories.removeAll { $0.id == category.id }
        save(budgetCategories, forKey: budgetCategoriesKey)
    }
    
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        save(expenses, forKey: expensesKey)
    }
    
    func updateExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense
            save(expenses, forKey: expensesKey)
        }
    }
    
    func deleteExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
        save(expenses, forKey: expensesKey)
    }
    
    func addRecurringExpense(_ recurring: RecurringExpense) {
        recurringExpenses.append(recurring)
        save(recurringExpenses, forKey: recurringExpensesKey)
    }
    
    func updateRecurringExpense(_ recurring: RecurringExpense) {
        if let index = recurringExpenses.firstIndex(where: { $0.id == recurring.id }) {
            recurringExpenses[index] = recurring
            save(recurringExpenses, forKey: recurringExpensesKey)
        }
    }
    
    func deleteRecurringExpense(_ recurring: RecurringExpense) {
        recurringExpenses.removeAll { $0.id == recurring.id }
        save(recurringExpenses, forKey: recurringExpensesKey)
    }
    
    func generateRecurringExpenses() {
        let calendar = Calendar.current
        let today = Date()
        
        for var recurring in recurringExpenses where recurring.isActive {
            guard let lastGen = recurring.lastGenerated else {
                // First time, generate for start date
                if recurring.startDate <= today {
                    createExpenseFromRecurring(recurring, for: recurring.startDate)
                    recurring.lastGenerated = recurring.startDate
                    updateRecurringExpense(recurring)
                }
                continue
            }
            
            // Check if we need to generate new expense
            var nextDate = calendar.date(byAdding: recurring.frequency.component, value: 1, to: lastGen) ?? lastGen
            
            while nextDate <= today {
                if let endDate = recurring.endDate, nextDate > endDate {
                    break
                }
                
                createExpenseFromRecurring(recurring, for: nextDate)
                recurring.lastGenerated = nextDate
                updateRecurringExpense(recurring)
                
                nextDate = calendar.date(byAdding: recurring.frequency.component, value: 1, to: nextDate) ?? nextDate
            }
        }
    }
    
    private func createExpenseFromRecurring(_ recurring: RecurringExpense, for date: Date) {
        let expense = Expense(
            title: recurring.title,
            amount: recurring.amount,
            category: recurring.category,
            date: date,
            notes: "Recurring: \(recurring.frequency.rawValue)",
            isRecurring: true,
            recurringId: recurring.id
        )
        addExpense(expense)
    }
    
    func getMonthlyBudget(for month: String) -> MonthlyBudget {
        let monthExpenses = expenses.filter { $0.monthKey == month }
        let totalSpent = monthExpenses.reduce(0) { $0 + $1.amount }
        let totalBudget = budgetCategories.reduce(0) { $0 + $1.limit }
        
        var breakdown: [BudgetCategory: Double] = [:]
        for category in budgetCategories {
            let spent = monthExpenses.filter { $0.category.id == category.id }.reduce(0) { $0 + $1.amount }
            breakdown[category] = spent
        }
        
        return MonthlyBudget(
            month: month,
            totalBudget: totalBudget,
            totalSpent: totalSpent,
            remaining: totalBudget - totalSpent,
            categoryBreakdown: breakdown
        )
    }
    
    // MARK: - Vault Methods
    
    func addVaultItem(_ item: VaultItem) {
        vaultItems.append(item)
        saveVault()
    }
    
    func updateVaultItem(_ item: VaultItem) {
        if let index = vaultItems.firstIndex(where: { $0.id == item.id }) {
            vaultItems[index] = item
            saveVault()
        }
    }
    
    func deleteVaultItem(_ item: VaultItem) {
        // Delete Keychain data first
        item.deleteKeychainData()
        
        // Then remove from array
        vaultItems.removeAll { $0.id == item.id }
        saveVault()
    }
    
    func clearAllVaultData() {
        // Delete all Keychain data for all vault items
        for item in vaultItems {
            item.deleteKeychainData()
        }
        
        // Clear the array
        vaultItems.removeAll()
        saveVault()
    }
    
    // MARK: - Settings Methods
    
    func updateSettings(_ newSettings: UserSettings) {
        settings = newSettings
        saveSettings()
    }
    
    // MARK: - Private Save/Load Methods
    
    private func saveEvents() {
        save(events, forKey: eventsKey)
    }
    
    private func saveHabits() {
        save(habits, forKey: habitsKey)
    }
    
    private func saveJournal() {
        save(journalEntries, forKey: journalKey)
    }
    
    private func saveTransactions() {
        save(transactions, forKey: transactionsKey)
    }
    
    private func saveRecipes() {
        save(recipes, forKey: recipesKey)
    }
    
    private func saveMealPlans() {
        save(mealPlans, forKey: mealPlansKey)
    }
    
    private func saveShoppingItems() {
        save(shoppingItems, forKey: shoppingItemsKey)
    }
    
    private func saveVault() {
        save(vaultItems, forKey: vaultKey)
    }
    
    private func saveSettings() {
        save(settings, forKey: settingsKey)
    }
    
    private func save<T: Encodable>(_ items: T, forKey key: String) {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    private func loadAllData() {
        events = load(forKey: eventsKey) ?? []
        habits = load(forKey: habitsKey) ?? []
        journalEntries = load(forKey: journalKey) ?? []
        transactions = load(forKey: transactionsKey) ?? []
        recipes = load(forKey: recipesKey) ?? []
        mealPlans = load(forKey: mealPlansKey) ?? []
        shoppingItems = load(forKey: shoppingItemsKey) ?? []
        vaultItems = load(forKey: vaultKey) ?? []
        settings = load(forKey: settingsKey) ?? UserSettings()
        budgetSetup = load(forKey: budgetSetupKey) ?? BudgetSetup(monthlyIncome: 0)
        budgetCategories = load(forKey: budgetCategoriesKey) ?? []
        expenses = load(forKey: expensesKey) ?? []
        recurringExpenses = load(forKey: recurringExpensesKey) ?? []
        
        // Load cleaning tracker data
        cleaningProfile = load(forKey: cleaningProfileKey)
        cleaningTasks = load(forKey: cleaningTasksKey) ?? []
        cleaningSessions = load(forKey: cleaningSessionsKey) ?? []
        cleaningAchievements = load(forKey: cleaningAchievementsKey) ?? CleaningAchievement.createDefaultAchievements()
        cleaningStatistics = load(forKey: cleaningStatisticsKey) ?? CleaningStatistics()
        
        // Load sample recipes if this is first launch
        if recipes.isEmpty {
            loadSampleRecipes()
        }
        
        // Generate any pending recurring expenses
        generateRecurringExpenses()
    }
    
    private func load<T: Decodable>(forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        return decoded
    }
    
    // MARK: - Cleaning Tracker Methods
    
    func setupCleaningProfile(_ profile: CleaningProfile) {
        cleaningProfile = profile
        save(profile, forKey: cleaningProfileKey)
        
        // Generate initial tasks and schedule
        generateCleaningSchedule()
    }
    
    func updateCleaningProfile(_ profile: CleaningProfile) {
        cleaningProfile = profile
        save(profile, forKey: cleaningProfileKey)
    }
    
    func generateCleaningSchedule() {
        guard let profile = cleaningProfile else { return }
        
        // Generate weekly schedule based on profile
        let weeklySchedule = CleaningTaskTemplates.generateWeeklySchedule(profile: profile)
        cleaningTasks = Array(weeklySchedule.values)
        save(cleaningTasks, forKey: cleaningTasksKey)
        
        // Generate sessions for the upcoming weeks (4 weeks ahead)
        generateUpcomingSessions(weeks: 4)
    }
    
    private func generateUpcomingSessions(weeks: Int) {
        guard let profile = cleaningProfile else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Clear future sessions
        cleaningSessions.removeAll { !$0.isCompleted && !$0.isSkipped && $0.scheduledDate >= today }
        
        // Generate new sessions
        for weekOffset in 0..<weeks {
            for task in cleaningTasks {
                guard let dayOfWeek = task.dayOfWeek else { continue }
                
                // Calculate date for this task in this week
                let weekStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: today) ?? today
                guard let sessionDate = calendar.date(bySetting: .weekday, value: dayOfWeek, of: weekStart) else { continue }
                
                // Only create if it doesn't exist and is in the future
                if sessionDate >= today {
                    let sessionExists = cleaningSessions.contains { session in
                        calendar.isDate(session.scheduledDate, inSameDayAs: sessionDate) &&
                        session.taskId == task.id
                    }
                    
                    if !sessionExists {
                        let session = CleaningSession(
                            taskId: task.id,
                            taskTitle: task.title,
                            taskArea: task.area,
                            scheduledDate: sessionDate
                        )
                        cleaningSessions.append(session)
                    }
                }
            }
        }
        
        save(cleaningSessions, forKey: cleaningSessionsKey)
    }
    
    func addCustomCleaningTask(_ task: CleaningTask) {
        cleaningTasks.append(task)
        save(cleaningTasks, forKey: cleaningTasksKey)
    }
    
    func updateCleaningTask(_ task: CleaningTask) {
        if let index = cleaningTasks.firstIndex(where: { $0.id == task.id }) {
            cleaningTasks[index] = task
            save(cleaningTasks, forKey: cleaningTasksKey)
        }
    }
    
    func deleteCleaningTask(_ task: CleaningTask) {
        cleaningTasks.removeAll { $0.id == task.id }
        cleaningSessions.removeAll { $0.taskId == task.id }
        save(cleaningTasks, forKey: cleaningTasksKey)
        save(cleaningSessions, forKey: cleaningSessionsKey)
    }
    
    func completeCleaningSession(_ session: CleaningSession, duration: Int? = nil) {
        guard let index = cleaningSessions.firstIndex(where: { $0.id == session.id }) else { return }
        
        cleaningSessions[index].isCompleted = true
        cleaningSessions[index].completedDate = Date()
        cleaningSessions[index].actualDuration = duration ?? cleaningTasks.first(where: { $0.id == session.taskId })?.estimatedDuration
        
        // Update statistics
        cleaningStatistics.recordCompletion(
            area: session.taskArea,
            duration: cleaningSessions[index].actualDuration ?? 30,
            date: Date()
        )
        
        // Check for achievements
        checkAchievements()
        
        // Schedule notifications for tomorrow if needed
        scheduleCleaningNotifications()
        
        save(cleaningSessions, forKey: cleaningSessionsKey)
        save(cleaningStatistics, forKey: cleaningStatisticsKey)
        save(cleaningAchievements, forKey: cleaningAchievementsKey)
    }
    
    func skipCleaningSession(_ session: CleaningSession, reason: String? = nil) {
        guard let index = cleaningSessions.firstIndex(where: { $0.id == session.id }) else { return }
        
        cleaningSessions[index].isSkipped = true
        cleaningSessions[index].skipReason = reason
        save(cleaningSessions, forKey: cleaningSessionsKey)
    }
    
    func rescheduleCleaningSession(_ session: CleaningSession, to newDate: Date) {
        guard let index = cleaningSessions.firstIndex(where: { $0.id == session.id }) else { return }
        
        cleaningSessions[index].scheduledDate = newDate
        save(cleaningSessions, forKey: cleaningSessionsKey)
    }
    
    private func checkAchievements() {
        // First Clean
        if cleaningStatistics.totalTasksCompleted == 1 {
            unlockAchievement(type: .firstClean)
        }
        
        // Week Warrior
        if cleaningStatistics.currentStreak >= 7 {
            unlockAchievement(type: .weekWarrior)
        }
        
        // Month Master
        if cleaningStatistics.totalTasksCompleted >= 30 {
            unlockAchievement(type: .monthMaster)
        }
        
        // Deep Diver - check if a deep clean was completed
        if let lastSession = cleaningSessions.last(where: { $0.isCompleted }),
           let task = cleaningTasks.first(where: { $0.id == lastSession.taskId }),
           task.isDeepClean {
            unlockAchievement(type: .deepDiver)
        }
        
        // Early Bird / Night Owl
        if let lastCompletedDate = cleaningStatistics.lastCompletedDate {
            let hour = Calendar.current.component(.hour, from: lastCompletedDate)
            if hour < 8 {
                unlockAchievement(type: .earlyBird)
            } else if hour >= 20 {
                unlockAchievement(type: .nightOwl)
            }
        }
    }
    
    private func unlockAchievement(type: CleaningAchievement.AchievementType) {
        guard let index = cleaningAchievements.firstIndex(where: { $0.type == type && !$0.isUnlocked }) else { return }
        
        cleaningAchievements[index].isUnlocked = true
        cleaningAchievements[index].unlockedDate = Date()
    }
    
    func scheduleCleaningNotifications() {
        guard let profile = cleaningProfile, profile.enableNotifications else { return }
        
        // Cancel existing cleaning notifications
        NotificationManager.shared.cancelNotifications(withPrefix: "cleaning-")
        
        // Schedule for upcoming sessions (next 7 days)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekFromNow = calendar.date(byAdding: .day, value: 7, to: today) ?? today
        
        let upcomingSessions = cleaningSessions.filter { session in
            !session.isCompleted && !session.isSkipped &&
            session.scheduledDate >= today && session.scheduledDate <= weekFromNow
        }
        
        for session in upcomingSessions {
            if let notificationTime = profile.notificationTime {
                let notificationDate = calendar.date(
                    bySettingHour: calendar.component(.hour, from: notificationTime),
                    minute: calendar.component(.minute, from: notificationTime),
                    second: 0,
                    of: session.scheduledDate
                ) ?? session.scheduledDate
                
                let title = "🧹 Time to Clean!"
                let body = "\(session.taskTitle) is ready"
                
                Task {
                    await NotificationManager.shared.scheduleNotification(
                        identifier: "cleaning-\(session.id.uuidString)",
                        title: title,
                        body: body,
                        date: notificationDate
                    )
                }
            }
        }
    }
    
    func getTodaySession() -> CleaningSession? {
        let calendar = Calendar.current
        return cleaningSessions.first { session in
            calendar.isDateInToday(session.scheduledDate) && !session.isCompleted && !session.isSkipped
        }
    }
    
    func getUpcomingSessions(limit: Int = 5) -> [CleaningSession] {
        let today = Calendar.current.startOfDay(for: Date())
        return cleaningSessions
            .filter { !$0.isCompleted && !$0.isSkipped && $0.scheduledDate >= today }
            .sorted { $0.scheduledDate < $1.scheduledDate }
            .prefix(limit)
            .map { $0 }
    }
    
    func getThisWeekSessions() -> [CleaningSession] {
        let calendar = Calendar.current
        let today = Date()
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start,
              let weekEnd = calendar.dateInterval(of: .weekOfYear, for: today)?.end else {
            return []
        }
        
        return cleaningSessions
            .filter { $0.scheduledDate >= weekStart && $0.scheduledDate < weekEnd }
            .sorted { $0.scheduledDate < $1.scheduledDate }
    }
    
    // MARK: - Sample Recipes
    
    private func loadSampleRecipes() {
        let sampleRecipes = createSampleRecipes()
        for recipe in sampleRecipes {
            recipes.append(recipe)
        }
        saveRecipes()
    }
    
    private func createSampleRecipes() -> [Recipe] {
        var samples: [Recipe] = []
        
        // 1. Overnight Oats
        let overnightOats = Recipe(
            name: "Overnight Oats",
            mealType: .breakfast,
            prepTime: 5,
            cookTime: 0,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "rolled oats", amount: "1/2", unit: "cup"),
                Recipe.Ingredient(name: "milk (dairy or non-dairy)", amount: "1/2", unit: "cup"),
                Recipe.Ingredient(name: "Greek yogurt", amount: "1/4", unit: "cup"),
                Recipe.Ingredient(name: "chia seeds", amount: "1", unit: "tbsp"),
                Recipe.Ingredient(name: "honey or maple syrup", amount: "1", unit: "tbsp"),
                Recipe.Ingredient(name: "vanilla extract", amount: "1/2", unit: "tsp"),
                Recipe.Ingredient(name: "banana", amount: "1/2", unit: ""),
                Recipe.Ingredient(name: "berries (fresh or frozen)", amount: "1/4", unit: "cup"),
                Recipe.Ingredient(name: "nuts or granola", amount: "2", unit: "tbsp")
            ],
            instructions: [
                "In a mason jar or bowl, combine rolled oats, milk, Greek yogurt, chia seeds, honey, and vanilla extract.",
                "Stir everything together until well combined.",
                "Slice the banana and add half to the oat mixture. Stir gently.",
                "Cover the jar or bowl with a lid or plastic wrap.",
                "Refrigerate overnight (or at least 4 hours) to allow the oats to absorb the liquid and soften.",
                "In the morning, give the oats a good stir. Add more milk if you prefer a thinner consistency.",
                "Top with fresh berries, remaining banana slices, and your choice of nuts or granola.",
                "Enjoy cold straight from the fridge, or warm it in the microwave for 30-60 seconds if preferred."
            ],
            recipeDescription: "A no-cook, make-ahead breakfast that's creamy, nutritious, and customizable. Perfect for busy mornings!",
            notes: "Tip: Prepare multiple jars at once for easy grab-and-go breakfasts throughout the week. Try different toppings like peanut butter, cinnamon, or chocolate chips!"
        )
        samples.append(overnightOats)
        
        // 2. Baked Oats
        let bakedOats = Recipe(
            name: "Baked Oats",
            mealType: .breakfast,
            prepTime: 10,
            cookTime: 25,
            servings: 2,
            ingredients: [
                Recipe.Ingredient(name: "rolled oats", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "ripe banana", amount: "1", unit: "large"),
                Recipe.Ingredient(name: "milk (dairy or non-dairy)", amount: "1/2", unit: "cup"),
                Recipe.Ingredient(name: "egg", amount: "1", unit: "large"),
                Recipe.Ingredient(name: "baking powder", amount: "1", unit: "tsp"),
                Recipe.Ingredient(name: "vanilla extract", amount: "1", unit: "tsp"),
                Recipe.Ingredient(name: "cinnamon", amount: "1/2", unit: "tsp"),
                Recipe.Ingredient(name: "honey or maple syrup", amount: "2", unit: "tbsp"),
                Recipe.Ingredient(name: "salt", amount: "1/4", unit: "tsp"),
                Recipe.Ingredient(name: "blueberries or chocolate chips", amount: "1/4", unit: "cup")
            ],
            instructions: [
                "Preheat your oven to 350°F (175°C). Grease two small ramekins or one medium baking dish with cooking spray or butter.",
                "In a blender or food processor, combine the rolled oats, banana, milk, egg, baking powder, vanilla extract, cinnamon, honey, and salt.",
                "Blend until smooth and well combined. The mixture should be pourable but thick, similar to pancake batter.",
                "Pour the batter into the prepared ramekins or baking dish, filling about 3/4 full.",
                "Gently fold in or sprinkle blueberries or chocolate chips on top of the batter.",
                "Bake for 20-25 minutes, until the oats are set in the center and the top is golden brown. A toothpick inserted should come out mostly clean.",
                "Remove from the oven and let cool for 2-3 minutes.",
                "Serve warm, optionally topped with extra fruit, a drizzle of honey, nut butter, or a dollop of yogurt."
            ],
            recipeDescription: "A warm, cake-like breakfast that tastes like dessert but is packed with wholesome ingredients. Perfect for cozy mornings!",
            notes: "Variations: Try adding cocoa powder for chocolate baked oats, peanut butter for protein, or different mix-ins like nuts, dried fruit, or coconut flakes."
        )
        samples.append(bakedOats)
        
        // 3. Breakfast Egg, Cheese & Bacon Tacos
        let breakfastTacos = Recipe(
            name: "Breakfast Egg, Cheese & Bacon Tacos",
            mealType: .breakfast,
            prepTime: 10,
            cookTime: 15,
            servings: 2,
            ingredients: [
                Recipe.Ingredient(name: "bacon strips", amount: "4", unit: ""),
                Recipe.Ingredient(name: "eggs", amount: "4", unit: "large"),
                Recipe.Ingredient(name: "milk", amount: "2", unit: "tbsp"),
                Recipe.Ingredient(name: "salt", amount: "1/4", unit: "tsp"),
                Recipe.Ingredient(name: "black pepper", amount: "1/8", unit: "tsp"),
                Recipe.Ingredient(name: "butter", amount: "1", unit: "tbsp"),
                Recipe.Ingredient(name: "shredded cheddar cheese", amount: "1/2", unit: "cup"),
                Recipe.Ingredient(name: "small flour tortillas", amount: "4", unit: ""),
                Recipe.Ingredient(name: "avocado", amount: "1", unit: "medium"),
                Recipe.Ingredient(name: "salsa", amount: "1/4", unit: "cup"),
                Recipe.Ingredient(name: "sour cream", amount: "2", unit: "tbsp"),
                Recipe.Ingredient(name: "fresh cilantro", amount: "2", unit: "tbsp")
            ],
            instructions: [
                "Cook the bacon in a large skillet over medium heat until crispy, about 6-8 minutes. Transfer to a paper towel-lined plate, then chop into bite-sized pieces.",
                "While bacon is cooking, crack the eggs into a bowl. Add milk, salt, and pepper. Whisk together until well combined.",
                "Drain most of the bacon grease from the skillet, leaving about 1 teaspoon. Alternatively, wipe clean and add butter.",
                "Heat the skillet over medium-low heat and add the butter. Once melted and foamy, pour in the egg mixture.",
                "Using a spatula, gently scramble the eggs, stirring occasionally, until they're just set but still slightly creamy, about 3-4 minutes.",
                "Remove from heat and immediately stir in the shredded cheddar cheese until melted.",
                "Warm the tortillas in a dry skillet or microwave for 15-20 seconds until pliable.",
                "Assemble the tacos: Divide the scrambled eggs among the tortillas. Top each with chopped bacon.",
                "Slice the avocado and add a few slices to each taco.",
                "Add a spoonful of salsa, a dollop of sour cream, and sprinkle with fresh cilantro.",
                "Fold and serve immediately while warm. Enjoy with hot sauce if desired!"
            ],
            recipeDescription: "A savory, protein-packed breakfast that's quick to make and endlessly customizable. Perfect for weekend brunch or busy weekday mornings!",
            notes: "Make it your own: Add sautéed bell peppers, onions, jalapeños, or swap bacon for sausage or vegetarian chorizo. These tacos are also great for meal prep - just store components separately and assemble fresh."
        )
        samples.append(breakfastTacos)
        
        // 4. Chicken Fajita Bowl
        let chickenFajitaBowl = Recipe(
            name: "Chicken Fajita Bowl",
            mealType: .dinner,
            prepTime: 15,
            cookTime: 20,
            servings: 4,
            ingredients: [
                Recipe.Ingredient(name: "boneless skinless chicken breasts", amount: "1.5", unit: "lbs"),
                Recipe.Ingredient(name: "bell peppers (mix of colors)", amount: "3", unit: ""),
                Recipe.Ingredient(name: "red onion", amount: "1", unit: "large"),
                Recipe.Ingredient(name: "olive oil", amount: "3", unit: "tbsp"),
                Recipe.Ingredient(name: "chili powder", amount: "2", unit: "tsp"),
                Recipe.Ingredient(name: "cumin", amount: "1.5", unit: "tsp"),
                Recipe.Ingredient(name: "paprika", amount: "1", unit: "tsp"),
                Recipe.Ingredient(name: "garlic powder", amount: "1", unit: "tsp"),
                Recipe.Ingredient(name: "salt", amount: "1", unit: "tsp"),
                Recipe.Ingredient(name: "black pepper", amount: "1/2", unit: "tsp"),
                Recipe.Ingredient(name: "lime", amount: "2", unit: ""),
                Recipe.Ingredient(name: "cooked rice or quinoa", amount: "4", unit: "cups"),
                Recipe.Ingredient(name: "black beans", amount: "1", unit: "can"),
                Recipe.Ingredient(name: "corn kernels", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "avocado", amount: "2", unit: ""),
                Recipe.Ingredient(name: "sour cream", amount: "1/2", unit: "cup"),
                Recipe.Ingredient(name: "shredded cheese", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "fresh cilantro", amount: "1/4", unit: "cup")
            ],
            instructions: [
                "Slice chicken breasts into thin strips. In a bowl, combine chili powder, cumin, paprika, garlic powder, salt, and black pepper.",
                "Toss chicken strips with half of the spice mixture and 1 tablespoon olive oil. Set aside to marinate while you prep vegetables.",
                "Slice bell peppers and red onion into thin strips.",
                "Heat 1 tablespoon olive oil in a large skillet over medium-high heat. Add chicken strips and cook for 6-8 minutes, stirring occasionally, until cooked through and slightly charred. Transfer to a plate.",
                "In the same skillet, add remaining 1 tablespoon olive oil. Add bell peppers and onions with remaining spice mixture.",
                "Sauté vegetables for 6-8 minutes until tender and slightly caramelized, stirring occasionally.",
                "Return chicken to the skillet and toss with vegetables. Squeeze juice of 1 lime over everything and stir to combine.",
                "Drain and rinse black beans. If using canned corn, drain it as well.",
                "To assemble bowls: Start with a base of rice or quinoa in each bowl.",
                "Top with chicken and pepper mixture, black beans, and corn.",
                "Slice avocados and add to bowls. Add a dollop of sour cream and sprinkle with shredded cheese.",
                "Garnish with fresh cilantro and serve with lime wedges. Add salsa or hot sauce if desired!"
            ],
            recipeDescription: "A colorful, protein-packed bowl with tender seasoned chicken, sautéed peppers and onions, and all your favorite Mexican-inspired toppings. Healthy, satisfying, and bursting with flavor!",
            notes: "Meal prep tip: Cook chicken and vegetables ahead, store separately, and assemble bowls throughout the week. Customize with your favorite toppings like jalapeños, pico de gallo, or guacamole. Can easily be made low-carb by using cauliflower rice instead of regular rice."
        )
        samples.append(chickenFajitaBowl)
        
        // 5. Salmon and Sweet Potato
        let salmonSweetPotato = Recipe(
            name: "Salmon and Sweet Potato",
            mealType: .dinner,
            prepTime: 10,
            cookTime: 25,
            servings: 4,
            ingredients: [
                Recipe.Ingredient(name: "salmon fillets", amount: "4", unit: "6-oz"),
                Recipe.Ingredient(name: "sweet potatoes", amount: "2", unit: "large"),
                Recipe.Ingredient(name: "olive oil", amount: "4", unit: "tbsp"),
                Recipe.Ingredient(name: "garlic cloves", amount: "4", unit: ""),
                Recipe.Ingredient(name: "lemon", amount: "1", unit: "large"),
                Recipe.Ingredient(name: "paprika", amount: "1", unit: "tsp"),
                Recipe.Ingredient(name: "dried thyme", amount: "1", unit: "tsp"),
                Recipe.Ingredient(name: "salt", amount: "1", unit: "tsp"),
                Recipe.Ingredient(name: "black pepper", amount: "1/2", unit: "tsp"),
                Recipe.Ingredient(name: "fresh parsley", amount: "1/4", unit: "cup"),
                Recipe.Ingredient(name: "asparagus or green beans", amount: "1", unit: "lb"),
                Recipe.Ingredient(name: "honey", amount: "2", unit: "tbsp")
            ],
            instructions: [
                "Preheat oven to 400°F (200°C). Line a large baking sheet with parchment paper.",
                "Peel sweet potatoes and cut into 1-inch cubes. Toss with 2 tablespoons olive oil, half the salt, pepper, and paprika.",
                "Spread sweet potato cubes on one side of the baking sheet. Roast for 15 minutes.",
                "While sweet potatoes are roasting, pat salmon fillets dry with paper towels. Season with remaining salt, pepper, and thyme.",
                "Trim asparagus or green beans. Toss with 1 tablespoon olive oil and a pinch of salt.",
                "After 15 minutes, remove baking sheet from oven. Flip sweet potatoes.",
                "Place salmon fillets skin-side down on the other side of the baking sheet. Arrange vegetables around them.",
                "Mince garlic and mix with remaining 1 tablespoon olive oil and honey. Brush this mixture over the salmon.",
                "Slice lemon into thin rounds and place on top of salmon fillets.",
                "Return to oven and bake for 10-12 minutes, until salmon flakes easily with a fork and registers 145°F internally.",
                "Remove from oven. Squeeze any remaining lemon juice over everything.",
                "Garnish with fresh chopped parsley and serve immediately."
            ],
            recipeDescription: "A one-pan dinner featuring omega-3 rich salmon with caramelized sweet potatoes and tender vegetables. Healthy, elegant, and ready in under 40 minutes!",
            notes: "Pro tips: For crispy sweet potatoes, make sure they're not crowded on the pan. Salmon is done when it's opaque and flakes easily - don't overcook! Great for meal prep; store components separately and reheat gently. Can substitute with other vegetables like Brussels sprouts or broccoli."
        )
        samples.append(salmonSweetPotato)
        
        // 6. Turkey Taco Lettuce Bowls
        let turkeyTacoBowls = Recipe(
            name: "Turkey Taco Lettuce Bowls",
            mealType: .dinner,
            prepTime: 10,
            cookTime: 15,
            servings: 4,
            ingredients: [
                Recipe.Ingredient(name: "ground turkey", amount: "1.5", unit: "lbs"),
                Recipe.Ingredient(name: "olive oil", amount: "1", unit: "tbsp"),
                Recipe.Ingredient(name: "yellow onion", amount: "1", unit: "medium"),
                Recipe.Ingredient(name: "garlic cloves", amount: "3", unit: ""),
                Recipe.Ingredient(name: "chili powder", amount: "2", unit: "tbsp"),
                Recipe.Ingredient(name: "cumin", amount: "1", unit: "tbsp"),
                Recipe.Ingredient(name: "paprika", amount: "1", unit: "tsp"),
                Recipe.Ingredient(name: "oregano", amount: "1", unit: "tsp"),
                Recipe.Ingredient(name: "salt", amount: "1", unit: "tsp"),
                Recipe.Ingredient(name: "tomato paste", amount: "2", unit: "tbsp"),
                Recipe.Ingredient(name: "water or chicken broth", amount: "1/2", unit: "cup"),
                Recipe.Ingredient(name: "romaine lettuce hearts", amount: "2", unit: "large"),
                Recipe.Ingredient(name: "cherry tomatoes", amount: "2", unit: "cups"),
                Recipe.Ingredient(name: "black beans", amount: "1", unit: "can"),
                Recipe.Ingredient(name: "corn kernels", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "shredded Mexican cheese", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "avocado", amount: "2", unit: ""),
                Recipe.Ingredient(name: "Greek yogurt or sour cream", amount: "1/2", unit: "cup"),
                Recipe.Ingredient(name: "lime", amount: "2", unit: "")
            ],
            instructions: [
                "Heat olive oil in a large skillet over medium-high heat. Dice the onion and mince the garlic.",
                "Add ground turkey to the skillet, breaking it up with a wooden spoon. Cook for 5-6 minutes until browned.",
                "Add diced onion and minced garlic. Cook for 2-3 minutes until onion is softened.",
                "Stir in chili powder, cumin, paprika, oregano, and salt. Cook for 1 minute until fragrant.",
                "Add tomato paste and water (or broth). Stir well to combine. Simmer for 5 minutes until mixture thickens slightly. Taste and adjust seasonings.",
                "While turkey cooks, chop romaine lettuce and divide among 4 bowls. Halve cherry tomatoes.",
                "Drain and rinse black beans. Prepare your toppings.",
                "Assemble bowls: Start with chopped romaine as the base.",
                "Top with seasoned turkey, black beans, corn, and cherry tomatoes.",
                "Slice avocados and add to bowls. Sprinkle with shredded cheese.",
                "Add a dollop of Greek yogurt or sour cream.",
                "Squeeze fresh lime juice over each bowl and garnish with extra cilantro if desired. Serve immediately!"
            ],
            recipeDescription: "A light, fresh, and protein-packed dinner that swaps tortillas for crispy lettuce. Low-carb, high-flavor, and loaded with colorful toppings!",
            notes: "Healthier alternative: Using ground turkey instead of beef cuts calories and fat while keeping it delicious. Can meal prep the turkey mixture ahead. For extra crunch, add tortilla strips or crushed chips. Customize with salsa, jalapeños, or your favorite taco toppings!"
        )
        samples.append(turkeyTacoBowls)
        
        // 7. Marry Me Chicken Pasta
        let marryMeChicken = Recipe(
            name: "Marry Me Chicken Pasta",
            mealType: .dinner,
            prepTime: 10,
            cookTime: 30,
            servings: 4,
            ingredients: [
                Recipe.Ingredient(name: "boneless skinless chicken breasts", amount: "1.5", unit: "lbs"),
                Recipe.Ingredient(name: "pasta (penne or rigatoni)", amount: "12", unit: "oz"),
                Recipe.Ingredient(name: "olive oil", amount: "2", unit: "tbsp"),
                Recipe.Ingredient(name: "butter", amount: "2", unit: "tbsp"),
                Recipe.Ingredient(name: "garlic cloves", amount: "4", unit: ""),
                Recipe.Ingredient(name: "sun-dried tomatoes in oil", amount: "1/2", unit: "cup"),
                Recipe.Ingredient(name: "chicken broth", amount: "3/4", unit: "cup"),
                Recipe.Ingredient(name: "heavy cream", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "grated Parmesan cheese", amount: "1/2", unit: "cup"),
                Recipe.Ingredient(name: "Italian seasoning", amount: "2", unit: "tsp"),
                Recipe.Ingredient(name: "red pepper flakes", amount: "1/4", unit: "tsp"),
                Recipe.Ingredient(name: "salt", amount: "1", unit: "tsp"),
                Recipe.Ingredient(name: "black pepper", amount: "1/2", unit: "tsp"),
                Recipe.Ingredient(name: "fresh basil", amount: "1/4", unit: "cup"),
                Recipe.Ingredient(name: "fresh spinach", amount: "2", unit: "cups")
            ],
            instructions: [
                "Bring a large pot of salted water to boil. Cook pasta according to package directions until al dente. Drain and set aside.",
                "Season chicken breasts with salt, pepper, and 1 teaspoon Italian seasoning on both sides.",
                "Heat olive oil in a large skillet over medium-high heat. Add chicken and cook for 6-7 minutes per side until golden brown and cooked through (165°F internal temp).",
                "Remove chicken from skillet and let rest on a cutting board. Tent with foil.",
                "In the same skillet, reduce heat to medium. Add butter and minced garlic. Sauté for 1 minute until fragrant.",
                "Drain and chop sun-dried tomatoes. Add to the skillet and cook for 1 minute.",
                "Pour in chicken broth, scraping up any browned bits from the bottom of the pan.",
                "Stir in heavy cream, Parmesan cheese, remaining Italian seasoning, and red pepper flakes. Bring to a gentle simmer.",
                "Let sauce simmer for 3-5 minutes until slightly thickened, stirring occasionally.",
                "Slice the rested chicken into strips. Add fresh spinach to the sauce and stir until wilted, about 1 minute.",
                "Add cooked pasta to the sauce and toss to coat. Add sliced chicken on top.",
                "Garnish with fresh torn basil, extra Parmesan, and serve immediately. Season with additional salt and pepper to taste."
            ],
            recipeDescription: "A restaurant-quality pasta dish with tender chicken in a rich, creamy sun-dried tomato sauce. It's called 'Marry Me' because it's so delicious, someone might propose after eating it!",
            notes: "Make it special: Use high-quality Parmesan and fresh basil for best flavor. The sun-dried tomatoes in oil add amazing depth - don't skip them! For a lighter version, substitute half the cream with pasta water or chicken broth. Pairs beautifully with garlic bread and a simple salad."
        )
        samples.append(marryMeChicken)
        
        // 8. High Protein Italian Chopped Salad
        let italianChoppedSalad = Recipe(
            name: "High Protein Italian Chopped Salad",
            mealType: .dinner,
            prepTime: 20,
            cookTime: 0,
            servings: 4,
            ingredients: [
                Recipe.Ingredient(name: "rotisserie chicken", amount: "3", unit: "cups"),
                Recipe.Ingredient(name: "romaine lettuce", amount: "1", unit: "large head"),
                Recipe.Ingredient(name: "chickpeas", amount: "1", unit: "can"),
                Recipe.Ingredient(name: "cherry tomatoes", amount: "2", unit: "cups"),
                Recipe.Ingredient(name: "cucumber", amount: "1", unit: "large"),
                Recipe.Ingredient(name: "red onion", amount: "1/2", unit: "medium"),
                Recipe.Ingredient(name: "salami", amount: "4", unit: "oz"),
                Recipe.Ingredient(name: "mozzarella pearls", amount: "8", unit: "oz"),
                Recipe.Ingredient(name: "pepperoncini peppers", amount: "1/2", unit: "cup"),
                Recipe.Ingredient(name: "Kalamata olives", amount: "1/2", unit: "cup"),
                Recipe.Ingredient(name: "Parmesan cheese", amount: "1/2", unit: "cup"),
                Recipe.Ingredient(name: "red wine vinegar", amount: "3", unit: "tbsp"),
                Recipe.Ingredient(name: "extra virgin olive oil", amount: "1/2", unit: "cup"),
                Recipe.Ingredient(name: "Dijon mustard", amount: "1", unit: "tsp"),
                Recipe.Ingredient(name: "Italian seasoning", amount: "2", unit: "tsp"),
                Recipe.Ingredient(name: "garlic cloves", amount: "2", unit: ""),
                Recipe.Ingredient(name: "salt", amount: "1/2", unit: "tsp"),
                Recipe.Ingredient(name: "black pepper", amount: "1/4", unit: "tsp")
            ],
            instructions: [
                "Make the dressing first: In a small bowl or jar, combine red wine vinegar, olive oil, Dijon mustard, Italian seasoning, minced garlic, salt, and pepper. Whisk or shake until emulsified. Set aside.",
                "Chop rotisserie chicken into bite-sized pieces (or use leftover grilled chicken).",
                "Finely chop romaine lettuce into small pieces and place in a large serving bowl.",
                "Drain and rinse chickpeas. Pat dry with paper towels.",
                "Halve cherry tomatoes. Dice cucumber into small cubes. Thinly slice red onion.",
                "Dice salami into small pieces. Drain mozzarella pearls and pepperoncini peppers. Slice or chop olives.",
                "Add all chopped ingredients to the bowl with lettuce: chicken, chickpeas, tomatoes, cucumber, red onion, salami, mozzarella, pepperoncini, and olives.",
                "Use a vegetable peeler or grater to shave Parmesan cheese into ribbons or grate it. Add to the salad.",
                "Pour the dressing over the salad, starting with about 2/3 of it. Toss everything together thoroughly.",
                "Taste and add more dressing if needed. The salad should be well-coated but not soggy.",
                "Let sit for 5 minutes for flavors to meld, then give another quick toss.",
                "Serve immediately, or refrigerate for up to 2 hours before serving. Best eaten fresh!"
            ],
            recipeDescription: "A hearty, Italian-inspired salad loaded with protein from chicken, chickpeas, cheese, and salami. Every bite is packed with flavor from tangy dressing, salty olives, and fresh vegetables!",
            notes: "Protein powerhouse: This salad has over 30g of protein per serving! Make it vegetarian by omitting chicken and salami, and adding more chickpeas or white beans. Great for meal prep - store dressing separately and add just before eating. Can be customized with artichoke hearts, roasted red peppers, or your favorite Italian ingredients."
        )
        samples.append(italianChoppedSalad)
        
        return samples
    }
}
