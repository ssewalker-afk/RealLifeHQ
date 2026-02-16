# AI Meal Planner Updates

## Changes Made ✅

### 1. Matched Dietary Restrictions to AI Recipe Generator

**Before:**
- AI Recipe Generator: `["Vegetarian", "Vegan", "Gluten-Free", "Dairy-Free", "Nut-Free", "Low-Carb"]`
- AI Meal Planner: `["Vegetarian", "Vegan", "Pescatarian", "Keto", "Paleo", "Mediterranean"]`

**After:**
- Both now use: `["Vegetarian", "Vegan", "Gluten-Free", "Dairy-Free", "Nut-Free", "Low-Carb"]`

**Why:** Consistency across the app and these are the most common dietary restrictions.

---

### 2. Added Cuisine Selection to AI Meal Planner

**Before:**
- AI Meal Planner had no cuisine selection

**After:**
- Added "Cuisine Preferences" section with same options as AI Recipe Generator
- Cuisines: `["Italian", "Mexican", "Chinese", "Indian", "American", "French", "Japanese", "Mediterranean"]`
- Users can select multiple cuisines (or none for variety)
- Footer text: "Leave empty for variety across all cuisines"

**UI:**
```swift
Section("Cuisine Preferences") {
    ForEach(cuisines, id: \.self) { cuisine in
        Button {
            // Toggle selection
        } label: {
            HStack {
                Image(systemName: cuisinePreferences.contains(cuisine) ? "checkmark.circle.fill" : "circle")
                Text(cuisine)
            }
        }
    }
} footer: {
    Text("Leave empty for variety across all cuisines")
}
```

---

### 3. Removed Cuisine Prefix from Recipe Titles

**Before:**
- Template recipes: `"Italian Veggie Scramble"`, `"Mexican Pasta Primavera"`
- AI recipes: `"Tuscan Chicken"` → Would show as styled but templates had prefix

**After:**
- Template recipes: `"Veggie Scramble"`, `"Pasta Primavera"`
- AI recipes: `"Tuscan Chicken"` (unchanged - already good)
- All recipes now have clean titles without cuisine prefix

**Changes:**

**File: `AIRecipeGenerator.swift`**

1. **Line ~820** - `generateMealRecipe()`:
   ```swift
   // Before:
   name: "\(cuisine) \(selectedMeal.name)"
   
   // After:
   name: selectedMeal.name  // Don't prefix with cuisine
   ```

2. **Line ~695** - `generateRecipeName()`:
   - Added comment explaining no cuisine prefix
   - The style descriptors (Tuscan, Homestyle, etc.) are cuisine-appropriate but not explicit cuisine names

**Why:** 
- Recipe titles look cleaner and more professional
- The cuisine information is already stored in the `category` field
- Users see cuisine in the recipe details, not cluttering the title

---

### 4. Updated Variable Naming for Consistency

**Before:**
```swift
@State private var dietaryPreferences: Set<String> = []
let dietary = ["Vegetarian", "Vegan", "Pescatarian", "Keto", "Paleo", "Mediterranean"]
```

**After:**
```swift
@State private var dietaryRestrictions: Set<String> = []
@State private var cuisinePreferences: Set<String> = []
let restrictions = ["Vegetarian", "Vegan", "Gluten-Free", "Dairy-Free", "Nut-Free", "Low-Carb"]
let cuisines = ["Italian", "Mexican", "Chinese", "Indian", "American", "French", "Japanese", "Mediterranean"]
```

**Why:** Better clarity - "restrictions" vs "preferences" for dietary, and added separate `cuisinePreferences`.

---

### 5. Updated API Call to Include Cuisine Preferences

**Before:**
```swift
let recipes = try await AIRecipeGenerator.shared.generateBalancedMealPlan(
    days: numberOfDays,
    dietaryPreferences: Array(dietaryPreferences),
    calorieTarget: dailyCalories,
    selectedMeals: selectedMeals
)
```

**After:**
```swift
let recipes = try await AIRecipeGenerator.shared.generateBalancedMealPlan(
    days: numberOfDays,
    dietaryPreferences: Array(dietaryRestrictions),
    calorieTarget: dailyCalories,
    cuisinePreferences: Array(cuisinePreferences),
    selectedMeals: selectedMeals
)
```

---

## Files Modified

### 1. `AIRecipeViews.swift`
- **Lines 225-237:** Updated state variables and constants
  - Changed `dietaryPreferences` → `dietaryRestrictions`
  - Added `cuisinePreferences: Set<String>`
  - Changed `dietary` → `restrictions` with matching options
  - Added `cuisines` array
  
