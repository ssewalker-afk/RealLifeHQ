import SwiftUI

// MARK: - Meal Plan Detail View
// Shows the full meal plan with daily breakdown

struct MealPlanDetailView: View {
    let mealPlan: MealPlan
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    @State private var showingDeleteAlert = false
    @State private var showingGenerateShoppingList = false
    
    var sortedDays: [(Date, MealPlan.DayMeals)] {
        mealPlan.meals.sorted { $0.key < $1.key }
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Card
                    headerCard
                    
                    // Action Buttons
                    actionButtons
                    
                    // Daily Meals
                    ForEach(sortedDays, id: \.0) { date, dayMeals in
                        DayMealsCard(date: date, dayMeals: dayMeals, includeMeals: mealPlan.includeMeals)
                    }
                }
                .padding()
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle(mealPlan.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete Meal Plan", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                }
            }
            .alert("Delete Meal Plan", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    dataManager.deleteMealPlan(mealPlan)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this meal plan? This action cannot be undone.")
            }
            .sheet(isPresented: $showingGenerateShoppingList) {
                GenerateShoppingListView(mealPlan: mealPlan)
            }
        }
    }
    
    // MARK: - Header Card
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(mealPlan.dateRange)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                            Text("\(mealPlan.numberOfDays) days")
                                .font(.subheadline)
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: "fork.knife")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                            Text("\(totalMealCount) meals")
                                .font(.subheadline)
                        }
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if mealPlan.endDate >= Date() {
                    Text("Active")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .cornerRadius(8)
                }
            }
            
            Divider()
            
            // Included Meals
            HStack(spacing: 8) {
                Text("Meals:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if mealPlan.includeMeals.breakfast {
                    MealBadge(icon: "sunrise.fill", text: "Breakfast", color: .orange)
                }
                if mealPlan.includeMeals.lunch {
                    MealBadge(icon: "sun.max.fill", text: "Lunch", color: .yellow)
                }
                if mealPlan.includeMeals.dinner {
                    MealBadge(icon: "moon.stars.fill", text: "Dinner", color: .purple)
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                showingGenerateShoppingList = true
            } label: {
                HStack {
                    Image(systemName: "cart.fill.badge.plus")
                    Text("Generate Shopping List")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(
                    LinearGradient(
                        colors: [
                            themeManager.currentTheme.primaryColor,
                            themeManager.currentTheme.accentColor
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
        }
    }
    
    private var totalMealCount: Int {
        var count = 0
        for (_, dayMeals) in mealPlan.meals {
            if dayMeals.breakfast != nil { count += 1 }
            if dayMeals.lunch != nil { count += 1 }
            if dayMeals.dinner != nil { count += 1 }
        }
        return count
    }
}

// MARK: - Day Meals Card

struct DayMealsCard: View {
    let date: Date
    let dayMeals: MealPlan.DayMeals
    let includeMeals: MealPlan.IncludedMeals
    @EnvironmentObject var themeManager: ThemeManager
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(dateFormatter.string(from: date))
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                
                if isToday {
                    Text("Today")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(themeManager.currentTheme.accentColor)
                        .cornerRadius(6)
                }
            }
            
            Divider()
            
            if includeMeals.breakfast {
                MealDetailRow(
                    icon: "sunrise.fill",
                    color: .orange,
                    mealType: "Breakfast",
                    recipePair: dayMeals.breakfast
                )
            }
            
            if includeMeals.lunch {
                MealDetailRow(
                    icon: "sun.max.fill",
                    color: .yellow,
                    mealType: "Lunch",
                    recipePair: dayMeals.lunch
                )
            }
            
            if includeMeals.dinner {
                MealDetailRow(
                    icon: "moon.stars.fill",
                    color: .purple,
                    mealType: "Dinner",
                    recipePair: dayMeals.dinner
                )
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
        .overlay(
            isToday
            ? RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.currentTheme.accentColor, lineWidth: 2)
            : nil
        )
    }
}

// MARK: - Meal Detail Row

struct MealDetailRow: View {
    let icon: String
    let color: Color
    let mealType: String
    let recipePair: MealPlan.RecipeServingPair?
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(mealType)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                if let pair = recipePair {
                    NavigationLink(destination: RecipeDetailView(recipe: pair.recipe)) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pair.recipe.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 10) {
                                Text("\(pair.servings) servings")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("•")
                                    .foregroundColor(.secondary)
                                
                                Text(pair.recipe.totalTimeString)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } else {
                    Text("No recipe selected")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            
            Spacer()
            
            if recipePair != nil {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Meal Badge

struct MealBadge: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption)
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .cornerRadius(6)
    }
}

// MARK: - Generate Shopping List View

struct GenerateShoppingListView: View {
    let mealPlan: MealPlan
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    @State private var allIngredients: [Recipe.Ingredient] = []
    @State private var selectedIngredients: Set<UUID> = []
    @State private var showingSuccessAlert = false
    @State private var itemsAddedCount = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if allIngredients.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "cart.fill.badge.questionmark")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No ingredients found")
                            .font(.headline)
                        Text("Add recipes to your meal plan to generate a shopping list")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Spacer()
                    }
                    .padding()
                } else {
                    // Instructions header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select the ingredients you need to buy. Uncheck items you already have at home.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(themeManager.currentTheme.cardColor)
                    }
                    
                    // Ingredients list
                    List {
                        ForEach(allIngredients) { ingredient in
                            IngredientSelectionRow(
                                ingredient: ingredient,
                                isSelected: selectedIngredients.contains(ingredient.id)
                            ) {
                                toggleIngredientSelection(ingredient.id)
                            }
                        }
                    }
                    .listStyle(.plain)
                    
                    // Action button
                    VStack(spacing: 12) {
                        Button {
                            addToShoppingList()
                        } label: {
                            HStack {
                                Image(systemName: "cart.fill.badge.plus")
                                Text("Add \(selectedIngredients.count) Items to Shopping List")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                selectedIngredients.isEmpty 
                                ? Color.gray 
                                : themeManager.currentTheme.primaryColor
                            )
                            .cornerRadius(12)
                        }
                        .disabled(selectedIngredients.isEmpty)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                    .padding(.top, 12)
                    .background(themeManager.currentTheme.cardColor)
                    .shadow(color: .black.opacity(0.1), radius: 5, y: -2)
                }
            }
            .navigationTitle("Generate Shopping List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !allIngredients.isEmpty {
                        Button(selectedIngredients.count == allIngredients.count ? "Deselect All" : "Select All") {
                            toggleSelectAll()
                        }
                        .disabled(allIngredients.isEmpty)
                    }
                }
            }
            .onAppear {
                // Load ingredients once and cache them
                allIngredients = mealPlan.getAllIngredients()
                // Select all by default
                selectedIngredients = Set(allIngredients.map { $0.id })
            }
            .alert("Added to Shopping List", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("\(itemsAddedCount) items added to your shopping list successfully!")
            }
        }
    }
    
    private func toggleIngredientSelection(_ id: UUID) {
        if selectedIngredients.contains(id) {
            selectedIngredients.remove(id)
        } else {
            selectedIngredients.insert(id)
        }
    }
    
    private func toggleSelectAll() {
        if selectedIngredients.count == allIngredients.count {
            selectedIngredients.removeAll()
        } else {
            selectedIngredients = Set(allIngredients.map { $0.id })
        }
    }
    
    private func addToShoppingList() {
        var addedCount = 0
        
        for ingredient in allIngredients where selectedIngredients.contains(ingredient.id) {
            let shoppingItem = ShoppingItem(
                name: ingredient.name,
                quantity: "\(ingredient.amount) \(ingredient.unit)".trimmingCharacters(in: .whitespaces),
                category: categorizeIngredient(ingredient.name)
            )
            dataManager.addShoppingItem(shoppingItem)
            addedCount += 1
        }
        
        itemsAddedCount = addedCount
        showingSuccessAlert = true
    }
    
    private func categorizeIngredient(_ name: String) -> ShoppingItem.ShoppingCategory {
        let lowercased = name.lowercased()
        
        let produceKeywords = ["lettuce", "tomato", "onion", "garlic", "potato", "carrot", "celery", "pepper", "cucumber", "spinach", "kale", "broccoli", "cauliflower", "mushroom", "zucchini", "squash", "apple", "banana", "orange", "lemon", "lime", "berry", "fruit", "vegetable", "avocado", "cilantro", "parsley", "basil", "herb"]
        if produceKeywords.contains(where: { lowercased.contains($0) }) { return .produce }
        
        let dairyKeywords = ["milk", "cheese", "yogurt", "cream", "butter", "sour cream", "cottage cheese", "parmesan", "mozzarella", "cheddar"]
        if dairyKeywords.contains(where: { lowercased.contains($0) }) { return .dairy }
        
        let meatKeywords = ["chicken", "beef", "pork", "turkey", "fish", "salmon", "tuna", "shrimp", "steak", "ground beef", "bacon", "sausage", "ham", "meat"]
        if meatKeywords.contains(where: { lowercased.contains($0) }) { return .meat }
        
        let bakeryKeywords = ["bread", "bun", "roll", "bagel", "croissant", "muffin", "tortilla"]
        if bakeryKeywords.contains(where: { lowercased.contains($0) }) { return .bakery }
        
        let pantryKeywords = ["flour", "sugar", "salt", "pepper", "spice", "rice", "pasta", "beans", "oil", "vinegar", "sauce", "ketchup", "mustard"]
        if pantryKeywords.contains(where: { lowercased.contains($0) }) { return .pantry }
        
        return .other
    }
}

// MARK: - Ingredient Selection Row

struct IngredientSelectionRow: View {
    let ingredient: Recipe.Ingredient
    let isSelected: Bool
    let onTap: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? themeManager.currentTheme.primaryColor : .gray)
                
                Text(ingredient.displayText)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .contentShape(Rectangle())
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MealPlanDetailView(mealPlan: MealPlan(
        name: "Week of March 3rd",
        startDate: Date(),
        numberOfDays: 7,
        meals: [:]
    ))
    .environmentObject(ThemeManager())
    .environmentObject(DataManager())
}
