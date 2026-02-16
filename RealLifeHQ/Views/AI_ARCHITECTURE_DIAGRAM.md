# AI Recipe System - Complete Architecture

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           YOUR iOS APP                                       │
│                                                                              │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                        USER INTERFACE LAYER                            │  │
│  │                                                                         │  │
│  │  ┌──────────────┐  ┌──────────────────┐  ┌─────────────────────────┐ │  │
│  │  │  RecipesView │  │  AISettingsView  │  │  AIRecipeGeneratorView  │ │  │
│  │  │              │  │                  │  │                         │ │  │
│  │  │ [+ AI Menu ▼]│  │  Provider:       │  │  Meal Description:      │ │  │
│  │  │              │  │  • Apple Intel   │  │  "Creamy pasta..."      │ │  │
│  │  │  • Generate  │  │  • OpenAI        │  │                         │ │  │
│  │  │    Recipe    │  │  • Anthropic     │  │  [Generate Recipe]      │ │  │
│  │  │  • Generate  │  │  • Google        │  │                         │ │  │
│  │  │    Meal Plan │  │                  │  │                         │ │  │
│  │  │  • Settings  │  │  [Add API Key]   │  │                         │ │  │
│  │  └──────────────┘  └──────────────────┘  └─────────────────────────┘ │  │
│  │          │                  │                        │                 │  │
│  └──────────┼──────────────────┼────────────────────────┼─────────────────┘  │
│             │                  │                        │                    │
│             └──────────────────┴────────────────────────┘                    │
│                                │                                             │
│  ┌─────────────────────────────┼─────────────────────────────────────────┐  │
│  │                    SERVICE LAYER                                       │  │
│  │                             │                                          │  │
│  │  ┌──────────────────────────▼─────────────────────────────────────┐   │  │
│  │  │              AIServiceManager (Singleton)                       │   │  │
│  │  │                                                                 │   │  │
│  │  │  Properties:                                                    │   │  │
│  │  │  • currentProvider: AIProvider                                 │   │  │
│  │  │  • appleIntelligenceAvailable: Bool                           │   │  │
│  │  │                                                                 │   │  │
│  │  │  Methods:                                                       │   │  │
│  │  │  • generateRecipe(mealDescription, cuisine, dietary...)        │   │  │
│  │  │  • generateMealPlan(numberOfDays, preferences)                │   │  │
│  │  │  • hasAPIKey(for: AIProvider) -> Bool                         │   │  │
│  │  │  • saveAPIKey(_ key: String, for: AIProvider)                 │   │  │
│  │  │  • deleteAPIKey(for: AIProvider)                              │   │  │
│  │  │                                                                 │   │  │
│  │  └───────┬────────────┬─────────────┬────────────┬───────────────┘   │  │
│  │          │            │             │            │                    │  │
│  └──────────┼────────────┼─────────────┼────────────┼────────────────────┘  │
│             │            │             │            │                       │
│             ▼            ▼             ▼            ▼                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    AI PROVIDER IMPLEMENTATIONS                       │   │
│  │                                                                      │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌─────────┐│   │
│  │  │    Apple     │  │    OpenAI    │  │  Anthropic   │  │ Google  ││   │
│  │  │ Intelligence │  │    GPT-4     │  │   Claude     │  │ Gemini  ││   │
│  │  │              │  │              │  │              │  │         ││   │
│  │  │ On-Device    │  │  Cloud API   │  │  Cloud API   │  │Cloud API││   │
│  │  │ FREE         │  │  ~$0.05/rec  │  │  ~$0.05/rec  │  │  FREE*  ││   │
│  │  │ 100% Private │  │  User's Key  │  │  User's Key  │  │User's Key│   │
│  │  │              │  │              │  │              │  │         ││   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  └─────────┘│   │
│  │         │                  │                 │               │     │   │
│  └─────────┼──────────────────┼─────────────────┼───────────────┼─────┘   │
│            │                  │                 │               │          │
│            ▼                  └─────────────────┴───────────────┘          │
│  ┌────────────────────┐              │                                     │
│  │ FoundationModels   │              ▼                                     │
│  │    Framework       │    ┌──────────────────────┐                       │
│  │                    │    │  KeychainManager     │                       │
│  │ • SystemLM         │    │                      │                       │
│  │ • LMSession        │    │  Methods:            │                       │
│  │ • @Generable       │    │  • saveAIAPIKey()    │                       │
│  │                    │    │  • retrieveAIAPIKey()│                       │
│  └────────────────────┘    │  • deleteAIAPIKey()  │                       │
│           │                 │                      │                       │
│           │                 └──────────┬───────────┘                       │
│           │                            │                                   │
│           ▼                            ▼                                   │
│  ┌────────────────────┐    ┌──────────────────────┐                       │
│  │  iOS (On-Device)   │    │   iOS Keychain       │                       │
│  │  Apple Intelligence│    │  (Secure Storage)    │                       │
│  │                    │    │                      │                       │
│  │  • Private         │    │  • Encrypted         │                       │
│  │  • No network      │    │  • Hardware-backed   │                       │
│  │  • Fast            │    │  • Biometric-protected│                      │
│  └────────────────────┘    └──────────────────────┘                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                       │
                                       │ (When using external providers)
                                       ▼
              ┌────────────────────────────────────────────┐
              │          EXTERNAL AI SERVICES              │
              │                                            │
              │  ┌──────────────┐  ┌──────────────┐       │
              │  │   OpenAI     │  │  Anthropic   │       │
              │  │   Servers    │  │   Servers    │       │
              │  └──────────────┘  └──────────────┘       │
              │                                            │
              │  ┌──────────────┐                         │
              │  │   Google     │                         │
              │  │   Servers    │                         │
              │  └──────────────┘                         │
              │                                            │
              └────────────────────────────────────────────┘
