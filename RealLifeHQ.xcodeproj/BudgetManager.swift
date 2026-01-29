//
//  BudgetManager.swift
//  RealLifeHQ
//
//  Created by Sarah Walker on 1/16/26.
//

import Foundation
import SwiftUI

@MainActor
@Observable
class BudgetManager {
    static let shared = BudgetManager()
    
    var budgetSetup: BudgetSetup
    var categories: [BudgetCategory]
    var expenses: [Expense]
    
    private let setupKey = "budgetSetup"
    private let categoriesKey = "budgetCategories"
    private let expensesKey = "budgetExpenses"
    
    init() {
        // Load budget setup
        if let data = UserDefaults.standard.data(forKey: setupKey),
           let decoded = try? JSONDecoder().decode(BudgetSetup.self, from: data) {
            self.budgetSetup = decoded
        } else {
            self.budgetSetup = BudgetSetup()
        }
        
        // Load categories
        if let data = UserDefaults.standard.data(forKey: categoriesKey),
           let decoded = try? JSONDecoder().decode([BudgetCategory].self, from: data) {
            self.categories = decoded
        } else {
            self.categories = []
        }
        
        // Load expenses
        if let data = UserDefaults.standard.data(forKey: expensesKey),
           let decoded = try? JSONDecoder().decode([Expense].self, from: data) {
            self.expenses = decoded
        } else {
            self.expenses = []
        }
        
        // Generate recurring expenses if needed
        generateRecurringExpenses()
    }
    
    // MARK: - Save Methods
    
    func saveBudgetSetup() {
        if let encoded = try? JSONEncoder().encode(budgetSetup) {
            UserDefaults.standard.set(encoded, forKey: setupKey)
        }
    }
    
