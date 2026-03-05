import SwiftUI

// MARK: - My Meal Plan View
// Displays and manages meal plans

struct MyMealPlanView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    @State private var showingCreateMealPlan = false
    @State private var selectedMealPlan: MealPlan?
    
    var activeMealPlans: [MealPlan] {
        dataManager.mealPlans
            .filter { $0.endDate >= Date() }
            .sorted { $0.startDate < $1.startDate }
    }
    
    var pastMealPlans: [MealPlan] {
        dataManager.mealPlans
            .filter { $0.endDate < Date() }
            .sorted { $0.startDate > $1.startDate }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if dataManager.mealPlans.isEmpty {
                emptyState
            } else {
                mealPlansList
            }
        }
        .sheet(isPresented: $showingCreateMealPlan) {
            CreateMealPlanView()
        }
        .sheet(item: $selectedMealPlan) { mealPlan in
            MealPlanDetailView(mealPlan: mealPlan)
        }
    }
    
    // MARK: - Meal Plans List
    
    private var mealPlansList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Active Meal Plans
                if !activeMealPlans.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Active Meal Plans")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(activeMealPlans) { mealPlan in
                            Button {
                                selectedMealPlan = mealPlan
                            } label: {
                                MealPlanCard(mealPlan: mealPlan, isActive: true)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Past Meal Plans
                if !pastMealPlans.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Past Meal Plans")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(pastMealPlans) { mealPlan in
                            Button {
                                selectedMealPlan = mealPlan
                            } label: {
                                MealPlanCard(mealPlan: mealPlan, isActive: false)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
            .padding(.bottom, 80) // Space for FAB
        }
        .overlay(alignment: .bottomTrailing) {
            addButton
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 80))
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
            
            Text("No Meal Plans Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Create a meal plan to organize your weekly meals and generate shopping lists!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showingCreateMealPlan = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Meal Plan")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(themeManager.currentTheme.primaryColor)
                .cornerRadius(12)
            }
            .padding(.top, 8)
            
            Spacer()
        }
    }
    
    // MARK: - Add Button (FAB)
    
    private var addButton: some View {
        Button {
            showingCreateMealPlan = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                Text("Create Plan")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
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
            .cornerRadius(30)
            .shadow(color: themeManager.currentTheme.primaryColor.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }
}

// MARK: - Meal Plan Card

struct MealPlanCard: View {
    let mealPlan: MealPlan
    let isActive: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var totalRecipes: Int {
        var count = 0
        for (_, dayMeals) in mealPlan.meals {
            if dayMeals.breakfast != nil { count += 1 }
            if dayMeals.lunch != nil { count += 1 }
            if dayMeals.dinner != nil { count += 1 }
        }
        return count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mealPlan.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(mealPlan.dateRange)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isActive {
                    Text("Active")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .cornerRadius(6)
                }
            }
            
            Divider()
            
            // Stats
            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    Text("\(mealPlan.numberOfDays) days")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "fork.knife")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    Text("\(totalRecipes) meals")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    MyMealPlanView()
        .environmentObject(ThemeManager())
        .environmentObject(DataManager())
}
