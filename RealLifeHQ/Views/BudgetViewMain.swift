import SwiftUI
import Charts

// MARK: - Budget View (Main) - DEPRECATED - Use BudgetView.swift instead

struct BudgetViewMain_DEPRECATED: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedMonth = Date()
    @State private var showingSetup = false
    
    var body: some View {
        NavigationView {
            Group {
                if !dataManager.budgetSetup.isSetupComplete {
                    setupPromptView
                } else {
                    budgetDashboard
                }
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Budget")
            .sheet(isPresented: $showingSetup) {
                BudgetSetupWizard()
            }
        }
    }
    
    private var setupPromptView: some View {
        VStack(spacing: 24) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(themeManager.currentTheme.primaryColor)
            
            Text("Welcome to Budget")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Set up your monthly budget using the 50/30/20 rule")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                BudgetRuleRow(emoji: "🏠", title: "50% Needs", description: "Essentials like rent, food, utilities")
                BudgetRuleRow(emoji: "🎉", title: "30% Wants", description: "Entertainment, dining out, hobbies")
                BudgetRuleRow(emoji: "💰", title: "20% Savings", description: "Emergency fund, investments, goals")
            }
            .padding()
            .background(themeManager.currentTheme.cardColor)
            .cornerRadius(16)
            .padding(.horizontal)
            
            Button {
                showingSetup = true
            } label: {
                Text("Start Setup")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(themeManager.currentTheme.primaryColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    private var budgetDashboard: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Month Selector
                monthSelector
                
                // Budget Overview Card
                budgetOverviewCard
                
                // Quick Actions
                quickActionsCard
                
                // Spending by Category
                spendingByCategoryCard
                
                // Recent Expenses
                recentExpensesCard
                
                // Monthly Comparison
                monthlyComparisonCard
            }
            .padding()
        }
    }
    
    private var monthSelector: some View {
        HStack {
            Button {
                selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            
            Spacer()
            
            Text(monthString(selectedMonth))
                .font(.headline)
            
            Spacer()
            
            Button {
                selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            
            Button("Today") {
                selectedMonth = Date()
            }
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(themeManager.currentTheme.accentColor)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
    
    private var budgetOverviewCard: some View {
        let monthBudget = dataManager.getMonthlyBudget(for: monthKey(selectedMonth))
        
        return VStack(spacing: 16) {
            HStack {
                Text("Budget Overview")
                    .font(.headline)
                Spacer()
                Menu {
                    NavigationLink(destination: BudgetSetupWizard()) {
                        Label("Edit Budget", systemImage: "slider.horizontal.3")
                    }
                    NavigationLink(destination: ManageCategoriesView()) {
                        Label("Manage Categories", systemImage: "folder")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
            
            HStack(spacing: 40) {
                BudgetStatItem(
                    title: "Budget",
                    amount: monthBudget.totalBudget,
                    color: .blue
                )
                
                BudgetStatItem(
                    title: "Spent",
                    amount: monthBudget.totalSpent,
                    color: .red
                )
                
                BudgetStatItem(
                    title: "Remaining",
                    amount: monthBudget.remaining,
                    color: .green
                )
            }
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                        .cornerRadius(6)
                    
                    Rectangle()
                        .fill(progressColor(monthBudget.spentPercentage))
                        .frame(width: geo.size.width * min(monthBudget.spentPercentage / 100, 1), height: 12)
                        .cornerRadius(6)
                }
            }
            .frame(height: 12)
            
            Text("\(Int(monthBudget.spentPercentage))% of budget used")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
    
    private var quickActionsCard: some View {
        HStack(spacing: 12) {
            NavigationLink(destination: AddExpenseView()) {
                QuickActionButton_DEPRECATED(
                    icon: "plus.circle.fill",
                    title: "Add Expense",
                    color: themeManager.currentTheme.primaryColor
                )
            }
            
            NavigationLink(destination: RecurringExpensesView()) {
                QuickActionButton_DEPRECATED(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Recurring",
                    color: themeManager.currentTheme.accentColor
                )
            }
            
            NavigationLink(destination: AllExpensesView()) {
                QuickActionButton_DEPRECATED(
                    icon: "list.bullet",
                    title: "All Expenses",
                    color: .blue
                )
            }
        }
    }
    
    private var spendingByCategoryCard: some View {
        let monthBudget = dataManager.getMonthlyBudget(for: monthKey(selectedMonth))
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Spending by Category")
                .font(.headline)
            
            if monthBudget.categoryBreakdown.isEmpty {
                Text("No expenses this month")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                // Pie Chart would go here
                ForEach(Array(monthBudget.categoryBreakdown.keys), id: \.id) { category in
                    if let spent = monthBudget.categoryBreakdown[category], spent > 0 {
                        CategorySpendingRow(
                            category: category,
                            spent: spent,
                            limit: category.limit
                        )
                    }
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
    
    private var recentExpensesCard: some View {
        let recentExpenses = dataManager.expenses
            .filter { $0.monthKey == monthKey(selectedMonth) }
            .sorted { $0.date > $1.date }
            .prefix(5)
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Expenses")
                    .font(.headline)
                Spacer()
                NavigationLink(destination: AllExpensesView()) {
                    Text("See All")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
            
            if recentExpenses.isEmpty {
                Text("No expenses yet")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(Array(recentExpenses)) { expense in
                    ExpenseRow_DEPRECATED(expense: expense)
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
    
    private var monthlyComparisonCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("6-Month Trend")
                .font(.headline)
            
            // Simple bar chart showing last 6 months
            let months = getLast6Months()
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(months, id: \.self) { month in
                    let budget = dataManager.getMonthlyBudget(for: monthKey(month))
                    VStack(spacing: 4) {
                        Rectangle()
                            .fill(themeManager.currentTheme.primaryColor)
                            .frame(width: 40, height: max(CGFloat(budget.totalSpent / 100), 10))
                        
                        Text(monthAbbrev(month))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 150)
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
    
    // Helper functions
    private func monthString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func monthKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }
    
    private func monthAbbrev(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
    
    private func progressColor(_ percentage: Double) -> Color {
        if percentage >= 90 { return .red }
        if percentage >= 75 { return .orange }
        return .green
    }
    
    private func getLast6Months() -> [Date] {
        var months: [Date] = []
        for i in 0..<6 {
            if let month = Calendar.current.date(byAdding: .month, value: -i, to: selectedMonth) {
                months.append(month)
            }
        }
        return months.reversed()
    }
}

// MARK: - Supporting Views

struct BudgetRuleRow: View {
    let emoji: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.largeTitle)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct BudgetStatItem: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("$\(Int(amount))")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

struct CategorySpendingRow: View {
    let category: BudgetCategory
    let spent: Double
    let limit: Double
    @EnvironmentObject var themeManager: ThemeManager
    
    private var percentage: Double {
        limit > 0 ? (spent / limit) * 100 : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(colorFromString(category.color))
                
                Text(category.name)
                    .font(.subheadline)
                
                Spacer()
                
                Text("$\(Int(spent)) / $\(Int(limit))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(colorFromString(category.color))
                        .frame(width: geo.size.width * min(percentage / 100, 1), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
    }
    
    private func colorFromString(_ string: String) -> Color {
        switch string.lowercased() {
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        case "red": return .red
        case "orange": return .orange
        case "pink": return .pink
        case "teal": return .teal
        default: return themeManager.currentTheme.primaryColor
        }
    }
}


