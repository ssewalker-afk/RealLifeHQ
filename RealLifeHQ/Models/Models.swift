import Foundation
import SwiftUI

// MARK: - Data Models
// These define what information we store for each feature

// Calendar Event
struct Event: Identifiable, Codable {
    var id = UUID()          // Unique identifier
    var title: String
    var date: Date
    var time: Date?          // Optional start time
    var endTime: Date?       // Optional end time
    var isAllDay: Bool = false // All-day event flag
    var notes: String?       // Optional notes
    var isCompleted: Bool = false
    var reminderMinutesBefore: Int? // Minutes before event to remind (nil = no reminder)
    var notificationIdentifier: String? // For canceling notifications
    var recurrenceRule: RecurrenceRule? // Recurring event pattern
    var recurrenceEndDate: Date? // When to stop recurring (nil = forever)
    
    enum RecurrenceRule: String, Codable, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case biweekly = "Every 2 Weeks"
        case monthly = "Monthly"
        case yearly = "Yearly"
        
        var displayName: String { rawValue }
    }
    
    // For displaying in lists
    var dateString: String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
    
    var timeString: String? {
        if isAllDay {
            return "All day"
        }
        
        guard let startTime = time else { return nil }
        
        if let endTime = endTime {
            return "\(startTime.formatted(date: .omitted, time: .shortened)) - \(endTime.formatted(date: .omitted, time: .shortened))"
        }
        
        return startTime.formatted(date: .omitted, time: .shortened)
    }
    
    // Combined date and time for the actual event
    var eventDateTime: Date {
        if let time = time {
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            
            var combined = DateComponents()
            combined.year = dateComponents.year
            combined.month = dateComponents.month
            combined.day = dateComponents.day
            combined.hour = timeComponents.hour
            combined.minute = timeComponents.minute
            
            return calendar.date(from: combined) ?? date
        }
        return date
    }
    
    // Combined date and end time for the event
    var eventEndDateTime: Date? {
        guard let endTime = endTime else { return nil }
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        
        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        
        return calendar.date(from: combined)
    }
}

// Habit Tracker
struct Habit: Identifiable, Codable {
    var id = UUID()
    var name: String
    var icon: String         // SF Symbol name (like "figure.walk")
    var color: String        // Color name
    var frequency: Frequency // How often to do it
    var selectedDays: Set<Int> = Set([1, 2, 3, 4, 5, 6, 7]) // Days of week (1=Sunday, 7=Saturday)
    var completedDates: [Date] = []  // Dates when completed
    var reminderEnabled: Bool = false  // Whether notifications are enabled
    var reminderTime: Date?  // Time of day for reminder
    var notificationIdentifiers: [String] = []  // IDs for scheduled notifications
    
    // Calendar Integration
    var addToCalendar: Bool = false  // Whether to add to system calendar
    var calendarEventIdentifiers: [String] = []  // Calendar event IDs for removal
    var calendarDuration: Int = 30  // Duration in minutes (default 30 min)
    
    enum Frequency: String, Codable, CaseIterable {
        case daily = "Daily"
        case specificDays = "Specific Days"
        case weekly = "Weekly"
    }
    
    // Check if completed today
    func isCompletedToday() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return completedDates.contains { date in
            Calendar.current.isDate(date, inSameDayAs: today)
        }
    }
    
    // Check if habit is scheduled for today
    func isScheduledForToday() -> Bool {
        if frequency == .daily {
            return true
        }
        
        let weekday = Calendar.current.component(.weekday, from: Date())
        return selectedDays.contains(weekday)
    }
    
    // Get completion streak
    func currentStreak() -> Int {
        var streak = 0
        var checkDate = Date()
        
        while true {
            let dayStart = Calendar.current.startOfDay(for: checkDate)
            let weekday = Calendar.current.component(.weekday, from: checkDate)
            
            // Only count days when the habit is scheduled
            if frequency == .daily || selectedDays.contains(weekday) {
                if completedDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: dayStart) }) {
                    streak += 1
                    checkDate = Calendar.current.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
                } else {
                    break
                }
            } else {
                // Skip days not scheduled
                checkDate = Calendar.current.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            }
        }
        return streak
    }
}

