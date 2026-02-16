# Quick Integration: Add AI to Recipes View

## What to Add

This document shows exactly what to add to your existing RecipesView to enable AI features.

## Step 1: Add State Variables

Add these to the top of your `RecipesView` struct (or wherever your main recipes interface is):

```swift
struct RecipesView: View {
    // ... existing state variables ...
    
    // AI Feature State Variables
    @State private var showingAIRecipeGenerator = false
    @State private var showingAIMealPlanGenerator = false
    @State private var showingAISettings = false
    
    // ... rest of your view ...
}
```

## Step 2: Update Toolbar

Find your existing `.toolbar` modifier and add AI options to the menu:

### Option A: If you have a "+" menu button

```swift
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Menu {
            // Your existing buttons (Add Recipe manually, etc.)
            Button {
                showingAddRecipe = true
            } label: {
                Label("Add Recipe Manually", systemImage: "plus")
            }
            
            // ADD THIS DIVIDER AND AI OPTIONS
            Divider()
            
            Button {
                showingAIRecipeGenerator = true
            } label: {
                Label("Generate Recipe with AI", systemImage: "sparkles")
            }
            
            Button {
                showingAIMealPlanGenerator = true
            } label: {
                Label("Generate Meal Plan with AI", systemImage: "calendar.badge.plus")
            }
            
            Divider()
            
            Button {
                showingAISettings = true
            } label: {
                Label("AI Settings", systemImage: "gear")
            }
        } label: {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(themeManager.currentTheme.primaryColor)
        }
    }
}
```

### Option B: If you have separate toolbar buttons

```swift
.toolbar {
    // Your existing toolbar items...
    
    // ADD THESE NEW TOOLBAR ITEMS
    ToolbarItem(placement: .navigationBarTrailing) {
        Button {
            showingAIRecipeGenerator = true
        } label: {
            Image(systemName: "sparkles")
                .foregroundColor(themeManager.currentTheme.primaryColor)
        }
    }
    
    ToolbarItem(placement: .navigationBarTrailing) {
        Menu {
            Button {
                showingAIMealPlanGenerator = true
            } label: {
                Label("Generate Meal Plan", systemImage: "calendar.badge.plus")
            }
            
            Button {
                showingAISettings = true
            } label: {
                Label("AI Settings", systemImage: "gear")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundColor(themeManager.currentTheme.primaryColor)
        }
    }
}
```

## Step 3: Add Sheet Modifiers

Add these sheet modifiers at the bottom of your view (before the closing brace), alongside your other sheets:

```swift
struct RecipesView: View {
    // ... all your view code ...
    
    var body: some View {
        // ... your existing view structure ...
        
        // Your existing sheets
        .sheet(isPresented: $showingAddRecipe) {
            AddRecipeView()
        }
        
        // ADD THESE THREE NEW SHEETS
        .sheet(isPresented: $showingAIRecipeGenerator) {
            AIRecipeGeneratorView()
        }
        .sheet(isPresented: $showingAIMealPlanGenerator) {
            AIMealPlanGeneratorView()
        }
        .sheet(isPresented: $showingAISettings) {
            AISettingsView()
        }
    }
}
```

## Step 4: Add AI Settings to App Settings (Optional)

If you have a settings/preferences view in your app, add this section:

```swift
// In your SettingsView or PreferencesView

Section {
    NavigationLink {
        AISettingsView()
    } label: {
        HStack {
            Image(systemName: "sparkles")
                .foregroundColor(themeManager.currentTheme.primaryColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("AI Settings")
                    .font(.body)
                
                Text(AIServiceManager.shared.currentProvider.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if AIServiceManager.shared.currentProvider.requiresAPIKey {
                if AIServiceManager.shared.hasAPIKey(for: AIServiceManager.shared.currentProvider) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.orange)
                }
            }
        }
    }
} header: {
    Text("AI Features")
} footer: {
    Text("Configure AI providers for recipe and meal plan generation")
}
```

## Complete Minimal Example

