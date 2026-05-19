import SwiftUI

// MARK: - My Recipes View
// Displays all user recipes in a card-based layout

struct MyRecipesView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddRecipe = false
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
        
        return recipes.sorted { $0.createdDate > $1.createdDate }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and Filters
            searchAndFilters
            
            if dataManager.recipes.isEmpty {
                emptyState
            } else if filteredRecipes.isEmpty {
                noResultsState
            } else {
                recipesList
            }
        }
        .sheet(isPresented: $showingAddRecipe) {
            AddRecipeView()
        }
    }
    
    // MARK: - Search and Filters
    
    private var searchAndFilters: some View {
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
    
    // MARK: - Recipes List
    
    private var recipesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredRecipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        RecipeCard(recipe: recipe)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
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
            
            Image(systemName: "book.closed.fill")
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
            
            Text("No Recipes Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Start building your recipe collection by adding your first recipe!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showingAddRecipe = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Your First Recipe")
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
    
    // MARK: - No Results State
    
    private var noResultsState: some View {
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
    
    // MARK: - Add Button (FAB)
    
    private var addButton: some View {
        Button {
            showingAddRecipe = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                Text("Add Recipe")
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

// MARK: - Recipe Card Component

struct RecipeCard: View {
    let recipe: Recipe
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Recipe Image or Placeholder
            recipeImage
            
            // Recipe Details
            VStack(alignment: .leading, spacing: 8) {
                // Meal Type Badge & Favorite
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: recipe.mealType.icon)
                            .font(.caption)
                        Text(recipe.mealType.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(themeManager.currentTheme.primaryColor.opacity(0.15))
                    .cornerRadius(6)
                    
                    Spacer()
                    
                    Button {
                        dataManager.toggleFavorite(recipe)
                    } label: {
                        Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 20))
                            .foregroundColor(recipe.isFavorite ? .red : .gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Recipe Name
                Text(recipe.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                // Time & Servings Info
                HStack(spacing: 16) {
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
                        Text("\(recipe.servings) servings")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                // Ingredient count
                Text("\(recipe.ingredients.count) ingredients")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
        }
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    @ViewBuilder
    private var recipeImage: some View {
        if let imageData = recipe.imageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .clipped()
                .cornerRadius(16, corners: [.topLeft, .topRight])
        } else {
            // Placeholder with gradient and icon
            ZStack {
                LinearGradient(
                    colors: [
                        themeManager.currentTheme.primaryColor.opacity(0.6),
                        themeManager.currentTheme.accentColor.opacity(0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                Image(systemName: "fork.knife")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(height: 180)
            .cornerRadius(16, corners: [.topLeft, .topRight])
        }
    }
}

// MARK: - Helper Extension for Rounded Corners

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    NavigationStack {
        MyRecipesView()
            .environmentObject(ThemeManager())
            .environmentObject(DataManager())
    }
}
