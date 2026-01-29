import SwiftUI
import Charts

// MARK: - Main Budget View - DEPRECATED - Use BudgetView.swift instead

struct BudgetViewNew_DEPRECATED: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var showingSetupWizard = false
    
    private var monthKey: String {
        String(format: "%04d-%02d", selectedYear, selectedMonth)
    }
    
    var body: some View {
        NavigationView {
            Group {
                if !dataManager.budgetSetup.isSetupComplete {
                    setupRequiredView
                } else {
                    budgetMainView
                }
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Budget")
            .sheet(isPresented: $showingSetupWizard) {
                BudgetSetupWizard()
            }
        }
    }
    
    private var setupRequiredView: some View {
        VStack(spacing: 20) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(themeManager.currentTheme.primaryColor.opacity(0.5))
            
            Text("Budget Setup Required")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Set up your monthly budget using the 50/30/20 rule to start tracking your finances")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Start Budget Setup") {
                showingSetupWizard = true
            }
            .buttonStyle(.borderedProminent)
            .tint(themeManager.currentTheme.primaryColor)
        }
        .padding()
    }
    
    private var budgetMainView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Month Selector
                monthSelector
                
                // Budget Overview Card
                budgetOverviewCard
                
                // Quick Actions
                quickActionsView
                
                // Spending by Category (Pie Chart)
                spendingPieChart
                
                // Recent Expenses
                recentExpensesView
                
                // Monthly Comparison (Bar Chart)
                monthlyComparisonChart
            }
            .padding()
        }
    }
    
    private var monthSelector: some View {
        HStack {
            Button {
                changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            
            Spacer()
            
            Text(monthYearString)
                .font(.headline)
            
            Spacer()
            
            Button {
                changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            
            Button {
                let now = Date()
                selectedMonth = Calendar.current.component(.month, from: now)
                selectedYear = Calendar.current.component(.year, from: now)
            } label: {
                Text("Today")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(themeManager.currentTheme.accentColor)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
    
    private var budgetOverviewCard: some View {
        let budget = dataManager.getMonthlyBudget(for: monthKey)
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Budget Overview")
                .font(.headline)
            
            // Total Budget
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Budget")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(budget.totalBudget.formatted(.currency(code: "USD")))
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Spent")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(budget.totalSpent.formatted(.currency(code: "USD")))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(budget.remaining >= 0 ? .green : .red)
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                        .cornerRadius(6)
                    
                    Rectangle()
                        .fill(budget.remaining >= 0 ? themeManager.currentTheme.primaryColor : Color.red)
                        .frame(width: min(geometry.size.width * (budget.spentPercentage / 100), geometry.size.width), height: 12)
                        .cornerRadius(6)
                }
            }
            .frame(height: 12)
            
            // Remaining
            HStack {
                Text("Remaining")
                    .font(.subheadline)
                Spacer()
                Text(budget.remaining.formatted(.currency(code: "USD")))
                    .font(.headline)
                    .foregroundColor(budget.remaining >= 0 ? .green : .red)
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
    
    private var quickActionsView: some View {
        HStack(spacing: 12) {
            NavigationLink(destination: AddExpenseView()) {
                QuickActionButton_DEPRECATED(icon: "plus.circle.fill", title: "Add Expense", color: themeManager.currentTheme.primaryColor)
            }
            
            NavigationLink(destination: ManageCategoriesView()) {
                QuickActionButton_DEPRECATED(icon: "folder.fill", title: "Categories", color: themeManager.currentTheme.accentColor)
            }
            
            NavigationLink(destination: RecurringExpensesView()) {
                QuickActionButton_DEPRECATED(icon: "repeat.circle.fill", title: "Recurring", color: .orange)
            }
            
            Button {
                showingSetupWizard = true
            } label: {
                QuickActionButton_DEPRECATED(icon: "gear", title: "Setup", color: .gray)
            }
        }
    }
    
    private var spendingPieChart: some View {
        let budget = dataManager.getMonthlyBudget(for: monthKey)
        let hasData = budget.totalSpent > 0
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Spending by Category")
                .font(.headline)
            
            if hasData {
                Chart {
                    ForEach(Array(budget.categoryBreakdown.keys), id: \.id) { category in
                        if let amount = budget.categoryBreakdown[category], amount > 0 {
                            SectorMark(
                                angle: .value("Amount", amount),
                                innerRadius: .ratio(0.5),
                                angularInset: 1.5
                            )
                            .foregroundStyle(by: .value("Category", category.name))
                            .annotation(position: .overlay) {
                                Text(category.icon)
                                    .font(.title2)
                            }
                        }
                    }
                }
                .frame(height: 250)
                
                // Legend
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(Array(budget.categoryBreakdown.keys.sorted(by: { budget.categoryBreakdown[$0] ?? 0 > budget.categoryBreakdown[$1] ?? 0 })), id: \.id) { category in
                        if let amount = budget.categoryBreakdown[category], amount > 0 {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color(category.color))
                                    .frame(width: 8, height: 8)
                                Text(category.name)
                                    .font(.caption)
                                Spacer()
                                Text(amount.formatted(.currency(code: "USD")))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            } else {
                Text("No expenses this month")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
    
    private var recentExpensesView: some View {
        VStack(alignment: .leading, spacing: 12) {
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
            
            let monthExpenses = dataManager.expenses
                .filter { $0.monthKey == monthKey }
                .sorted { $0.date > $1.date }
                .prefix(5)
            
            if monthExpenses.isEmpty {
                Text("No expenses yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(Array(monthExpenses), id: \.id) { expense in
                    ExpenseRow_DEPRECATED(expense: expense)
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
    
    private var monthlyComparisonChart: some View {
        let last6Months = getLast6Months()
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("6-Month Spending Trend")
                .font(.headline)
            
            Chart {
                ForEach(last6Months, id: \.month) { data in
                    BarMark(
                        x: .value("Month", data.month),
                        y: .value("Amount", data.amount)
                    )
                    .foregroundStyle(themeManager.currentTheme.primaryColor)
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
    
    // Helper Methods
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let components = DateComponents(year: selectedYear, month: selectedMonth)
        return formatter.string(from: Calendar.current.date(from: components) ?? Date())
    }
    
    private func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth)) ?? Date()) {
            selectedMonth = Calendar.current.component(.month, from: newDate)
            selectedYear = Calendar.current.component(.year, from: newDate)
        }
    }
    
    private func getLast6Months() -> [SpendingTrend] {
        var trends: [SpendingTrend] = []
        let calendar = Calendar.current
        
        for i in 0..<6 {
            if let date = calendar.date(byAdding: .month, value: -i, to: Date()) {
                let month = calendar.component(.month, from: date)
                let year = calendar.component(.year, from: date)
                let key = String(format: "%04d-%02d", year, month)
                
                let monthExpenses = dataManager.expenses.filter { $0.monthKey == key }
                let total = monthExpenses.reduce(0) { $0 + $1.amount }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM"
                let monthName = formatter.string(from: date)
                
                trends.append(SpendingTrend(month: monthName, amount: total, category: nil))
            }
        }
        
        return trends.reversed()
    }
}

// MARK: - Quick Action Button - DEPRECATED

struct QuickActionButton_DEPRECATED: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Expense Row - DEPRECATED

struct ExpenseRow_DEPRECATED: View {
    let expense: Expense
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: expense.category.icon)
                .foregroundColor(Color(expense.category.color))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 4) {
                    Text(expense.category.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if expense.isRecurring {
                        Image(systemName: "repeat.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(expense.amount.formatted(.currency(code: "USD")))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// Continued in BudgetViewPart2.swift...
