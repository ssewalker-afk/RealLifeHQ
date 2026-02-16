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
            
            // Sync to Google Calendar if enabled
            let googleCalendarManager = await GoogleCalendarManager.shared
            if googleCalendarManager.isAuthenticated && googleCalendarManager.syncEnabled {
                if let googleEventId = try? await googleCalendarManager.createEvent(event) {
                    // Update event with Google Calendar ID
                    await MainActor.run {
                        if let index = self.events.firstIndex(where: { $0.id == event.id }) {
                            self.events[index].googleCalendarEventId = googleEventId
                            self.saveEvents()
                        }
                    }
                }
            }
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
                
                // Sync to Google Calendar if enabled
                let googleCalendarManager = await GoogleCalendarManager.shared
                if googleCalendarManager.isAuthenticated && googleCalendarManager.syncEnabled {
                    if let googleEventId = event.googleCalendarEventId {
                        try? await googleCalendarManager.updateEvent(event, googleEventId: googleEventId)
                    } else {
                        // Create new event if no ID exists
                        if let googleEventId = try? await googleCalendarManager.createEvent(event) {
                            await MainActor.run {
                                if let idx = self.events.firstIndex(where: { $0.id == event.id }) {
                                    self.events[idx].googleCalendarEventId = googleEventId
                                    self.saveEvents()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func deleteEvent(_ event: Event) {
        // Sync deletion to Apple Calendar if enabled
        Task {
            let appleCalendarManager = await AppleCalendarManager.shared
            try? await appleCalendarManager.deleteEventFromAppleCalendar(event)
            
            // Sync deletion to Google Calendar if enabled
            let googleCalendarManager = await GoogleCalendarManager.shared
            if googleCalendarManager.isAuthenticated && googleCalendarManager.syncEnabled {
                if let googleEventId = event.googleCalendarEventId {
                    try? await googleCalendarManager.deleteEvent(googleEventId: googleEventId)
                }
            }
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
    
    func addIngredientsToShoppingList(from recipe: Recipe) {
        for ingredient in recipe.ingredients {
            let item = ShoppingItem(
                name: ingredient,
                quantity: "1",
                category: categorizeIngredient(ingredient)
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
}
