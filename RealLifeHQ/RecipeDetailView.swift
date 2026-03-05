import SwiftUI

// MARK: - Recipe Detail View
// Shows full recipe details with option to scale servings

struct RecipeDetailView: View {
    let recipe: Recipe
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    @State private var scaledServings: Int
    @State private var showingEditSheet = false
    @Environment(\.dismiss) var dismiss
    
    init(recipe: Recipe) {
        self.recipe = recipe
        _scaledServings = State(initialValue: recipe.servings)
    }
    
    var scaledRecipe: Recipe {
        recipe.scaled(toServings: scaledServings)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recipe Image
                if let imageData = recipe.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipped()
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                
                // Recipe Header
                VStack(alignment: .leading, spacing: 12) {
                    // Meal Type Badge
                    HStack(spacing: 8) {
                        Image(systemName: recipe.mealType.icon)
                        Text(recipe.mealType.rawValue)
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(themeManager.currentTheme.primaryColor.opacity(0.15))
                    .cornerRadius(8)
                    
                    // Recipe Name
                    Text(recipe.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Time & Servings Info
                    HStack(spacing: 20) {
                        InfoChip(icon: "clock", text: recipe.totalTimeString)
                        InfoChip(icon: "person.2", text: "\(recipe.servings) servings")
                        InfoChip(icon: "list.bullet", text: "\(recipe.ingredients.count) ingredients")
                    }
                }
                
                // Serving Size Adjuster
                servingSizeAdjuster
                
                // Description
                if let description = recipe.recipeDescription, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How to Prepare")
                            .font(.headline)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(themeManager.currentTheme.cardColor)
                    .cornerRadius(12)
                }
                
                // Ingredients
                ingredientsSection
                
                // Instructions
                instructionsSection
                
                // Notes
                if let notes = recipe.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        
                        Text(notes)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(themeManager.currentTheme.cardColor)
                    .cornerRadius(12)
                }
                
                // Add to Shopping List Button
                Button {
                    addIngredientsToShoppingList()
                } label: {
                    HStack {
                        Image(systemName: "cart.fill.badge.plus")
                        Text("Add Ingredients to Shopping List")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(themeManager.currentTheme.accentColor)
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        dataManager.toggleFavorite(recipe)
                    } label: {
                        Label(
                            recipe.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                            systemImage: recipe.isFavorite ? "heart.slash" : "heart"
                        )
                    }
                    
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Edit Recipe", systemImage: "pencil")
                    }
                    
                    Button {
                        shareRecipe()
                    } label: {
                        Label("Share Recipe", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddRecipeView(recipeToEdit: recipe)
        }
    }
    
    // MARK: - Serving Size Adjuster
    
    private var servingSizeAdjuster: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Adjust Servings")
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.primaryColor)
            
