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
    
    // HIDDEN - Recipe feature disabled
    /*
    func loadPrebuiltRecipes() {
        let prebuiltRecipes = PrebuiltRecipesLoader.loadPrebuiltRecipes()
        
        // Add recipes that don't already exist (avoid duplicates)
        for recipe in prebuiltRecipes {
            if !recipes.contains(where: { $0.name == recipe.name && $0.isPrebuilt }) {
                recipes.append(recipe)
            }
        }
        
        saveRecipes()
        print("✅ Loaded \(prebuiltRecipes.count) prebuilt recipes")
    }
    */
    
    // HIDDEN - Recipe feature disabled
    /*
    func hasPrebuiltRecipes() -> Bool {
        return recipes.contains(where: { $0.isPrebuilt })
    }
    */
    
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
    
    // MARK: - Auto-Generate Meal Plan
    
    /// Automatically generates a meal plan by intelligently selecting recipes
    /// - Parameters:
    ///   - numberOfDays: Number of days for the meal plan
    ///   - startDate: Starting date
    ///   - includeMeals: Which meals to include (breakfast, lunch, dinner)
    ///   - prioritizeFavorites: Whether to prioritize favorite recipes
    ///   - allowRepetition: Whether to allow the same recipe to appear multiple times
    /// - Returns: Dictionary of meals for each day
    func generateAutoMealPlan(
        numberOfDays: Int,
        startDate: Date,
        includeMeals: MealPlan.IncludedMeals,
        prioritizeFavorites: Bool = true,
        allowRepetition: Bool = true
    ) -> [Date: MealPlan.DayMeals] {
        var generatedMeals: [Date: MealPlan.DayMeals] = [:]
        
        // Get recipes by meal type
        let breakfastRecipes = recipes.filter { $0.mealType == .breakfast }
        let lunchRecipes = recipes.filter { $0.mealType == .lunch || $0.mealType == .snack }
        let dinnerRecipes = recipes.filter { $0.mealType == .dinner }
        
        // Track used recipes to avoid repetition if needed
        var usedBreakfasts: Set<UUID> = []
        var usedLunches: Set<UUID> = []
        var usedDinners: Set<UUID> = []
        
        for dayOffset in 0..<numberOfDays {
            guard let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Calendar.current.startOfDay(for: startDate)) else {
                continue
            }
            
            var dayMeals = MealPlan.DayMeals()
            
            // Generate breakfast
            if includeMeals.breakfast {
                if let recipe = selectRecipe(
                    from: breakfastRecipes,
                    excluding: allowRepetition ? [] : usedBreakfasts,
                    prioritizeFavorites: prioritizeFavorites
                ) {
                    dayMeals.breakfast = MealPlan.RecipeServingPair(recipe: recipe, servings: recipe.servings)
                    usedBreakfasts.insert(recipe.id)
                }
            }
            
            // Generate lunch
            if includeMeals.lunch {
                if let recipe = selectRecipe(
                    from: lunchRecipes,
                    excluding: allowRepetition ? [] : usedLunches,
                    prioritizeFavorites: prioritizeFavorites
                ) {
                    dayMeals.lunch = MealPlan.RecipeServingPair(recipe: recipe, servings: recipe.servings)
                    usedLunches.insert(recipe.id)
                }
            }
            
            // Generate dinner
            if includeMeals.dinner {
                if let recipe = selectRecipe(
                    from: dinnerRecipes,
                    excluding: allowRepetition ? [] : usedDinners,
                    prioritizeFavorites: prioritizeFavorites
                ) {
                    dayMeals.dinner = MealPlan.RecipeServingPair(recipe: recipe, servings: recipe.servings)
                    usedDinners.insert(recipe.id)
                }
            }
            
            generatedMeals[date] = dayMeals
        }
        
        return generatedMeals
    }
    
    /// Selects a recipe from the available recipes, optionally prioritizing favorites
    private func selectRecipe(
        from availableRecipes: [Recipe],
        excluding usedIds: Set<UUID>,
        prioritizeFavorites: Bool
    ) -> Recipe? {
        // Filter out already used recipes
        var candidates = availableRecipes.filter { !usedIds.contains($0.id) }
        
        // If we've used all recipes and repetition is not allowed, reset and use all
        if candidates.isEmpty && !usedIds.isEmpty {
            candidates = availableRecipes
        }
        
        guard !candidates.isEmpty else { return nil }
        
        // Separate favorites and non-favorites
        if prioritizeFavorites {
            let favorites = candidates.filter { $0.isFavorite }
            
            // If there are favorites, weighted random selection (80% chance for favorites)
            if !favorites.isEmpty {
                let randomValue = Double.random(in: 0...1)
                if randomValue < 0.8 {
                    return favorites.randomElement()
                }
            }
        }
        
        // Random selection from all candidates
        return candidates.randomElement()
    }
    
    /// Quick check to see if auto-generation is possible
    func canAutoGenerateMealPlan(includeMeals: MealPlan.IncludedMeals) -> (canGenerate: Bool, reason: String?) {
        if recipes.isEmpty {
            return (false, "No recipes available. Add some recipes first!")
        }
        
        var missingMealTypes: [String] = []
        
        if includeMeals.breakfast {
            let hasBreakfast = recipes.contains { $0.mealType == .breakfast }
            if !hasBreakfast {
                missingMealTypes.append("breakfast")
            }
        }
        
        if includeMeals.lunch {
            let hasLunch = recipes.contains { $0.mealType == .lunch || $0.mealType == .snack }
            if !hasLunch {
                missingMealTypes.append("lunch")
            }
        }
        
        if includeMeals.dinner {
            let hasDinner = recipes.contains { $0.mealType == .dinner }
            if !hasDinner {
                missingMealTypes.append("dinner")
            }
        }
        
        if !missingMealTypes.isEmpty {
            let types = missingMealTypes.joined(separator: ", ")
            return (false, "No recipes available for: \(types)")
        }
        
        return (true, nil)
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
    
    // HIDDEN - Recipe feature disabled
    /*
    private func loadHealthyRecipeCollection() {
        let healthyRecipes = createHealthyRecipeCollection()
        for recipe in healthyRecipes {
            recipes.append(recipe)
        }
        saveRecipes()
    }
    */
    
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
        
        // 9. Banana Peanut Butter Toast
        let bananaPBToast = Recipe(
            name: "Banana Peanut Butter Toast",
            mealType: .breakfast,
            prepTime: 3,
            cookTime: 2,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "whole grain bread", amount: "1", unit: "slice"),
                Recipe.Ingredient(name: "peanut butter", amount: "1", unit: "tbsp"),
                Recipe.Ingredient(name: "banana", amount: "0.5", unit: ""),
                Recipe.Ingredient(name: "cinnamon", amount: "1", unit: "pinch")
            ],
            instructions: [
                "Toast the bread until golden.",
                "Spread peanut butter on the toast.",
                "Top with banana slices.",
                "Sprinkle cinnamon and serve."
            ],
            recipeDescription: "A quick and filling breakfast with protein and natural sweetness."
        )
        samples.append(bananaPBToast)
        
        // 10. Simple Egg Scramble
        let simpleEggScramble = Recipe(
            name: "Simple Egg Scramble",
            mealType: .breakfast,
            prepTime: 4,
            cookTime: 6,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "eggs", amount: "2", unit: ""),
                Recipe.Ingredient(name: "milk", amount: "1", unit: "tbsp"),
                Recipe.Ingredient(name: "salt", amount: "1", unit: "pinch"),
                Recipe.Ingredient(name: "black pepper", amount: "1", unit: "pinch"),
                Recipe.Ingredient(name: "shredded cheese", amount: "1", unit: "tbsp")
            ],
            instructions: [
                "Crack eggs into a bowl.",
                "Add milk, salt, and pepper and whisk.",
                "Heat a lightly greased pan over medium heat.",
                "Pour eggs into pan and stir until cooked.",
                "Add cheese if desired."
            ],
            recipeDescription: "A beginner friendly hot breakfast packed with protein."
        )
        samples.append(simpleEggScramble)
        
        // 11. Yogurt Berry Bowl (already exists - skipping)
        
        // 12. Avocado Toast
        let avocadoToast = Recipe(
            name: "Avocado Toast",
            mealType: .breakfast,
            prepTime: 3,
            cookTime: 2,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "bread", amount: "1", unit: "slice"),
                Recipe.Ingredient(name: "avocado", amount: "0.5", unit: ""),
                Recipe.Ingredient(name: "salt", amount: "1", unit: "pinch"),
                Recipe.Ingredient(name: "black pepper", amount: "1", unit: "pinch")
            ],
            instructions: [
                "Toast bread.",
                "Mash avocado in a bowl.",
                "Spread avocado on toast.",
                "Add salt and pepper."
            ],
            recipeDescription: "A simple healthy breakfast that is quick and satisfying."
        )
        samples.append(avocadoToast)
        
        // 13. Microwave Oatmeal
        let microwaveOatmeal = Recipe(
            name: "Microwave Oatmeal",
            mealType: .breakfast,
            prepTime: 1,
            cookTime: 2,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "oats", amount: "0.5", unit: "cup"),
                Recipe.Ingredient(name: "milk or water", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "honey", amount: "1", unit: "tbsp")
            ],
            instructions: [
                "Combine oats and milk in a bowl.",
                "Microwave 1 to 2 minutes.",
                "Stir and add honey."
            ],
            recipeDescription: "Warm comforting oats ready in just a few minutes."
        )
        samples.append(microwaveOatmeal)
        
        // 14. Egg and Cheese Breakfast Sandwich
        let breakfastSandwich = Recipe(
            name: "Egg and Cheese Breakfast Sandwich",
            mealType: .breakfast,
            prepTime: 3,
            cookTime: 7,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "egg", amount: "1", unit: ""),
                Recipe.Ingredient(name: "English muffin", amount: "1", unit: ""),
                Recipe.Ingredient(name: "cheese", amount: "1", unit: "slice")
            ],
            instructions: [
                "Cook egg in skillet.",
                "Toast muffin.",
                "Place egg and cheese in muffin and serve."
            ],
            recipeDescription: "A simple hot breakfast sandwich perfect for busy mornings."
        )
        samples.append(breakfastSandwich)
        
        // 15. Peanut Butter Banana Smoothie
        let pbBananaSmoothie = Recipe(
            name: "Peanut Butter Banana Smoothie",
            mealType: .breakfast,
            prepTime: 5,
            cookTime: 0,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "banana", amount: "1", unit: ""),
                Recipe.Ingredient(name: "peanut butter", amount: "1", unit: "tbsp"),
                Recipe.Ingredient(name: "milk", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "ice", amount: "0.5", unit: "cup")
            ],
            instructions: [
                "Place ingredients in blender.",
                "Blend until smooth.",
                "Serve immediately."
            ],
            recipeDescription: "A creamy smoothie that makes an easy breakfast."
        )
        samples.append(pbBananaSmoothie)
        
        // 16. Apple Cinnamon Oatmeal
        let appleCinnamonOatmeal = Recipe(
            name: "Apple Cinnamon Oatmeal",
            mealType: .breakfast,
            prepTime: 3,
            cookTime: 5,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "oats", amount: "0.5", unit: "cup"),
                Recipe.Ingredient(name: "milk", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "apple", amount: "0.5", unit: ""),
                Recipe.Ingredient(name: "cinnamon", amount: "0.5", unit: "tsp")
            ],
            instructions: [
                "Cook oats with milk.",
                "Stir in chopped apple.",
                "Sprinkle cinnamon.",
                "Serve warm."
            ],
            recipeDescription: "Warm oatmeal with sweet apples and cinnamon."
        )
        samples.append(appleCinnamonOatmeal)
        
        // 17. Cottage Cheese Fruit Bowl
        let cottageCheeseBowl = Recipe(
            name: "Cottage Cheese Fruit Bowl",
            mealType: .breakfast,
            prepTime: 3,
            cookTime: 0,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "cottage cheese", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "fruit", amount: "0.5", unit: "cup")
            ],
            instructions: [
                "Add cottage cheese to bowl.",
                "Top with fruit."
            ],
            recipeDescription: "A quick high protein breakfast bowl."
        )
        samples.append(cottageCheeseBowl)
        
        // 18. Honey Toast
        let honeyToast = Recipe(
            name: "Honey Toast",
            mealType: .breakfast,
            prepTime: 1,
            cookTime: 2,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "bread", amount: "1", unit: "slice"),
                Recipe.Ingredient(name: "honey", amount: "1", unit: "tbsp")
            ],
            instructions: [
                "Toast bread.",
                "Drizzle with honey.",
                "Serve warm."
            ],
            recipeDescription: "A simple sweet toast for quick mornings."
        )
        samples.append(honeyToast)
        
        // 19. Turkey and Cheese Wrap
        let turkeyCheeseWrap = Recipe(
            name: "Turkey and Cheese Wrap",
            mealType: .lunch,
            prepTime: 5,
            cookTime: 0,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "tortilla", amount: "1", unit: ""),
                Recipe.Ingredient(name: "turkey", amount: "3", unit: "slices"),
                Recipe.Ingredient(name: "cheese", amount: "1", unit: "slice"),
                Recipe.Ingredient(name: "lettuce", amount: "1", unit: "leaf")
            ],
            instructions: [
                "Lay tortilla flat.",
                "Add turkey cheese and lettuce.",
                "Roll tightly.",
                "Slice and serve."
            ],
            recipeDescription: "A fast lunch wrap with protein and crunch."
        )
        samples.append(turkeyCheeseWrap)
        
        // 20. Chicken Salad Bowl
        let chickenSaladBowl = Recipe(
            name: "Chicken Salad Bowl",
            mealType: .lunch,
            prepTime: 10,
            cookTime: 0,
            servings: 2,
            ingredients: [
                Recipe.Ingredient(name: "shredded chicken", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "mayo", amount: "2", unit: "tbsp"),
                Recipe.Ingredient(name: "celery", amount: "1", unit: "tbsp"),
                Recipe.Ingredient(name: "salt and pepper", amount: "1", unit: "pinch")
            ],
            instructions: [
                "Combine chicken mayo and celery.",
                "Season with salt and pepper.",
                "Serve with crackers or bread."
            ],
            recipeDescription: "A creamy chicken salad perfect for sandwiches or bowls."
        )
        samples.append(chickenSaladBowl)
        
        // 21. Simple Tuna Melt
        let tunaMelt = Recipe(
            name: "Simple Tuna Melt",
            mealType: .lunch,
            prepTime: 5,
            cookTime: 5,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "tuna", amount: "1", unit: "can"),
                Recipe.Ingredient(name: "mayo", amount: "2", unit: "tbsp"),
                Recipe.Ingredient(name: "cheese", amount: "1", unit: "slice"),
                Recipe.Ingredient(name: "bread", amount: "2", unit: "slices")
            ],
            instructions: [
                "Mix tuna and mayo.",
                "Spread on bread.",
                "Add cheese and top with second slice.",
                "Cook in skillet until toasted."
            ],
            recipeDescription: "A warm sandwich with melty cheese and tuna."
        )
        samples.append(tunaMelt)
        
        // 22. Ham and Cheese Sandwich
        let hamCheeseSandwich = Recipe(
            name: "Ham and Cheese Sandwich",
            mealType: .lunch,
            prepTime: 5,
            cookTime: 0,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "bread", amount: "2", unit: "slices"),
                Recipe.Ingredient(name: "ham", amount: "2", unit: "slices"),
                Recipe.Ingredient(name: "cheese", amount: "1", unit: "slice")
            ],
            instructions: [
                "Layer ham and cheese between bread slices.",
                "Serve immediately."
            ],
            recipeDescription: "A classic sandwich that is quick and filling."
        )
        samples.append(hamCheeseSandwich)
        
        // 23. Peanut Butter and Jelly Sandwich
        let pbAndJ = Recipe(
            name: "Peanut Butter and Jelly Sandwich",
            mealType: .lunch,
            prepTime: 3,
            cookTime: 0,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "bread", amount: "2", unit: "slices"),
                Recipe.Ingredient(name: "peanut butter", amount: "1", unit: "tbsp"),
                Recipe.Ingredient(name: "jelly", amount: "1", unit: "tbsp")
            ],
            instructions: [
                "Spread peanut butter on one slice.",
                "Spread jelly on the other.",
                "Close sandwich."
            ],
            recipeDescription: "A simple sandwich loved by kids and adults."
        )
        samples.append(pbAndJ)
        
        // 24. Grilled Cheese Sandwich
        let grilledCheese = Recipe(
            name: "Grilled Cheese Sandwich",
            mealType: .lunch,
            prepTime: 3,
            cookTime: 7,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "bread", amount: "2", unit: "slices"),
                Recipe.Ingredient(name: "cheese", amount: "1", unit: "slice"),
                Recipe.Ingredient(name: "butter", amount: "1", unit: "tbsp")
            ],
            instructions: [
                "Butter bread.",
                "Place cheese between slices.",
                "Cook in skillet until golden."
            ],
            recipeDescription: "A crispy golden sandwich with melted cheese."
        )
        samples.append(grilledCheese)
        
        // 25. Chicken Quesadilla
        let chickenQuesadilla = Recipe(
            name: "Chicken Quesadilla",
            mealType: .lunch,
            prepTime: 4,
            cookTime: 6,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "tortilla", amount: "1", unit: ""),
                Recipe.Ingredient(name: "shredded chicken", amount: "0.5", unit: "cup"),
                Recipe.Ingredient(name: "shredded cheese", amount: "0.25", unit: "cup")
            ],
            instructions: [
                "Add chicken and cheese to tortilla.",
                "Fold tortilla.",
                "Cook in skillet until cheese melts."
            ],
            recipeDescription: "A cheesy tortilla filled with chicken."
        )
        samples.append(chickenQuesadilla)
        
        // 26. Simple Chicken Salad Sandwich
        let chickenSaladSandwich = Recipe(
            name: "Simple Chicken Salad Sandwich",
            mealType: .lunch,
            prepTime: 5,
            cookTime: 0,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "chicken salad", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "bread", amount: "2", unit: "slices")
            ],
            instructions: [
                "Place chicken salad between bread slices.",
                "Serve."
            ],
            recipeDescription: "A quick sandwich using prepared chicken salad."
        )
        samples.append(chickenSaladSandwich)
        
        // 27. Cheese and Crackers Plate
        let cheeseAndCrackers = Recipe(
            name: "Cheese and Crackers Plate",
            mealType: .lunch,
            prepTime: 3,
            cookTime: 0,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "crackers", amount: "6", unit: ""),
                Recipe.Ingredient(name: "cheese", amount: "2", unit: "slices")
            ],
            instructions: [
                "Place cheese on crackers.",
                "Serve."
            ],
            recipeDescription: "A light lunch or snack plate."
        )
        samples.append(cheeseAndCrackers)
        
        // 28. Air Fryer Chicken Tenders
        let airFryerChickenTenders = Recipe(
            name: "Air Fryer Chicken Tenders",
            mealType: .dinner,
            prepTime: 5,
            cookTime: 10,
            servings: 2,
            ingredients: [
                Recipe.Ingredient(name: "chicken breasts", amount: "2", unit: ""),
                Recipe.Ingredient(name: "egg", amount: "1", unit: ""),
                Recipe.Ingredient(name: "breadcrumbs", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "salt and pepper", amount: "1", unit: "pinch")
            ],
            instructions: [
                "Preheat air fryer to 375°F.",
                "Dip chicken into egg then breadcrumbs.",
                "Place in air fryer basket.",
                "Cook 10 to 12 minutes until cooked through."
            ],
            recipeDescription: "Crispy homemade chicken tenders cooked quickly in an air fryer."
        )
        samples.append(airFryerChickenTenders)
        
        // 29. Air Fryer Salmon
        let airFryerSalmon = Recipe(
            name: "Air Fryer Salmon",
            mealType: .dinner,
            prepTime: 4,
            cookTime: 8,
            servings: 2,
            ingredients: [
                Recipe.Ingredient(name: "salmon fillets", amount: "2", unit: ""),
                Recipe.Ingredient(name: "olive oil", amount: "1", unit: "tbsp"),
                Recipe.Ingredient(name: "salt and pepper", amount: "1", unit: "pinch")
            ],
            instructions: [
                "Brush salmon with olive oil.",
                "Season with salt and pepper.",
                "Air fry at 400°F for 8 to 10 minutes."
            ],
            recipeDescription: "A quick and flavorful salmon dinner."
        )
        samples.append(airFryerSalmon)
        
        // 30. Air Fryer Mini Pizza
        let airFryerMiniPizza = Recipe(
            name: "Air Fryer Mini Pizza",
            mealType: .dinner,
            prepTime: 3,
            cookTime: 5,
            servings: 2,
            ingredients: [
                Recipe.Ingredient(name: "English muffins", amount: "2", unit: ""),
                Recipe.Ingredient(name: "pizza sauce", amount: "2", unit: "tbsp"),
                Recipe.Ingredient(name: "shredded mozzarella", amount: "0.5", unit: "cup")
            ],
            instructions: [
                "Spread sauce on muffins.",
                "Add cheese.",
                "Air fry at 370°F for 5 to 6 minutes."
            ],
            recipeDescription: "A fast homemade pizza using English muffins."
        )
        samples.append(airFryerMiniPizza)
        
        // 31. Slow Cooker BBQ Chicken
        let slowCookerBBQChicken = Recipe(
            name: "Slow Cooker BBQ Chicken",
            mealType: .dinner,
            prepTime: 5,
            cookTime: 360,
            servings: 4,
            ingredients: [
                Recipe.Ingredient(name: "chicken breasts", amount: "2", unit: ""),
                Recipe.Ingredient(name: "BBQ sauce", amount: "1", unit: "cup")
            ],
            instructions: [
                "Place chicken in slow cooker.",
                "Pour BBQ sauce over chicken.",
                "Cook on low for 6 hours.",
                "Shred chicken and serve."
            ],
            recipeDescription: "Tender shredded BBQ chicken perfect for sandwiches."
        )
        samples.append(slowCookerBBQChicken)
        
        // 32. Slow Cooker Chicken Tacos
        let slowCookerChickenTacos = Recipe(
            name: "Slow Cooker Chicken Tacos",
            mealType: .dinner,
            prepTime: 5,
            cookTime: 360,
            servings: 4,
            ingredients: [
                Recipe.Ingredient(name: "chicken breasts", amount: "2", unit: ""),
                Recipe.Ingredient(name: "taco seasoning", amount: "1", unit: "packet"),
                Recipe.Ingredient(name: "salsa", amount: "1", unit: "cup")
            ],
            instructions: [
                "Add all ingredients to slow cooker.",
                "Cook on low 6 hours.",
                "Shred chicken.",
                "Serve in tortillas."
            ],
            recipeDescription: "Easy shredded taco chicken for quick meals."
        )
        samples.append(slowCookerChickenTacos)
        
        // 33. Slow Cooker Chili
        let slowCookerChili = Recipe(
            name: "Slow Cooker Chili",
            mealType: .dinner,
            prepTime: 10,
            cookTime: 360,
            servings: 4,
            ingredients: [
                Recipe.Ingredient(name: "ground beef", amount: "1", unit: "lb"),
                Recipe.Ingredient(name: "beans", amount: "1", unit: "can"),
                Recipe.Ingredient(name: "diced tomatoes", amount: "1", unit: "can"),
                Recipe.Ingredient(name: "chili powder", amount: "1", unit: "tbsp")
            ],
            instructions: [
                "Brown beef in skillet.",
                "Add all ingredients to slow cooker.",
                "Cook on low for 6 hours."
            ],
            recipeDescription: "A simple hearty chili great for weeknights."
        )
        samples.append(slowCookerChili)
        
        // 34. Simple Spaghetti
        let simpleSpaghetti = Recipe(
            name: "Simple Spaghetti",
            mealType: .dinner,
            prepTime: 5,
            cookTime: 15,
            servings: 2,
            ingredients: [
                Recipe.Ingredient(name: "cooked spaghetti", amount: "2", unit: "cups"),
                Recipe.Ingredient(name: "marinara sauce", amount: "0.5", unit: "cup"),
                Recipe.Ingredient(name: "Parmesan cheese", amount: "2", unit: "tbsp")
            ],
            instructions: [
                "Cook pasta.",
                "Heat marinara sauce.",
                "Combine pasta and sauce.",
                "Top with parmesan."
            ],
            recipeDescription: "Classic pasta with marinara sauce."
        )
        samples.append(simpleSpaghetti)
        
        // 35. Sheet Pan Sausage and Veggies
        let sheetPanSausageVeggies = Recipe(
            name: "Sheet Pan Sausage and Veggies",
            mealType: .dinner,
            prepTime: 5,
            cookTime: 20,
            servings: 2,
            ingredients: [
                Recipe.Ingredient(name: "sausage links", amount: "2", unit: ""),
                Recipe.Ingredient(name: "potatoes", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "broccoli", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "olive oil", amount: "1", unit: "tbsp")
            ],
            instructions: [
                "Preheat oven to 400°F.",
                "Toss ingredients with oil.",
                "Spread on sheet pan.",
                "Bake 20 to 25 minutes."
            ],
            recipeDescription: "A simple one pan dinner with roasted vegetables."
        )
        samples.append(sheetPanSausageVeggies)
        
        // 36. Chicken Rice Bowl
        let chickenRiceBowl = Recipe(
            name: "Chicken Rice Bowl",
            mealType: .dinner,
            prepTime: 5,
            cookTime: 5,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "rice", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "cooked chicken", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "broccoli", amount: "0.5", unit: "cup"),
                Recipe.Ingredient(name: "soy sauce", amount: "1", unit: "tbsp")
            ],
            instructions: [
                "Add rice to bowl.",
                "Top with chicken and broccoli.",
                "Drizzle soy sauce."
            ],
            recipeDescription: "A quick dinner bowl with chicken and rice."
        )
        samples.append(chickenRiceBowl)
        
        // 37. Ground Beef Taco Bowl
        let groundBeefTacoBowl = Recipe(
            name: "Ground Beef Taco Bowl",
            mealType: .dinner,
            prepTime: 5,
            cookTime: 10,
            servings: 2,
            ingredients: [
                Recipe.Ingredient(name: "rice", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "cooked ground beef", amount: "0.5", unit: "cup"),
                Recipe.Ingredient(name: "shredded cheese", amount: "0.25", unit: "cup"),
                Recipe.Ingredient(name: "salsa", amount: "2", unit: "tbsp")
            ],
            instructions: [
                "Add rice to bowl.",
                "Top with beef.",
                "Add cheese and salsa."
            ],
            recipeDescription: "A simple taco style rice bowl."
        )
        samples.append(groundBeefTacoBowl)
        
        // 38. Butter Parmesan Pasta
        let butterParmesanPasta = Recipe(
            name: "Butter Parmesan Pasta",
            mealType: .dinner,
            prepTime: 2,
            cookTime: 10,
            servings: 2,
            ingredients: [
                Recipe.Ingredient(name: "pasta", amount: "2", unit: "cups"),
                Recipe.Ingredient(name: "butter", amount: "1", unit: "tbsp"),
                Recipe.Ingredient(name: "Parmesan cheese", amount: "2", unit: "tbsp")
            ],
            instructions: [
                "Cook pasta.",
                "Toss with butter.",
                "Sprinkle parmesan."
            ],
            recipeDescription: "An ultra simple pasta dinner."
        )
        samples.append(butterParmesanPasta)
        
        // 39. Air Fryer Roasted Vegetables
        let airFryerVegetables = Recipe(
            name: "Air Fryer Roasted Vegetables",
            mealType: .dinner,
            prepTime: 2,
            cookTime: 10,
            servings: 2,
            ingredients: [
                Recipe.Ingredient(name: "mixed vegetables", amount: "2", unit: "cups"),
                Recipe.Ingredient(name: "olive oil", amount: "1", unit: "tbsp"),
                Recipe.Ingredient(name: "salt and pepper", amount: "1", unit: "pinch")
            ],
            instructions: [
                "Toss vegetables with oil.",
                "Air fry at 380°F for 10 to 12 minutes."
            ],
            recipeDescription: "Crispy roasted vegetables made in the air fryer."
        )
        samples.append(airFryerVegetables)
        
        // 40. Air Fryer Quesadilla
        let airFryerQuesadilla = Recipe(
            name: "Air Fryer Quesadilla",
            mealType: .dinner,
            prepTime: 2,
            cookTime: 6,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "tortilla", amount: "1", unit: ""),
                Recipe.Ingredient(name: "shredded chicken", amount: "0.5", unit: "cup"),
                Recipe.Ingredient(name: "cheese", amount: "0.25", unit: "cup")
            ],
            instructions: [
                "Fill tortilla with chicken and cheese.",
                "Fold tortilla.",
                "Air fry 375°F for 6 minutes."
            ],
            recipeDescription: "A crispy quesadilla cooked quickly in the air fryer."
        )
        samples.append(airFryerQuesadilla)
        
        // 41. Slow Cooker Beef and Potatoes
        let slowCookerBeefPotatoes = Recipe(
            name: "Slow Cooker Beef and Potatoes",
            mealType: .dinner,
            prepTime: 10,
            cookTime: 420,
            servings: 4,
            ingredients: [
                Recipe.Ingredient(name: "stew beef", amount: "1", unit: "lb"),
                Recipe.Ingredient(name: "potatoes", amount: "2", unit: "cups"),
                Recipe.Ingredient(name: "carrots", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "beef broth", amount: "1", unit: "cup")
            ],
            instructions: [
                "Add ingredients to slow cooker.",
                "Cook on low 7 to 8 hours."
            ],
            recipeDescription: "A hearty slow cooked beef and potato meal."
        )
        samples.append(slowCookerBeefPotatoes)
        
        // 42. Slow Cooker Chicken Alfredo
        let slowCookerChickenAlfredo = Recipe(
            name: "Slow Cooker Chicken Alfredo",
            mealType: .dinner,
            prepTime: 5,
            cookTime: 360,
            servings: 4,
            ingredients: [
                Recipe.Ingredient(name: "chicken breasts", amount: "2", unit: ""),
                Recipe.Ingredient(name: "Alfredo sauce", amount: "1", unit: "jar")
            ],
            instructions: [
                "Place chicken and sauce in slow cooker.",
                "Cook 6 hours.",
                "Shred chicken and serve over pasta."
            ],
            recipeDescription: "Creamy shredded chicken for pasta dinners."
        )
        samples.append(slowCookerChickenAlfredo)
        
        // 43. Rice and Fried Egg Bowl
        let riceEggBowl = Recipe(
            name: "Rice and Fried Egg Bowl",
            mealType: .dinner,
            prepTime: 3,
            cookTime: 7,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "rice", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "fried egg", amount: "1", unit: ""),
                Recipe.Ingredient(name: "soy sauce", amount: "1", unit: "tbsp")
            ],
            instructions: [
                "Add rice to bowl.",
                "Top with fried egg.",
                "Drizzle soy sauce."
            ],
            recipeDescription: "A simple comfort bowl with rice and egg."
        )
        samples.append(riceEggBowl)
        
        // 44. Chocolate Banana Bites
        let chocolateBananaBites = Recipe(
            name: "Chocolate Banana Bites",
            mealType: .dessert,
            prepTime: 5,
            cookTime: 20,
            servings: 2,
            ingredients: [
                Recipe.Ingredient(name: "banana", amount: "1", unit: ""),
                Recipe.Ingredient(name: "melted chocolate", amount: "2", unit: "tbsp")
            ],
            instructions: [
                "Slice banana.",
                "Dip slices in chocolate.",
                "Freeze 20 minutes."
            ],
            recipeDescription: "Frozen banana bites dipped in chocolate."
        )
        samples.append(chocolateBananaBites)
        
        // 45. Apple Cinnamon Bowl
        let appleCinnamonBowl = Recipe(
            name: "Apple Cinnamon Bowl",
            mealType: .dessert,
            prepTime: 5,
            cookTime: 0,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "apple", amount: "1", unit: ""),
                Recipe.Ingredient(name: "cinnamon", amount: "1", unit: "tsp"),
                Recipe.Ingredient(name: "honey", amount: "1", unit: "tsp")
            ],
            instructions: [
                "Add apples to bowl.",
                "Sprinkle cinnamon.",
                "Drizzle honey."
            ],
            recipeDescription: "Fresh apples with warm cinnamon flavor."
        )
        samples.append(appleCinnamonBowl)
        
        // 46. Greek Yogurt Honey Dessert
        let greekYogurtHoneyDessert = Recipe(
            name: "Greek Yogurt Honey Dessert",
            mealType: .dessert,
            prepTime: 3,
            cookTime: 0,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "Greek yogurt", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "honey", amount: "1", unit: "tbsp")
            ],
            instructions: [
                "Add yogurt to bowl.",
                "Drizzle honey."
            ],
            recipeDescription: "A quick creamy sweet treat."
        )
        samples.append(greekYogurtHoneyDessert)
        
        // 47. Strawberries and Whipped Cream
        let strawberriesWhippedCream = Recipe(
            name: "Strawberries and Whipped Cream",
            mealType: .dessert,
            prepTime: 3,
            cookTime: 0,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "strawberries", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "whipped cream", amount: "2", unit: "tbsp")
            ],
            instructions: [
                "Place strawberries in bowl.",
                "Top with whipped cream."
            ],
            recipeDescription: "A classic light dessert."
        )
        samples.append(strawberriesWhippedCream)
        
        // 48. Chocolate Yogurt Bowl
        let chocolateYogurtBowl = Recipe(
            name: "Chocolate Yogurt Bowl",
            mealType: .dessert,
            prepTime: 3,
            cookTime: 0,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "yogurt", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "chocolate chips", amount: "1", unit: "tbsp")
            ],
            instructions: [
                "Mix yogurt and chocolate chips.",
                "Serve."
            ],
            recipeDescription: "A creamy chocolate snack dessert."
        )
        samples.append(chocolateYogurtBowl)
        
        // 49. Chocolate Chip Mug Cake
        let chocolateChipMugCake = Recipe(
            name: "Chocolate Chip Mug Cake",
            mealType: .dessert,
            prepTime: 2,
            cookTime: 1,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "flour", amount: "3", unit: "tbsp"),
                Recipe.Ingredient(name: "sugar", amount: "2", unit: "tbsp"),
                Recipe.Ingredient(name: "chocolate chips", amount: "1", unit: "tbsp"),
                Recipe.Ingredient(name: "milk", amount: "3", unit: "tbsp")
            ],
            instructions: [
                "Mix ingredients in mug.",
                "Microwave 1 minute.",
                "Let cool slightly."
            ],
            recipeDescription: "A warm single serving dessert made in the microwave."
        )
        samples.append(chocolateChipMugCake)
        
        // 50. Peanut Butter Mug Dessert
        let peanutButterMugDessert = Recipe(
            name: "Peanut Butter Mug Dessert",
            mealType: .dessert,
            prepTime: 1,
            cookTime: 1,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "peanut butter", amount: "2", unit: "tbsp"),
                Recipe.Ingredient(name: "honey", amount: "1", unit: "tbsp"),
                Recipe.Ingredient(name: "oats", amount: "1", unit: "tbsp")
            ],
            instructions: [
                "Mix ingredients in mug.",
                "Microwave 20 seconds.",
                "Stir and enjoy."
            ],
            recipeDescription: "A quick peanut butter dessert ready in seconds."
        )
        samples.append(peanutButterMugDessert)
        
        // 51. Energy Balls
        let energyBalls = Recipe(
            name: "Energy Balls",
            mealType: .snack,
            prepTime: 10,
            cookTime: 30,
            servings: 6,
            ingredients: [
                Recipe.Ingredient(name: "oats", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "peanut butter", amount: "0.5", unit: "cup"),
                Recipe.Ingredient(name: "honey", amount: "2", unit: "tbsp"),
                Recipe.Ingredient(name: "chocolate chips", amount: "2", unit: "tbsp")
            ],
            instructions: [
                "Mix ingredients in bowl.",
                "Roll into balls.",
                "Refrigerate 30 minutes."
            ],
            recipeDescription: "No bake snack balls great for meal prep."
        )
        samples.append(energyBalls)
        
        // 52. Veggie Snack Cups
        let veggieSnackCups = Recipe(
            name: "Veggie Snack Cups",
            mealType: .snack,
            prepTime: 5,
            cookTime: 0,
            servings: 2,
            ingredients: [
                Recipe.Ingredient(name: "carrot sticks", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "celery sticks", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "ranch dressing", amount: "4", unit: "tbsp")
            ],
            instructions: [
                "Add ranch to small cup.",
                "Place vegetables upright."
            ],
            recipeDescription: "Easy veggie snacks with dip."
        )
        samples.append(veggieSnackCups)
        
        // 53. Hard Boiled Eggs
        let hardBoiledEggs = Recipe(
            name: "Hard Boiled Eggs",
            mealType: .snack,
            prepTime: 2,
            cookTime: 10,
            servings: 2,
            ingredients: [
                Recipe.Ingredient(name: "eggs", amount: "2", unit: ""),
                Recipe.Ingredient(name: "salt and pepper", amount: "1", unit: "pinch")
            ],
            instructions: [
                "Boil eggs 10 minutes.",
                "Cool and peel.",
                "Season."
            ],
            recipeDescription: "A simple high protein snack."
        )
        samples.append(hardBoiledEggs)
        
        // 54. Apple and Peanut Butter Snack
        let applePeanutButterSnack = Recipe(
            name: "Apple and Peanut Butter Snack",
            mealType: .snack,
            prepTime: 3,
            cookTime: 0,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "apple", amount: "1", unit: ""),
                Recipe.Ingredient(name: "peanut butter", amount: "1", unit: "tbsp")
            ],
            instructions: [
                "Slice apple.",
                "Dip slices into peanut butter."
            ],
            recipeDescription: "Crunchy apple slices with peanut butter."
        )
        samples.append(applePeanutButterSnack)
        
        // 55. Banana Oat Snack
        let bananaOatSnack = Recipe(
            name: "Banana Oat Snack",
            mealType: .snack,
            prepTime: 2,
            cookTime: 0,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "banana", amount: "1", unit: ""),
                Recipe.Ingredient(name: "oats", amount: "2", unit: "tbsp")
            ],
            instructions: [
                "Slice banana.",
                "Sprinkle oats on top."
            ],
            recipeDescription: "A quick snack with fiber and natural sweetness."
        )
        samples.append(bananaOatSnack)
        
        // 56. Ham Roll Ups
        let hamRollUps = Recipe(
            name: "Ham Roll Ups",
            mealType: .snack,
            prepTime: 2,
            cookTime: 0,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "ham", amount: "2", unit: "slices"),
                Recipe.Ingredient(name: "cheese", amount: "1", unit: "slice")
            ],
            instructions: [
                "Roll cheese inside ham slices."
            ],
            recipeDescription: "Simple protein snack rolls."
        )
        samples.append(hamRollUps)
        
        // 57. Quick Nachos
        let quickNachos = Recipe(
            name: "Quick Nachos",
            mealType: .snack,
            prepTime: 1,
            cookTime: 1,
            servings: 2,
            ingredients: [
                Recipe.Ingredient(name: "tortilla chips", amount: "1", unit: "cup"),
                Recipe.Ingredient(name: "shredded cheese", amount: "0.5", unit: "cup")
            ],
            instructions: [
                "Place chips on plate.",
                "Add cheese.",
                "Microwave 30 seconds."
            ],
            recipeDescription: "A quick cheesy snack."
        )
        samples.append(quickNachos)
        
        // 58. Simple Fruit Bowl
        let simpleFruitBowl = Recipe(
            name: "Simple Fruit Bowl",
            mealType: .snack,
            prepTime: 2,
            cookTime: 0,
            servings: 1,
            ingredients: [
                Recipe.Ingredient(name: "mixed fruit", amount: "1", unit: "cup")
            ],
            instructions: [
                "Place fruit in bowl.",
                "Serve."
            ],
            recipeDescription: "A refreshing snack with fresh fruit."
        )
        samples.append(simpleFruitBowl)
        
        return samples
    }
}
