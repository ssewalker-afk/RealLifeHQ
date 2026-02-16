import SwiftUI

// MARK: - Edit Budget View
// Allows users to adjust their monthly income, budget percentages, and individual category limits

struct EditBudgetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var monthlyIncome: String = ""
    @State private var needsPercent: Double = 50
    @State private var wantsPercent: Double = 30
    @State private var savingsPercent: Double = 20
    @State private var editingCategories: [BudgetCategory] = []
    @State private var showingAddCategory = false
    @State private var selectedCategoryType: BudgetCategory.CategoryType = .needs
    @State private var showingDeleteAlert = false
    @State private var categoryToDelete: BudgetCategory?
    
    private var totalPercentage: Double {
        needsPercent + wantsPercent + savingsPercent
    }
    
    private var isValidBudget: Bool {
        abs(totalPercentage - 100) < 0.01 && (Double(monthlyIncome) ?? 0) > 0
    }
    
    private var needsAmount: Double {
        (Double(monthlyIncome) ?? 0) * (needsPercent / 100)
    }
    
    private var wantsAmount: Double {
        (Double(monthlyIncome) ?? 0) * (wantsPercent / 100)
    }
    
    private var savingsAmount: Double {
        (Double(monthlyIncome) ?? 0) * (savingsPercent / 100)
    }
    
    private func categoriesForType(_ type: BudgetCategory.CategoryType) -> [BudgetCategory] {
        editingCategories.filter { $0.type == type }
    }
    
    private func totalAllocated(for type: BudgetCategory.CategoryType) -> Double {
        categoriesForType(type).reduce(0) { $0 + $1.limit }
    }
    
    private func availableAmount(for type: BudgetCategory.CategoryType) -> Double {
        switch type {
        case .needs: return needsAmount
        case .wants: return wantsAmount
        case .savings: return savingsAmount
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Income Section
                Section {
                    HStack {
                        Text("Monthly Income")
                        Spacer()
                        TextField("$0.00", text: $monthlyIncome)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .font(.headline)
                    }
                } header: {
                    Text("Income")
                } footer: {
                    Text("Enter your monthly take-home pay after taxes")
                }
                
                // Budget Percentages Section
                Section {
                    VStack(spacing: 16) {
                        budgetPercentageRow(
                            title: "Needs",
                            percentage: $needsPercent,
                            amount: needsAmount,
                            color: .blue,
                            description: "Housing, food, utilities"
                        )
                        
                        Divider()
                        
                        budgetPercentageRow(
                            title: "Wants",
                            percentage: $wantsPercent,
                            amount: wantsAmount,
                            color: .purple,
                            description: "Entertainment, dining out"
                        )
                        
                        Divider()
                        
                        budgetPercentageRow(
                            title: "Savings",
                            percentage: $savingsPercent,
                            amount: savingsAmount,
                            color: .green,
                            description: "Emergency fund, investments"
                        )
                    }
                    .padding(.vertical, 8)
                    
                    // Total percentage indicator
                    HStack {
                        Text("Total")
                            .fontWeight(.bold)
                        Spacer()
                        Text("\(Int(totalPercentage))%")
                            .fontWeight(.bold)
                            .foregroundColor(isValidBudget ? .green : .red)
                    }
                    .padding(.top, 8)
                } header: {
                    Text("Budget Distribution")
                } footer: {
                    if !isValidBudget {
                        Text("⚠️ Total must equal 100%")
                            .foregroundColor(.red)
                    }
                }
                
                // Needs Categories
                Section {
                    categorySection(for: .needs)
                } header: {
                    HStack {
                        Text("Needs Categories")
                        Spacer()
                        Text(totalAllocated(for: .needs).formatted(.currency(code: "USD")))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("of")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(needsAmount.formatted(.currency(code: "USD")))
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                } footer: {
                    let difference = needsAmount - totalAllocated(for: .needs)
                    if abs(difference) > 0.01 {
                        Text(difference > 0 ? "💡 \(difference.formatted(.currency(code: "USD"))) unallocated" : "⚠️ Over budget by \(abs(difference).formatted(.currency(code: "USD")))")
                            .foregroundColor(difference > 0 ? .secondary : .red)
                    }
                }
                
                // Wants Categories
                Section {
                    categorySection(for: .wants)
                } header: {
                    HStack {
                        Text("Wants Categories")
                        Spacer()
                        Text(totalAllocated(for: .wants).formatted(.currency(code: "USD")))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("of")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(wantsAmount.formatted(.currency(code: "USD")))
                            .font(.caption)
                            .foregroundColor(.purple)
                    }
                } footer: {
                    let difference = wantsAmount - totalAllocated(for: .wants)
                    if abs(difference) > 0.01 {
                        Text(difference > 0 ? "💡 \(difference.formatted(.currency(code: "USD"))) unallocated" : "⚠️ Over budget by \(abs(difference).formatted(.currency(code: "USD")))")
                            .foregroundColor(difference > 0 ? .secondary : .red)
                    }
                }
                
                // Savings Categories
                Section {
                    categorySection(for: .savings)
                } header: {
                    HStack {
                        Text("Savings Categories")
                        Spacer()
                        Text(totalAllocated(for: .savings).formatted(.currency(code: "USD")))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("of")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(savingsAmount.formatted(.currency(code: "USD")))
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                } footer: {
                    let difference = savingsAmount - totalAllocated(for: .savings)
                    if abs(difference) > 0.01 {
                        Text(difference > 0 ? "💡 \(difference.formatted(.currency(code: "USD"))) unallocated" : "⚠️ Over budget by \(abs(difference).formatted(.currency(code: "USD")))")
                            .foregroundColor(difference > 0 ? .secondary : .red)
                    }
                }
                
                // Reset Budget Section
                Section {
                    Button(role: .destructive) {
                        resetToDefaults()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Reset to 50/30/20 Rule")
                            Spacer()
                        }
                    }
                } footer: {
                    Text("This will reset percentages to 50% Needs, 30% Wants, 20% Savings")
                }
            }
            .navigationTitle("Edit Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveBudget()
                    }
                    .disabled(!isValidBudget)
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategorySheet(categoryType: selectedCategoryType) { newCategory in
                    editingCategories.append(newCategory)
                }
            }
            .alert("Delete Category", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let category = categoryToDelete {
                        deleteCategory(category)
                    }
                }
            } message: {
                if let category = categoryToDelete {
                    Text("Are you sure you want to delete '\(category.name)'? This will not delete existing expenses in this category.")
                }
            }
        }
        .onAppear {
            // Load current budget data
            monthlyIncome = String(format: "%.2f", dataManager.budgetSetup.monthlyIncome)
            needsPercent = dataManager.budgetSetup.needsPercentage
            wantsPercent = dataManager.budgetSetup.wantsPercentage
            savingsPercent = dataManager.budgetSetup.savingsPercentage
            editingCategories = dataManager.budgetCategories
        }
    }
    
    // MARK: - View Components
    
    private func budgetPercentageRow(
        title: String,
        percentage: Binding<Double>,
        amount: Double,
        color: Color,
        description: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(color)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(percentage.wrappedValue))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                    Text(amount.formatted(.currency(code: "USD")))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Slider(value: percentage, in: 0...100, step: 1)
                .tint(color)
        }
    }
    
    private func categorySection(for type: BudgetCategory.CategoryType) -> some View {
        Group {
            ForEach(categoriesForType(type)) { category in
                EditCategoryRow(category: binding(for: category)) {
                    categoryToDelete = category
                    showingDeleteAlert = true
                }
            }
            
            Button {
                selectedCategoryType = type
                showingAddCategory = true
            } label: {
                Label("Add Category", systemImage: "plus.circle.fill")
                    .foregroundColor(colorForType(type))
            }
        }
    }
    
    private func binding(for category: BudgetCategory) -> Binding<BudgetCategory> {
        guard let index = editingCategories.firstIndex(where: { $0.id == category.id }) else {
            return .constant(category)
        }
        return $editingCategories[index]
    }
    
    private func colorForType(_ type: BudgetCategory.CategoryType) -> Color {
        switch type {
        case .needs: return .blue
        case .wants: return .purple
        case .savings: return .green
        }
    }
    
    // MARK: - Actions
    
    private func saveBudget() {
        guard let income = Double(monthlyIncome), isValidBudget else { return }
        
        // Update budget setup
        var setup = dataManager.budgetSetup
        setup.monthlyIncome = income
        setup.needsPercentage = needsPercent
        setup.wantsPercentage = wantsPercent
        setup.savingsPercentage = savingsPercent
        dataManager.saveBudgetSetup(setup)
        
        // Update categories
        for category in editingCategories {
            if dataManager.budgetCategories.contains(where: { $0.id == category.id }) {
                dataManager.updateBudgetCategory(category)
            } else {
                dataManager.addBudgetCategory(category)
            }
        }
        
        // Remove deleted categories
        let deletedCategories = dataManager.budgetCategories.filter { existingCategory in
            !editingCategories.contains(where: { $0.id == existingCategory.id })
        }
        for category in deletedCategories {
            dataManager.deleteBudgetCategory(category)
        }
        
        dismiss()
    }
    
    private func resetToDefaults() {
        needsPercent = 50
        wantsPercent = 30
        savingsPercent = 20
    }
    
    private func deleteCategory(_ category: BudgetCategory) {
        editingCategories.removeAll { $0.id == category.id }
    }
}