// Journal Entry
struct JournalEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var mood: Mood?          // Optional mood tracking
    var content: String
    var tags: [String] = []  // For categorizing entries
    
    enum Mood: String, Codable, CaseIterable {
        case great = "😊"
        case good = "🙂"
        case okay = "😐"
        case sad = "😔"
        case stressed = "😰"
        
        var displayName: String {
            switch self {
            case .great: return "Great"
            case .good: return "Good"
            case .okay: return "Okay"
            case .sad: return "Sad"
            case .stressed: return "Stressed"
            }
        }
    }
    
    var dateString: String {
        date.formatted(date: .complete, time: .omitted)
    }
}

// Budget Transaction
struct Transaction: Identifiable, Codable {
    var id = UUID()
    var title: String
    var amount: Double
    var category: Category
    var date: Date
    var isIncome: Bool       // true = income, false = expense
    var notes: String?
    
    enum Category: String, Codable, CaseIterable {
        case food = "Food"
        case transport = "Transport"
        case shopping = "Shopping"
        case bills = "Bills"
        case entertainment = "Entertainment"
        case income = "Income"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .food: return "fork.knife"
            case .transport: return "car.fill"
            case .shopping: return "bag.fill"
            case .bills: return "doc.text.fill"
            case .entertainment: return "sparkles"
            case .income: return "dollarsign.circle.fill"
            case .other: return "folder.fill"
            }
        }
    }
    
    // Formatted amount with currency
    var amountString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

// Recipe
struct Recipe: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var mealType: MealType = .lunch
    var prepTime: Int        // In minutes
    var cookTime: Int        // In minutes
    var servings: Int
    var ingredients: [Ingredient]  // Changed to support measurements
    var instructions: [String]
    var recipeDescription: String?  // How to prepare
    var notes: String?
    var isFavorite: Bool = false
    var imageData: Data?  // Optional recipe image
    var createdDate: Date = Date()
    
    enum MealType: String, Codable, CaseIterable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case dessert = "Dessert"
        case snack = "Snack"
        
        var icon: String {
            switch self {
            case .breakfast: return "sunrise.fill"
            case .lunch: return "sun.max.fill"
            case .dinner: return "moon.stars.fill"
            case .dessert: return "birthday.cake.fill"
            case .snack: return "carrot.fill"
            }
        }
    }
    
    struct Ingredient: Identifiable, Codable, Hashable {
        var id = UUID()
        var name: String
        var amount: String  // e.g., "2", "1/2", "1.5"
        var unit: String    // e.g., "cups", "tbsp", "oz"
        
        var displayText: String {
            if amount.isEmpty && unit.isEmpty {
                return name
            } else if amount.isEmpty {
                return "\(unit) \(name)"
            } else if unit.isEmpty {
                return "\(amount) \(name)"
            } else {
                return "\(amount) \(unit) \(name)"
            }
        }
        
        // Scale ingredient for different serving sizes
        func scaled(by factor: Double) -> Ingredient {
            guard let amountValue = parseAmount(amount) else {
                return self
            }
            let scaledAmount = amountValue * factor
            return Ingredient(
                id: id,
                name: name,
                amount: formatAmount(scaledAmount),
                unit: unit
            )
        }
        
        private func parseAmount(_ str: String) -> Double? {
            // Handle fractions like "1/2", "1/4"
            if str.contains("/") {
                let parts = str.split(separator: "/")
                if parts.count == 2,
                   let numerator = Double(parts[0]),
                   let denominator = Double(parts[1]),
                   denominator != 0 {
                    return numerator / denominator
                }
            }
            // Handle decimals and whole numbers
            return Double(str)
        }
        
        private func formatAmount(_ value: Double) -> String {
            // Round to 2 decimal places
            let rounded = round(value * 100) / 100
            
            // If it's a whole number, show it without decimals
            if rounded.truncatingRemainder(dividingBy: 1) == 0 {
                return String(Int(rounded))
            }
            
            // Otherwise show with up to 2 decimal places
            return String(format: "%.2f", rounded).replacingOccurrences(of: #"\.?0+$"#, with: "", options: .regularExpression)
        }
    }
    
    var totalTime: Int {
        prepTime + cookTime
    }
    
    var totalTimeString: String {
        if totalTime < 60 {
            return "\(totalTime) min"
        } else {
            let hours = totalTime / 60
            let minutes = totalTime % 60
            if minutes == 0 {
                return "\(hours)h"
            }
            return "\(hours)h \(minutes)m"
        }
    }
    
    // Get scaled recipe for different serving size
    func scaled(toServings newServings: Int) -> Recipe {
        let factor = Double(newServings) / Double(servings)
        var scaledRecipe = self
        scaledRecipe.servings = newServings
        scaledRecipe.ingredients = ingredients.map { $0.scaled(by: factor) }
        return scaledRecipe
    }
}

