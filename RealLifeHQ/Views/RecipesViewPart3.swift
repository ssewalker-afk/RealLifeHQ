import SwiftUI

// MARK: - Create Meal Plan View

struct CreateMealPlanView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var name = ""
    @State private var numberOfDays = 7
    @State private var startDate = Date()
    @State private var isGenerating = false
    @State private var showingNoRecipesAlert = false
    @State private var showingSuccessAlert = false
    @State private var generatedMealCount = 0
    
    let dayOptions = [1, 3, 5, 7, 10, 14]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Meal Plan Details") {
                    TextField("Plan Name (e.g., Week of Jan 24)", text: $name)
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    
                    Picker("Number of Days", selection: $numberOfDays) {
                        ForEach(dayOptions, id: \.self) { days in
                            Text("\(days) days").tag(days)
                        }
                    }
                }
                
                if dataManager.recipes.isEmpty {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("No Recipes Yet")
                                    .fontWeight(.semibold)
                            }
                            
                            Text("You need to add some recipes before creating a meal plan.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button {
                                addSampleRecipes()
                            } label: {
                                Label("Add Sample Recipes", systemImage: "plus.circle.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(themeManager.currentTheme.accentColor)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(dataManager.recipes.count) recipes available")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if dataManager.recipes.count > 0 {
                                Text("AI will randomly assign them to meals")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "fork.knife")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                }
                
                Section {
                    Button {
                        generateMealPlan()
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                            Text(dataManager.recipes.isEmpty ? "Add Recipes First" : "Generate AI Meal Plan")
                            
                            if isGenerating {
                                Spacer()
                                ProgressView()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(name.isEmpty || isGenerating || dataManager.recipes.isEmpty)
                } footer: {
                    if dataManager.recipes.isEmpty {
                        Text("Add at least one recipe to generate a meal plan")
                            .font(.caption)
                    } else {
                        Text("AI will create a balanced meal plan using your existing recipes")
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("New Meal Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("No Recipes Available", isPresented: $showingNoRecipesAlert) {
                Button("Add Recipes", action: {
                    dismiss()
                })
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Please add some recipes first before creating a meal plan.")
            }
            .alert("Meal Plan Created!", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Generated \(generatedMealCount) meals for your \(numberOfDays)-day plan")
            }
        }
    }
    
    private func addSampleRecipes() {
        // Add 5 sample recipes to get started
        let sampleRecipes = [
            Recipe(
                name: "Scrambled Eggs & Toast",
                category: "Breakfast",
                prepTime: 5,
                cookTime: 10,
                servings: 2,
                ingredients: ["4 eggs", "2 slices bread", "butter", "salt", "pepper"],
                instructions: ["Beat eggs in bowl", "Heat butter in pan", "Cook eggs until fluffy", "Toast bread", "Serve together"],
                notes: "Quick and easy breakfast"
            ),
            Recipe(
                name: "Chicken Caesar Salad",
                category: "Lunch",
                prepTime: 15,
                cookTime: 15,
                servings: 2,
                ingredients: ["2 chicken breasts", "romaine lettuce", "caesar dressing", "parmesan cheese", "croutons"],
                instructions: ["Grill chicken", "Chop lettuce", "Combine ingredients", "Add dressing", "Top with parmesan"],
                notes: "Healthy lunch option"
            ),
            Recipe(
                name: "Spaghetti Bolognese",
                category: "Dinner",
                prepTime: 10,
                cookTime: 30,
                servings: 4,
                ingredients: ["1 lb ground beef", "1 onion", "2 cans tomatoes", "1 lb spaghetti", "garlic", "italian seasoning"],
                instructions: ["Cook pasta", "Brown beef with onions", "Add tomatoes and seasoning", "Simmer 20 minutes", "Serve over pasta"],
                notes: "Classic Italian dinner"
            ),
            Recipe(
                name: "Greek Yogurt Parfait",
                category: "Breakfast",
                prepTime: 5,
                cookTime: 0,
                servings: 1,
                ingredients: ["1 cup greek yogurt", "granola", "fresh berries", "honey"],
                instructions: ["Layer yogurt in bowl", "Add granola", "Top with berries", "Drizzle honey"],
                notes: "Healthy breakfast"
            ),
            Recipe(
                name: "Grilled Chicken Sandwich",
                category: "Lunch",
                prepTime: 10,
                cookTime: 15,
                servings: 2,
                ingredients: ["2 chicken breasts", "2 buns", "lettuce", "tomato", "mayo"],
                instructions: ["Grill chicken", "Toast buns", "Assemble sandwich", "Add toppings"],
                notes: "Simple lunch"
            )
        ]
        
        for recipe in sampleRecipes {
            dataManager.addRecipe(recipe)
        }
    }
    
    private func generateMealPlan() {
        if dataManager.recipes.isEmpty {
            showingNoRecipesAlert = true
            return
        }
        
        isGenerating = true
        
        // Simulate AI generation with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            createMealPlan()
            isGenerating = false
        }
    }
    
    private func createMealPlan() {
        var meals: [Date: MealPlan.DayMeals] = [:]
        let availableRecipes = dataManager.recipes
        var mealCount = 0
        
        // Generate meals for each day
        for dayIndex in 0..<numberOfDays {
            let date = Calendar.current.date(byAdding: .day, value: dayIndex, to: startDate) ?? startDate
            
            // Randomly assign recipes (in real app, this would use AI/ML)
            let breakfast = availableRecipes.randomElement()
            let lunch = availableRecipes.randomElement()
            let dinner = availableRecipes.randomElement()
            
            if breakfast != nil { mealCount += 1 }
            if lunch != nil { mealCount += 1 }
            if dinner != nil { mealCount += 1 }
            
            meals[date] = MealPlan.DayMeals(
                breakfast: breakfast,
                lunch: lunch,
                dinner: dinner
            )
        }
        
        let mealPlan = MealPlan(
            name: name,
            startDate: startDate,
            numberOfDays: numberOfDays,
            meals: meals,
            createdDate: Date()
        )
        
        dataManager.addMealPlan(mealPlan)
        
        generatedMealCount = mealCount
        showingSuccessAlert = true
    }
}

