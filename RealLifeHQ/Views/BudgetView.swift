import SwiftUI
import Charts

// MARK: - Main Budget View

struct BudgetView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Group {
            if !dataManager.budgetSetup.isSetupComplete {
                BudgetSetupWizard()
            } else {
                BudgetDashboard()
            }
        }
    }
}

#Preview {
    BudgetView()
        .environmentObject(DataManager())
        .environmentObject(ThemeManager())
}

// MARK: - Commitment Template

private struct CommitmentTemplate: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: String
    let type: BudgetCategory.CategoryType
}

// MARK: - Income Row (local state for wizard)

private struct IncomeRow: Identifiable {
    var id = UUID()
    var name: String = "Primary Income"
    var amountText: String = ""
    var amount: Double { Double(amountText) ?? 0 }
}

// MARK: - Budget Setup Wizard (5 steps)

struct BudgetSetupWizard: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager

    @State private var incomeRows: [IncomeRow] = [IncomeRow()]
    @State private var selectedCommitments: Set<String> = []
    @State private var needsPercent: Double = 50
    @State private var wantsPercent: Double = 30
    @State private var savingsPercent: Double = 20
    @State private var savingsGoals: [SavingsGoal] = []
    @State private var newGoalName: String = ""
    @State private var newGoalAmount: String = ""
    @State private var currentPage = 0

    private let totalPages = 5

    private let commitmentTemplates: [CommitmentTemplate] = [
        CommitmentTemplate(name: "Rent / Mortgage",  icon: "house.fill",             color: "blue",   type: .needs),
        CommitmentTemplate(name: "Car Payment",       icon: "car.fill",               color: "blue",   type: .needs),
        CommitmentTemplate(name: "Student Loans",     icon: "book.fill",              color: "purple", type: .needs),
        CommitmentTemplate(name: "Childcare",         icon: "figure.and.child.holdinghands", color: "pink", type: .needs),
        CommitmentTemplate(name: "Utilities",         icon: "bolt.fill",              color: "orange", type: .needs),
        CommitmentTemplate(name: "Groceries",         icon: "cart.fill",              color: "orange", type: .needs),
        CommitmentTemplate(name: "Internet / Phone",  icon: "wifi",                   color: "teal",   type: .needs),
        CommitmentTemplate(name: "Subscriptions",     icon: "play.rectangle.fill",    color: "blue",   type: .wants),
        CommitmentTemplate(name: "Dining Out",        icon: "fork.knife",             color: "pink",   type: .wants),
        CommitmentTemplate(name: "Entertainment",     icon: "film.fill",              color: "purple", type: .wants),
        CommitmentTemplate(name: "Gym / Fitness",     icon: "figure.run",             color: "green",  type: .wants),
        CommitmentTemplate(name: "Shopping",          icon: "bag.fill",               color: "purple", type: .wants),
    ]

    private var totalIncome: Double {
        incomeRows.reduce(0.0) { $0 + $1.amount }
    }

    private var canAdvance: Bool {
        switch currentPage {
        case 0: return totalIncome > 0
        case 2: return abs(needsPercent + wantsPercent + savingsPercent - 100) < 0.01
        default: return true
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Progress dots
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Circle()
                        .fill(index <= currentPage
                              ? themeManager.currentTheme.primaryColor
                              : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 4)

            Text("Step \(currentPage + 1) of \(totalPages)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)

            Group {
                switch currentPage {
                case 0: incomePageView
                case 1: commitmentsPageView
                case 2: budgetSplitPageView
                case 3: savingsGoalsPageView
                default: summaryPageView
                }
            }
            .animation(.easeInOut(duration: 0.2), value: currentPage)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack {
                if currentPage > 0 {
                    Button("Back") {
                        withAnimation { currentPage -= 1 }
                    }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                }
                Spacer()
                if currentPage < totalPages - 1 {
                    Button("Next") {
                        withAnimation { currentPage += 1 }
                    }
                    .disabled(!canAdvance)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(canAdvance ? themeManager.currentTheme.primaryColor : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("Budget Setup")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Page 1: Income

    private var incomePageView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(themeManager.currentTheme.primaryColor)

                Text("Monthly Take-Home Income")
                    .font(.title2).fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Add all sources of monthly income after taxes.")
                    .font(.subheadline).foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 12) {
                    ForEach($incomeRows) { $row in
                        HStack(spacing: 10) {
                            TextField("Source name", text: $row.name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            TextField("$0", text: $row.amountText)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 100)

                            if incomeRows.count > 1 {
                                Button {
                                    incomeRows.removeAll { $0.id == row.id }
                                } label: {
                                    Image(systemName: "minus.circle.fill").foregroundColor(.red)
                                }
                            }
                        }
                    }

                    Button {
                        incomeRows.append(IncomeRow(name: "Additional Income"))
                    } label: {
                        Label("Add Income Source", systemImage: "plus.circle.fill")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                }
                .padding()
                .background(themeManager.currentTheme.cardColor)
                .cornerRadius(12)

                if totalIncome > 0 {
                    HStack {
                        Text("Total Monthly Income")
                        Spacer()
                        Text("$\(totalIncome, specifier: "%.2f")")
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                    .padding()
                    .background(themeManager.currentTheme.primaryColor.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
    }

    // MARK: - Page 2: Commitments

    private var commitmentsPageView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(themeManager.currentTheme.primaryColor)

                Text("Monthly Commitments")
                    .font(.title2).fontWeight(.bold)

                Text("Select your regular expenses. These become your budget categories.")
                    .font(.subheadline).foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 0) {
                    ForEach(commitmentTemplates) { template in
                        Button {
                            if selectedCommitments.contains(template.name) {
                                selectedCommitments.remove(template.name)
                            } else {
                                selectedCommitments.insert(template.name)
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: template.icon)
                                    .foregroundColor(colorFromString(template.color))
                                    .frame(width: 28)

                                Text(template.name).foregroundColor(.primary)
                                Spacer()

                                Text(template.type.rawValue)
                                    .font(.caption).foregroundColor(.secondary)

                                Image(systemName: selectedCommitments.contains(template.name)
                                      ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedCommitments.contains(template.name)
                                                     ? themeManager.currentTheme.primaryColor
                                                     : Color.gray.opacity(0.4))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        Divider().padding(.leading, 56)
                    }
                }
                .background(themeManager.currentTheme.cardColor)
                .cornerRadius(12)

                Text("You can always add or remove categories later.")
                    .font(.caption).foregroundColor(.secondary)
            }
            .padding()
        }
    }

    // MARK: - Page 3: Budget Split

    private var budgetSplitPageView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Budget Split")
                    .font(.title2).fontWeight(.bold)

                Text("The 50/30/20 rule is a great starting point. Adjust sliders to fit your life.")
                    .font(.subheadline).foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 16) {
                    budgetRuleRow(title: "Needs", percent: $needsPercent, color: .blue,
                                  description: "Housing, food, utilities, transportation")
                    Divider()
                    budgetRuleRow(title: "Wants", percent: $wantsPercent, color: .purple,
                                  description: "Entertainment, dining out, shopping")
                    Divider()
                    budgetRuleRow(title: "Savings", percent: $savingsPercent, color: .green,
                                  description: "Emergency fund, goals, investments")
                }
                .padding()
                .background(themeManager.currentTheme.cardColor)
                .cornerRadius(12)

                let total = needsPercent + wantsPercent + savingsPercent
                HStack {
                    Text("Total")
                    Spacer()
                    Text("\(Int(total))%")
                        .fontWeight(.bold)
                        .foregroundColor(abs(total - 100) < 0.01 ? .green : .red)
                }
                .padding()
                .background(themeManager.currentTheme.cardColor)
                .cornerRadius(10)

                if totalIncome > 0 {
                    VStack(spacing: 8) {
                        summaryRow(title: "Needs (\(Int(needsPercent))%)",   amount: totalIncome * needsPercent / 100,   color: .blue)
                        summaryRow(title: "Wants (\(Int(wantsPercent))%)",   amount: totalIncome * wantsPercent / 100,   color: .purple)
                        summaryRow(title: "Savings (\(Int(savingsPercent))%)", amount: totalIncome * savingsPercent / 100, color: .green)
                    }
                    .padding()
                    .background(themeManager.currentTheme.cardColor)
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }

    // MARK: - Page 4: Savings Goals

    private var savingsGoalsPageView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "target")
                    .font(.system(size: 60))
                    .foregroundColor(themeManager.currentTheme.primaryColor)

                Text("Savings Goals")
                    .font(.title2).fontWeight(.bold)

                Text("What are you saving for? Set goals and track your progress.")
                    .font(.subheadline).foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                if !savingsGoals.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(savingsGoals.indices, id: \.self) { i in
                            HStack(spacing: 12) {
                                Image(systemName: savingsGoals[i].icon)
                                    .foregroundColor(.green).frame(width: 28)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(savingsGoals[i].name).font(.subheadline)
                                    Text("Target: $\(savingsGoals[i].targetAmount, specifier: "%.0f")")
                                        .font(.caption).foregroundColor(.secondary)
                                }
                                Spacer()
                                Button { savingsGoals.remove(at: i) } label: {
                                    Image(systemName: "minus.circle.fill").foregroundColor(.red)
                                }
                            }
                            .padding(.horizontal, 16).padding(.vertical, 12)
                            if i < savingsGoals.count - 1 {
                                Divider().padding(.leading, 56)
                            }
                        }
                    }
                    .background(themeManager.currentTheme.cardColor)
                    .cornerRadius(12)
                }

                let quickGoals: [(String, String)] = [
                    ("Emergency Fund", "shield.fill"), ("Vacation", "airplane"),
                    ("New Car", "car.fill"), ("Home Down Payment", "house.fill"),
                    ("Retirement", "chart.line.uptrend.xyaxis")
                ]
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Add").font(.caption).foregroundColor(.secondary)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(quickGoals, id: \.0) { name, icon in
                            if !savingsGoals.contains(where: { $0.name == name }) {
                                Button {
                                    savingsGoals.append(SavingsGoal(name: name, targetAmount: 1000, icon: icon))
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: icon).font(.caption)
                                        Text(name).font(.caption).lineLimit(1)
                                    }
                                    .padding(.horizontal, 10).padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(themeManager.currentTheme.primaryColor.opacity(0.1))
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                }

                VStack(spacing: 10) {
                    Text("Custom Goal")
                        .font(.caption).foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack(spacing: 8) {
                        TextField("Goal name", text: $newGoalName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("$Target", text: $newGoalAmount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 90)
                        Button {
                            if let amount = Double(newGoalAmount), !newGoalName.isEmpty {
                                savingsGoals.append(SavingsGoal(name: newGoalName, targetAmount: amount))
                                newGoalName = ""; newGoalAmount = ""
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                                .font(.title2)
                        }
                        .disabled(newGoalName.isEmpty || Double(newGoalAmount) == nil)
                    }
                }

                Text("You can skip this step and add goals later.")
                    .font(.caption).foregroundColor(.secondary)
            }
            .padding()
        }
    }

    // MARK: - Page 5: Summary

    private var summaryPageView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 60))
                    .foregroundColor(themeManager.currentTheme.primaryColor)

                Text("Your Budget Plan")
                    .font(.title2).fontWeight(.bold)

                VStack(spacing: 12) {
                    HStack {
                        Text("Monthly Income").fontWeight(.semibold)
                        Spacer()
                        Text("$\(totalIncome, specifier: "%.2f")").font(.headline)
                    }
                    Divider()
                    summaryRow(title: "Needs (\(Int(needsPercent))%)",    amount: totalIncome * needsPercent / 100,    color: .blue)
                    summaryRow(title: "Wants (\(Int(wantsPercent))%)",    amount: totalIncome * wantsPercent / 100,    color: .purple)
                    summaryRow(title: "Savings (\(Int(savingsPercent))%)", amount: totalIncome * savingsPercent / 100, color: .green)
                }
                .padding()
                .background(themeManager.currentTheme.cardColor)
                .cornerRadius(12)

                if !selectedCommitments.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Categories: \(selectedCommitments.count)")
                            .font(.subheadline).fontWeight(.semibold)
                        Text(selectedCommitments.sorted().joined(separator: " · "))
                            .font(.caption).foregroundColor(.secondary)
                    }
                    .padding()
                    .background(themeManager.currentTheme.cardColor)
                    .cornerRadius(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                if !savingsGoals.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Savings Goals: \(savingsGoals.count)")
                            .font(.subheadline).fontWeight(.semibold)
                        ForEach(savingsGoals) { goal in
                            Text("• \(goal.name): $\(goal.targetAmount, specifier: "%.0f")")
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(themeManager.currentTheme.cardColor)
                    .cornerRadius(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle").font(.caption).foregroundColor(.secondary)
                    Text("Expenses are tracked month-by-month. Each new month starts with a fresh log — your budget setup and goals stay saved.")
                        .font(.caption).foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.07))
                .cornerRadius(10)

                Button { completeSetup() } label: {
                    Text("Start Budgeting")
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.currentTheme.primaryColor)
                        .cornerRadius(12)
                }
                .disabled(totalIncome <= 0)
            }
            .padding()
        }
    }

    // MARK: - Helper Views

    private func budgetRuleRow(title: String, percent: Binding<Double>, color: Color, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                Text("\(Int(percent.wrappedValue))%").font(.headline).foregroundColor(color)
            }
            Slider(value: percent, in: 0...100, step: 5).tint(color)
            Text(description).font(.caption).foregroundColor(.secondary)
        }
    }

    private func summaryRow(title: String, amount: Double, color: Color) -> some View {
        HStack {
            Text(title).foregroundColor(color)
            Spacer()
            Text("$\(amount, specifier: "%.2f")").font(.headline)
        }
    }

    private func colorFromString(_ string: String) -> Color {
        switch string.lowercased() {
        case "blue":   return .blue
        case "purple": return .purple
        case "green":  return .green
        case "red":    return .red
        case "orange": return .orange
        case "pink":   return .pink
        case "teal":   return .teal
        default:       return .blue
        }
    }

    // MARK: - Setup Completion

    private func completeSetup() {
        var setup = BudgetSetup(monthlyIncome: totalIncome)
        setup.needsPercentage = needsPercent
        setup.wantsPercentage = wantsPercent
        setup.savingsPercentage = savingsPercent
        setup.isSetupComplete = true
        setup.incomeSources = incomeRows.compactMap { row in
            guard row.amount > 0 else { return nil }
            return IncomeSource(name: row.name, amount: row.amount)
        }
        setup.savingsGoals = savingsGoals
        dataManager.saveBudgetSetup(setup)
        createCategories(setup: setup)
    }

    private func createCategories(setup: BudgetSetup) {
        if selectedCommitments.isEmpty {
            let defaults: [(String, String, String, BudgetCategory.CategoryType, Double)] = [
                ("Housing",        "house.fill",  "blue",   .needs,   setup.needsAmount * 0.4),
                ("Food & Groceries","cart.fill",  "orange", .needs,   setup.needsAmount * 0.3),
                ("Transportation", "car.fill",    "blue",   .needs,   setup.needsAmount * 0.3),
                ("Entertainment",  "film.fill",   "purple", .wants,   setup.wantsAmount * 0.5),
                ("Dining Out",     "fork.knife",  "pink",   .wants,   setup.wantsAmount * 0.5),
                ("Emergency Fund", "shield.fill", "green",  .savings, setup.savingsAmount),
            ]
            for (name, icon, color, type, limit) in defaults {
                dataManager.addBudgetCategory(BudgetCategory(name: name, icon: icon, color: color, limit: limit, type: type))
            }
        } else {
            let selected = commitmentTemplates.filter { selectedCommitments.contains($0.name) }
            let needsCount = max(selected.filter { $0.type == .needs }.count, 1)
            let wantsCount = max(selected.filter { $0.type == .wants }.count, 1)

            for template in selected {
                let limit: Double
                switch template.type {
                case .needs:   limit = setup.needsAmount / Double(needsCount)
                case .wants:   limit = setup.wantsAmount / Double(wantsCount)
                case .savings: limit = setup.savingsAmount
                }
                dataManager.addBudgetCategory(BudgetCategory(name: template.name, icon: template.icon, color: template.color, limit: limit, type: template.type))
            }

            if selected.filter({ $0.type == .savings }).isEmpty {
                dataManager.addBudgetCategory(BudgetCategory(name: "Emergency Fund", icon: "shield.fill", color: "green", limit: setup.savingsAmount, type: .savings))
            }
        }

        for goal in savingsGoals {
            dataManager.addBudgetCategory(BudgetCategory(name: goal.name, icon: goal.icon, color: goal.color, limit: goal.targetAmount, type: .savings))
        }
    }
}