```

## Data Flow: Generate Recipe

```
USER ACTION
    │
    ▼
[1] User taps "Generate Recipe with AI"
    │
    ▼
[2] AIRecipeGeneratorView presents
    │
    ▼
[3] User enters:
    • Meal description: "Creamy pasta with mushrooms"
    • Cuisine: Italian
    • Dietary: Vegetarian
    • Servings: 4
    │
    ▼
[4] User taps "Generate Recipe"
    │
    ▼
[5] AIRecipeGeneratorView calls:
    AIServiceManager.shared.generateRecipe(
        mealDescription: "Creamy pasta with mushrooms",
        cuisine: "Italian",
        dietaryRestrictions: ["Vegetarian"],
        servings: 4,
        maxPrepTime: nil,
        maxCookTime: nil
    )
    │
    ▼
[6] AIServiceManager checks currentProvider
    │
    ├─── If Apple Intelligence ───────────────────────┐
    │                                                  │
    │   [7a] Check availability                       │
    │   [8a] Create LanguageModelSession              │
    │   [9a] Build prompt with user preferences       │
    │   [10a] Call session.respond()                  │
    │   [11a] Parse GeneratedRecipe                   │
    │   [12a] Return Recipe object                    │
    │                                                  │
    └─── If External Provider (OpenAI, etc.) ────────┤
                                                       │
        [7b] Retrieve API key from KeychainManager    │
        [8b] Build HTTP request with prompt           │
        [9b] Add API key to headers                   │
        [10b] Send URLSession request                 │
        [11b] Parse JSON response                     │
        [12b] Extract recipe data                     │
        [13b] Return Recipe object                    │
                                                       │
    ┌──────────────────────────────────────────────────┘
    │
    ▼
[14] Recipe returned to AIRecipeGeneratorView
    │
    ▼
[15] Show GeneratedRecipePreviewView with recipe
    │
    ├─── User taps "Save" ──┐
    │                        │
    │   [16a] Add to DataManager
    │   [17a] Save to UserDefaults
    │   [18a] Dismiss views
    │   [19a] Return to RecipesView
    │                        │
    └─── User taps "Discard" │
                             │
        [16b] Dismiss views  │
        [17b] Return to RecipesView
                             │
                             ▼
                        COMPLETE
