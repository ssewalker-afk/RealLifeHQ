import SwiftUI

// MARK: - Add Recipe View

struct AddRecipeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var name = ""
    @State private var category = ""
    @State private var prepTime = ""
    @State private var cookTime = ""
    @State private var servings = ""
    @State private var ingredientText = ""
    @State private var ingredients: [String] = []
    @State private var instructionText = ""
    @State private var instructions: [String] = []
    @State private var notes = ""
    
    var body: some View {
        Form {
            Section("Basic Info") {
                    TextField("Recipe Name", text: $name)
                    TextField("Category (e.g., Dinner, Dessert)", text: $category)
                    
                    HStack {
                        TextField("Prep Time", text: $prepTime)
                            .keyboardType(.numberPad)
                        Text("min")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        TextField("Cook Time", text: $cookTime)
                            .keyboardType(.numberPad)
                        Text("min")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        TextField("Servings", text: $servings)
                            .keyboardType(.numberPad)
                        Text("servings")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Ingredients") {
                    HStack {
                        TextField("Add ingredient", text: $ingredientText)
                        
                        Button {
                            addIngredient()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                        .disabled(ingredientText.isEmpty)
                    }
                    
                    ForEach(Array(ingredients.enumerated()), id: \.offset) { index, ingredient in
                        HStack {
                            Text(ingredient)
                            Spacer()
                            Button {
                                ingredients.remove(at: index)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                Section("Instructions") {
                    HStack {
                        TextField("Add step", text: $instructionText)
                        
                        Button {
                            addInstruction()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                        .disabled(instructionText.isEmpty)
                    }
                    
                    ForEach(Array(instructions.enumerated()), id: \.offset) { index, instruction in
                        HStack(alignment: .top) {
                            Text("\(index + 1).")
                                .fontWeight(.semibold)
                            Text(instruction)
                            Spacer()
                            Button {
                                instructions.remove(at: index)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveRecipe()
                    }
                    .disabled(!canSave)
                }
            }
    }
    
    private var canSave: Bool {
        !name.isEmpty &&
        !category.isEmpty &&
        !prepTime.isEmpty &&
        !cookTime.isEmpty &&
        !servings.isEmpty &&
        !ingredients.isEmpty &&
        !instructions.isEmpty
    }
    
    private func addIngredient() {
        let trimmed = ingredientText.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            ingredients.append(trimmed)
            ingredientText = ""
        }
    }
    
    private func addInstruction() {
        let trimmed = instructionText.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            instructions.append(trimmed)
            instructionText = ""
        }
    }
    
    private func saveRecipe() {
        guard let prep = Int(prepTime),
              let cook = Int(cookTime),
              let servs = Int(servings) else { return }
        
        let newRecipe = Recipe(
            name: name,
            category: category,
            prepTime: prep,
            cookTime: cook,
            servings: servs,
            ingredients: ingredients,
            instructions: instructions,
            notes: notes.isEmpty ? nil : notes
        )
        
        dataManager.addRecipe(newRecipe)
        dismiss()
    }
}

// MARK: - Meal Plans Tab

struct MealPlansTabView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingCreateMealPlan = false
    
    var body: some View {
        ZStack {
            if dataManager.mealPlans.isEmpty {
                emptyStateView
            } else {
                mealPlansList
            }
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingCreateMealPlan = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreateMealPlan) {
            NavigationStack {
                CreateMealPlanView()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(themeManager.currentTheme.primaryColor.opacity(0.5))
            
            Text("No Meal Plans")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create a meal plan to organize your recipes")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Create Meal Plan") {
                showingCreateMealPlan = true
            }
            .buttonStyle(.borderedProminent)
            .tint(themeManager.currentTheme.primaryColor)
        }
        .padding()
    }
    
    private var mealPlansList: some View {
        List {
            ForEach(dataManager.mealPlans.sorted(by: { $0.createdDate > $1.createdDate })) { mealPlan in
                NavigationLink(destination: MealPlanDetailView(mealPlan: mealPlan)) {
                    MealPlanRow(mealPlan: mealPlan)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        dataManager.deleteMealPlan(mealPlan)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Meal Plan Row

struct MealPlanRow: View {
    let mealPlan: MealPlan
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(mealPlan.name)
                .font(.headline)
            
            HStack {
                Label(mealPlan.dateRange, systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label("\(mealPlan.numberOfDays) days", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Meal Plan Detail View

struct MealPlanDetailView: View {
    let mealPlan: MealPlan
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var showingEditMealPlan = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(mealPlan.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(mealPlan.dateRange)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(themeManager.currentTheme.cardColor)
                .cornerRadius(12)
                
                // Days
                ForEach(0..<mealPlan.numberOfDays, id: \.self) { dayIndex in
                    let date = Calendar.current.date(byAdding: .day, value: dayIndex, to: mealPlan.startDate) ?? mealPlan.startDate
                    
                    if let dayMeals = mealPlan.meals[date] {
                        DayMealsView(date: date, meals: dayMeals)
                    }
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
                    Button {
                        showingEditMealPlan = true
                    } label: {
                        Label("Edit Meal Plan", systemImage: "pencil")
                    }
                    
                    Divider()
                    
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
        .sheet(isPresented: $showingEditMealPlan) {
            NavigationStack {
                EditMealPlanView(mealPlan: mealPlan)
            }
        }
        .alert("Delete Meal Plan", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataManager.deleteMealPlan(mealPlan)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete '\(mealPlan.name)'? This action cannot be undone.")
        }
    }
}

// MARK: - Day Meals View

struct DayMealsView: View {
    let date: Date
    let meals: MealPlan.DayMeals
    @EnvironmentObject var themeManager: ThemeManager
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(dateString)
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.primaryColor)
            
            // Breakfast
            if let breakfast = meals.breakfast {
                MealCardView(mealType: "Breakfast", recipe: breakfast)
            }
            
            // Lunch
            if let lunch = meals.lunch {
                MealCardView(mealType: "Lunch", recipe: lunch)
            }
            
            // Dinner
            if let dinner = meals.dinner {
                MealCardView(mealType: "Dinner", recipe: dinner)
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
}

// MARK: - Meal Card View

struct MealCardView: View {
    let mealType: String
    let recipe: Recipe
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mealType)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(recipe.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Label(recipe.totalTimeString, systemImage: "clock")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Edit Meal Plan View

struct EditMealPlanView: View {
    let mealPlan: MealPlan
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var name = ""
    @State private var numberOfDays = 7
    @State private var startDate = Date()
    
    let dayOptions = [1, 3, 5, 7, 10, 14]
    
    var body: some View {
        Form {
            Section("Meal Plan Details") {
                TextField("Plan Name", text: $name)
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                
                Picker("Number of Days", selection: $numberOfDays) {
                    ForEach(dayOptions, id: \.self) { days in
                        Text("\(days) days").tag(days)
                    }
                }
            }
            
            Section {
                Text("Note: Changing the number of days or start date will regenerate the meal schedule using your existing recipes.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Edit Meal Plan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveMealPlan()
                }
                .disabled(name.isEmpty)
            }
        }
        .onAppear {
            // Initialize with existing meal plan data
            name = mealPlan.name
            numberOfDays = mealPlan.numberOfDays
            startDate = mealPlan.startDate
        }
    }
    
    private func saveMealPlan() {
        // If days or start date changed, regenerate meal schedule
        if numberOfDays != mealPlan.numberOfDays || !Calendar.current.isDate(startDate, inSameDayAs: mealPlan.startDate) {
            // Regenerate meals for new schedule
            var newMeals: [Date: MealPlan.DayMeals] = [:]
            let availableRecipes = dataManager.recipes
            
            for dayIndex in 0..<numberOfDays {
                let date = Calendar.current.date(byAdding: .day, value: dayIndex, to: startDate) ?? startDate
                
                // Try to preserve existing meals where possible, or assign random recipes
                let oldDate = Calendar.current.date(byAdding: .day, value: dayIndex, to: mealPlan.startDate)
                let existingMeals = oldDate.flatMap { mealPlan.meals[$0] }
                
                let breakfast = existingMeals?.breakfast ?? availableRecipes.randomElement()
                let lunch = existingMeals?.lunch ?? availableRecipes.randomElement()
                let dinner = existingMeals?.dinner ?? availableRecipes.randomElement()
                
                newMeals[date] = MealPlan.DayMeals(
                    breakfast: breakfast,
                    lunch: lunch,
                    dinner: dinner
                )
            }
            
            let updatedPlan = MealPlan(
                id: mealPlan.id,
                name: name,
                startDate: startDate,
                numberOfDays: numberOfDays,
                meals: newMeals,
                createdDate: mealPlan.createdDate
            )
            
            dataManager.updateMealPlan(updatedPlan)
        } else {
            // Just update the name
            var updatedPlan = mealPlan
            updatedPlan.name = name
            dataManager.updateMealPlan(updatedPlan)
        }
        
        dismiss()
    }
}

// Continued in RecipesViewPart3.swift...
