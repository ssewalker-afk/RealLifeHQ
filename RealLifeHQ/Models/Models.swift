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
struct Recipe: Identifiable, Codable {
    var id = UUID()
    var name: String
    var category: String
    var prepTime: Int        // In minutes
    var cookTime: Int        // In minutes
    var servings: Int
    var ingredients: [String]
    var instructions: [String]
    var notes: String?
    var isFavorite: Bool = false
    
    var totalTime: Int {
        prepTime + cookTime
    }
    
    var totalTimeString: String {
        "\(totalTime) min"
    }
}

// Meal Plan
struct MealPlan: Identifiable, Codable {
    var id = UUID()
    var name: String
    var startDate: Date
    var numberOfDays: Int
    var meals: [Date: DayMeals]  // Meals for each day
    var createdDate: Date
    
    struct DayMeals: Codable {
        var breakfast: Recipe?
        var lunch: Recipe?
        var dinner: Recipe?
    }
    
    var dateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let endDate = Calendar.current.date(byAdding: .day, value: numberOfDays - 1, to: startDate) ?? startDate
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
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
    var password: String?    // Will be encrypted
    var url: String?
    var notes: String?
    var category: VaultCategory
    var imageData: Data?     // Store attached photo as Data
    
    enum VaultCategory: String, Codable, CaseIterable {
        case login = "Login"
        case card = "Card"
        case note = "Secure Note"
        case identity = "Identity"
        
        var icon: String {
            switch self {
            case .login: return "key.fill"
            case .card: return "creditcard.fill"
            case .note: return "doc.text.fill"
            case .identity: return "person.text.rectangle.fill"
            }
        }
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