// Meal Plan
struct MealPlan: Identifiable, Codable {
    var id = UUID()
    var name: String
    var startDate: Date
    var numberOfDays: Int
    var includeMeals: IncludedMeals  // Which meals to include
    var meals: [Date: DayMeals]  // Meals for each day
    var createdDate: Date
    
    struct IncludedMeals: Codable {
        var breakfast: Bool = true
        var lunch: Bool = true
        var dinner: Bool = true
    }
    
    struct DayMeals: Codable, Hashable {
        var breakfast: RecipeServingPair?
        var lunch: RecipeServingPair?
        var dinner: RecipeServingPair?
    }
    
    struct RecipeServingPair: Codable, Hashable {
        var recipe: Recipe
        var servings: Int  // Custom serving size for this meal
    }
    
    var dateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let endDate = Calendar.current.date(byAdding: .day, value: numberOfDays - 1, to: startDate) ?? startDate
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
    
    var endDate: Date {
        Calendar.current.date(byAdding: .day, value: numberOfDays - 1, to: startDate) ?? startDate
    }
    
    // Get all unique ingredients from the meal plan
    func getAllIngredients() -> [Recipe.Ingredient] {
        var ingredientsMap: [String: Recipe.Ingredient] = [:]
        
        for (_, dayMeals) in meals {
            let recipePairs: [RecipeServingPair?] = [
                dayMeals.breakfast,
                dayMeals.lunch,
                dayMeals.dinner
            ]
            
            for pair in recipePairs.compactMap({ $0 }) {
                let scaledRecipe = pair.recipe.scaled(toServings: pair.servings)
                for ingredient in scaledRecipe.ingredients {
                    let key = "\(ingredient.name)|\(ingredient.unit)"
                    
                    if let existing = ingredientsMap[key] {
                        // Combine amounts if same ingredient and unit
                        let existingAmount = parseAmount(existing.amount) ?? 0
                        let newAmount = parseAmount(ingredient.amount) ?? 0
                        let combined = existingAmount + newAmount
                        ingredientsMap[key] = Recipe.Ingredient(
                            name: ingredient.name,
                            amount: formatAmount(combined),
                            unit: ingredient.unit
                        )
                    } else {
                        ingredientsMap[key] = ingredient
                    }
                }
            }
        }
        
        return Array(ingredientsMap.values).sorted { $0.name < $1.name }
    }
    
    private func parseAmount(_ str: String) -> Double? {
        if str.contains("/") {
            let parts = str.split(separator: "/")
            if parts.count == 2,
               let numerator = Double(parts[0]),
               let denominator = Double(parts[1]),
               denominator != 0 {
                return numerator / denominator
            }
        }
        return Double(str)
    }
    
    private func formatAmount(_ value: Double) -> String {
        let rounded = round(value * 100) / 100
        if rounded.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(rounded))
        }
        return String(format: "%.2f", rounded).replacingOccurrences(of: #"\.?0+$"#, with: "", options: .regularExpression)
    }
    
    // MARK: - Custom Codable Implementation
    enum CodingKeys: String, CodingKey {
        case id, name, startDate, numberOfDays, includeMeals, meals, createdDate
    }
    
    init(id: UUID = UUID(), name: String, startDate: Date, numberOfDays: Int, includeMeals: IncludedMeals = IncludedMeals(), meals: [Date: DayMeals] = [:], createdDate: Date = Date()) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.numberOfDays = numberOfDays
        self.includeMeals = includeMeals
        self.meals = meals
        self.createdDate = createdDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        startDate = try container.decode(Date.self, forKey: .startDate)
        numberOfDays = try container.decode(Int.self, forKey: .numberOfDays)
        includeMeals = (try? container.decode(IncludedMeals.self, forKey: .includeMeals)) ?? IncludedMeals()
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        
        // Decode meals dictionary with Date keys
        let mealsArray = try container.decode([[String: DayMeals]].self, forKey: .meals)
        meals = [:]
        for dict in mealsArray {
            for (dateString, dayMeals) in dict {
                if let date = ISO8601DateFormatter().date(from: dateString) {
                    meals[date] = dayMeals
                }
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(numberOfDays, forKey: .numberOfDays)
        try container.encode(includeMeals, forKey: .includeMeals)
        try container.encode(createdDate, forKey: .createdDate)
        
        // Encode meals dictionary with Date keys as strings
        let formatter = ISO8601DateFormatter()
        let mealsArray = meals.map { date, dayMeals in
            [formatter.string(from: date): dayMeals]
        }
        try container.encode(mealsArray, forKey: .meals)
    }
}