// MARK: - Budget Dashboard

struct BudgetDashboard: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selectedMonth = Date()
    @State private var showingAddExpense = false
    @State private var showingCategories = false
    @State private var showingRecurring = false
    @State private var showingAllExpenses = false
    @State private var showingEditBudget = false

    private var monthKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: selectedMonth)
    }

    private var monthlyBudget: MonthlyBudget {
        dataManager.getMonthlyBudget(for: monthKey)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                if horizontalSizeClass == .regular {
                    iPadLayout
                } else {
                    iPhoneLayout
                }
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())

            // Floating add expense button
            Button {
                showingAddExpense = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(themeManager.currentTheme.primaryColor)
                    .clipShape(Circle())
                    .shadow(color: themeManager.currentTheme.primaryColor.opacity(0.4), radius: 8, y: 4)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
        }
        .navigationTitle("Budget")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button { showingEditBudget = true } label: {
                        Label("Edit Budget", systemImage: "slider.horizontal.3")
                    }
                    Button { showingCategories = true } label: {
                        Label("Manage Categories", systemImage: "folder")
                    }
                    Button { showingRecurring = true } label: {
                        Label("Recurring Expenses", systemImage: "repeat")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
        }
        .sheet(isPresented: $showingAddExpense)    { AddExpenseView() }
        .sheet(isPresented: $showingEditBudget)    { EditBudgetView() }
        .sheet(isPresented: $showingCategories)    { ManageCategoriesView() }
        .sheet(isPresented: $showingRecurring)     { RecurringExpensesView() }
        .sheet(isPresented: $showingAllExpenses)   { AllExpensesView(month: monthKey) }
    }

    // MARK: - Layouts

    private var iPhoneLayout: some View {
        VStack(spacing: 20) {
            monthSelector
            budgetSummaryCard
            if !dataManager.expenses.isEmpty { spendingChartCard }
            categoriesBreakdownCard
            if !dataManager.budgetSetup.savingsGoals.isEmpty { savingsGoalsCard }
            recentExpensesCard
        }
        .padding()
        .padding(.bottom, 80) // room for FAB
    }

    private var iPadLayout: some View {
        VStack(spacing: 20) {
            monthSelector.padding(.horizontal)
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20)
            ], spacing: 20) {
                budgetSummaryCard
                if !dataManager.expenses.isEmpty { spendingChartCard }
                categoriesBreakdownCard.gridCellColumns(2)
                if !dataManager.budgetSetup.savingsGoals.isEmpty {
                    savingsGoalsCard.gridCellColumns(2)
                }
                recentExpensesCard.gridCellColumns(2)
            }
            .padding()
            .padding(.bottom, 80)
        }
    }

    // MARK: - Cards

    private var monthSelector: some View {
        HStack {
            Button {
                selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }

            Spacer()

            Text(selectedMonth.formatted(.dateTime.month(.wide).year()))
                .font(.headline)

            Spacer()

            Button {
                selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }

            Button("Today") { selectedMonth = Date() }
                .font(.caption)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(themeManager.currentTheme.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }

    private var budgetSummaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Budget")
                        .font(.caption).foregroundColor(.secondary)
                    Text("$\(monthlyBudget.totalBudget, specifier: "%.2f")")
                        .font(.title).fontWeight(.bold)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Remaining")
                        .font(.caption).foregroundColor(.secondary)
                    Text("$\(monthlyBudget.remaining, specifier: "%.2f")")
                        .font(.title2).fontWeight(.bold)
                        .foregroundColor(monthlyBudget.remaining >= 0 ? .green : .red)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.gray.opacity(0.2))
                    Rectangle()
                        .fill(monthlyBudget.spentPercentage > 100
                              ? Color.red : themeManager.currentTheme.primaryColor)
                        .frame(width: min(geo.size.width * (monthlyBudget.spentPercentage / 100), geo.size.width))
                }
            }
            .frame(height: 12).cornerRadius(6)

            HStack {
                Text("Spent: $\(monthlyBudget.totalSpent, specifier: "%.2f")")
                    .font(.caption)
                Spacer()
                Text("\(Int(monthlyBudget.spentPercentage))%")
                    .font(.caption)
                    .foregroundColor(monthlyBudget.spentPercentage > 100 ? .red : .secondary)
            }

            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "calendar.badge.clock").font(.caption2).foregroundColor(.secondary)
                Text("Expenses reset at the start of each month. Your budget settings stay saved.")
                    .font(.caption2).foregroundColor(.secondary)
            }

            Button { showingEditBudget = true } label: {
                HStack {
                    Image(systemName: "pencil.circle.fill")
                    Text("Edit Budget")
                }
                .font(.subheadline)
                .foregroundColor(themeManager.currentTheme.primaryColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(themeManager.currentTheme.primaryColor.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }

    private var spendingChartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending by Category").font(.headline)
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(Array(monthlyBudget.categoryBreakdown.keys), id: \.id) { category in
                        if let amount = monthlyBudget.categoryBreakdown[category], amount > 0 {
                            SectorMark(
                                angle: .value("Amount", amount),
                                innerRadius: .ratio(0.5)
                            )
                            .foregroundStyle(by: .value("Category", category.name))
                        }
                    }
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }

    private var categoriesBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories").font(.headline)
            ForEach(dataManager.budgetCategories) { category in
                CategoryBreakdownRow(category: category, spent: monthlyBudget.categoryBreakdown[category] ?? 0)
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }

    private var savingsGoalsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Savings Goals").font(.headline)
            ForEach(dataManager.budgetSetup.savingsGoals) { goal in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: goal.icon)
                            .foregroundColor(.green).frame(width: 24)
                        Text(goal.name).font(.subheadline)
                        Spacer()
                        Text("$\(goal.currentAmount, specifier: "%.0f") / $\(goal.targetAmount, specifier: "%.0f")")
                            .font(.caption).foregroundColor(.secondary)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle().fill(Color.gray.opacity(0.2))
                                .frame(height: 6).cornerRadius(3)
                            Rectangle().fill(Color.green)
                                .frame(width: geo.size.width * goal.progress, height: 6)
                                .cornerRadius(3)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }

    private var recentExpensesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Expenses").font(.headline)
                Spacer()
                Button("See All") { showingAllExpenses = true }
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }

            let monthExpenses = dataManager.expenses
                .filter { $0.monthKey == monthKey }
                .sorted { $0.date > $1.date }

            if monthExpenses.isEmpty {
                Text("No expenses this month")
                    .font(.subheadline).foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(monthExpenses.prefix(5)) { expense in
                    ExpenseRowInteractive(expense: expense)
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views

struct CategoryBreakdownRow: View {
    let category: BudgetCategory
    let spent: Double
    @EnvironmentObject var themeManager: ThemeManager

    private var percentage: Double {
        category.limit > 0 ? (spent / category.limit) * 100 : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(colorFromString(category.color))
                Text(category.name).font(.subheadline)
                Spacer()
                Text("$\(Int(spent)) / $\(Int(category.limit))")
                    .font(.caption).foregroundColor(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 6).cornerRadius(3)
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
        case "blue":   return .blue
        case "purple": return .purple
        case "green":  return .green
        case "red":    return .red
        case "orange": return .orange
        case "pink":   return .pink
        case "teal":   return .teal
        default:       return themeManager.currentTheme.primaryColor
        }
    }
}

struct ExpenseRow: View {
    let expense: Expense
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: expense.category.icon)
                .foregroundColor(colorFromString(expense.category.color))
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title).font(.subheadline).fontWeight(.medium)
                HStack(spacing: 4) {
                    Text(expense.category.name).font(.caption).foregroundColor(.secondary)
                    if expense.isRecurring {
                        Image(systemName: "repeat.circle.fill")
                            .font(.caption2).foregroundColor(.orange)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(expense.amount, specifier: "%.2f")").font(.subheadline).fontWeight(.semibold)
                Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func colorFromString(_ string: String) -> Color {
        switch string.lowercased() {
        case "blue":   return .blue
        case "purple": return .purple
        case "green":  return .green
        case "red":    return .red
        case "orange": return .orange
        case "pink":   return .pink
        case "teal":   return .teal
        default:       return .gray
        }
    }
}

// MARK: - Interactive Expense Row

struct ExpenseRowInteractive: View {
    let expense: Expense
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    @State private var showingEditExpense = false

    var body: some View {
        Button { showingEditExpense = true } label: {
            HStack(spacing: 12) {
                Image(systemName: expense.category.icon)
                    .foregroundColor(colorFromString(expense.category.color))
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text(expense.title).font(.subheadline).fontWeight(.medium).foregroundColor(.primary)
                    HStack(spacing: 4) {
                        Text(expense.category.name).font(.caption).foregroundColor(.secondary)
                        if expense.isRecurring {
                            Image(systemName: "repeat.circle.fill").font(.caption2).foregroundColor(.orange)
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("$\(expense.amount, specifier: "%.2f")").font(.subheadline).fontWeight(.semibold).foregroundColor(.primary)
                    Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2).foregroundColor(.secondary)
                }

                Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingEditExpense) { EditExpenseView(expense: expense) }
    }

    private func colorFromString(_ string: String) -> Color {
        switch string.lowercased() {
        case "blue":   return .blue
        case "purple": return .purple
        case "green":  return .green
        case "red":    return .red
        case "orange": return .orange
        case "pink":   return .pink
        case "teal":   return .teal
        default:       return .gray
        }
    }
}

// MARK: - Add Expense View

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager

    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory: BudgetCategory?
    @State private var date = Date()
    @State private var notes = ""
    @State private var isRecurring = false

    var body: some View {
        NavigationView {
            Form {
                Section("Expense Details") {
                    TextField("Title", text: $title)
                    TextField("Amount", text: $amount).keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        Text("Select Category").tag(nil as BudgetCategory?)
                        ForEach(dataManager.budgetCategories) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.name)
                            }
                            .tag(category as BudgetCategory?)
                        }
                    }
                }
                Section("Additional Options") {
                    Toggle("Recurring Expense", isOn: $isRecurring)
                    TextField("Notes (Optional)", text: $notes, axis: .vertical).lineLimit(3...6)
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveExpense() }.disabled(!isValid)
                }
            }
        }
    }

    private var isValid: Bool {
        !title.isEmpty && !amount.isEmpty && selectedCategory != nil && Double(amount) != nil
    }

    private func saveExpense() {
        guard let category = selectedCategory, let amountValue = Double(amount) else { return }
        dataManager.addExpense(Expense(title: title, amount: amountValue, category: category, date: date, notes: notes.isEmpty ? nil : notes, isRecurring: isRecurring))
        dismiss()
    }
}