// MARK: - Edit Category Row

struct EditCategoryRow: View {
    @Binding var category: BudgetCategory
    let onDelete: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingEditSheet = false
    
    var body: some View {
        Button {
            showingEditSheet = true
        } label: {
            HStack {
                // Icon
                Image(systemName: category.icon)
                    .foregroundColor(Color(category.color))
                    .frame(width: 30)
                
                // Name and limit
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Text(category.limit.formatted(.currency(code: "USD")))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Edit indicator
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
            }
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditCategorySheet(category: $category)
        }
    }
}

// MARK: - Edit Category Sheet

struct EditCategorySheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var category: BudgetCategory
    @State private var editedName: String = ""
    @State private var editedIcon: String = ""
    @State private var editedColor: String = ""
    @State private var editedLimit: String = ""
    @State private var showingIconPicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    // Category name
                    TextField("Category Name", text: $editedName)
                    
                    // Icon and color
                    Button {
                        showingIconPicker = true
                    } label: {
                        HStack {
                            Text("Icon & Color")
                            Spacer()
                            Image(systemName: editedIcon)
                                .foregroundColor(colorForName(editedColor))
                                .font(.title2)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Budget limit
                    HStack {
                        Text("Budget Limit")
                        Spacer()
                        TextField("$0.00", text: $editedLimit)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                    }
                } header: {
                    Text("Category Details")
                }
                
                Section {
                    // Preview
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: editedIcon)
                                .font(.system(size: 50))
                                .foregroundColor(colorForName(editedColor))
                            Text(editedName.isEmpty ? "Category Name" : editedName)
                                .font(.headline)
                            if let amount = Double(editedLimit), amount > 0 {
                                Text(amount.formatted(.currency(code: "USD")))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        Spacer()
                    }
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle("Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(editedName.isEmpty || editedLimit.isEmpty)
                }
            }
            .sheet(isPresented: $showingIconPicker) {
                CategoryIconPickerView(selectedIcon: $editedIcon, selectedColor: $editedColor)
            }
            .onAppear {
                // Load current values
                editedName = category.name
                editedIcon = category.icon
                editedColor = category.color
                editedLimit = String(format: "%.2f", category.limit)
            }
        }
    }
    
    private func colorForName(_ name: String) -> Color {
        switch name {
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "teal": return .teal
        case "indigo": return .indigo
        case "cyan": return .cyan
        default: return .blue
        }
    }
    
    private func saveChanges() {
        guard let limitValue = Double(editedLimit) else { return }
        
        category.name = editedName
        category.icon = editedIcon
        category.color = editedColor
        category.limit = limitValue
        
        dismiss()
    }
}