```

## Security & Privacy Architecture

```
┌────────────────────────────────────────────────────────────┐
│                    SECURITY LAYERS                          │
│                                                             │
│  Layer 1: User Control                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ • User chooses AI provider                          │   │
│  │ • User brings own API keys (if external)            │   │
│  │ • User can delete keys anytime                      │   │
│  │ • Clear privacy disclosure                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│  Layer 2: Application Security                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ • API keys stored in iOS Keychain (never files)     │   │
│  │ • Keys never logged or exposed in UI                │   │
│  │ • HTTPS only for external API calls                 │   │
│  │ • No intermediate servers (direct API calls)        │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│  Layer 3: iOS System Security                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ • Keychain encrypted by iOS                         │   │
│  │ • Hardware-backed encryption                        │   │
│  │ • Biometric protection available                    │   │
│  │ • Sandboxed app environment                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│  Layer 4: On-Device AI Option                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ • Apple Intelligence runs on-device                 │   │
│  │ • No data sent to external servers                  │   │
│  │ • Works offline                                     │   │
│  │ • 100% private                                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

## Request Flow Comparison

### Apple Intelligence (On-Device)
```
User Description
      ↓
[1 ms] Parse user input
      ↓
[10 ms] Build prompt
      ↓
[5-10 sec] On-device AI processing
      ↓
[5 ms] Parse response
      ↓
Recipe returned

Total: ~5-10 seconds
Cost: FREE
Privacy: 100% private
Network: Not required
```

### External Provider (e.g., OpenAI)
```
User Description
      ↓
[1 ms] Parse user input
      ↓
[2 ms] Retrieve API key from Keychain
      ↓
[10 ms] Build HTTP request
      ↓
[50-200 ms] Network request to API server
      ↓
[3-8 sec] API processing (cloud)
      ↓
[50-200 ms] Network response
      ↓
[10 ms] Parse JSON response
      ↓
Recipe returned

Total: ~5-15 seconds
Cost: ~$0.05 per recipe
Privacy: Data sent to provider
Network: Required
```

## State Management Flow

```
┌──────────────────────────────────────────────────────────────┐
│                    @Observable Pattern                        │
│                                                               │
│  AIServiceManager (Singleton)                                │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ @Observable class AIServiceManager {                   │  │
│  │                                                         │  │
│  │   var currentProvider: AIProvider {                    │  │
│  │     didSet {                                           │  │
│  │       UserDefaults.standard.set(...)  // Persist      │  │
│  │     }                                                  │  │
│  │   }                                                    │  │
│  │                                                         │  │
│  │   var appleIntelligenceAvailable: Bool {              │  │
│  │     // Check SystemLanguageModel availability         │  │
│  │   }                                                    │  │
│  │ }                                                       │  │
│  └────────────────────────────────────────────────────────┘  │
│                           │                                   │
│                           │ Observable changes                │
│                           ▼                                   │
│  ┌────────────────────────────────────────────────────────┐  │
│  │              SwiftUI Views (Auto-update)               │  │
│  │                                                         │  │
│  │  • AISettingsView                                      │  │
│  │    └─> Shows current provider                         │  │
│  │    └─> Updates when provider changes                  │  │
│  │                                                         │  │
│  │  • AIRecipeGeneratorView                               │  │
│  │    └─> Shows provider status                          │  │
│  │    └─> Enables/disables based on API key             │  │
│  │                                                         │  │
│  │  • AIMealPlanGeneratorView                             │  │
│  │    └─> Same reactive behavior                         │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

## Error Handling Flow

```
┌────────────────────────────────────────────────────────────┐
│                    ERROR SCENARIOS                          │
│                                                             │
│  API Call                                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ try await AIServiceManager.shared.generateRecipe()  │   │
│  └─────────────────┬───────────────────────────────────┘   │
│                    │                                        │
│         ┌──────────┴──────────┐                            │
│         │                     │                            │
│    ✅ Success           ❌ Error                           │
│         │                     │                            │
│         │          ┌──────────┴─────────────┐              │
│         │          │                        │              │
│         │    AIError.missingAPIKey    AIError.apiError    │
│         │          │                        │              │
│         │          │                  (401, 429, etc.)    │
│         │          │                        │              │
│         │          ▼                        ▼              │
│         │   ┌──────────────┐      ┌──────────────┐        │
│         │   │Show alert:   │      │Show alert:   │        │
│         │   │"Add API Key" │      │"Check API Key│        │
│         │   │              │      │ or try later"│        │
│         │   │[Configure]   │      │[OK] [Retry]  │        │
│         │   └──────────────┘      └──────────────┘        │
│         │                                                  │
│         ▼                                                  │
│  ┌──────────────────────────────────────────────────────┐ │
│  │            Display Recipe                            │ │
│  │                                                       │ │
│  │  • Show GeneratedRecipePreviewView                  │ │
│  │  • User can save or discard                         │ │
│  └──────────────────────────────────────────────────────┘ │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