    func saveCategories() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: categoriesKey)
        }
    }
    
    func saveExpenses() {
        if let encoded = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: expensesKey)
        }
    }
    
    // MARK: - Budget Setup
    
    func completeBudgetSetup(income: Double, needs: Double, wants: Double, savings: Double) {
        budgetSetup.monthlyIncome = income
        budgetSetup.needsPercentage = needs
        budgetSetup.wantsPercentage = wants
        budgetSetup.savingsPercentage = savings
        budgetSetup.isCompleted = true
        saveBudgetSetup()
        
        // Create default categories if none exist
        if categories.isEmpty {
            createDefaultCategories()
        }
    }
    
    func createDefaultCategories() {
        let defaultCategories: [BudgetCategory] = [
            // Needs
            BudgetCategory(name: "Housing", icon: "house.fill", color: "FF5733", limit: budgetSetup.needsAmount * 0.4, type: .needs),
            BudgetCategory(name: "Groceries", icon: "cart.fill", color: "FF6B6B", limit: budgetSetup.needsAmount * 0.3, type: .needs),
            BudgetCategory(name: "Transportation", icon: "car.fill", color: "FF8C8C", limit: budgetSetup.needsAmount * 0.2, type: .needs),
            BudgetCategory(name: "Utilities", icon: "bolt.fill", color: "FFA5A5", limit: budgetSetup.needsAmount * 0.1, type: .needs),
            
            // Wants
            BudgetCategory(name: "Dining Out", icon: "fork.knife", color: "FFA500", limit: budgetSetup.wantsAmount * 0.4, type: .wants),
            BudgetCategory(name: "Entertainment", icon: "ticket.fill", color: "FFB84D", limit: budgetSetup.wantsAmount * 0.3, type: .wants),
            BudgetCategory(name: "Shopping", icon: "bag.fill", color: "FFCA7A", limit: budgetSetup.wantsAmount * 0.3, type: .wants),
            
            // Savings
            BudgetCategory(name: "Emergency Fund", icon: "shield.fill", color: "4CAF50", limit: budgetSetup.savingsAmount * 0.5, type: .savings),
            BudgetCategory(name: "Investments", icon: "chart.line.uptrend.xyaxis", color: "66BB6A", limit: budgetSetup.savingsAmount * 0.3, type: .savings),
            BudgetCategory(name: "Goals", icon: "flag.fill", color: "81C784", limit: budgetSetup.savingsAmount * 0.2, type: .savings),
        ]
        
        categories = defaultCategories
        saveCategories()
    }
    
    // MARK: - Category Management
    
    func addCategory(_ category: BudgetCategory) {
        categories.append(category)
        saveCategories()
    }
    
    func updateCategory(_ category: BudgetCategory) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            saveCategories()
        }
    }
    
    func deleteCategory(_ category: BudgetCategory) {
        categories.removeAll { $0.id == category.id }
        // Also remove expenses in this category
        expenses.removeAll { $0.category.id == category.id }
        saveCategories()
        saveExpenses()
    }
    
    // MARK: - Expense Management
    
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        saveExpenses()
    }
    
    func updateExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense
            saveExpenses()
        }
    }
    
    func deleteExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
        saveExpenses()
    }
    
    // MARK: - Recurring Expenses
    
    func generateRecurringExpenses() {
        let today = Date()
        let calendar = Calendar.current
        
        // Find all recurring expenses
        let recurringExpenses = expenses.filter { $0.isRecurring }
        
        for expense in recurringExpenses {
            guard let schedule = expense.recurringSchedule else { continue }
            
            // Check if we need to generate a new expense
            var currentDate = schedule.startDate
            
            while currentDate <= today {
                // Check if end date has passed
                if let endDate = schedule.endDate, currentDate > endDate {
                    break
                }
                
                // Check if expense already exists for this date
                let existingExpense = expenses.contains { existingExp in
                    !existingExp.isRecurring &&
                    existingExp.category.id == expense.category.id &&
                    existingExp.amount == expense.amount &&
                    calendar.isDate(existingExp.date, inSameDayAs: currentDate)
                }
                
                // Create expense if it doesn't exist
                if !existingExpense && currentDate != expense.date {
                    let newExpense = Expense(
                        amount: expense.amount,
                        category: expense.category,
                        date: currentDate,
                        note: expense.note + " (Recurring)",
                        isRecurring: false
                    )
                    expenses.append(newExpense)
                }
                
                // Move to next occurrence
                if let nextDate = schedule.frequency.nextDate(from: currentDate) {
                    currentDate = nextDate
                } else {
                    break
                }
            }
        }
        
        saveExpenses()
    }
    
    // MARK: - Calculations
    
    func totalSpent(for month: Date) -> Double {
        expensesForMonth(month).reduce(0) { $0 + $1.amount }
    }
    
    func totalSpent(for category: BudgetCategory, in month: Date) -> Double {
        expensesForMonth(month)
            .filter { $0.category.id == category.id }
            .reduce(0) { $0 + $1.amount }
    }
    
    func totalSpent(for type: BudgetCategory.CategoryType, in month: Date) -> Double {
        let typeCategories = categories.filter { $0.type == type }
        return typeCategories.reduce(0) { total, category in
            total + totalSpent(for: category, in: month)
        }
    }
    
    func expensesForMonth(_ month: Date) -> [Expense] {
        let calendar = Calendar.current
        return expenses.filter { expense in
            calendar.isDate(expense.date, equalTo: month, toGranularity: .month)
        }
    }
    
    func expensesForCategory(_ category: BudgetCategory, in month: Date) -> [Expense] {
        expensesForMonth(month).filter { $0.category.id == category.id }
    }
    
    func remainingBudget(for month: Date) -> Double {
        budgetSetup.monthlyIncome - totalSpent(for: month)
    }
    
    func categoryProgress(_ category: BudgetCategory, in month: Date) -> Double {
        let spent = totalSpent(for: category, in: month)
        guard category.limit > 0 else { return 0 }
        return min(spent / category.limit, 1.0)
    }
    
    // MARK: - Chart Data
    
    func spendingByCategory(for month: Date) -> [(category: BudgetCategory, amount: Double)] {
        categories.map { category in
            (category: category, amount: totalSpent(for: category, in: month))
        }.filter { $0.amount > 0 }
    }
    
    func spendingByMonth(for categoryType: BudgetCategory.CategoryType? = nil) -> [(month: Date, amount: Double)] {
        let calendar = Calendar.current
        let currentDate = Date()
        
        // Get last 6 months
        var months: [Date] = []
        for i in 0..<6 {
            if let month = calendar.date(byAdding: .month, value: -i, to: currentDate) {
                months.append(calendar.startOfMonth(for: month))
            }
        }
        
        return months.reversed().map { month in
            let amount: Double
            if let type = categoryType {
                amount = totalSpent(for: type, in: month)
            } else {
                amount = totalSpent(for: month)
            }
            return (month: month, amount: amount)
        }
    }
}

// MARK: - Calendar Extension

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}