// MARK: - Add Category Sheet (for Edit Budget View)

struct AddCategorySheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    let categoryType: BudgetCategory.CategoryType
    let onSave: (BudgetCategory) -> Void
    
    @State private var name = ""
    @State private var icon = "tag.fill"
    @State private var color = "blue"
    @State private var limit = ""
    @State private var showingIconPicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Category Name", text: $name)
                    
                    HStack {
                        Text("Icon")
                        Spacer()
                        Button {
                            showingIconPicker = true
                        } label: {
                            HStack {
                                Image(systemName: icon)
                                    .foregroundColor(Color(color))
                                Text("Change")
                                    .font(.caption)
                            }
                        }
                    }
                    
                    HStack {
                        Text("Budget Limit")
                        Spacer()
                        TextField("$0.00", text: $limit)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                } header: {
                    Text("\(categoryType.rawValue) Category")
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
                    Button("Add") {
                        saveCategory()
                    }
                    .disabled(name.isEmpty || limit.isEmpty)
                }
            }
            .sheet(isPresented: $showingIconPicker) {
                CategoryIconPickerView(selectedIcon: $icon, selectedColor: $color)
            }
        }
    }
    
    private func saveCategory() {
        guard let limitValue = Double(limit) else { return }
        
        let newCategory = BudgetCategory(
            name: name,
            icon: icon,
            color: color,
            limit: limitValue,
            type: categoryType
        )
        
        onSave(newCategory)
        dismiss()
    }
}