// MARK: - Edit Expense View

struct EditExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager

    let expense: Expense

    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory: BudgetCategory?
    @State private var date = Date()
    @State private var notes = ""
    @State private var isRecurring = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationView {
            Form {
                Section("Expense Details") {
                    TextField("Title", text: $title)
                    TextField("Amount", text: $amount).keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        Text("Select Category").tag(nil as BudgetCategory?)
                        ForEach(dataManager.budgetCategories) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.name)
                            }
                            .tag(category as BudgetCategory?)
                        }
                    }
                }
                Section("Additional Options") {
                    Toggle("Recurring Expense", isOn: $isRecurring)
                    TextField("Notes (Optional)", text: $notes, axis: .vertical).lineLimit(3...6)
                }
                Section {
                    Button(role: .destructive) { showingDeleteConfirmation = true } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "trash.fill")
                            Text("Delete Expense")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading)  { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Save") { saveExpense() }.disabled(!isValid) }
            }
            .onAppear { loadExpense() }
            .confirmationDialog("Delete Expense", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) { deleteExpense() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this expense? This action cannot be undone.")
            }
        }
    }

    private var isValid: Bool {
        !title.isEmpty && !amount.isEmpty && selectedCategory != nil && Double(amount) != nil
    }

    private func loadExpense() {
        title = expense.title
        amount = String(expense.amount)
        selectedCategory = expense.category
        date = expense.date
        notes = expense.notes ?? ""
        isRecurring = expense.isRecurring
    }

    private func saveExpense() {
        guard let category = selectedCategory, let amountValue = Double(amount) else { return }
        var updated = expense
        updated.title = title; updated.amount = amountValue
        updated.category = category; updated.date = date
        updated.notes = notes.isEmpty ? nil : notes; updated.isRecurring = isRecurring
        dataManager.updateExpense(updated)
        dismiss()
    }

    private func deleteExpense() {
        dataManager.deleteExpense(expense)
        dismiss()
    }
}

