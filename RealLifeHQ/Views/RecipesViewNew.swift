import SwiftUI

import SwiftUI

// MARK: - Recipes Main View with Top Segment Control

struct RecipesView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Top segment control
            Picker("View", selection: $selectedTab) {
                Text("Recipes").tag(0)
                Text("Meal Plans").tag(1)
                Text("Shopping").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            .background(themeManager.currentTheme.cardColor)
            
            // Content
            TabView(selection: $selectedTab) {
                RecipesTabView()
                    .tag(0)
                
                MealPlansTabView()
                    .tag(1)
                
                ShoppingListTabView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle(tabTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var tabTitle: String {
        switch selectedTab {
        case 0: return "Recipes"
        case 1: return "Meal Plans"
        case 2: return "Shopping List"
        default: return "Recipes"
        }
    }
}

// MARK: - Recipes Tab

struct RecipesTabView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingAddRecipe = false
    @State private var showingAIGenerator = false
    @State private var searchText = ""
    @State private var showFavoritesOnly = false
    
    var body: some View {
        ZStack {
            if filteredRecipes.isEmpty {
                emptyStateView
            } else {
                recipesList
            }
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .searchable(text: $searchText, prompt: "Search recipes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingAIGenerator = true
                    } label: {
                        Label("AI Recipe Generator", systemImage: "sparkles")
                    }
                    
                    Divider()
                    
                    Button {
                        showingAddRecipe = true
                    } label: {
                        Label("New Recipe", systemImage: "plus")
                    }
                    
                    Divider()
                    
                    Button {
                        showFavoritesOnly.toggle()
                    } label: {
                        Label(showFavoritesOnly ? "Show All" : "Favorites Only", 
                              systemImage: showFavoritesOnly ? "star.slash" : "star.fill")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
        }
        .sheet(isPresented: $showingAddRecipe) {
            AddRecipeView()
        }
        .sheet(isPresented: $showingAIGenerator) {
            AIGenerateRecipeView()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(themeManager.currentTheme.primaryColor.opacity(0.5))
            
            Text("No Recipes Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create recipes manually or use AI to generate them")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 12) {
                Button("Generate with AI") {
                    showingAIGenerator = true
                }
                .buttonStyle(.borderedProminent)
                .tint(themeManager.currentTheme.accentColor)
                
                Button("Add Manually") {
                    showingAddRecipe = true
                }
                .buttonStyle(.bordered)
                .tint(themeManager.currentTheme.primaryColor)
            }
        }
        .padding()
    }
    
    private var recipesList: some View {
        List {
            ForEach(filteredRecipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    RecipeRow(recipe: recipe)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        dataManager.deleteRecipe(recipe)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        dataManager.toggleFavorite(recipe)
                    } label: {
                        Label(recipe.isFavorite ? "Unfavorite" : "Favorite", 
                              systemImage: recipe.isFavorite ? "star.slash" : "star.fill")
                    }
                    .tint(.yellow)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var filteredRecipes: [Recipe] {
        var recipes = dataManager.recipes
        
        if showFavoritesOnly {
            recipes = recipes.filter { $0.isFavorite }
        }
        
        if !searchText.isEmpty {
            recipes = recipes.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return recipes.sorted { $0.isFavorite && !$1.isFavorite }
    }
}

// MARK: - Recipe Row

struct RecipeRow: View {
    let recipe: Recipe
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(recipe.name)
                        .font(.headline)
                    
                    if recipe.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
                
                HStack(spacing: 12) {
                    Label(recipe.category, systemImage: "tag.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label(recipe.totalTimeString, systemImage: "clock.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label("\(recipe.servings)", systemImage: "person.2.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Quick favorite button
            Button {
                dataManager.toggleFavorite(recipe)
            } label: {
                Image(systemName: recipe.isFavorite ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundColor(recipe.isFavorite ? .yellow : .gray.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Recipe Detail View

struct RecipeDetailView: View {
    let recipe: Recipe
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingAddToShoppingList = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(recipe.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        if recipe.isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.title2)
                        }
                    }
                    
                    HStack(spacing: 20) {
                        Label("\(recipe.totalTime) min", systemImage: "clock.fill")
                        Label("\(recipe.servings) servings", systemImage: "person.2.fill")
                        Label(recipe.category, systemImage: "tag.fill")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    // Add to Shopping List Button
                    Button {
                        dataManager.addIngredientsToShoppingList(from: recipe)
                        showingAddToShoppingList = true
                    } label: {
                        Label("Add to Shopping List", systemImage: "cart.fill.badge.plus")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(themeManager.currentTheme.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(themeManager.currentTheme.cardColor)
                .cornerRadius(12)
                
                // Ingredients
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ingredients")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    ForEach(Array(recipe.ingredients.enumerated()), id: \.offset) { index, ingredient in
                        HStack(alignment: .top) {
                            Circle()
                                .fill(themeManager.currentTheme.primaryColor)
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)
                            
                            Text(ingredient)
                                .font(.body)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(themeManager.currentTheme.cardColor)
                .cornerRadius(12)
                
                // Instructions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Instructions")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.headline)
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                                .frame(width: 24, height: 24)
                                .background(themeManager.currentTheme.primaryColor.opacity(0.2))
                                .cornerRadius(12)
                            
                            Text(instruction)
                                .font(.body)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(themeManager.currentTheme.cardColor)
                .cornerRadius(12)
                
                // Notes
                if let notes = recipe.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        
                        Text(notes)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(themeManager.currentTheme.cardColor)
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dataManager.toggleFavorite(recipe)
                } label: {
                    Image(systemName: recipe.isFavorite ? "star.fill" : "star")
                        .foregroundColor(recipe.isFavorite ? .yellow : themeManager.currentTheme.primaryColor)
                }
            }
        }
        .alert("Added to Shopping List", isPresented: $showingAddToShoppingList) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("All ingredients have been added to your shopping list")
        }
    }
}

// Continued in next message due to length...
