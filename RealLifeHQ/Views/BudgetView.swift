import SwiftUI
import Charts

// MARK: - Main Budget View with Setup Check

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

// MARK: - Preview Provider

#Preview {
    BudgetView()
        .environmentObject(DataManager())
        .environmentObject(ThemeManager())
}

// MARK: - Budget Setup Wizard (50/30/20 Rule)

struct BudgetSetupWizard: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var monthlyIncome: String = ""
    @State private var needsPercent: Double = 50
    @State private var wantsPercent: Double = 30
    @State private var savingsPercent: Double = 20
    @State private var currentPage = 0
    
    var body: some View {
        VStack(spacing: 24) {
            // Progress indicator
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(index == currentPage ? themeManager.currentTheme.primaryColor : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.top)
                
                TabView(selection: $currentPage) {
                    // Page 1: Income
                    VStack(spacing: 20) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        
                        Text("What's your monthly take-home pay?")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        TextField("$0.00", text: $monthlyIncome)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 48, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(themeManager.currentTheme.cardColor)
                            .cornerRadius(12)
                    }
                    .padding()
                    .tag(0)
                    
                    // Page 2: Budget Rule
                    VStack(spacing: 20) {
                        Text("50/30/20 Budget Rule")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("A simple way to budget your money")
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 16) {
                            budgetRuleRow(
                                title: "Needs",
                                percent: $needsPercent,
                                color: .blue,
                                description: "Housing, food, utilities"
                            )
                            
                            budgetRuleRow(
                                title: "Wants",
                                percent: $wantsPercent,
                                color: .purple,
                                description: "Entertainment, dining out"
                            )
                            
                            budgetRuleRow(
                                title: "Savings",
                                percent: $savingsPercent,
                                color: .green,
                                description: "Emergency fund, investments"
                            )
                        }
                        .padding()
                        .background(themeManager.currentTheme.cardColor)
                        .cornerRadius(12)
                        
                        Text("Total: \(Int(needsPercent + wantsPercent + savingsPercent))%")
                            .font(.headline)
                            .foregroundColor(needsPercent + wantsPercent + savingsPercent == 100 ? .green : .red)
                    }
                    .padding()
                    .tag(1)
                    
                    // Page 3: Summary
                    VStack(spacing: 20) {
                        Text("Your Budget Plan")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let income = Double(monthlyIncome) {
                            VStack(spacing: 16) {
                                summaryRow(title: "Monthly Income", amount: income, color: .gray)
                                Divider()
                                summaryRow(title: "Needs (\(Int(needsPercent))%)", amount: income * needsPercent / 100, color: .blue)
                                summaryRow(title: "Wants (\(Int(wantsPercent))%)", amount: income * wantsPercent / 100, color: .purple)
                                summaryRow(title: "Savings (\(Int(savingsPercent))%)", amount: income * savingsPercent / 100, color: .green)
                            }
                            .padding()
                            .background(themeManager.currentTheme.cardColor)
                            .cornerRadius(12)
                        }
                        
                        Button {
                            completeSetup()
                        } label: {
                            Text("Start Budgeting")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(themeManager.currentTheme.primaryColor)
                                .cornerRadius(12)
                        }
                        .disabled(monthlyIncome.isEmpty || needsPercent + wantsPercent + savingsPercent != 100)
                    }
                    .padding()
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Navigation buttons
                HStack {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if currentPage < 2 {
                        Button("Next") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .disabled(currentPage == 0 && monthlyIncome.isEmpty)
                    }
                }
                .padding()
            }
            .navigationTitle("Budget Setup")
            .navigationBarTitleDisplayMode(.inline)
        }
    
    private func budgetRuleRow(title: String, percent: Binding<Double>, color: Color, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text("\(Int(percent.wrappedValue))%")
                    .font(.headline)
                    .foregroundColor(color)
            }
            
            Slider(value: percent, in: 0...100, step: 5)
                .tint(color)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func summaryRow(title: String, amount: Double, color: Color) -> some View {
        HStack {
            Text(title)
                .foregroundColor(color)
            Spacer()
            Text("$\(amount, specifier: "%.2f")")
                .font(.headline)
        }
    }
    
    private func completeSetup() {
        guard let income = Double(monthlyIncome) else { return }
        
        var setup = BudgetSetup(monthlyIncome: income)
        setup.needsPercentage = needsPercent
        setup.wantsPercentage = wantsPercent
        setup.savingsPercentage = savingsPercent
        setup.isSetupComplete = true
        
        dataManager.saveBudgetSetup(setup)
        
        // Create default categories
        createDefaultCategories()
    }
    
    private func createDefaultCategories() {
        let categories = [
            BudgetCategory(name: "Housing", icon: "house.fill", color: "blue", limit: dataManager.budgetSetup.needsAmount * 0.4, type: .needs),
            BudgetCategory(name: "Food", icon: "cart.fill", color: "orange", limit: dataManager.budgetSetup.needsAmount * 0.3, type: .needs),
            BudgetCategory(name: "Transportation", icon: "car.fill", color: "blue", limit: dataManager.budgetSetup.needsAmount * 0.3, type: .needs),
            BudgetCategory(name: "Entertainment", icon: "film.fill", color: "purple", limit: dataManager.budgetSetup.wantsAmount * 0.5, type: .wants),
            BudgetCategory(name: "Dining Out", icon: "fork.knife", color: "pink", limit: dataManager.budgetSetup.wantsAmount * 0.5, type: .wants),
            BudgetCategory(name: "Emergency Fund", icon: "shield.fill", color: "green", limit: dataManager.budgetSetup.savingsAmount, type: .savings)
        ]
        
        for category in categories {
            dataManager.addBudgetCategory(category)
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
        ScrollView {
            if horizontalSizeClass == .regular {
                // iPad: Grid layout
                iPadLayout
            } else {
                // iPhone: Vertical layout
                iPhoneLayout
            }
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle("Budget")
        .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingAddExpense = true
                        } label: {
                            Label("Add Expense", systemImage: "plus.circle")
                        }
                        
                        Button {
                            showingEditBudget = true
                        } label: {
                            Label("Edit Budget", systemImage: "slider.horizontal.3")
                        }
                        
                        Button {
                            showingCategories = true
                        } label: {
                            Label("Manage Categories", systemImage: "folder")
                        }
                        
                        Button {
                            showingRecurring = true
                        } label: {
                            Label("Recurring Expenses", systemImage: "repeat")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
            }
            .sheet(isPresented: $showingEditBudget) {
                EditBudgetView()
            }
            .sheet(isPresented: $showingCategories) {
                ManageCategoriesView()
            }
            .sheet(isPresented: $showingRecurring) {
                RecurringExpensesView()
            }
            .sheet(isPresented: $showingAllExpenses) {
                AllExpensesView(month: monthKey)
            }
    }
    
    // iPhone Layout - Vertical Stack
    private var iPhoneLayout: some View {
        VStack(spacing: 20) {
            monthSelector
            budgetSummaryCard
            
            if !dataManager.expenses.isEmpty {
                spendingChartCard
            }
            
            categoriesBreakdownCard
            recentExpensesCard
        }
        .padding()
    }
    
    // iPad Layout - Two-Column Grid
    private var iPadLayout: some View {
        VStack(spacing: 20) {
            monthSelector
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20)
            ], spacing: 20) {
                budgetSummaryCard
                
                if !dataManager.expenses.isEmpty {
                    spendingChartCard
                }
                
                categoriesBreakdownCard
                    .gridCellColumns(2)
                
                recentExpensesCard
                    .gridCellColumns(2)
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
            
            Text(selectedMonth.formatted(.dateTime.month(.wide).year()))
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
    
    private var budgetSummaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Budget")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(monthlyBudget.totalBudget, specifier: "%.2f")")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(monthlyBudget.remaining, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(monthlyBudget.remaining >= 0 ? .green : .red)
                }
            }
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                    
                    Rectangle()
                        .fill(monthlyBudget.spentPercentage > 100 ? Color.red : themeManager.currentTheme.primaryColor)
                        .frame(width: min(geo.size.width * (monthlyBudget.spentPercentage / 100), geo.size.width))
                }
            }
            .frame(height: 12)
            .cornerRadius(6)
            
            HStack {
                Text("Spent: $\(monthlyBudget.totalSpent, specifier: "%.2f")")
                    .font(.caption)
                Spacer()
                Text("\(Int(monthlyBudget.spentPercentage))%")
                    .font(.caption)
                    .foregroundColor(monthlyBudget.spentPercentage > 100 ? .red : .secondary)
            }
            
            // Edit budget button
            Button {
                showingEditBudget = true
            } label: {
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
            Text("Spending by Category")
                .font(.headline)
            
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
            Text("Categories")
                .font(.headline)
            
            ForEach(dataManager.budgetCategories) { category in
                CategoryBreakdownRow(category: category, spent: monthlyBudget.categoryBreakdown[category] ?? 0)
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
    
    private var recentExpensesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Expenses")
                    .font(.headline)
                
                Spacer()
                
                Button("See All") {
                    showingAllExpenses = true
                }
                .font(.caption)
                .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            
            let monthExpenses = dataManager.expenses.filter { $0.monthKey == monthKey }.sorted { $0.date > $1.date }
            
            if monthExpenses.isEmpty {
                Text("No expenses this month")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(monthExpenses.prefix(5)) { expense in
                    ExpenseRow(expense: expense)
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
                
                Text(category.name)
                    .font(.subheadline)
                
                Spacer()
                
                Text("$\(Int(spent)) / $\(Int(category.limit))")
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

struct ExpenseRow: View {
    let expense: Expense
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: expense.category.icon)
                .foregroundColor(colorFromString(expense.category.color))
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
                Text("$\(expense.amount, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
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
        default: return .gray
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
                    
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
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
                    
                    TextField("Notes (Optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !title.isEmpty && !amount.isEmpty && selectedCategory != nil && Double(amount) != nil
    }
    
    private func saveExpense() {
        guard let category = selectedCategory,
              let amountValue = Double(amount) else { return }
        
        let expense = Expense(
            title: title,
            amount: amountValue,
            category: category,
            date: date,
            notes: notes.isEmpty ? nil : notes,
            isRecurring: isRecurring
        )
        
        dataManager.addExpense(expense)
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddCategory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView()
            }
        }
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        for index in offsets {
            let category = dataManager.budgetCategories[index]
            dataManager.deleteBudgetCategory(category)
        }
    }
}

struct CategoryListRow: View {
    let category: BudgetCategory
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Image(systemName: category.icon)
                .foregroundColor(colorFromString(category.color))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.subheadline)
                
                Text(categoryTypeString(category.type))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("$\(Int(category.limit))")
                .font(.caption)
                .foregroundColor(.secondary)
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
    
    private func categoryTypeString(_ type: BudgetCategory.CategoryType) -> String {
        switch type {
        case .needs: return "Needs"
        case .wants: return "Wants"
        case .savings: return "Savings"
        }
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
    
    let availableIcons = ["house.fill", "cart.fill", "car.fill", "film.fill", "fork.knife", "heart.fill", "book.fill", "gamecontroller.fill", "briefcase.fill", "shield.fill"]
    let availableColors = ["blue", "purple", "green", "red", "orange", "pink", "teal"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Category Details") {
                    TextField("Name", text: $name)
                    
                    TextField("Limit", text: $limit)
                        .keyboardType(.decimalPad)
                    
                    Picker("Type", selection: $type) {
                        Text("Needs").tag(BudgetCategory.CategoryType.needs)
                        Text("Wants").tag(BudgetCategory.CategoryType.wants)
                        Text("Savings").tag(BudgetCategory.CategoryType.savings)
                    }
                }
                
                Section("Icon") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 16) {
                        ForEach(availableIcons, id: \.self) { iconName in
                            Image(systemName: iconName)
                                .font(.title2)
                                .foregroundColor(icon == iconName ? .white : .primary)
                                .frame(width: 50, height: 50)
                                .background(icon == iconName ? themeManager.currentTheme.primaryColor : Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .onTapGesture {
                                    icon = iconName
                                }
                        }
                    }
                }
                
                Section("Color") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 16) {
                        ForEach(availableColors, id: \.self) { colorName in
                            Circle()
                                .fill(colorFromString(colorName))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: color == colorName ? 4 : 0)
                                )
                                .onTapGesture {
                                    color = colorName
                                }
                        }
                    }
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCategory()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty && !limit.isEmpty && Double(limit) != nil
    }
    
    private func saveCategory() {
        guard let limitValue = Double(limit) else { return }
        
        let category = BudgetCategory(
            name: name,
            icon: icon,
            color: color,
            limit: limitValue,
            type: type
        )
        
        dataManager.addBudgetCategory(category)
        dismiss()
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
        default: return .blue
        }
    }
}

// MARK: - Recurring Expenses View

struct RecurringExpensesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    private var recurringExpenses: [Expense] {
        dataManager.expenses.filter { $0.isRecurring }
    }
    
    var body: some View {
        NavigationView {
            List {
                if recurringExpenses.isEmpty {
                    Text("No recurring expenses")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(recurringExpenses) { expense in
                        ExpenseRow(expense: expense)
                    }
                }
            }
            .navigationTitle("Recurring Expenses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
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
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(expenses) { expense in
                        ExpenseRow(expense: expense)
                    }
                    .onDelete(perform: deleteExpenses)
                }
            }
            .navigationTitle(month.isEmpty ? "All Expenses" : "Expenses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func deleteExpenses(at offsets: IndexSet) {
        for index in offsets {
            let expense = expenses[index]
            dataManager.deleteExpense(expense)
        }
    }
}

