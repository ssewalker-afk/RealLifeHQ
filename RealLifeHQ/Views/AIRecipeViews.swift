import SwiftUI

// MARK: - AI Recipe Generation Views

// Generate Recipe from Ingredients
struct AIGenerateRecipeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var aiGenerator = AIRecipeGenerator.shared
    
    @State private var ingredientText = ""
    @State private var ingredients: [String] = []
    @State private var selectedCuisine = "Any"
    @State private var cookingTime = 30
    @State private var dietaryRestrictions: Set<String> = []
    
    @State private var isGenerating = false
    @State private var generatedRecipe: Recipe?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    let cuisines = ["Any", "Italian", "Mexican", "Chinese", "Indian", "American", "French", "Japanese", "Mediterranean"]
    let restrictions = ["Vegetarian", "Vegan", "Gluten-Free", "Dairy-Free", "Nut-Free", "Low-Carb"]
    
    var body: some View {
        NavigationView {
            Form {
                // Status Badge - Always shows Smart Recipe Builder (AI coming soon)
                Section {
                    HStack {
                        Image(systemName: "wand.and.stars")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Smart Recipe Builder")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text("Apple Intelligence integration coming in future update")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Available Ingredients") {
                    HStack {
                        TextField("Add ingredient", text: $ingredientText)
                            .textInputAutocapitalization(.never)
                        
                        Button {
                            addIngredient()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                        .disabled(ingredientText.isEmpty)
                    }
                    
                    if !ingredients.isEmpty {
                        ForEach(ingredients, id: \.self) { ingredient in
                            HStack {
                                Text(ingredient)
                                Spacer()
                                Button {
                                    ingredients.removeAll { $0 == ingredient }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                
                Section("Preferences") {
                    Picker("Cuisine Type", selection: $selectedCuisine) {
                        ForEach(cuisines, id: \.self) { cuisine in
                            Text(cuisine).tag(cuisine)
                        }
                    }
                    
                    Stepper("Cooking Time: \(cookingTime) min", value: $cookingTime, in: 10...120, step: 5)
                }
                
                Section("Dietary Restrictions") {
                    ForEach(restrictions, id: \.self) { restriction in
                        Button {
                            if dietaryRestrictions.contains(restriction) {
                                dietaryRestrictions.remove(restriction)
                            } else {
                                dietaryRestrictions.insert(restriction)
                            }
                        } label: {
                            HStack {
                                Image(systemName: dietaryRestrictions.contains(restriction) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(dietaryRestrictions.contains(restriction) ? themeManager.currentTheme.primaryColor : .gray)
                                Text(restriction)
                                    .foregroundColor(.primary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Section {
                    Button {
                        generateRecipe()
                    } label: {
                        HStack {
                            Image(systemName: "wand.and.stars")
                            Text("Create Smart Recipe")
                            
                            if isGenerating {
                                Spacer()
                                ProgressView()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(ingredients.isEmpty || isGenerating)
                } footer: {
                    Text("Smart templates will create a detailed recipe using your ingredients")
                        .font(.caption)
                }
                
                if let recipe = generatedRecipe {
                    Section("Generated Recipe") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(recipe.name)
                                .font(.headline)
                            
                            Text("Ingredients: \(recipe.ingredients.count) | Time: \(recipe.totalTime) min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button {
                                saveRecipe(recipe)
                            } label: {
                                Label("Save Recipe", systemImage: "square.and.arrow.down")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(themeManager.currentTheme.primaryColor)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("AI Recipe Generator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func addIngredient() {
        let trimmed = ingredientText.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !ingredients.contains(trimmed) {
            ingredients.append(trimmed)
            ingredientText = ""
        }
    }
    
    private func generateRecipe() {
        isGenerating = true
        
        Task {
            do {
                let recipe = try await AIRecipeGenerator.shared.generateRecipe(
                    from: ingredients,
                    cuisine: selectedCuisine.lowercased(),
                    dietaryRestrictions: Array(dietaryRestrictions),
                    cookingTime: cookingTime
                )
                
                await MainActor.run {
                    generatedRecipe = recipe
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    isGenerating = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func saveRecipe(_ recipe: Recipe) {
        dataManager.addRecipe(recipe)
        dismiss()
    }
}

// MARK: - AI Meal Plan Generator View

struct AIMealPlanGeneratorView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var aiGenerator = AIRecipeGenerator.shared
    
    @State private var planName = ""
    @State private var numberOfDays = 7
    @State private var startDate = Date()
    @State private var dailyCalories = 2000
    @State private var dietaryPreferences: Set<String> = []
    @State private var isGenerating = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    let dayOptions = [1, 3, 5, 7, 10, 14]
    let calorieOptions = [1500, 1800, 2000, 2200, 2500, 3000]
    let dietary = ["Vegetarian", "Vegan", "Pescatarian", "Keto", "Paleo", "Mediterranean"]
    
    var body: some View {
        NavigationView {
            Form {
                // Status Badge - Always shows Smart Meal Planning (AI coming soon)
                Section {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Smart Meal Planning")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text("Apple Intelligence integration coming in future update")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Plan Details") {
                    TextField("Plan Name", text: $planName)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    
                    Picker("Duration", selection: $numberOfDays) {
                        ForEach(dayOptions, id: \.self) { days in
                            Text("\(days) days").tag(days)
                        }
                    }
                }
                
                Section("Nutrition Goals") {
                    Picker("Daily Calories", selection: $dailyCalories) {
                        ForEach(calorieOptions, id: \.self) { calories in
                            Text("\(calories) cal").tag(calories)
                        }
                    }
                }
                
                Section("Dietary Preferences") {
                    ForEach(dietary, id: \.self) { preference in
                        Button {
                            if dietaryPreferences.contains(preference) {
                                dietaryPreferences.remove(preference)
                            } else {
                                dietaryPreferences.insert(preference)
                            }
                        } label: {
                            HStack {
                                Image(systemName: dietaryPreferences.contains(preference) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(dietaryPreferences.contains(preference) ? themeManager.currentTheme.primaryColor : .gray)
                                Text(preference)
                                    .foregroundColor(.primary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Section {
                    Button {
                        generateAIMealPlan()
                    } label: {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                            Text("Create Smart Meal Plan")
                            
                            if isGenerating {
                                Spacer()
                                ProgressView()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(planName.isEmpty || isGenerating)
                } footer: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Smart meal planning will create:")
                            .font(.caption)
                        Text("• Balanced nutrition across all days")
                            .font(.caption2)
                        Text("• Variety of cuisines and flavors")
                            .font(.caption2)
                        Text("• Complete recipes with instructions")
                            .font(.caption2)
                    }
                }
            }
            .navigationTitle("AI Meal Planner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func generateAIMealPlan() {
        isGenerating = true
        
        Task {
            do {
                let recipes = try await AIRecipeGenerator.shared.generateBalancedMealPlan(
                    days: numberOfDays,
                    dietaryPreferences: Array(dietaryPreferences),
                    calorieTarget: dailyCalories
                )
                
                await MainActor.run {
                    // Save generated recipes
                    for recipe in recipes {
                        dataManager.addRecipe(recipe)
                    }
                    
                    // Create meal plan
                    createMealPlanFromRecipes(recipes)
                    isGenerating = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isGenerating = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func createMealPlanFromRecipes(_ recipes: [Recipe]) {
        var meals: [Date: MealPlan.DayMeals] = [:]
        
        // Organize recipes into days
        let recipesPerDay = 3 // breakfast, lunch, dinner
        
        for dayIndex in 0..<numberOfDays {
            let date = Calendar.current.date(byAdding: .day, value: dayIndex, to: startDate) ?? startDate
            let startIdx = dayIndex * recipesPerDay
            
            let breakfast = recipes.indices.contains(startIdx) ? recipes[startIdx] : nil
            let lunch = recipes.indices.contains(startIdx + 1) ? recipes[startIdx + 1] : nil
            let dinner = recipes.indices.contains(startIdx + 2) ? recipes[startIdx + 2] : nil
            
            meals[date] = MealPlan.DayMeals(
                breakfast: breakfast,
                lunch: lunch,
                dinner: dinner
            )
        }
        
        let mealPlan = MealPlan(
            name: planName,
            startDate: startDate,
            numberOfDays: numberOfDays,
            meals: meals,
            createdDate: Date()
        )
        
        dataManager.addMealPlan(mealPlan)
    }
}