// Shopping List Item
struct ShoppingItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var quantity: String
    var category: ShoppingCategory
    var isChecked: Bool = false
    var addedDate: Date = Date()
    
    enum ShoppingCategory: String, Codable, CaseIterable {
        case produce = "Produce"
        case dairy = "Dairy"
        case meat = "Meat & Seafood"
        case bakery = "Bakery"
        case pantry = "Pantry"
        case frozen = "Frozen"
        case beverages = "Beverages"
        case snacks = "Snacks"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .produce: return "leaf.fill"
            case .dairy: return "drop.fill"
            case .meat: return "fish.fill"
            case .bakery: return "birthday.cake.fill"
            case .pantry: return "cabinet.fill"
            case .frozen: return "snowflake"
            case .beverages: return "cup.and.saucer.fill"
            case .snacks: return "takeoutbag.and.cup.and.straw.fill"
            case .other: return "cart.fill"
            }
        }
    }
}

// Secure Vault Item
struct VaultItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var username: String?
    // Note: password is stored separately in Keychain (not here)
    var url: String?
    // Note: notes are stored separately in Keychain (not here)
    var category: VaultCategory
    var imageData: Data?     // Store attached photo as Data
    var hasPassword: Bool = false  // Flag to indicate password exists in Keychain
    var hasNotes: Bool = false     // Flag to indicate notes exist in Keychain
    
    enum VaultCategory: String, Codable, CaseIterable {
        case login = "Login"
        case card = "Card"
        case note = "Secure Note"
        case identity = "Identity"
        case insurance = "Insurance"
        case pets = "Pets"
        case family = "Family"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .login: return "key.fill"
            case .card: return "creditcard.fill"
            case .note: return "doc.text.fill"
            case .identity: return "person.text.rectangle.fill"
            case .insurance: return "shield.checkered"
            case .pets: return "pawprint.fill"
            case .family: return "person.3.fill"
            case .other: return "folder.fill"
            }
        }
    }
    
    // MARK: - Keychain Integration
    
    /// Retrieve password from Keychain
    var password: String? {
        get {
            guard hasPassword else { return nil }
            return KeychainManager.shared.retrieveVaultPassword(forItemId: id)
        }
    }
    
    /// Retrieve notes from Keychain
    var notes: String? {
        get {
            guard hasNotes else { return nil }
            return KeychainManager.shared.retrieveVaultNotes(forItemId: id)
        }
    }
    
    /// Save password to Keychain
    mutating func setPassword(_ password: String?) {
        if let password = password, !password.isEmpty {
            KeychainManager.shared.saveVaultPassword(password, forItemId: id)
            hasPassword = true
        } else {
            KeychainManager.shared.deleteVaultPassword(forItemId: id)
            hasPassword = false
        }
    }
    
    /// Save notes to Keychain
    mutating func setNotes(_ notes: String?) {
        if let notes = notes, !notes.isEmpty {
            KeychainManager.shared.saveVaultNotes(notes, forItemId: id)
            hasNotes = true
        } else {
            KeychainManager.shared.deleteVaultNotes(forItemId: id)
            hasNotes = false
        }
    }
    
    /// Delete all Keychain data for this item
    func deleteKeychainData() {
        KeychainManager.shared.deleteVaultPassword(forItemId: id)
        KeychainManager.shared.deleteVaultNotes(forItemId: id)
    }
}

// User Settings
struct UserSettings: Codable {
    var dashboardWidgets: [String] = ["events", "habits", "journal", "budget", "recipes"]
    var theme: String = "tealAmber"
    var enableNotifications: Bool = true
    var biometricEnabled: Bool = false
    var hasCompletedOnboarding: Bool = false
}
