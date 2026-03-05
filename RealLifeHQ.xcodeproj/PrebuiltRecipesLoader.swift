import Foundation

// MARK: - Prebuilt Recipes Loader
// This loads the 50 prebuilt recipes from the JSON file

struct PrebuiltRecipesLoader {
    
    // MARK: - JSON Structs (matching your JSON file structure)
    
    struct RecipesContainer: Codable {
        let recipes: [JSONRecipe]
    }
    
    struct JSONRecipe: Codable {
        let id: String
        let title: String
        let mealType: String
        let prepTimeMinutes: Int
        let cookTimeMinutes: Int
        let servings: Int
        let calories: Int
        let dietaryTags: [String]
        let ingredients: [JSONIngredient]
        let steps: [String]
    }
    
    struct JSONIngredient: Codable {
        let name: String
        let amount: Double
        let unit: String
    }
    
    // MARK: - Load Recipes
    
    static func loadPrebuiltRecipes() -> [Recipe] {
        // Try to load from bundle
        guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json") else {
            print("❌ Could not find recipes.json in bundle")
            return []
        }
        
        guard let data = try? Data(contentsOf: url) else {
            print("❌ Could not load data from recipes.json")
            return []
        }
        
        let decoder = JSONDecoder()
        
        guard let container = try? decoder.decode(RecipesContainer.self, from: data) else {
            print("❌ Could not decode recipes.json")
            return []
        }
        
        print("✅ Successfully loaded \(container.recipes.count) recipes from JSON")
        
        // Convert JSON recipes to app Recipe models
        return container.recipes.compactMap { convertToRecipe($0) }
    }
    
    // MARK: - Conversion
    
    private static func convertToRecipe(_ jsonRecipe: JSONRecipe) -> Recipe? {
        // Convert meal type string to enum
        guard let mealType = convertMealType(jsonRecipe.mealType) else {
            print("⚠️ Unknown meal type: \(jsonRecipe.mealType)")
            return nil
        }
        
        // Convert ingredients
        let ingredients = jsonRecipe.ingredients.map { jsonIngredient in
            Recipe.Ingredient(
                name: jsonIngredient.name,
                amount: formatAmount(jsonIngredient.amount),
                unit: jsonIngredient.unit
            )
        }
        
        // Convert dietary tags
        let dietaryTags = jsonRecipe.dietaryTags.compactMap { convertDietaryTag($0) }
        
        // Create the recipe
        return Recipe(
            id: UUID(), // Generate new UUID
            name: jsonRecipe.title,
            mealType: mealType,
            prepTime: jsonRecipe.prepTimeMinutes,
            cookTime: jsonRecipe.cookTimeMinutes,
            servings: jsonRecipe.servings,
            ingredients: ingredients,
            instructions: jsonRecipe.steps,
            recipeDescription: nil,
            notes: nil,
            isFavorite: false,
            imageData: nil,
            createdDate: Date(),
            calories: jsonRecipe.calories,
            protein: nil, // Not in your JSON
            carbs: nil, // Not in your JSON
            fat: nil, // Not in your JSON
            fiber: nil, // Not in your JSON
            dietaryTags: dietaryTags,
            isPrebuilt: true
        )
    }
    
    // MARK: - Helper Functions
    
    private static func convertMealType(_ string: String) -> Recipe.MealType? {
        switch string.lowercased() {
        case "breakfast":
            return .breakfast
        case "lunch":
            return .lunch
        case "dinner":
            return .dinner
        case "dessert":
            return .dessert
        case "snack":
            return .snack
        case "slow cooker", "slowcooker":
            return .slowCooker
        case "air fryer", "airfryer":
            return .airFryer
        default:
            return nil
        }
    }
    
    private static func convertDietaryTag(_ string: String) -> Recipe.DietaryTag? {
        switch string.lowercased() {
        case "vegetarian":
            return .vegetarian
        case "vegan":
            return .vegan
        case "gluten-free", "glutenfree":
            return .glutenFree
        case "dairy-free", "dairyfree":
            return .dairyFree
        case "low-carb", "lowcarb":
            return .lowCarb
        case "high-protein", "highprotein":
            return .highProtein
        case "pescatarian":
            return .pescatarian
        case "keto":
            return .keto
        case "paleo":
            return .paleo
        case "nut-free", "nutfree":
            return .nutFree
        case "high-fiber", "highfiber":
            return .highFiber
        default:
            print("⚠️ Unknown dietary tag: \(string)")
            return nil
        }
    }
    
    private static func formatAmount(_ value: Double) -> String {
        // Round to 2 decimal places
        let rounded = round(value * 100) / 100
        
        // If it's a whole number, show it without decimals
        if rounded.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(rounded))
        }
        
        // Otherwise show with up to 2 decimal places
        let formatted = String(format: "%.2f", rounded)
        return formatted.replacingOccurrences(of: #"\.?0+$"#, with: "", options: .regularExpression)
    }
}