// MARK: - Shopping List Tab

struct ShoppingListTabView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingAddItem = false
    @State private var showingCopyConfirmation = false
    
    var body: some View {
        ZStack {
            if dataManager.shoppingItems.isEmpty {
                emptyStateView
            } else {
                shoppingList
            }
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingAddItem = true
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                    
                    Button {
                        copyListToClipboard()
                    } label: {
                        Label("Copy List", systemImage: "doc.on.doc")
                    }
                    .disabled(uncheckedItems.isEmpty)
                    
                    Button(role: .destructive) {
                        dataManager.clearCheckedItems()
                    } label: {
                        Label("Clear Checked", systemImage: "trash")
                    }
                    .disabled(checkedItems.isEmpty)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddShoppingItemView()
        }
        .alert("Copied to Clipboard", isPresented: $showingCopyConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Shopping list copied! You can paste it anywhere.")
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart.fill")
                .font(.system(size: 60))
                .foregroundColor(themeManager.currentTheme.primaryColor.opacity(0.5))
            
            Text("Shopping List Empty")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add items or import from a recipe")
                .foregroundColor(.secondary)
            
            Button("Add First Item") {
                showingAddItem = true
            }
            .buttonStyle(.borderedProminent)
            .tint(themeManager.currentTheme.primaryColor)
        }
    }
    
    private var shoppingList: some View {
        List {
            if !uncheckedItems.isEmpty {
                Section {
                    ForEach(sortedCategories, id: \.self) { category in
                        if let items = groupedUncheckedItems[category], !items.isEmpty {
                            DisclosureGroup(isExpanded: .constant(true)) {
                                ForEach(items) { item in
                                    ShoppingItemRow(item: item)
                                        .listRowInsets(EdgeInsets(top: 8, leading: 32, bottom: 8, trailing: 16))
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: category.icon)
                                        .font(.title3)
                                        .foregroundColor(themeManager.currentTheme.primaryColor)
                                        .frame(width: 30)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(category.rawValue)
                                            .font(.headline)
                                        
                                        Text("\(items.count) item\(items.count == 1 ? "" : "s")")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                } header: {
                    Text("Shopping List")
                        .font(.headline)
                }
            }
            
            if !checkedItems.isEmpty {
                Section {
                    ForEach(checkedItems) { item in
                        ShoppingItemRow(item: item)
                    }
                } header: {
                    HStack {
                        Text("Checked Items")
                        Spacer()
                        Text("\(checkedItems.count)")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // Sort categories in a logical store layout order
    private var sortedCategories: [ShoppingItem.ShoppingCategory] {
        let order: [ShoppingItem.ShoppingCategory] = [
            .produce,
            .meat,
            .dairy,
            .frozen,
            .bakery,
            .pantry,
            .beverages,
            .snacks,
            .other
        ]
        
        return order.filter { category in
            groupedUncheckedItems[category]?.isEmpty == false
        }
    }
    
    private var uncheckedItems: [ShoppingItem] {
        dataManager.shoppingItems.filter { !$0.isChecked }
    }
    
    private var checkedItems: [ShoppingItem] {
        dataManager.shoppingItems.filter { $0.isChecked }
    }
    
    private var groupedUncheckedItems: [ShoppingItem.ShoppingCategory: [ShoppingItem]] {
        Dictionary(grouping: uncheckedItems, by: { $0.category })
    }
    
    private func copyListToClipboard() {
        let items = uncheckedItems.map { "• \($0.quantity) \($0.name)" }.joined(separator: "\n")
        UIPasteboard.general.string = items
        showingCopyConfirmation = true
    }
}

// MARK: - Shopping Item Row

struct ShoppingItemRow: View {
    let item: ShoppingItem
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingEditSheet = false
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                dataManager.toggleShoppingItemChecked(item)
            } label: {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isChecked ? .green : .gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .strikethrough(item.isChecked)
                    .foregroundColor(item.isChecked ? .secondary : .primary)
                    .font(.subheadline)
                
                HStack(spacing: 8) {
                    Text(item.quantity)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Show category badge for checked items (since they're not grouped)
                    if item.isChecked {
                        HStack(spacing: 4) {
                            Image(systemName: item.category.icon)
                                .font(.caption2)
                            Text(item.category.rawValue)
                                .font(.caption2)
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            Button {
                showingEditSheet = true
            } label: {
                Image(systemName: "pencil.circle")
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .font(.body)
            }
            .buttonStyle(.plain)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                dataManager.deleteShoppingItem(item)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditShoppingItemView(item: item)
        }
    }
}

// MARK: - Add Shopping Item View

struct AddShoppingItemView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var name = ""
    @State private var quantity = "1"
    @State private var category: ShoppingItem.ShoppingCategory = .other
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Details") {
                    TextField("Item Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Quantity", text: $quantity)
                    
                    Picker("Category", selection: $category) {
                        ForEach(ShoppingItem.ShoppingCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        saveItem()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveItem() {
        let item = ShoppingItem(
            name: name,
            quantity: quantity,
            category: category
        )
        dataManager.addShoppingItem(item)
        dismiss()
    }
}

// MARK: - Edit Shopping Item View

struct EditShoppingItemView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    let item: ShoppingItem
    
    @State private var name: String
    @State private var quantity: String
    @State private var category: ShoppingItem.ShoppingCategory
    
    init(item: ShoppingItem) {
        self.item = item
        _name = State(initialValue: item.name)
        _quantity = State(initialValue: item.quantity)
        _category = State(initialValue: item.category)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Details") {
                    TextField("Item Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Quantity", text: $quantity)
                    
                    Picker("Category", selection: $category) {
                        ForEach(ShoppingItem.ShoppingCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                }
            }
            .navigationTitle("Edit Item")
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
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        var updatedItem = item
        updatedItem.name = name
        updatedItem.quantity = quantity
        updatedItem.category = category
        dataManager.updateShoppingItem(updatedItem)
        dismiss()
    }
}