- **Lines 310-340:** Added "Cuisine Preferences" section
  - Multi-select checkboxes for cuisines
  - Footer explaining empty selection means variety

- **Lines 342-360:** Renamed "Dietary Preferences" → "Dietary Restrictions"
  - Updated to use `restrictions` array
  - Updated to use `dietaryRestrictions` state variable

- **Lines 395-410:** Updated `generateAIMealPlan()` function
  - Pass `Array(cuisinePreferences)` to API call
  - Use `dietaryRestrictions` instead of `dietaryPreferences`

### 2. `AIRecipeGenerator.swift`
- **Line 695:** Added comment to `generateRecipeName()` clarifying no cuisine prefix
  
- **Line 820:** Modified `generateMealRecipe()` return statement
  - Changed: `name: "\(cuisine) \(selectedMeal.name)"`
  - To: `name: selectedMeal.name`

---

## Example Before/After

### Recipe Titles

**Before:**
```
Italian Veggie Scramble
Mexican Pasta Primavera
American Garlic Herb Chicken
Mediterranean Salmon Teriyaki
```

**After:**
```
Veggie Scramble
Pasta Primavera
Garlic Herb Chicken
Salmon Teriyaki
```

(Cuisine info is still available in the recipe's `category` field)

### AI Meal Planner UI

**Before:**
```
┌─────────────────────────────────┐
│ Nutrition Goals                 │
│ Daily Calories: 2000 cal        │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│ Dietary Preferences             │
│ ○ Vegetarian                    │
│ ○ Vegan                         │
│ ○ Pescatarian                   │
│ ○ Keto                          │
│ ○ Paleo                         │
│ ○ Mediterranean                 │
└─────────────────────────────────┘
```

**After:**
```
┌─────────────────────────────────┐
│ Nutrition Goals                 │
│ Daily Calories: 2000 cal        │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│ Cuisine Preferences             │
│ ○ Italian                       │
│ ○ Mexican                       │
│ ○ Chinese                       │
│ ○ Indian                        │
│ ○ American                      │
│ ○ French                        │
│ ○ Japanese                      │
│ ○ Mediterranean                 │
│                                 │
│ Leave empty for variety across  │
│ all cuisines                    │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│ Dietary Restrictions            │
│ ○ Vegetarian                    │
│ ○ Vegan                         │
│ ○ Gluten-Free                   │
│ ○ Dairy-Free                    │
│ ○ Nut-Free                      │
│ ○ Low-Carb                      │
└─────────────────────────────────┘
```

---

## Testing Checklist

- [x] AI Meal Planner shows cuisine selection
- [x] Dietary restrictions match AI Recipe Generator
- [x] Cuisine options match AI Recipe Generator  
- [x] Recipe titles don't have cuisine prefix
- [x] Multiple cuisines can be selected
- [x] Empty cuisine selection allows variety
- [x] Generated recipes saved correctly
- [x] Meal plan created successfully
- [x] Recipe `category` field still has cuisine info

---

## User Benefits

1. **Consistent Interface** - Both AI features work the same way
2. **More Control** - Users can specify cuisine preferences for meal plans
3. **Cleaner Titles** - Recipe names are more professional looking
4. **Better Organization** - Cuisine is in the metadata, not cluttering titles
5. **Flexibility** - Can select multiple cuisines or none for variety

---

## Technical Notes

### Why Not Remove Style Descriptors Too?

The style descriptors (like "Tuscan", "Homestyle", "Stir-Fried") are kept because:
- They add character to recipe names
- They're not redundant with the category field
- They make recipes sound more appealing
- They're cuisine-appropriate without being explicit cuisine names

Example: "Tuscan Chicken" is better than "Italian Chicken" or just "Chicken"

### Cuisine Category Still Available

The cuisine type is stored in the `Recipe.category` field and is displayed:
- In recipe details view
- In recipe lists (can be used for filtering)
- In meal plan views

So no information is lost - just moved to the appropriate place.

---

## Backward Compatibility

✅ Existing recipes are unaffected
✅ Existing meal plans continue to work
✅ API changes are additive (default parameters)
✅ No database migration needed
✅ Template recipes work with new format

---

## Summary

✅ **Dietary restrictions:** NOW MATCH (6 options, same as recipe generator)
✅ **Cuisine selection:** NOW AVAILABLE (8 options, multi-select)
✅ **Recipe titles:** CLEANED UP (no cuisine prefix)
✅ **User experience:** IMPROVED (consistent interface)
✅ **Code quality:** ENHANCED (better variable naming)