Here's a minimal complete example showing where everything goes:

```swift
import SwiftUI

struct RecipesView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    // Existing state
    @State private var showingAddRecipe = false
    @State private var searchText = ""
    
    // NEW: AI feature state
    @State private var showingAIRecipeGenerator = false
    @State private var showingAIMealPlanGenerator = false
    @State private var showingAISettings = false
    
    var body: some View {
        NavigationView {
            List {
                // Your existing recipe list
                ForEach(filteredRecipes) { recipe in
                    RecipeRow(recipe: recipe)
                }
            }
            .navigationTitle("Recipes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // Existing options
                        Button {
                            showingAddRecipe = true
                        } label: {
                            Label("Add Recipe Manually", systemImage: "plus")
                        }
                        
                        Divider()
                        
                        // NEW: AI options
                        Button {
                            showingAIRecipeGenerator = true
                        } label: {
                            Label("Generate Recipe with AI", systemImage: "sparkles")
                        }
                        
                        Button {
                            showingAIMealPlanGenerator = true
                        } label: {
                            Label("Generate Meal Plan with AI", systemImage: "calendar.badge.plus")
                        }
                        
                        Divider()
                        
                        Button {
                            showingAISettings = true
                        } label: {
                            Label("AI Settings", systemImage: "gear")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                }
            }
            .searchable(text: $searchText)
            
            // Existing sheets
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView()
            }
            
            // NEW: AI feature sheets
            .sheet(isPresented: $showingAIRecipeGenerator) {
                AIRecipeGeneratorView()
            }
            .sheet(isPresented: $showingAIMealPlanGenerator) {
                AIMealPlanGeneratorView()
            }
            .sheet(isPresented: $showingAISettings) {
                AISettingsView()
            }
        }
    }
    
    private var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return dataManager.recipes
        }
        return dataManager.recipes.filter { recipe in
            recipe.name.localizedCaseInsensitiveContains(searchText)
        }
    }
}
```

## Testing Your Integration

1. **Build and Run** the app
2. **Navigate to Recipes** view
3. **Tap the "+" menu** (or wherever you added the AI buttons)
4. **Verify you see**:
   - "Generate Recipe with AI" option
   - "Generate Meal Plan with AI" option
   - "AI Settings" option
5. **Tap "AI Settings"** first to configure your AI provider
6. **Try generating** a test recipe

## Troubleshooting

### "Cannot find 'AIRecipeGeneratorView' in scope"
- Make sure `AIRecipeGeneratorView.swift` is added to your Xcode project
- Check that it's included in your target's "Compile Sources"

### "Cannot find 'AIServiceManager' in scope"
- Make sure `AIServiceManager.swift` is in your project
- Import Foundation and FoundationModels if needed

### AI Settings sheet appears blank
- Make sure `AISettingsView.swift` is added to your project
- Check that ThemeManager is properly injected as environment object

### Buttons don't appear in toolbar
- Check that you're adding them inside the `.toolbar { }` modifier
- Verify you're not accidentally hiding them with conditional logic
- Try running on a physical device or different simulator

## What Users Will See

### First Time Flow:
1. User taps "Generate Recipe with AI"
2. Sees a prompt to configure AI provider (if not set up)
3. Opens AI Settings
4. Chooses provider (Apple Intelligence or external)
5. If external, enters API key
6. Returns to recipe generator
7. Describes meal and generates

### After Setup:
1. User taps "Generate Recipe with AI"
2. Enters meal description: "healthy chicken salad"
3. Optionally sets preferences (cuisine, dietary, etc.)
4. Taps "Generate"
5. Waits 5-15 seconds
6. Reviews generated recipe
7. Saves or discards

## Next Steps

After integration:
1. ✅ Test with Apple Intelligence (if you have a compatible device)
2. ✅ Test with an external provider (get a free API key)
3. ✅ Generate a few test recipes
4. ✅ Try generating a meal plan
5. 📝 Update your app description to mention AI features!

---

That's it! Your recipes view now has AI superpowers! 🎉✨