## Persistence Layer

```
┌────────────────────────────────────────────────────────────┐
│                    DATA PERSISTENCE                         │
│                                                             │
│  Configuration (UserDefaults)                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ • Current AI provider selection                     │   │
│  │ • User preferences                                  │   │
│  │ • Settings                                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│  API Keys (iOS Keychain) - SECURE                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ • OpenAI API key (encrypted)                        │   │
│  │ • Anthropic API key (encrypted)                     │   │
│  │ • Google API key (encrypted)                        │   │
│  │ • Hardware-backed encryption                        │   │
│  │ • Biometric protection available                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│  Generated Recipes (UserDefaults/Core Data)                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ • Recipe name, ingredients, instructions            │   │
│  │ • Prep/cook times                                   │   │
│  │ • User's saved collection                           │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│  Meal Plans (UserDefaults/Core Data)                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ • Plan name and date range                          │   │
│  │ • Meals organized by date                           │   │
│  │ • References to recipes                             │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

## Performance Optimization

```
┌────────────────────────────────────────────────────────────┐
│                PERFORMANCE STRATEGIES                       │
│                                                             │
│  1. Async/Await Pattern                                    │
│     ┌──────────────────────────────────────────────────┐   │
│     │ • Non-blocking UI during AI generation          │   │
│     │ • Proper error propagation                       │   │
│     │ • Cancellable operations                         │   │
│     └──────────────────────────────────────────────────┘   │
│                                                             │
│  2. Caching Strategy                                       │
│     ┌──────────────────────────────────────────────────┐   │
│     │ • KeychainManager caches API keys in memory     │   │
│     │ • Provider availability cached                   │   │
│     │ • Generated recipes saved immediately            │   │
│     └──────────────────────────────────────────────────┘   │
│                                                             │
│  3. Progress Indicators                                    │
│     ┌──────────────────────────────────────────────────┐   │
│     │ • Show loading state during generation           │   │
│     │ • Disable input during processing                │   │
│     │ • Clear completion feedback                      │   │
│     └──────────────────────────────────────────────────┘   │
│                                                             │
│  4. Batch Operations (Meal Plans)                          │
│     ┌──────────────────────────────────────────────────┐   │
│     │ • Single API call generates multiple recipes     │   │
│     │ • Efficient prompt engineering                   │   │
│     │ • Batch save to DataManager                      │   │
│     └──────────────────────────────────────────────────┘   │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

---

## Component Dependencies

```
AIRecipeGeneratorView
    ├─ Depends on: AIServiceManager
    ├─ Depends on: DataManager
    ├─ Depends on: ThemeManager
    └─ Presents: GeneratedRecipePreviewView

AIMealPlanGeneratorView
    ├─ Depends on: AIServiceManager
    ├─ Depends on: DataManager
    ├─ Depends on: ThemeManager
    └─ Presents: GeneratedMealPlanPreviewView

AISettingsView
    ├─ Depends on: AIServiceManager
    ├─ Depends on: ThemeManager
    └─ Presents: APIKeyInputView

AIServiceManager
    ├─ Depends on: KeychainManager
    ├─ Depends on: FoundationModels
    └─ Makes API calls to: External providers

KeychainManager
    └─ Depends on: iOS Security framework

All views inject via @EnvironmentObject:
    • DataManager
    • ThemeManager
```

---

This architecture provides:
✅ Clear separation of concerns
✅ Secure credential storage
✅ Flexible provider selection
✅ Privacy-first design
✅ Scalable for future providers
✅ Testable components
✅ Performance optimized
