import SwiftUI

// MARK: - Main Recipes Container
// This view contains three tabs: My Recipes, My Meal Plan, My Shopping List

struct RecipesView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTab: RecipeTab = .myRecipes
    
    enum RecipeTab: String, CaseIterable {
        case myRecipes = "My Recipes"
        case mealPlan = "My Meal Plan"
        case shoppingList = "My Shopping List"
        
        var icon: String {
            switch self {
            case .myRecipes: return "book.fill"
            case .mealPlan: return "calendar"
            case .shoppingList: return "cart.fill"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Tab Picker
                customTabPicker
                
                // Tab Content
                TabView(selection: $selectedTab) {
                    MyRecipesView()
                        .tag(RecipeTab.myRecipes)
                    
                    MyMealPlanView()
                        .tag(RecipeTab.mealPlan)
                    
                    MyShoppingListView()
                        .tag(RecipeTab.shoppingList)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // Custom Tab Picker at the top
    private var customTabPicker: some View {
        HStack(spacing: 0) {
            ForEach(RecipeTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20))
                            .foregroundColor(selectedTab == tab ? themeManager.currentTheme.primaryColor : .gray)
                        
                        Text(tab.rawValue)
                            .font(.caption)
                            .fontWeight(selectedTab == tab ? .semibold : .regular)
                            .foregroundColor(selectedTab == tab ? themeManager.currentTheme.primaryColor : .gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedTab == tab
                        ? themeManager.currentTheme.primaryColor.opacity(0.1)
                        : Color.clear
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

#Preview {
    RecipesView()
        .environmentObject(ThemeManager())
        .environmentObject(DataManager())
}
