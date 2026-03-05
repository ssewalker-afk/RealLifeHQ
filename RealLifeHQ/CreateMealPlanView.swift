import SwiftUI

// MARK: - Create Meal Plan View
// Allows users to create a new meal plan by selecting recipes

struct CreateMealPlanView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    
    @State private var planName = ""
    @State private var startDate = Date()
    @State private var numberOfDays = 7
    @State private var includeMeals = MealPlan.IncludedMeals()
    @State private var currentStep: CreationStep = .setup
    @State private var mealPlanDays: [MealPlanDay] = []
    @State private var showingAutoGenerateOptions = false
    @State private var autoGenPrioritizeFavorites = true
    @State private var autoGenAllowRepetition = true
    
    enum CreationStep {
        case setup
        case selectMeals
        case review
    }
    
    struct MealPlanDay: Identifiable {
        let id = UUID()
        let date: Date
        var breakfast: MealPlan.RecipeServingPair?
        var lunch: MealPlan.RecipeServingPair?
        var dinner: MealPlan.RecipeServingPair?
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Indicator
                progressIndicator
                
                // Step Content
                switch currentStep {
                case .setup:
                    setupStep
                case .selectMeals:
                    selectMealsStep
                case .review:
                    reviewStep
                }
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Create Meal Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Progress Indicator
    
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach([CreationStep.setup, .selectMeals, .review], id: \.self) { step in
                Circle()
                    .fill(stepIndex(step) <= stepIndex(currentStep) ? themeManager.currentTheme.primaryColor : Color.gray.opacity(0.3))
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(themeManager.currentTheme.cardColor)
    }
    
    private func stepIndex(_ step: CreationStep) -> Int {
        switch step {
        case .setup: return 0
        case .selectMeals: return 1
        case .review: return 2
        }
    }
    
    // MARK: - Step 1: Setup
    
    private var setupStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Plan Details")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    // Plan Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Plan Name")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        TextField("e.g., Week of March 3rd", text: $planName)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)
                    
                    // Start Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Start Date")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }
                    .padding(.horizontal)
                    
                    // Number of Days
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Number of Days: \(numberOfDays)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Stepper("", value: $numberOfDays, in: 1...14)
                        Text("\(numberOfDays) day\(numberOfDays == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Include Meals
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Include Meals")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            Toggle(isOn: $includeMeals.breakfast) {
                                HStack {
                                    Image(systemName: "sunrise.fill")
                                        .foregroundColor(.orange)
                                    Text("Breakfast")
                                }
                            }
                            .padding()
                            .background(themeManager.currentTheme.cardColor)
                            
                            Divider()
                            
                            Toggle(isOn: $includeMeals.lunch) {
                                HStack {
                                    Image(systemName: "sun.max.fill")
                                        .foregroundColor(.yellow)
                                    Text("Lunch")
                                }
                            }
                            .padding()
                            .background(themeManager.currentTheme.cardColor)
                            
                            Divider()
                            
                            Toggle(isOn: $includeMeals.dinner) {
                                HStack {
                                    Image(systemName: "moon.stars.fill")
                                        .foregroundColor(.purple)
                                    Text("Dinner")
                                }
                            }
                            .padding()
                            .background(themeManager.currentTheme.cardColor)
                        }
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                
                Spacer(minLength: 20)
                
                // Next Button
                Button {
                    generateMealPlanDays()
                    withAnimation {
                        currentStep = .selectMeals
                    }
                } label: {
                    Text("Next: Select Meals")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.currentTheme.primaryColor)
                        .cornerRadius(12)
                }
                .disabled(planName.isEmpty || !(includeMeals.breakfast || includeMeals.lunch || includeMeals.dinner))
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Step 2: Select Meals
    
    private var selectMealsStep: some View {
        VStack(spacing: 0) {
            // Header with Auto-Generate button
            HStack {
                Text("Select Recipes")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    showingAutoGenerateOptions = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "wand.and.stars")
                        Text("Auto")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
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
                    .cornerRadius(20)
                }
            }
            .padding()
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach($mealPlanDays) { $day in
                        DayMealSelector(day: $day, includeMeals: includeMeals)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
            }
            
            // Navigation Buttons
            HStack(spacing: 12) {
                Button {
                    withAnimation {
                        currentStep = .setup
                    }
                } label: {
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.currentTheme.cardColor)
                        .cornerRadius(12)
                }
                
                Button {
                    withAnimation {
                        currentStep = .review
                    }
                } label: {
                    Text("Review")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.currentTheme.primaryColor)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(themeManager.currentTheme.cardColor)
        }
        .sheet(isPresented: $showingAutoGenerateOptions) {
            AutoGenerateOptionsView(
                prioritizeFavorites: $autoGenPrioritizeFavorites,
                allowRepetition: $autoGenAllowRepetition,
                onGenerate: { autoGenerateMeals() }
            )
            .presentationDetents([.height(350)])
        }
    }
    
    // MARK: - Step 3: Review
    
    private var reviewStep: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Review Your Meal Plan")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // Plan Summary
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Plan Name:")
                                .fontWeight(.semibold)
                            Text(planName)
                        }
                        
                        HStack {
                            Text("Duration:")
                                .fontWeight(.semibold)
                            Text("\(numberOfDays) days")
                        }
                        
                        HStack {
                            Text("Meals per day:")
                                .fontWeight(.semibold)
                            HStack(spacing: 8) {
                                if includeMeals.breakfast {
                                    Text("Breakfast")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.orange.opacity(0.2))
                                        .cornerRadius(6)
                                }
                                if includeMeals.lunch {
                                    Text("Lunch")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.yellow.opacity(0.2))
                                        .cornerRadius(6)
                                }
                                if includeMeals.dinner {
                                    Text("Dinner")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.purple.opacity(0.2))
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(themeManager.currentTheme.cardColor)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Days Preview
                    ForEach(mealPlanDays) { day in
                        DayMealPreview(day: day, includeMeals: includeMeals)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .padding(.bottom, 80)
            }
            
            // Navigation Buttons
            HStack(spacing: 12) {
                Button {
                    withAnimation {
                        currentStep = .selectMeals
                    }
                } label: {
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.currentTheme.cardColor)
                        .cornerRadius(12)
                }
                
                Button {
                    saveMealPlan()
                } label: {
                    Text("Create Meal Plan")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.currentTheme.primaryColor)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(themeManager.currentTheme.cardColor)
        }
    }
    
    // MARK: - Helper Functions
    
    private func generateMealPlanDays() {
        mealPlanDays = (0..<numberOfDays).map { dayOffset in
            let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Calendar.current.startOfDay(for: startDate))!
            return MealPlanDay(date: date)
        }
    }
    
    private func autoGenerateMeals() {
        // Check if auto-generation is possible
        let validation = dataManager.canAutoGenerateMealPlan(includeMeals: includeMeals)
        guard validation.canGenerate else {
            // Could show an alert here, but for now we'll just return
            return
        }
        
        // Generate meals using DataManager
        let generatedMeals = dataManager.generateAutoMealPlan(
            numberOfDays: numberOfDays,
            startDate: startDate,
            includeMeals: includeMeals,
            prioritizeFavorites: autoGenPrioritizeFavorites,
            allowRepetition: autoGenAllowRepetition
        )
        
        // Update mealPlanDays with generated meals
        for (index, day) in mealPlanDays.enumerated() {
            if let dayMeals = generatedMeals[day.date] {
                mealPlanDays[index].breakfast = dayMeals.breakfast
                mealPlanDays[index].lunch = dayMeals.lunch
                mealPlanDays[index].dinner = dayMeals.dinner
            }
        }
    }
    
    private func saveMealPlan() {
        var meals: [Date: MealPlan.DayMeals] = [:]
        
        for day in mealPlanDays {
            meals[day.date] = MealPlan.DayMeals(
                breakfast: day.breakfast,
                lunch: day.lunch,
                dinner: day.dinner
            )
        }
        
        let mealPlan = MealPlan(
            name: planName,
            startDate: Calendar.current.startOfDay(for: startDate),
            numberOfDays: numberOfDays,
            includeMeals: includeMeals,
            meals: meals,
            createdDate: Date()
        )
        
        dataManager.addMealPlan(mealPlan)
        dismiss()
    }
}

