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
            Text("Select Recipes")
                .font(.title2)
                .fontWeight(.bold)
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
    
    var body: some View {
        NavigationStack {
            VStack {
                if dataManager.recipes.isEmpty {
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
                    }
                    .padding()
                } else {
                    List(dataManager.recipes) { recipe in
                        Button {
                            selectedRecipe = recipe
                            servings = recipe.servings
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(recipe.name)
                                        .foregroundColor(.primary)
                                    Text(recipe.mealType.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if selectedRecipe?.id == recipe.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(themeManager.currentTheme.primaryColor)
                                }
                            }
                        }
                    }
                    
                    if selectedRecipe != nil {
                        VStack(spacing: 16) {
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
            }
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