// MARK: - Manage Categories View

struct ManageCategoriesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingAddCategory = false

    var body: some View {
        NavigationView {
            List {
                ForEach(dataManager.budgetCategories) { category in
                    CategoryListRow(category: category)
                }
                .onDelete(perform: deleteCategories)
            }
            .navigationTitle("Manage Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading)  { Button("Done") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingAddCategory = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingAddCategory) { AddCategoryView() }
        }
    }

    private func deleteCategories(at offsets: IndexSet) {
        for index in offsets { dataManager.deleteBudgetCategory(dataManager.budgetCategories[index]) }
    }
}

struct CategoryListRow: View {
    let category: BudgetCategory
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack {
            Image(systemName: category.icon)
                .foregroundColor(colorFromString(category.color)).frame(width: 30)
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name).font(.subheadline)
                Text(categoryTypeString(category.type)).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Text("$\(Int(category.limit))").font(.caption).foregroundColor(.secondary)
        }
    }

    private func colorFromString(_ string: String) -> Color {
        switch string.lowercased() {
        case "blue":   return .blue
        case "purple": return .purple
        case "green":  return .green
        case "red":    return .red
        case "orange": return .orange
        case "pink":   return .pink
        case "teal":   return .teal
        default:       return themeManager.currentTheme.primaryColor
        }
    }

    private func categoryTypeString(_ type: BudgetCategory.CategoryType) -> String {
        switch type { case .needs: return "Needs"; case .wants: return "Wants"; case .savings: return "Savings" }
    }
}