// MARK: - Auto Generate Options View

struct AutoGenerateOptionsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var prioritizeFavorites: Bool
    @Binding var allowRepetition: Bool
    let onGenerate: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "wand.and.stars.inverse")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    themeManager.currentTheme.primaryColor,
                                    themeManager.currentTheme.accentColor
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Auto-Generate Meal Plan")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Let the app intelligently select recipes for you")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)
                
                // Options
                VStack(spacing: 0) {
                    Toggle(isOn: $prioritizeFavorites) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text("Prioritize Favorites")
                                    .fontWeight(.medium)
                            }
                            Text("80% chance to select favorite recipes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(themeManager.currentTheme.cardColor)
                    
                    Divider()
                    
                    Toggle(isOn: $allowRepetition) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "repeat")
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                                Text("Allow Repetition")
                                    .fontWeight(.medium)
                            }
                            Text("Same recipe can appear multiple times")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(themeManager.currentTheme.cardColor)
                }
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
                
                // Generate Button
                Button {
                    onGenerate()
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Generate Meal Plan")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
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
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Day Meal Selector Component

struct DayMealSelector: View {
    @Binding var day: CreateMealPlanView.MealPlanDay
    let includeMeals: MealPlan.IncludedMeals
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(dateFormatter.string(from: day.date))
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.primaryColor)
            
            if includeMeals.breakfast {
                MealSlot(
                    mealType: "Breakfast",
                    icon: "sunrise.fill",
                    color: .orange,
                    recipePair: $day.breakfast
                )
            }
            
            if includeMeals.lunch {
                MealSlot(
                    mealType: "Lunch",
                    icon: "sun.max.fill",
                    color: .yellow,
                    recipePair: $day.lunch
                )
            }
            
            if includeMeals.dinner {
                MealSlot(
                    mealType: "Dinner",
                    icon: "moon.stars.fill",
                    color: .purple,
                    recipePair: $day.dinner
                )
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
}

// MARK: - Meal Slot Component

struct MealSlot: View {
    let mealType: String
    let icon: String
    let color: Color
    @Binding var recipePair: MealPlan.RecipeServingPair?
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    @State private var showingRecipePicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(mealType)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            if let pair = recipePair {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pair.recipe.name)
                            .font(.subheadline)
                        Text("\(pair.servings) servings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        showingRecipePicker = true
                    } label: {
                        Text("Change")
                            .font(.caption)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                }
                .padding(10)
                .background(themeManager.currentTheme.primaryColor.opacity(0.1))
                .cornerRadius(8)
            } else {
                Button {
                    showingRecipePicker = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Recipe")
                    }
                    .font(.subheadline)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(themeManager.currentTheme.primaryColor.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .sheet(isPresented: $showingRecipePicker) {
            RecipePickerView(selectedRecipePair: $recipePair)
        }
    }
}

// MARK: - Recipe Picker View

struct RecipePickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedRecipePair: MealPlan.RecipeServingPair?
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedRecipe: Recipe?
    @State private var servings: Int = 4
    @State private var searchText = ""
    @State private var selectedMealTypeFilter: Recipe.MealType?
    @State private var showFavoritesOnly = false
    
    var filteredRecipes: [Recipe] {
        var recipes = dataManager.recipes
        
        // Filter by search text
        if !searchText.isEmpty {
            recipes = recipes.filter { recipe in
                recipe.name.localizedCaseInsensitiveContains(searchText) ||
                recipe.ingredients.contains { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Filter by meal type
        if let mealType = selectedMealTypeFilter {
            recipes = recipes.filter { $0.mealType == mealType }
        }
        
        // Filter by favorites
        if showFavoritesOnly {
            recipes = recipes.filter { $0.isFavorite }
        }
        
        return recipes.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if dataManager.recipes.isEmpty {
                    emptyStateView
                } else {
                    // Search and Filters
                    searchAndFiltersView
                    
                    if filteredRecipes.isEmpty {
                        noResultsView
                    } else {
                        // Recipe List
                        recipeListView
                    }
                    
                    // Bottom Selection Bar
                    if selectedRecipe != nil {
                        selectionBarView
                    }
                }
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Select Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No recipes available")
                .font(.headline)
            Text("Add recipes first to include them in your meal plan")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxHeight: .infinity)
    }
    
    // MARK: - Search and Filters
    
    private var searchAndFiltersView: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search recipes or ingredients...", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(themeManager.currentTheme.cardColor)
            .cornerRadius(10)
            .padding(.horizontal)
            
            // Meal Type Filter & Favorites Toggle
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // Favorites toggle
                    Button {
                        withAnimation {
                            showFavoritesOnly.toggle()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                            Text("Favorites")
                                .font(.subheadline)
                        }
                        .foregroundColor(showFavoritesOnly ? .white : themeManager.currentTheme.primaryColor)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            showFavoritesOnly
                            ? themeManager.currentTheme.primaryColor
                            : themeManager.currentTheme.primaryColor.opacity(0.15)
                        )
                        .cornerRadius(20)
                    }
                    
                    // All meals filter
                    Button {
                        withAnimation {
                            selectedMealTypeFilter = nil
                        }
                    } label: {
                        Text("All")
                            .font(.subheadline)
                            .foregroundColor(selectedMealTypeFilter == nil ? .white : themeManager.currentTheme.primaryColor)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                selectedMealTypeFilter == nil
                                ? themeManager.currentTheme.primaryColor
                                : themeManager.currentTheme.primaryColor.opacity(0.15)
                            )
                            .cornerRadius(20)
                    }
                    
                    ForEach(Recipe.MealType.allCases, id: \.self) { mealType in
                        Button {
                            withAnimation {
                                selectedMealTypeFilter = mealType
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: mealType.icon)
                                Text(mealType.rawValue)
                                    .font(.subheadline)
                            }
                            .foregroundColor(selectedMealTypeFilter == mealType ? .white : themeManager.currentTheme.primaryColor)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                selectedMealTypeFilter == mealType
                                ? themeManager.currentTheme.primaryColor
                                : themeManager.currentTheme.primaryColor.opacity(0.15)
                            )
                            .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
    }
    
    // MARK: - No Results View
    
    private var noResultsView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Recipes Found")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Try adjusting your filters or search terms")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                searchText = ""
                selectedMealTypeFilter = nil
                showFavoritesOnly = false
            } label: {
                Text("Clear Filters")
                    .font(.subheadline)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            .padding(.top, 8)
            
            Spacer()
        }
    }
    
    // MARK: - Recipe List
    
    private var recipeListView: some View {
        List(filteredRecipes) { recipe in
            Button {
                selectedRecipe = recipe
                servings = recipe.servings
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        // Recipe name
                        Text(recipe.name)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        // Meal type and info
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: recipe.mealType.icon)
                                    .font(.caption)
                                Text(recipe.mealType.rawValue)
                                    .font(.caption)
                            }
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.caption)
                                Text(recipe.totalTimeString)
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "person.2")
                                    .font(.caption)
                                Text("\(recipe.servings)")
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Selection indicator and favorite
                    HStack(spacing: 12) {
                        if recipe.isFavorite {
                            Image(systemName: "heart.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        if selectedRecipe?.id == recipe.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                    }
                }
                .contentShape(Rectangle())
            }
            .listRowBackground(themeManager.currentTheme.cardColor)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    // MARK: - Selection Bar
    
    private var selectionBarView: some View {
        VStack(spacing: 16) {
            Divider()
            
            if let recipe = selectedRecipe {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Selected:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(recipe.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            Stepper("Servings: \(servings)", value: $servings, in: 1...20)
                .padding(.horizontal)
            
            Button {
                if let recipe = selectedRecipe {
                    selectedRecipePair = MealPlan.RecipeServingPair(recipe: recipe, servings: servings)
                }
                dismiss()
            } label: {
                Text("Add to Meal Plan")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(themeManager.currentTheme.primaryColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(themeManager.currentTheme.cardColor)
    }
}

// MARK: - Day Meal Preview Component

struct DayMealPreview: View {
    let day: CreateMealPlanView.MealPlanDay
    let includeMeals: MealPlan.IncludedMeals
    @EnvironmentObject var themeManager: ThemeManager
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(dateFormatter.string(from: day.date))
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.primaryColor)
            
            if includeMeals.breakfast {
                if let breakfast = day.breakfast {
                    MealPreviewRow(icon: "sunrise.fill", color: .orange, name: breakfast.recipe.name, servings: breakfast.servings)
                } else {
                    MealPreviewRow(icon: "sunrise.fill", color: .orange, name: "No breakfast selected", servings: nil)
                }
            }
            
            if includeMeals.lunch {
                if let lunch = day.lunch {
                    MealPreviewRow(icon: "sun.max.fill", color: .yellow, name: lunch.recipe.name, servings: lunch.servings)
                } else {
                    MealPreviewRow(icon: "sun.max.fill", color: .yellow, name: "No lunch selected", servings: nil)
                }
            }
            
            if includeMeals.dinner {
                if let dinner = day.dinner {
                    MealPreviewRow(icon: "moon.stars.fill", color: .purple, name: dinner.recipe.name, servings: dinner.servings)
                } else {
                    MealPreviewRow(icon: "moon.stars.fill", color: .purple, name: "No dinner selected", servings: nil)
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
}

struct MealPreviewRow: View {
    let icon: String
    let color: Color
    let name: String
    let servings: Int?
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                    .foregroundColor(servings == nil ? .secondary : .primary)
                
                if let servings = servings {
                    Text("\(servings) servings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    CreateMealPlanView()
        .environmentObject(ThemeManager())
        .environmentObject(DataManager())
}
