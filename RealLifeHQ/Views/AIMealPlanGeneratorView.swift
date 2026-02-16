// MARK: - AI Meal Plan Generator View (DEPRECATED)
// This file has been deprecated. External AI integrations have been removed.
// See APPLE_INTELLIGENCE_NOTES.md for information about using Apple Intelligence.

/*
 DEPRECATION NOTICE
 ==================
 This view has been removed from active use.
 Remove this file from Build Phases → Compile Sources to prevent compilation.
 See NEXT_STEPS.md for instructions.
 */

#if false // Disable compilation

import SwiftUI

struct AIMealPlanGeneratorView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var aiService = AIServiceManager.shared
    @State private var planName: String = ""
    @State private var planDescription: String = ""
    @State private var numberOfDays: Int = 7
    @State private var selectedCuisine: String? = nil
    @State private var dietaryRestrictions: Set<String> = []
    @State private var servingsPerMeal: Int = 4
    @State private var maxPrepTimePerMeal: Int? = nil
    @State private var showPrepTimeLimit = false
    @State private var includeBreakfast = true
    @State private var includeLunch = true
    @State private var includeDinner = true
    @State private var isGenerating = false
    @State private var generatedMealPlan: MealPlan?
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingAISettings = false
    
    // Cuisine options
    private let cuisines = [
        "Italian", "Mexican", "Chinese", "Japanese", "Indian", "Thai",
        "French", "Mediterranean", "American", "Korean", "Greek", "Spanish",
        "Vietnamese", "Middle Eastern", "Brazilian", "Caribbean"
    ]
    
    // Common dietary restrictions
    private let dietaryOptions = [
        "Vegetarian", "Vegan", "Gluten-Free", "Dairy-Free",
        "Nut-Free", "Keto", "Paleo", "Low-Carb", "Low-Sodium"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                // AI Provider Status
                Section {
                    HStack {
                        Image(systemName: aiService.currentProvider.icon)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Using \(aiService.currentProvider.rawValue)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            if aiService.currentProvider.requiresAPIKey {
                                if aiService.hasAPIKey(for: aiService.currentProvider) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                        Text("API Key Configured")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                } else {
                                    HStack {
                                        Image(systemName: "exclamationmark.circle.fill")
                                            .foregroundColor(.red)
                                            .font(.caption)
                                        Text("No API Key - Please configure")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            showingAISettings = true
                        } label: {
                            Text("Change")
                                .font(.caption)
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                    }
                }
                
                // Plan Details
                Section {
                    TextField("Meal Plan Name", text: $planName)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Describe your preferences (optional)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $planDescription)
                            .frame(minHeight: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        
                        if planDescription.isEmpty {
                            Text("Examples: \"Quick weeknight dinners\", \"Meal prep friendly\", \"Family-friendly meals\"")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    .padding(.vertical, 4)
                    
                    Stepper("Number of Days: \(numberOfDays)", value: $numberOfDays, in: 1...14)
                } header: {
                    Text("Meal Plan Details")
                }
                
                // Meals to Include
                Section {
                    Toggle("Include Breakfast", isOn: $includeBreakfast)
                    Toggle("Include Lunch", isOn: $includeLunch)
                    Toggle("Include Dinner", isOn: $includeDinner)
                } header: {
                    Text("Meals to Include")
                } footer: {
                    if !includeBreakfast && !includeLunch && !includeDinner {
                        Text("⚠️ You must select at least one meal type.")
                            .foregroundColor(.red)
                    }
                }
                
                // Cuisine Selection
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // "Any" option
                            Button {
                                selectedCuisine = nil
                            } label: {
                                Text("Any")
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCuisine == nil ? themeManager.currentTheme.primaryColor : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedCuisine == nil ? .white : .primary)
                                    .cornerRadius(20)
                            }
                            
                            ForEach(cuisines, id: \.self) { cuisine in
                                Button {
                                    selectedCuisine = cuisine
                                } label: {
                                    Text(cuisine)
                                        .font(.subheadline)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedCuisine == cuisine ? themeManager.currentTheme.primaryColor : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedCuisine == cuisine ? .white : .primary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                } header: {
                    Text("Cuisine Type (Optional)")
                }
                
                // Dietary Restrictions
                Section {
                    ForEach(dietaryOptions, id: \.self) { option in
                        Button {
                            if dietaryRestrictions.contains(option) {
                                dietaryRestrictions.remove(option)
                            } else {
                                dietaryRestrictions.insert(option)
                            }
                        } label: {
                            HStack {
                                Text(option)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if dietaryRestrictions.contains(option) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(themeManager.currentTheme.primaryColor)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Dietary Restrictions (Optional)")
                }
                
                // Meal Parameters
                Section {
                    Stepper("Servings per Meal: \(servingsPerMeal)", value: $servingsPerMeal, in: 1...12)
                    
                    Toggle("Limit Prep Time", isOn: $showPrepTimeLimit)
                        .onChange(of: showPrepTimeLimit) { _, newValue in
                            if !newValue {
                                maxPrepTimePerMeal = nil
                            } else {
                                maxPrepTimePerMeal = 30
                            }
                        }
                    
                    if showPrepTimeLimit {
                        Stepper("Max Prep per Meal: \(maxPrepTimePerMeal ?? 30) min", value: Binding(
                            get: { maxPrepTimePerMeal ?? 30 },
                            set: { maxPrepTimePerMeal = $0 }
                        ), in: 5...120, step: 5)
                    }
                } header: {
                    Text("Meal Parameters")
                }
                
                // Generate Button
                Section {
                    Button {
                        generateMealPlan()
                    } label: {
                        HStack {
                            Spacer()
                            
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .padding(.trailing, 8)
                                Text("Generating Meal Plan...")
                            } else {
                                Image(systemName: "sparkles")
                                Text("Generate Meal Plan")
                            }
                            
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .background(canGenerate ? themeManager.currentTheme.primaryColor : Color.gray)
                        .cornerRadius(10)
                    }
                    .disabled(!canGenerate || isGenerating)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                } footer: {
                    if canGenerate {
                        Text("This will generate \(totalMealsCount) recipes for your \(numberOfDays)-day meal plan.")
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("AI Meal Plan Generator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isGenerating)
                }
            }
            .sheet(isPresented: $showingAISettings) {
                AISettingsView()
            }
            .sheet(item: $generatedMealPlan) { mealPlan in
                GeneratedMealPlanPreviewView(mealPlan: mealPlan) { savedMealPlan in
                    // Save all recipes
                    for (_, dayMeals) in savedMealPlan.meals {
                        if let breakfast = dayMeals.breakfast {
                            dataManager.addRecipe(breakfast)
                        }
                        if let lunch = dayMeals.lunch {
                            dataManager.addRecipe(lunch)
                        }
                        if let dinner = dayMeals.dinner {
                            dataManager.addRecipe(dinner)
                        }
                    }
                    
                    // Save the meal plan
                    dataManager.addMealPlan(savedMealPlan)
                    dismiss()
                }
            }
            .alert("Error Generating Meal Plan", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
                if !aiService.hasAPIKey(for: aiService.currentProvider) && aiService.currentProvider.requiresAPIKey {
                    Button("Configure API Key") {
                        showingAISettings = true
                    }
                }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var canGenerate: Bool {
        !planName.isEmpty && 
        (includeBreakfast || includeLunch || includeDinner) &&
        !isGenerating && 
        (aiService.hasAPIKey(for: aiService.currentProvider) || !aiService.currentProvider.requiresAPIKey)
    }
    
    private var totalMealsCount: Int {
        var count = 0
        if includeBreakfast { count += numberOfDays }
        if includeLunch { count += numberOfDays }
        if includeDinner { count += numberOfDays }
        return count
    }
    
    private func generateMealPlan() {
        guard canGenerate else { return }
        
        isGenerating = true
        
        Task {
            do {
                let preferences = MealPlanPreferences(
                    preferredCuisine: selectedCuisine,
                    dietaryRestrictions: Array(dietaryRestrictions),
                    maxPrepTimePerMeal: maxPrepTimePerMeal,
                    servingsPerMeal: servingsPerMeal,
                    includeBreakfast: includeBreakfast,
                    includeLunch: includeLunch,
                    includeDinner: includeDinner
                )
                
                let dayMealsArray = try await aiService.generateMealPlan(
                    numberOfDays: numberOfDays,
                    preferences: preferences
                )
                
                // Convert array to dictionary with dates
                var mealsDict: [Date: MealPlan.DayMeals] = [:]
                let startDate = Calendar.current.startOfDay(for: Date())
                
                for (index, dayMeals) in dayMealsArray.enumerated() {
                    if let date = Calendar.current.date(byAdding: .day, value: index, to: startDate) {
                        mealsDict[date] = dayMeals
                    }
                }
                
                let mealPlan = MealPlan(
                    name: planName,
                    startDate: startDate,
                    numberOfDays: numberOfDays,
                    meals: mealsDict,
                    createdDate: Date()
                )
                
                await MainActor.run {
                    generatedMealPlan = mealPlan
                    isGenerating = false
                }
            } catch let error as AIError {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                    showingError = true
                    isGenerating = false
                }
            }
        }
    }
}

// MARK: - Generated Meal Plan Preview View

struct GeneratedMealPlanPreviewView: View {
    let mealPlan: MealPlan
    let onSave: (MealPlan) -> Void
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedDayIndex = 0
    
    private var sortedDates: [Date] {
        mealPlan.meals.keys.sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Day selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(sortedDates.indices, id: \.self) { index in
                            Button {
                                selectedDayIndex = index
                            } label: {
                                VStack(spacing: 4) {
                                    Text("Day \(index + 1)")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    Text(sortedDates[index].formatted(.dateTime.month().day()))
                                        .font(.caption2)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedDayIndex == index ? themeManager.currentTheme.primaryColor : Color.gray.opacity(0.2))
                                .foregroundColor(selectedDayIndex == index ? .white : .primary)
                                .cornerRadius(20)
                            }
                        }
                    }
                    .padding()
                }
                .background(themeManager.currentTheme.cardColor)
                
                Divider()
                
                // Meals for selected day
                ScrollView {
                    VStack(spacing: 16) {
                        if selectedDayIndex < sortedDates.count {
                            let date = sortedDates[selectedDayIndex]
                            if let dayMeals = mealPlan.meals[date] {
                                if let breakfast = dayMeals.breakfast {
                                    MealCard(title: "Breakfast", recipe: breakfast)
                                }
                                
                                if let lunch = dayMeals.lunch {
                                    MealCard(title: "Lunch", recipe: lunch)
                                }
                                
                                if let dinner = dayMeals.dinner {
                                    MealCard(title: "Dinner", recipe: dinner)
                                }
                            }
                        }
                        
                        // AI Attribution
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                            Text("Generated by AI")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    .padding()
                }
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle(mealPlan.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Discard") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(mealPlan)
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Meal Card View

struct MealCard: View {
    let title: String
    let recipe: Recipe
    
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(recipe.name)
                        .font(.headline)
                }
                
                Spacer()
                
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .font(.title3)
                }
            }
            
            // Quick Info
            HStack {
                Label("\(recipe.prepTime) min prep", systemImage: "clock")
                Label("\(recipe.cookTime) min cook", systemImage: "flame")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            // Expanded Content
            if isExpanded {
                Divider()
                
                // Ingredients
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ForEach(recipe.ingredients.prefix(5), id: \.self) { ingredient in
                        HStack(spacing: 8) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 4))
                                .foregroundColor(themeManager.currentTheme.accentColor)
                            Text(ingredient)
                                .font(.caption)
                        }
                    }
                    
                    if recipe.ingredients.count > 5 {
                        Text("+ \(recipe.ingredients.count - 5) more ingredients")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
}

#Preview {
    AIMealPlanGeneratorView()
        .environmentObject(DataManager())
        .environmentObject(ThemeManager())
}
#endif // End disabled code

