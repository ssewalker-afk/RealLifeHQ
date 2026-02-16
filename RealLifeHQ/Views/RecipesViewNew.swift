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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var showingAddRecipe = false
    @State private var searchText = ""
    @State private var showFavoritesOnly = false
    
    var body: some View {
        ZStack {
            if filteredRecipes.isEmpty {
                emptyStateView
            } else {
                if horizontalSizeClass == .regular {
                    // iPad: Grid layout
                    iPadGridLayout
                } else {
                    // iPhone: List layout
                    recipesList
                }
            }
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .searchable(text: $searchText, prompt: "Search recipes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
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
            NavigationStack {
                AddRecipeView()
            }
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
            
            Text("Create your first recipe to get started")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Add Recipe") {
                showingAddRecipe = true
            }
            .buttonStyle(.borderedProminent)
            .tint(themeManager.currentTheme.primaryColor)
        }
        .padding()
    }
    
    // iPad Grid Layout
    private var iPadGridLayout: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20)
            ], spacing: 20) {
                ForEach(filteredRecipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        RecipeCardView(recipe: recipe)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
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

// MARK: - Recipe Card View (iPad Grid)

struct RecipeCardView: View {
    let recipe: Recipe
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Favorite indicator
            HStack {
                if recipe.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.title3)
                }
                
                Spacer()
                
                Button {
                    dataManager.toggleFavorite(recipe)
                } label: {
                    Image(systemName: recipe.isFavorite ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundColor(recipe.isFavorite ? .yellow : .gray.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
            
            // Recipe name
            Text(recipe.name)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Category
            Label(recipe.category, systemImage: "tag.fill")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Stats
            HStack(spacing: 12) {
                Label(recipe.totalTimeString, systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label("\(recipe.servings)", systemImage: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Delete button
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .frame(height: 200)
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .alert("Delete Recipe", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataManager.deleteRecipe(recipe)
            }
        } message: {
            Text("Are you sure you want to delete '\(recipe.name)'? This action cannot be undone.")
        }
    }
}

// MARK: - Recipe Detail View

struct RecipeDetailView: View {
    let recipe: Recipe
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var showingAddToShoppingList = false
    @State private var showingEditRecipe = false
    @State private var showingDeleteAlert = false
    
    // Get current favorite status from dataManager
    private var currentRecipe: Recipe? {
        dataManager.recipes.first(where: { $0.id == recipe.id })
    }
    
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
                        
                        if currentRecipe?.isFavorite == true {
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
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        var updatedRecipe = recipe
                        updatedRecipe.isFavorite.toggle()
                        dataManager.updateRecipe(updatedRecipe)
                    } label: {
                        Label((currentRecipe?.isFavorite ?? recipe.isFavorite) ? "Unfavorite" : "Favorite", 
                              systemImage: (currentRecipe?.isFavorite ?? recipe.isFavorite) ? "star.slash.fill" : "star.fill")
                    }
                    
                    Divider()
                    
                    Button {
                        showingEditRecipe = true
                    } label: {
                        Label("Edit Recipe", systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete Recipe", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
        }
        .sheet(isPresented: $showingEditRecipe) {
            NavigationStack {
                EditRecipeView(recipe: recipe)
            }
        }
        .alert("Delete Recipe", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataManager.deleteRecipe(recipe)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete '\(recipe.name)'? This action cannot be undone.")
        }
        .alert("Added to Shopping List", isPresented: $showingAddToShoppingList) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("All ingredients have been added to your shopping list")
        }
    }
}

// MARK: - Edit Recipe View

struct EditRecipeView: View {
    let recipe: Recipe
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
        .navigationTitle("Edit Recipe")
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
        .onAppear {
            // Initialize with existing recipe data
            name = recipe.name
            category = recipe.category
            prepTime = "\(recipe.prepTime)"
            cookTime = "\(recipe.cookTime)"
            servings = "\(recipe.servings)"
            ingredients = recipe.ingredients
            instructions = recipe.instructions
            notes = recipe.notes ?? ""
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
              let servs = Int(servings) else {
            return
        }
        
        var updatedRecipe = Recipe(
            id: recipe.id,  // Keep the same ID
            name: name,
            category: category,
            prepTime: prep,
            cookTime: cook,
            servings: servs,
            ingredients: ingredients,
            instructions: instructions,
            notes: notes.isEmpty ? nil : notes,
            isFavorite: recipe.isFavorite  // Preserve favorite status
        )
        
        dataManager.updateRecipe(updatedRecipe)
        dismiss()
    }
}

// Continued in next message due to length...