            HStack(spacing: 16) {
                Button {
                    if scaledServings > 1 {
                        withAnimation {
                            scaledServings -= 1
                        }
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
                .disabled(scaledServings <= 1)
                
                VStack(spacing: 4) {
                    Text("\(scaledServings)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    
                    Text("servings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(minWidth: 80)
                
                Button {
                    if scaledServings < 20 {
                        withAnimation {
                            scaledServings += 1
                        }
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
                .disabled(scaledServings >= 20)
                
                Spacer()
                
                if scaledServings != recipe.servings {
                    Button {
                        withAnimation {
                            scaledServings = recipe.servings
                        }
                    } label: {
                        Text("Reset")
                            .font(.subheadline)
                            .foregroundColor(themeManager.currentTheme.accentColor)
                    }
                }
            }
            .padding()
            .background(themeManager.currentTheme.cardColor)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Ingredients Section
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients")
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.primaryColor)
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(scaledRecipe.ingredients) { ingredient in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(themeManager.currentTheme.primaryColor)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)
                        
                        Text(ingredient.displayText)
                            .font(.body)
                    }
                }
            }
            .padding()
            .background(themeManager.currentTheme.cardColor)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Instructions Section
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Instructions")
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.primaryColor)
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(themeManager.currentTheme.primaryColor)
                            .clipShape(Circle())
                        
                        Text(instruction)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding()
            .background(themeManager.currentTheme.cardColor)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Actions
    
    private func addIngredientsToShoppingList() {
        for ingredient in scaledRecipe.ingredients {
            let shoppingItem = ShoppingItem(
                name: ingredient.name,
                quantity: "\(ingredient.amount) \(ingredient.unit)".trimmingCharacters(in: .whitespaces),
                category: categorizeIngredient(ingredient.name)
            )
            dataManager.addShoppingItem(shoppingItem)
        }
    }
    
    private func categorizeIngredient(_ name: String) -> ShoppingItem.ShoppingCategory {
        let lowercased = name.lowercased()
        
        let produceKeywords = ["lettuce", "tomato", "onion", "garlic", "potato", "carrot", "celery", "pepper", "cucumber", "spinach", "kale", "broccoli", "cauliflower", "mushroom", "zucchini", "squash", "apple", "banana", "orange", "lemon", "lime", "berry", "fruit", "vegetable", "avocado", "cilantro", "parsley", "basil", "herb"]
        if produceKeywords.contains(where: { lowercased.contains($0) }) { return .produce }
        
        let dairyKeywords = ["milk", "cheese", "yogurt", "cream", "butter", "sour cream", "cottage cheese", "parmesan", "mozzarella", "cheddar"]
        if dairyKeywords.contains(where: { lowercased.contains($0) }) { return .dairy }
        
        let meatKeywords = ["chicken", "beef", "pork", "turkey", "fish", "salmon", "tuna", "shrimp", "steak", "ground beef", "bacon", "sausage", "ham", "meat"]
        if meatKeywords.contains(where: { lowercased.contains($0) }) { return .meat }
        
        let bakeryKeywords = ["bread", "bun", "roll", "bagel", "croissant", "muffin", "tortilla"]
        if bakeryKeywords.contains(where: { lowercased.contains($0) }) { return .bakery }
        
        let pantryKeywords = ["flour", "sugar", "salt", "pepper", "spice", "rice", "pasta", "beans", "oil", "vinegar", "sauce", "ketchup", "mustard"]
        if pantryKeywords.contains(where: { lowercased.contains($0) }) { return .pantry }
        
        return .other
    }
    
    private func shareRecipe() {
        var recipeText = "\(recipe.name)\n\n"
        recipeText += "⏱ \(recipe.totalTimeString) | 👥 \(recipe.servings) servings\n\n"
        recipeText += "INGREDIENTS:\n"
        for ingredient in recipe.ingredients {
            recipeText += "• \(ingredient.displayText)\n"
        }
        recipeText += "\nINSTRUCTIONS:\n"
        for (index, instruction) in recipe.instructions.enumerated() {
            recipeText += "\(index + 1). \(instruction)\n"
        }
        
        let activityVC = UIActivityViewController(activityItems: [recipeText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Info Chip Component

struct InfoChip: View {
    let icon: String
    let text: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .foregroundColor(.secondary)
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: Recipe(
            name: "Spaghetti Carbonara",
            mealType: .dinner,
            prepTime: 10,
            cookTime: 20,
            servings: 4,
            ingredients: [
                Recipe.Ingredient(name: "Spaghetti", amount: "1", unit: "lb"),
                Recipe.Ingredient(name: "Bacon", amount: "8", unit: "slices"),
                Recipe.Ingredient(name: "Eggs", amount: "4", unit: ""),
                Recipe.Ingredient(name: "Parmesan cheese", amount: "1", unit: "cup")
            ],
            instructions: [
                "Cook spaghetti according to package directions",
                "Fry bacon until crispy, then chop",
                "Beat eggs with parmesan cheese",
                "Combine hot pasta with bacon and egg mixture"
            ],
            recipeDescription: "A classic Italian pasta dish with a creamy egg and cheese sauce",
            notes: "The heat from the pasta will cook the eggs. Don't add the eggs to boiling pasta or they'll scramble!"
        ))
        .environmentObject(ThemeManager())
        .environmentObject(DataManager())
    }
}
