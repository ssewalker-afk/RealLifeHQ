//
//  BudgetModels.swift
//  RealLifeHQ
//
//  Created by Sarah Walker on 1/16/26.
//

import Foundation
import SwiftUI

// MARK: - Budget Category

struct BudgetCategory: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var icon: String
    var color: String // Store as hex string
    var limit: Double
    var type: CategoryType
    
    enum CategoryType: String, Codable, CaseIterable {
        case needs = "Needs"
        case wants = "Wants"
        case savings = "Savings"
        
        var color: Color {
            switch self {
            case .needs: return .red
            case .wants: return .orange
            case .savings: return .green
            }
        }
    }
    
    init(id: UUID = UUID(), name: String, icon: String, color: String, limit: Double, type: CategoryType) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.limit = limit
        self.type = type
    }
    
    var colorValue: Color {
        Color(hex: color) ?? .blue
    }
}

// MARK: - Expense

struct Expense: Identifiable, Codable {
    let id: UUID
    var amount: Double
    var category: BudgetCategory
    var date: Date
    var note: String
    var isRecurring: Bool
    var recurringSchedule: RecurringSchedule?
    
    init(id: UUID = UUID(), amount: Double, category: BudgetCategory, date: Date = Date(), note: String = "", isRecurring: Bool = false, recurringSchedule: RecurringSchedule? = nil) {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note
        self.isRecurring = isRecurring
        self.recurringSchedule = recurringSchedule
    }
}

// MARK: - Recurring Schedule

struct RecurringSchedule: Codable {
    var frequency: Frequency
    var startDate: Date
    var endDate: Date?
    
    enum Frequency: String, Codable, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case biweekly = "Every 2 Weeks"
        case monthly = "Monthly"
        case yearly = "Yearly"
        
        func nextDate(from date: Date) -> Date? {
            let calendar = Calendar.current
            switch self {
            case .daily:
                return calendar.date(byAdding: .day, value: 1, to: date)
            case .weekly:
                return calendar.date(byAdding: .weekOfYear, value: 1, to: date)
            case .biweekly:
                return calendar.date(byAdding: .weekOfYear, value: 2, to: date)
            case .monthly:
                return calendar.date(byAdding: .month, value: 1, to: date)
            case .yearly:
                return calendar.date(byAdding: .year, value: 1, to: date)
            }
        }
    }
}

// MARK: - Budget Setup

struct BudgetSetup: Codable {
    var monthlyIncome: Double
    var needsPercentage: Double // Default 50%
    var wantsPercentage: Double // Default 30%
    var savingsPercentage: Double // Default 20%
    var isCompleted: Bool
    
    init(monthlyIncome: Double = 0, needsPercentage: Double = 50, wantsPercentage: Double = 30, savingsPercentage: Double = 20, isCompleted: Bool = false) {
        self.monthlyIncome = monthlyIncome
        self.needsPercentage = needsPercentage
        self.wantsPercentage = wantsPercentage
        self.savingsPercentage = savingsPercentage
        self.isCompleted = isCompleted
    }
    
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

// MARK: - Color Extension for Hex

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "%02lX%02lX%02lX",
                      lroundf(r * 255),
                      lroundf(g * 255),
                      lroundf(b * 255))
    }
}