struct AddCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager

    @State private var name = ""
    @State private var icon = "folder.fill"
    @State private var color = "blue"
    @State private var limit = ""
    @State private var type: BudgetCategory.CategoryType = .needs

    let availableIcons  = ["house.fill","cart.fill","car.fill","film.fill","fork.knife","heart.fill","book.fill","gamecontroller.fill","briefcase.fill","shield.fill"]
    let availableColors = ["blue","purple","green","red","orange","pink","teal"]

    var body: some View {
        NavigationView {
            Form {
                Section("Category Details") {
                    TextField("Name", text: $name)
                    TextField("Limit", text: $limit).keyboardType(.decimalPad)
                    Picker("Type", selection: $type) {
                        Text("Needs").tag(BudgetCategory.CategoryType.needs)
                        Text("Wants").tag(BudgetCategory.CategoryType.wants)
                        Text("Savings").tag(BudgetCategory.CategoryType.savings)
                    }
                }
                Section("Icon") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 16) {
                        ForEach(availableIcons, id: \.self) { iconName in
                            Image(systemName: iconName).font(.title2)
                                .foregroundColor(icon == iconName ? .white : .primary)
                                .frame(width: 50, height: 50)
                                .background(icon == iconName ? themeManager.currentTheme.primaryColor : Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .onTapGesture { icon = iconName }
                        }
                    }
                }
                Section("Color") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 16) {
                        ForEach(availableColors, id: \.self) { colorName in
                            Circle().fill(colorFromString(colorName))
                                .frame(width: 50, height: 50)
                                .overlay(Circle().stroke(Color.white, lineWidth: color == colorName ? 4 : 0))
                                .onTapGesture { color = colorName }
                        }
                    }
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading)  { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Save") { saveCategory() }.disabled(!isValid) }
            }
        }
    }

    private var parsedLimit: Double? {
        // Normalize locale-specific decimal separators (comma → period) before parsing
        let normalized = limit
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)
        return Double(normalized)
    }

    private var isValid: Bool { !name.isEmpty && !limit.isEmpty && parsedLimit != nil }

    private func saveCategory() {
        guard let limitValue = parsedLimit else { return }
        dataManager.addBudgetCategory(BudgetCategory(name: name, icon: icon, color: color, limit: limitValue, type: type))
        dismiss()
    }

    private func colorFromString(_ string: String) -> Color {
        switch string.lowercased() {
        case "blue":   return .blue
        case "purple": return .purple
        case "green":  return .green
        case "red":    return .red
        case "orange": return .orange
        case "pink":   return .pink
        case "teal":   return .teal
        default:       return .blue
        }
    }
}

