import Foundation
import Combine

// MARK: - Budget Models

// Budget Category with customization
struct BudgetCategory: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var icon: String
    var color: String
    var limit: Double
    var type: CategoryType // Needs, Wants, Savings
    
    enum CategoryType: String, Codable, CaseIterable {
        case needs = "Needs"
        case wants = "Wants"
        case savings = "Savings"
        
        var color: String {
            switch self {
            case .needs: return "blue"
            case .wants: return "purple"
            case .savings: return "green"
            }
        }
    }
}

// Expense with category
struct Expense: Identifiable, Codable {
    var id = UUID()
    var title: String
    var amount: Double
    var category: BudgetCategory
    var date: Date
    var notes: String?
    var isRecurring: Bool = false
    var recurringId: UUID? // Links to RecurringExpense
    
    var monthKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }
}

// Recurring Expense
struct RecurringExpense: Identifiable, Codable {
    var id = UUID()
    var title: String
    var amount: Double
    var category: BudgetCategory
    var frequency: Frequency
    var startDate: Date
    var endDate: Date?
    var lastGenerated: Date?
    var isActive: Bool = true
    
    enum Frequency: String, Codable, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case biweekly = "Bi-Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
        
        var icon: String {
            switch self {
            case .daily: return "calendar"
            case .weekly: return "calendar.badge.clock"
            case .biweekly: return "calendar.badge.clock"
            case .monthly: return "calendar.circle"
            case .yearly: return "calendar.badge.exclamationmark"
            }
        }
        
        var component: Calendar.Component {
            switch self {
            case .daily: return .day
            case .weekly: return .weekOfYear
            case .biweekly: return .weekOfYear
            case .monthly: return .month
            case .yearly: return .year
            }
        }
    }
}

// Budget Setup (50/30/20 rule)
struct BudgetSetup: Codable {
    var monthlyIncome: Double
    var needsPercentage: Double = 50
    var wantsPercentage: Double = 30
    var savingsPercentage: Double = 20
    var isSetupComplete: Bool = false
    
    var needsAmount: Double {
        monthlyIncome * (needsPercentage / 100)
    }
    
    var wantsAmount: Double {
        monthlyIncome * (wantsPercentage / 100)
    }
    
    var savingsAmount: Double {
        monthlyIncome * (savingsPercentage / 100)
    }
}

// Monthly Budget Summary
struct MonthlyBudget {
    let month: String
    let totalBudget: Double
    let totalSpent: Double
    let remaining: Double
    let categoryBreakdown: [BudgetCategory: Double]
    
    var spentPercentage: Double {
        totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0
    }
}

// Spending Trend Data
struct SpendingTrend {
    let month: String
    let amount: Double
    let category: BudgetCategory?
}