// MARK: - Category Icon Picker View

struct CategoryIconPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedIcon: String
    @Binding var selectedColor: String
    
    private let icons = [
        "house.fill", "car.fill", "cart.fill", "fork.knife",
        "film.fill", "gamecontroller.fill", "paintbrush.fill", "book.fill",
        "heart.fill", "cross.case.fill", "figure.run", "trophy.fill",
        "briefcase.fill", "phone.fill", "wifi", "bolt.fill",
        "leaf.fill", "pawprint.fill", "gift.fill", "balloon.fill",
        "graduationcap.fill", "airplane", "bed.double.fill", "lamp.fill",
        "wrench.fill", "scissors", "music.note", "bag.fill",
        "creditcard.fill", "banknote", "chart.bar.fill", "shield.fill"
    ]
    
    private let colors: [(name: String, color: Color)] = [
        ("blue", .blue),
        ("purple", .purple),
        ("pink", .pink),
        ("red", .red),
        ("orange", .orange),
        ("yellow", .yellow),
        ("green", .green),
        ("teal", .teal),
        ("indigo", .indigo),
        ("cyan", .cyan)
    ]
    
    private let columns = [
        GridItem(.adaptive(minimum: 60), spacing: 16)
    ]
    
    private var currentColor: Color {
        colors.first(where: { $0.name == selectedColor })?.color ?? .blue
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Icon Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Choose Icon")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(icons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.system(size: 24))
                                        .foregroundColor(currentColor)
                                        .frame(width: 56, height: 56)
                                        .background(
                                            selectedIcon == icon 
                                            ? currentColor.opacity(0.15)
                                            : Color.gray.opacity(0.1)
                                        )
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .strokeBorder(
                                                    selectedIcon == icon ? currentColor : Color.clear,
                                                    lineWidth: 2
                                                )
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Color Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Choose Color")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(colors, id: \.name) { colorItem in
                                Button {
                                    selectedColor = colorItem.name
                                } label: {
                                    Circle()
                                        .fill(colorItem.color)
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Circle()
                                                .strokeBorder(
                                                    selectedColor == colorItem.name ? Color.primary : Color.clear,
                                                    lineWidth: 3
                                                )
                                        )
                                        .overlay(
                                            selectedColor == colorItem.name ?
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(.white)
                                            : nil
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Preview
                    VStack(spacing: 16) {
                        Text("Preview")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            Image(systemName: selectedIcon)
                                .font(.system(size: 72))
                                .foregroundColor(currentColor)
                            
                            Text(selectedColor.capitalized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 20)
            }
            .navigationTitle("Icon & Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    EditBudgetView()
        .environmentObject(DataManager())
        .environmentObject(ThemeManager())
}