// MARK: - Recurring Expenses View

struct RecurringExpensesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager

    private var recurringExpenses: [Expense] { dataManager.expenses.filter { $0.isRecurring } }

    var body: some View {
        NavigationView {
            List {
                if recurringExpenses.isEmpty {
                    Text("No recurring expenses")
                        .foregroundColor(.secondary).frame(maxWidth: .infinity, alignment: .center).padding()
                } else {
                    ForEach(recurringExpenses) { expense in ExpenseRowInteractive(expense: expense) }
                        .onDelete(perform: deleteExpenses)
                }
            }
            .navigationTitle("Recurring Expenses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading)  { Button("Done") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
            }
        }
    }

    private func deleteExpenses(at offsets: IndexSet) {
        for index in offsets { dataManager.deleteExpense(recurringExpenses[index]) }
    }
}

// MARK: - All Expenses View

struct AllExpensesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager

    var month: String = ""

    private var expenses: [Expense] {
        if month.isEmpty {
            return dataManager.expenses.sorted { $0.date > $1.date }
        } else {
            return dataManager.expenses.filter { $0.monthKey == month }.sorted { $0.date > $1.date }
        }
    }

    var body: some View {
        NavigationView {
            List {
                if expenses.isEmpty {
                    Text("No expenses found")
                        .foregroundColor(.secondary).frame(maxWidth: .infinity, alignment: .center).padding()
                } else {
                    ForEach(expenses) { expense in ExpenseRowInteractive(expense: expense) }
                        .onDelete(perform: deleteExpenses)
                }
            }
            .navigationTitle(month.isEmpty ? "All Expenses" : "Expenses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading)  { Button("Done") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
            }
        }
    }

    private func deleteExpenses(at offsets: IndexSet) {
        for index in offsets { dataManager.deleteExpense(expenses[index]) }
    }
}
