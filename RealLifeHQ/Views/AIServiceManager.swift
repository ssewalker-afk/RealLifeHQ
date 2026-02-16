import Foundation

// MARK: - AI Service Manager (DEPRECATED - For Reference Only)
// This file has been deprecated. External AI integrations have been removed.
// See APPLE_INTELLIGENCE_NOTES.md for information about using Apple Intelligence.

/*
 
 DEPRECATION NOTICE
 ==================
 
 This AI Service Manager has been removed from the active codebase.
 External AI providers (OpenAI, Anthropic, Google) are no longer integrated.
 
 WHY REMOVED?
 - Privacy: External APIs send user data to third-party servers
 - Cost: API calls require payment
 - Complexity: Multiple providers increase maintenance
 - Apple Intelligence: iOS 18.1+ provides free, private, on-device AI
 
 WHAT'S NEXT?
 - Use Apple Intelligence when available (iOS 18.1+)
 - Continue with manual recipe entry
 - Focus on privacy and simplicity
 
 See APPLE_INTELLIGENCE_NOTES.md for integration guidance.
 
 */

// MARK: - Archive of Previous Implementation

// This code is kept for reference only and should not be compiled into the app.
// Remove this file from your target's "Compile Sources" build phase.

#if false // Disable compilation

@Observable
class AIServiceManager {
    static let shared = AIServiceManager()
    
    enum AIProvider: String, Codable, CaseIterable, Identifiable {
        case openAI = "OpenAI (GPT-4)"
        case anthropic = "Anthropic (Claude)"
        case google = "Google (Gemini)"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .openAI: return "brain"
            case .anthropic: return "circle.hexagongrid.fill"
            case .google: return "globe"
            }
        }
        
        var requiresAPIKey: Bool {
            return true
        }
    }
    
    var currentProvider: AIProvider {
        didSet {
            UserDefaults.standard.set(currentProvider.rawValue, forKey: "aiProvider")
        }
    }
    
    var appleIntelligenceAvailable: Bool {
        return false
    }
    
    private init() {
        if let savedProvider = UserDefaults.standard.string(forKey: "aiProvider"),
           let provider = AIProvider(rawValue: savedProvider) {
            self.currentProvider = provider
        } else {
            self.currentProvider = .openAI
        }
    }
    
    // Methods removed - see APPLE_INTELLIGENCE_NOTES.md for alternative approaches
}

struct MealPlanPreferences {
    var preferredCuisine: String?
    var dietaryRestrictions: [String]
    var maxPrepTimePerMeal: Int?
    var servingsPerMeal: Int
    var includeBreakfast: Bool
    var includeLunch: Bool
    var includeDinner: Bool
}

struct GeneratedRecipe: Codable {
    var name: String
    var category: String
    var prepTime: Int
    var cookTime: Int
    var ingredients: [String]
    var instructions: [String]
    var notes: String?
}

struct GeneratedMealPlan: Codable {
    var days: [DayMeals]
    
    struct DayMeals: Codable {
        var breakfast: GeneratedRecipe?
        var lunch: GeneratedRecipe?
        var dinner: GeneratedRecipe?
    }
}

struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}

struct AnthropicResponse: Codable {
    let content: [Content]
    
    struct Content: Codable {
        let text: String
    }
}

struct GoogleResponse: Codable {
    let candidates: [Candidate]
    
    struct Candidate: Codable {
        let content: Content
    }
    
    struct Content: Codable {
        let parts: [Part]
    }
    
    struct Part: Codable {
        let text: String
    }
}

enum AIError: LocalizedError {
    case modelUnavailable
    case missingAPIKey
    case invalidResponse
    case apiError(statusCode: Int)
    case notImplemented
    
    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            return "Apple Intelligence is not available on this device. Please enable it in Settings or use an external AI provider."
        case .missingAPIKey:
            return "API key is missing. Please add your API key in Settings."
        case .invalidResponse:
            return "Received an invalid response from the AI service."
        case .apiError(let statusCode):
            return "API request failed with status code: \(statusCode)"
        case .notImplemented:
            return "This feature is coming soon!"
        }
    }
}
#endif // End disabled code


