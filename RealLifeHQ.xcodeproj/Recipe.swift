import Foundation
import SwiftData

@Model
final class Recipe {
    var id: UUID
    var name: String
    var category: MealCategory
    var prepTime: Int // minutes
    var cookTime: Int // minutes
    var servings: Int
    var ingredients: [String]
    var instructions: [String]
    var nutritionInfo: NutritionInfo?
    var tags: [String]
    
    init(id: UUID = UUID(),
         name: String,
         category: MealCategory,
         prepTime: Int,
         cookTime: Int,
         servings: Int,
         ingredients: [String],
         instructions: [String],
         nutritionInfo: NutritionInfo? = nil,
         tags: [String] = []) {
        self.id = id
        self.name = name
        self.category = category
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.servings = servings
        self.ingredients = ingredients
        self.instructions = instructions
        self.nutritionInfo = nutritionInfo
        self.tags = tags
    }
    
    var totalTime: Int {
        prepTime + cookTime
    }
}

enum MealCategory: String, Codable, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
}

struct NutritionInfo: Codable {
    var calories: Int
    var protein: Int // grams
    var carbs: Int // grams
    var fat: Int // grams
    var fiber: Int // grams
}
