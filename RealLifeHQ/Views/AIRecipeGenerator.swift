import Foundation
import Combine

// MARK: - AI Recipe Generator  
// Intelligent recipe and meal plan generation
// Ready for Apple Intelligence when Foundation Models API becomes available
// Currently uses advanced template system with future AI integration prepared

class AIRecipeGenerator: ObservableObject {
    static let shared = AIRecipeGenerator()
    
    @Published var isGenerating = false
    @Published var error: String?
    @Published var isUsingAppleIntelligence = false
    
    private init() { 
        checkAppleIntelligenceAvailability()
    }
    
    // MARK: - Apple Intelligence Availability
    
    func checkAppleIntelligenceAvailability() {
        Task {
            // Check if we're on iOS 18.1+ and device supports Apple Intelligence
            if #available(iOS 18.1, *) {
                // Foundation Models API not yet available in public SDK
                // When available, check with: LanguageModel.isAvailable
                // For now, we'll use smart templates everywhere
                await MainActor.run {
                    self.isUsingAppleIntelligence = false
                }
            } else {
                await MainActor.run {
                    self.isUsingAppleIntelligence = false
                }
            }
        }
    }
    
    // MARK: - Recipe Generation
    
    func generateRecipe(
        from ingredients: [String],
        cuisine: String = "any",
        dietaryRestrictions: [String] = [],
        cookingTime: Int? = nil
    ) async throws -> Recipe {
        
        await MainActor.run {
            isGenerating = true
        }
        defer { 
            Task { @MainActor in
                isGenerating = false
            }
        }
        
        // Use smart template generation
        // Foundation Models API not yet available in current SDK
        return generateIntelligentRecipe(
            ingredients: ingredients,
            cuisine: cuisine,
            restrictions: dietaryRestrictions,
            time: cookingTime ?? 30
        )
    }
    
    func generateBalancedMealPlan(
        days: Int,
        dietaryPreferences: [String] = [],
        calorieTarget: Int? = nil,
        cuisinePreferences: [String] = []
    ) async throws -> [Recipe] {
        
        await MainActor.run {
            isGenerating = true
        }
        defer { 
            Task { @MainActor in
                isGenerating = false
            }
        }
        
        // Use smart template generation
        // Foundation Models API not yet available in current SDK
        var recipes: [Recipe] = []
        
        for day in 0..<days {
            recipes.append(generateMealRecipe(
                mealType: "Breakfast",
                day: day,
                dietary: dietaryPreferences,
                cuisines: cuisinePreferences.isEmpty ? ["American", "Mediterranean", "Asian"] : cuisinePreferences
            ))
            
            recipes.append(generateMealRecipe(
                mealType: "Lunch",
                day: day,
                dietary: dietaryPreferences,
                cuisines: cuisinePreferences.isEmpty ? ["American", "Mediterranean", "Asian"] : cuisinePreferences
            ))
            
            recipes.append(generateMealRecipe(
                mealType: "Dinner",
                day: day,
                dietary: dietaryPreferences,
                cuisines: cuisinePreferences.isEmpty ? ["American", "Mediterranean", "Asian"] : cuisinePreferences
            ))
        }
        
        return recipes
    }
    
    // MARK: - Smart Template Generation (Current Implementation)
    
    // MARK: - Future: Apple Intelligence Integration
    // When Foundation Models API becomes available in Xcode SDK, 
    // the following methods can be uncommented and used for real AI generation
    /*
    @available(iOS 18.1, *)
    private func generateRecipeWithAppleIntelligence(
        ingredients: [String],
        cuisine: String,
        restrictions: [String],
        time: Int
    ) async throws -> Recipe {
        let model = try await LanguageModel()
        let prompt = buildRecipePrompt(...)
        let response = try await model.generate(prompt: prompt, maxTokens: 1500)
        return try parseRecipeFromAIResponse(response, ...)
    }
    */
    
    // MARK: - Prompt Building (Ready for future AI integration)
    
    private func buildRecipePrompt(
        ingredients: [String],
        cuisine: String,
        restrictions: [String],
        time: Int
    ) -> String {
        let ingredientList = ingredients.map { "• \($0)" }.joined(separator: "\n")
        let restrictionText = restrictions.isEmpty ? "" : "\nDietary restrictions: \(restrictions.joined(separator: ", "))"
        let cuisineText = cuisine.lowercased() == "any" ? "any cuisine style" : "\(cuisine) cuisine"
        
        return """
        Create a detailed, delicious recipe using these available ingredients:
        \(ingredientList)
        
        Style: \(cuisineText)
        Total cooking time: approximately \(time) minutes\(restrictionText)
        
        Please provide:
        1. Recipe Name: [creative name]
        2. Prep Time: [X minutes]
        3. Cook Time: [Y minutes]
        4. Servings: [number]
        5. Ingredients:
           - [ingredient with measurement]
           - [ingredient with measurement]
           (Include the provided ingredients plus any necessary additions)
        6. Instructions:
           1. [detailed step]
           2. [detailed step]
           (Clear, numbered steps)
        7. Notes: [any helpful tips or variations]
        
        Make it realistic, delicious, and achievable for a home cook.
        """
    }
    
    private func buildMealPlanDayPrompt(
        dayNumber: Int,
        dietary: [String],
        calories: Int,
        cuisines: [String]
    ) -> String {
        let dietaryText = dietary.isEmpty ? "" : "\nDietary preferences: \(dietary.joined(separator: ", "))"
        let cuisineText = cuisines.isEmpty ? "" : "\nCuisine styles: \(cuisines.joined(separator: ", "))"
        
        return """
        Create a complete meal plan for Day \(dayNumber) with breakfast, lunch, and dinner.
        
        Requirements:
        - Total daily calories: approximately \(calories)\(dietaryText)\(cuisineText)
        - Nutritionally balanced
        - Variety of flavors and textures
        - Realistic portions
        
        For each meal, provide:
        
        BREAKFAST:
        Name: [meal name]
        Prep: [X min]
        Cook: [Y min]
        Servings: [number]
        Ingredients:
        - [ingredient with measurement]
        Instructions:
        1. [step]
        
        LUNCH:
        Name: [meal name]
        Prep: [X min]
        Cook: [Y min]
        Servings: [number]
        Ingredients:
        - [ingredient with measurement]
        Instructions:
        1. [step]
        
        DINNER:
        Name: [meal name]
        Prep: [X min]
        Cook: [Y min]
        Servings: [number]
        Ingredients:
        - [ingredient with measurement]
        Instructions:
        1. [step]
        
        Make each meal practical and delicious.
        """
    }
    
    // MARK: - Response Parsing
    
    private func parseRecipeFromAIResponse(_ response: String, ingredients: [String], cuisine: String) throws -> Recipe {
        var name = "Generated Recipe"
        var prepTime = 10
        var cookTime = 20
        var servings = 4
        var recipeIngredients: [String] = []
        var instructions: [String] = []
        var notes: String?
        
        let lines = response.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }
        
        var currentSection = ""
        var instructionNumber = 1
        
        for line in lines where !line.isEmpty {
            let lowercaseLine = line.lowercased()
            
            // Extract recipe name
            if lowercaseLine.contains("recipe name:") || lowercaseLine.hasPrefix("name:") {
                name = line.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
                if name.isEmpty { name = "Generated Recipe" }
            }
            
            // Extract times
            else if lowercaseLine.contains("prep time:") || lowercaseLine.contains("prep:") {
                if let time = extractMinutes(from: line) {
                    prepTime = time
                }
            }
            else if lowercaseLine.contains("cook time:") || lowercaseLine.contains("cook:") {
                if let time = extractMinutes(from: line) {
                    cookTime = time
                }
            }
            
            // Extract servings
            else if lowercaseLine.contains("servings:") {
                if let number = extractNumber(from: line) {
                    servings = number
                }
            }
            
            // Track sections
            else if lowercaseLine.contains("ingredients:") {
                currentSection = "ingredients"
            }
            else if lowercaseLine.contains("instructions:") || lowercaseLine.contains("directions:") {
                currentSection = "instructions"
                instructionNumber = 1
            }
            else if lowercaseLine.contains("notes:") || lowercaseLine.contains("tips:") {
                currentSection = "notes"
            }
            
            // Parse ingredients
            else if currentSection == "ingredients" && (line.hasPrefix("-") || line.hasPrefix("•") || line.hasPrefix("*")) {
                let ingredient = line.dropFirst().trimmingCharacters(in: .whitespaces)
                if !ingredient.isEmpty {
                    recipeIngredients.append(ingredient)
                }
            }
            
            // Parse instructions
            else if currentSection == "instructions" {
                // Remove numbering if present
                var instruction = line
                if let range = line.range(of: "^\\d+\\.\\s*", options: .regularExpression) {
                    instruction = String(line[range.upperBound...])
                }
                if !instruction.isEmpty && instruction.count > 3 {
                    instructions.append(instruction)
                    instructionNumber += 1
                }
            }
            
            // Parse notes
            else if currentSection == "notes" {
                if notes == nil {
                    notes = line
                } else {
                    notes? += " " + line
                }
            }
        }
        
        // Validation and fallbacks
        if recipeIngredients.isEmpty {
            recipeIngredients = ingredients.map { "1 cup \($0)" }
        }
        
        if instructions.isEmpty {
            instructions = [
                "Prepare all ingredients as listed",
                "Follow standard cooking procedures for this type of dish",
                "Cook until done and serve"
            ]
        }
        
        return Recipe(
            name: name,
            category: cuisine.capitalized,
            prepTime: prepTime,
            cookTime: cookTime,
            servings: servings,
            ingredients: recipeIngredients,
            instructions: instructions,
            notes: notes
        )
    }
    
    private func parseMealPlanFromAIResponse(_ response: String, dayNumber: Int) throws -> [Recipe] {
        var recipes: [Recipe] = []
        
        let sections = response.components(separatedBy: ":")
        var currentMealType = ""
        var currentMealData: [String: Any] = [:]
        
        // Simple parsing - look for meal type markers
        let mealTypes = ["BREAKFAST", "LUNCH", "DINNER"]
        
        for mealType in mealTypes {
            if let range = response.range(of: mealType, options: .caseInsensitive) {
                let startIndex = range.upperBound
                
                // Find the end (next meal type or end of string)
                var endIndex = response.endIndex
                for nextMeal in mealTypes where nextMeal != mealType {
                    if let nextRange = response.range(of: nextMeal, options: .caseInsensitive, range: startIndex..<response.endIndex) {
                        endIndex = nextRange.lowerBound
                        break
                    }
                }
                
                let mealSection = String(response[startIndex..<endIndex])
                
                if let recipe = parseSimpleMealSection(mealSection, mealType: mealType, dayNumber: dayNumber) {
                    recipes.append(recipe)
                }
            }
        }
        
        // Fallback if parsing failed
        if recipes.isEmpty {
            recipes = [
                generateMealRecipe(mealType: "Breakfast", day: dayNumber - 1, dietary: [], cuisines: []),
                generateMealRecipe(mealType: "Lunch", day: dayNumber - 1, dietary: [], cuisines: []),
                generateMealRecipe(mealType: "Dinner", day: dayNumber - 1, dietary: [], cuisines: [])
            ]
        }
        
        return recipes
    }
    
    private func parseSimpleMealSection(_ section: String, mealType: String, dayNumber: Int) -> Recipe? {
        var name = "\(mealType) - Day \(dayNumber)"
        var prepTime = 10
        var cookTime = 20
        var servings = mealType == "BREAKFAST" ? 2 : 4
        var ingredients: [String] = []
        var instructions: [String] = []
        
        let lines = section.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }
        var currentSection = ""
        
        for line in lines where !line.isEmpty {
            let lowercaseLine = line.lowercased()
            
            if lowercaseLine.contains("name:") {
                name = line.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
            }
            else if lowercaseLine.contains("prep:") {
                if let time = extractMinutes(from: line) { prepTime = time }
            }
            else if lowercaseLine.contains("cook:") {
                if let time = extractMinutes(from: line) { cookTime = time }
            }
            else if lowercaseLine.contains("servings:") {
                if let num = extractNumber(from: line) { servings = num }
            }
            else if lowercaseLine.contains("ingredients:") {
                currentSection = "ingredients"
            }
            else if lowercaseLine.contains("instructions:") {
                currentSection = "instructions"
            }
            else if currentSection == "ingredients" && (line.hasPrefix("-") || line.hasPrefix("•")) {
                ingredients.append(String(line.dropFirst()).trimmingCharacters(in: .whitespaces))
            }
            else if currentSection == "instructions" && !line.isEmpty {
                var instruction = line
                if let range = line.range(of: "^\\d+\\.\\s*", options: .regularExpression) {
                    instruction = String(line[range.upperBound...])
                }
                if !instruction.isEmpty {
                    instructions.append(instruction)
                }
            }
        }
        
        if ingredients.isEmpty {
            ingredients = ["Various ingredients"]
        }
        
        if instructions.isEmpty {
            instructions = ["Prepare according to standard method"]
        }
        
        return Recipe(
            name: name,
            category: mealType.capitalized,
            prepTime: prepTime,
            cookTime: cookTime,
            servings: servings,
            ingredients: ingredients,
            instructions: instructions,
            notes: "Generated for Day \(dayNumber)"
        )
    }
    
    // MARK: - Helper Methods
    
    private func extractMinutes(from text: String) -> Int? {
        let pattern = "(\\d+)\\s*(min|minute)"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let range = NSRange(text.startIndex..., in: text)
            if let match = regex.firstMatch(in: text, range: range),
               let minutesRange = Range(match.range(at: 1), in: text),
               let minutes = Int(text[minutesRange]) {
                return minutes
            }
        }
        return nil
    }
    
    private func extractNumber(from text: String) -> Int? {
        let pattern = "(\\d+)"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
           let numberRange = Range(match.range(at: 1), in: text),
           let number = Int(text[numberRange]) {
            return number
        }
        return nil
    }
    
    // MARK: - Private Generation Methods (Template Fallback)
    
    private func generateIntelligentRecipe(
        ingredients: [String],
        cuisine: String,
        restrictions: [String],
        time: Int
    ) -> Recipe {
        
        let mainIngredient = ingredients.first ?? "vegetables"
        let cuisineType = cuisine.lowercased() == "any" ? ["Italian", "Mexican", "Asian", "Mediterranean"].randomElement() ?? "International" : cuisine.capitalized
        
        // Better recipe names based on cuisine and ingredients
        let recipeName = generateRecipeName(cuisine: cuisineType, mainIngredient: mainIngredient)
        
        // Build comprehensive ingredient list
        var recipeIngredients = ingredients.map { ingredient in
            // Add appropriate measurements
            if ingredient.lowercased().contains("chicken") || ingredient.lowercased().contains("meat") {
                return "1 lb \(ingredient)"
            } else if ingredient.lowercased().contains("rice") || ingredient.lowercased().contains("pasta") {
                return "2 cups \(ingredient)"
            } else {
                return "1 cup \(ingredient), chopped"
            }
        }
        
        // Add cuisine-specific seasonings
        recipeIngredients.append(contentsOf: getCuisineSeasonings(cuisine: cuisineType))
        
        // Generate detailed instructions
        let instructions = generateDetailedInstructions(
            cuisine: cuisineType,
            mainIngredient: mainIngredient,
            ingredients: ingredients,
            time: time
        )
        
        // Calculate times
        let prepTime = max(5, time / 3)
        let cookTime = time - prepTime
        
        // Build notes
        var notes = "A delicious \(cuisineType.lowercased()) dish"
        if !restrictions.isEmpty {
            notes += " adapted for: \(restrictions.joined(separator: ", "))"
        }
        
        return Recipe(
            name: recipeName,
            category: cuisineType,
            prepTime: prepTime,
            cookTime: cookTime,
            servings: 4,
            ingredients: recipeIngredients,
            instructions: instructions,
            notes: notes
        )
    }
    
    private func generateRecipeName(cuisine: String, mainIngredient: String) -> String {
        let styles: [String: [String]] = [
            "Italian": ["Tuscan", "Sicilian", "Roman", "Venetian"],
            "Mexican": ["Authentic", "Homestyle", "Traditional", "Fresh"],
            "Asian": ["Stir-Fried", "Steamed", "Pan-Seared", "Wok"],
            "Mediterranean": ["Greek-Style", "Coastal", "Herbed", "Sun-Dried"],
            "French": ["Provençal", "Bistro-Style", "Rustic", "Classic"],
            "American": ["Home-Style", "Classic", "Comfort", "Grilled"]
        ]
        
        let style = styles[cuisine]?.randomElement() ?? "Delicious"
        return "\(style) \(mainIngredient.capitalized)"
    }
    
    private func getCuisineSeasonings(cuisine: String) -> [String] {
        switch cuisine.lowercased() {
        case "italian":
            return ["2 tbsp olive oil", "3 cloves garlic, minced", "1 tsp oregano", "1 tsp basil", "Salt and pepper to taste"]
        case "mexican":
            return ["2 tbsp olive oil", "1 tsp cumin", "1 tsp chili powder", "1/2 tsp paprika", "Salt to taste", "Lime juice"]
        case "asian":
            return ["2 tbsp sesame oil", "2 tbsp soy sauce", "1 tbsp ginger, minced", "2 cloves garlic, minced", "1 tsp rice vinegar"]
        case "mediterranean":
            return ["3 tbsp olive oil", "2 cloves garlic, minced", "1 tsp thyme", "1 lemon, juiced", "Salt and pepper to taste"]
        case "french":
            return ["2 tbsp butter", "2 shallots, minced", "1/2 cup white wine", "Fresh herbs", "Salt and pepper to taste"]
        default:
            return ["2 tbsp oil", "2 cloves garlic, minced", "Salt and pepper to taste"]
        }
    }
    
    private func generateDetailedInstructions(cuisine: String, mainIngredient: String, ingredients: [String], time: Int) -> [String] {
        var instructions: [String] = []
        
        // Prep step
        instructions.append("Prepare all ingredients: wash and chop vegetables, measure seasonings, and have everything ready.")
        
        // Cuisine-specific cooking method
        switch cuisine.lowercased() {
        case "italian":
            instructions.append("Heat olive oil in a large skillet over medium heat. Add minced garlic and sauté until fragrant, about 1 minute.")
            instructions.append("Add \(mainIngredient) to the pan and cook, stirring occasionally, until lightly browned.")
            instructions.append("Add remaining vegetables and cook for 5-7 minutes until tender.")
            instructions.append("Season with oregano, basil, salt, and pepper. Toss everything together.")
            
        case "mexican":
            instructions.append("Heat oil in a large skillet over medium-high heat.")
            instructions.append("Add \(mainIngredient) and cook until browned, about 5-6 minutes.")
            instructions.append("Stir in cumin, chili powder, and paprika. Cook for 1 minute until fragrant.")
            instructions.append("Add other ingredients and cook until everything is heated through and well combined.")
            instructions.append("Finish with a squeeze of fresh lime juice and adjust seasoning to taste.")
            
        case "asian":
            instructions.append("Heat a wok or large skillet over high heat. Add sesame oil.")
            instructions.append("Add ginger and garlic, stir-fry for 30 seconds until aromatic.")
            instructions.append("Add \(mainIngredient) and stir-fry for 3-4 minutes, keeping ingredients moving constantly.")
            instructions.append("Add remaining ingredients and soy sauce. Continue stir-frying for 3-5 minutes.")
            instructions.append("Drizzle with rice vinegar, toss everything together, and serve immediately.")
            
        case "mediterranean":
            instructions.append("In a large pan, heat olive oil over medium heat. Add garlic and cook until golden.")
            instructions.append("Add \(mainIngredient) and sear on both sides until golden brown.")
            instructions.append("Add other ingredients, thyme, lemon juice, salt and pepper.")
            instructions.append("Reduce heat and simmer for 10-15 minutes, stirring occasionally.")
            instructions.append("Taste and adjust seasoning. Drizzle with extra olive oil before serving.")
            
        default:
            instructions.append("Heat oil in a large pan over medium heat.")
            instructions.append("Add garlic and cook for 30 seconds until fragrant.")
            instructions.append("Add \(mainIngredient) and cook until done, about 8-10 minutes.")
            instructions.append("Add remaining ingredients and cook until tender.")
            instructions.append("Season with salt and pepper to taste.")
        }
        
        // Finishing step
        instructions.append("Serve hot and enjoy! Garnish with fresh herbs if desired.")
        
        return instructions
    }
    
    private func generateMealRecipe(
        mealType: String,
        day: Int,
        dietary: [String],
        cuisines: [String]
    ) -> Recipe {
        
        let cuisine = cuisines.randomElement() ?? ["American", "Italian", "Mexican", "Mediterranean", "Asian"].randomElement() ?? "American"
        
        let mealDatabase: [String: [(name: String, ingredients: [String], time: (prep: Int, cook: Int))]] = [
            "Breakfast": [
                (name: "Veggie Scramble", ingredients: ["3 eggs", "1/2 cup mixed vegetables", "1 tbsp butter", "Salt and pepper", "Fresh herbs"], time: (5, 10)),
                (name: "Greek Yogurt Parfait", ingredients: ["1 cup Greek yogurt", "1/2 cup granola", "1/2 cup mixed berries", "1 tbsp honey", "Nuts"], time: (5, 0)),
                (name: "Avocado Toast", ingredients: ["2 slices whole grain bread", "1 ripe avocado", "1 egg", "Cherry tomatoes", "Everything bagel seasoning"], time: (5, 8)),
                (name: "Oatmeal Bowl", ingredients: ["1 cup oats", "2 cups milk", "1 banana", "2 tbsp almond butter", "Cinnamon", "Honey"], time: (2, 10)),
                (name: "Breakfast Burrito", ingredients: ["2 eggs", "1 tortilla", "1/4 cup cheese", "1/4 cup black beans", "Salsa", "Avocado"], time: (5, 10))
            ],
            "Lunch": [
                (name: "Mediterranean Salad", ingredients: ["Mixed greens", "Cherry tomatoes", "Cucumber", "Feta cheese", "Olives", "Olive oil vinaigrette"], time: (10, 0)),
                (name: "Chicken & Rice Bowl", ingredients: ["1 cup cooked rice", "6 oz grilled chicken", "Steamed broccoli", "Teriyaki sauce", "Sesame seeds"], time: (10, 15)),
                (name: "Turkey Club Wrap", ingredients: ["1 large tortilla", "4 oz turkey", "2 slices bacon", "Lettuce", "Tomato", "Mayo"], time: (8, 5)),
                (name: "Quinoa Buddha Bowl", ingredients: ["1 cup quinoa", "Roasted vegetables", "Chickpeas", "Tahini dressing", "Avocado"], time: (10, 20)),
                (name: "Caprese Sandwich", ingredients: ["Ciabatta bread", "Fresh mozzarella", "Tomatoes", "Basil", "Balsamic glaze", "Olive oil"], time: (5, 3))
            ],
            "Dinner": [
                (name: "Garlic Herb Chicken", ingredients: ["4 chicken breasts", "4 cloves garlic", "Fresh herbs", "Lemon", "Olive oil", "Roasted vegetables"], time: (10, 30)),
                (name: "Pasta Primavera", ingredients: ["8 oz pasta", "Mixed vegetables", "Garlic", "Olive oil", "Parmesan cheese", "Fresh basil"], time: (10, 15)),
                (name: "Salmon Teriyaki", ingredients: ["2 salmon fillets", "Teriyaki sauce", "Rice", "Steamed broccoli", "Sesame seeds"], time: (5, 20)),
                (name: "Beef Tacos", ingredients: ["1 lb ground beef", "Taco seasoning", "Tortillas", "Lettuce", "Tomatoes", "Cheese", "Sour cream"], time: (10, 15)),
                (name: "Vegetable Stir-Fry", ingredients: ["Mixed vegetables", "Tofu or chicken", "Soy sauce", "Ginger", "Garlic", "Rice"], time: (15, 12))
            ]
        ]
        
        // Get appropriate meal
        guard let meals = mealDatabase[mealType] else {
            return Recipe(
                name: "\(cuisine) \(mealType)",
                category: mealType,
                prepTime: 10,
                cookTime: 20,
                servings: mealType == "Breakfast" ? 2 : 4,
                ingredients: ["Various ingredients"],
                instructions: ["Prepare according to recipe"],
                notes: dietary.isEmpty ? nil : "Dietary: \(dietary.joined(separator: ", "))"
            )
        }
        
        let selectedMeal = meals.randomElement() ?? meals[0]
        
        // Generate instructions based on meal type
        let instructions = generateMealInstructions(mealType: mealType, mealName: selectedMeal.name)
        
        var notes = "Day \(day + 1) - \(mealType)"
        if !dietary.isEmpty {
            notes += " | Dietary: \(dietary.joined(separator: ", "))"
        }
        
        return Recipe(
            name: "\(cuisine) \(selectedMeal.name)",
            category: mealType,
            prepTime: selectedMeal.time.prep,
            cookTime: selectedMeal.time.cook,
            servings: mealType == "Breakfast" ? 2 : 4,
            ingredients: selectedMeal.ingredients,
            instructions: instructions,
            notes: notes
        )
    }
    
    private func generateMealInstructions(mealType: String, mealName: String) -> [String] {
        switch mealType {
        case "Breakfast":
            if mealName.contains("Scramble") {
                return [
                    "Chop all vegetables into small pieces",
                    "Beat eggs in a bowl with salt and pepper",
                    "Heat butter in a pan over medium heat",
                    "Add vegetables and sauté for 2-3 minutes",
                    "Pour in eggs and scramble until cooked",
                    "Garnish with fresh herbs and serve"
                ]
            } else if mealName.contains("Parfait") {
                return [
                    "Layer Greek yogurt in a bowl or glass",
                    "Add a layer of granola",
                    "Top with fresh berries",
                    "Drizzle with honey",
                    "Add nuts for extra crunch",
                    "Enjoy immediately"
                ]
            } else if mealName.contains("Toast") {
                return [
                    "Toast bread until golden brown",
                    "Mash avocado with a fork, season with salt and pepper",
                    "Spread avocado on toast",
                    "Cook egg to your preference (fried or poached)",
                    "Top toast with egg and cherry tomatoes",
                    "Sprinkle with everything bagel seasoning"
                ]
            }
            
        case "Lunch":
            if mealName.contains("Salad") {
                return [
                    "Wash and prepare all vegetables",
                    "Chop vegetables into bite-sized pieces",
                    "Combine greens and vegetables in a large bowl",
                    "Add cheese and olives",
                    "Drizzle with olive oil vinaigrette",
                    "Toss well and serve immediately"
                ]
            } else if mealName.contains("Bowl") {
                return [
                    "Cook rice or quinoa according to package directions",
                    "Prepare protein (grill, bake, or sauté)",
                    "Steam or roast vegetables",
                    "Assemble bowl with base, protein, and vegetables",
                    "Drizzle with sauce",
                    "Top with garnishes and serve"
                ]
            } else if mealName.contains("Wrap") || mealName.contains("Sandwich") {
                return [
                    "Lay out tortilla or bread",
                    "Spread condiments evenly",
                    "Layer protein and cheese",
                    "Add fresh vegetables",
                    "Wrap tightly or close sandwich",
                    "Cut in half and serve"
                ]
            }
            
        case "Dinner":
            if mealName.contains("Chicken") || mealName.contains("Salmon") {
                return [
                    "Preheat oven to 400°F (200°C) or prepare grill",
                    "Season protein with herbs, spices, and oil",
                    "Prepare side dishes (vegetables, rice, etc.)",
                    "Cook protein until done (internal temp 165°F for chicken, 145°F for salmon)",
                    "Let rest for 5 minutes",
                    "Serve with prepared sides"
                ]
            } else if mealName.contains("Pasta") {
                return [
                    "Bring large pot of salted water to boil",
                    "Cook pasta according to package directions",
                    "Meanwhile, prepare sauce and vegetables",
                    "Sauté vegetables in olive oil until tender",
                    "Drain pasta, reserving 1/2 cup pasta water",
                    "Toss pasta with sauce and vegetables, adding pasta water if needed",
                    "Top with cheese and fresh herbs"
                ]
            } else if mealName.contains("Stir-Fry") {
                return [
                    "Prepare all ingredients before starting (mise en place)",
                    "Heat wok or large skillet over high heat",
                    "Add oil and swirl to coat pan",
                    "Cook protein first, remove and set aside",
                    "Stir-fry vegetables in batches, starting with hardest vegetables",
                    "Return protein to pan, add sauce",
                    "Toss everything together and serve over rice"
                ]
            }
            
        default:
            break
        }
        
        // Default generic instructions
        return [
            "Prepare all ingredients",
            "Follow standard cooking procedures",
            "Cook until done",
            "Season to taste",
            "Serve and enjoy"
        ]
    }
}

// MARK: - Supporting Types

struct MealPlanPreferences {
    var dailyCalories: Int = 2000
    var dietary: [String] = []
    var allergies: [String] = []
    var cuisines: [String] = []
}

enum AIError: LocalizedError {
    case modelNotAvailable
    case generationFailed
    case parsingFailed
    
    var errorDescription: String? {
        switch self {
        case .modelNotAvailable:
            return "AI generation temporarily unavailable"
        case .generationFailed:
            return "Failed to generate content"
        case .parsingFailed:
            return "Failed to parse response"
        }
    }
}

