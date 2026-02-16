# Recipe and Meal Plan Edit/Delete Feature

## Overview
Added full edit and delete capabilities for both recipes and meal plans, giving users complete control over their culinary content.

## Features Added

### 1. Recipe Management ✅

#### **Edit Recipe**
- Full editing of all recipe fields
- Pre-populated with existing data
- Preserves favorite status
- Validation before saving
- Accessible from recipe detail view

#### **Delete Recipe**
- Swipe-to-delete from recipe list (iPhone)
- Delete button in detail view (all devices)
- Confirmation alert before deletion
- Immediately updates all views

### 2. Meal Plan Management ✅

#### **Edit Meal Plan**
- Edit plan name, start date, and duration
- Intelligent meal regeneration when dates change
- Preserves existing meals where possible
- Simple rename when only name changes

#### **Delete Meal Plan**
- Swipe-to-delete from meal plans list
- Delete button in detail view
- Confirmation alert before deletion
- Immediately updates all views

---

## User Interface

### Recipe Detail View - New Menu

**Location:** Top-right toolbar

**Options:**
```
┌──────────────────────────┐
│ ⭐ Favorite/Unfavorite   │
├──────────────────────────┤
│ ✏️ Edit Recipe           │
├──────────────────────────┤
│ 🗑️ Delete Recipe         │
└──────────────────────────┘
```

### Meal Plan Detail View - New Menu

**Location:** Top-right toolbar

**Options:**
```
┌──────────────────────────┐
│ ✏️ Edit Meal Plan        │
├──────────────────────────┤
│ 🗑️ Delete Meal Plan      │
└──────────────────────────┘
```

### List View Swipe Actions

**Recipe List (iPhone):**
- **Swipe Left:** Delete (red)
- **Swipe Right:** Favorite/Unfavorite (yellow)

**Meal Plan List (iPhone):**
- **Swipe Left:** Delete (red)

---

## Technical Implementation

### New Methods in DataManager

```swift
// Already existed - now used by edit feature
func updateRecipe(_ recipe: Recipe) {
    if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
        recipes[index] = recipe
        saveRecipes()
    }
}

// NEW - Added for meal plan editing
func updateMealPlan(_ mealPlan: MealPlan) {
    if let index = mealPlans.firstIndex(where: { $0.id == mealPlan.id }) {
        mealPlans[index] = mealPlan
        saveMealPlans()
    }
}
```

### New Views

#### **EditRecipeView**
**File:** `RecipesViewNew.swift`
**Features:**
- Identical UI to AddRecipeView for consistency
- Pre-populated with existing recipe data
- Preserves recipe ID and favorite status
- Full validation before saving
- Dynamic ingredient/instruction lists

**Key Implementation:**
```swift
struct EditRecipeView: View {
    let recipe: Recipe
    @State private var name = ""
    @State private var category = ""
    // ... other fields
    
    .onAppear {
        // Pre-populate fields
        name = recipe.name
        category = recipe.category
        // ... etc
    }
    
    private func saveRecipe() {
        var updatedRecipe = Recipe(
            id: recipe.id,  // Keep same ID!
            name: name,
            // ... other fields
            isFavorite: recipe.isFavorite  // Preserve favorite
        )
        dataManager.updateRecipe(updatedRecipe)
    }
}
```

#### **EditMealPlanView**
**File:** `RecipesViewPart2.swift`
**Features:**
- Edit name, start date, and number of days
- Intelligent meal regeneration
- Preserves existing meals when possible
- Clear user feedback about changes

**Smart Regeneration Logic:**
```swift
if numberOfDays != mealPlan.numberOfDays || startDate changed {
    // Regenerate meals for new schedule
    // Try to keep existing meals where possible
    let existingMeals = oldDate.flatMap { mealPlan.meals[$0] }
    let breakfast = existingMeals?.breakfast ?? availableRecipes.randomElement()
    // ...
} else {
    // Just update the name - simple!
    var updatedPlan = mealPlan
    updatedPlan.name = name
}
```

---

## Updated Views

### RecipeDetailView
**File:** `RecipesViewNew.swift`
**Changes:**
- Added `@State` for sheet and alert presentation
- Replaced single favorite button with menu
- Added edit and delete options to menu
- Added sheet presentation for EditRecipeView
- Added delete confirmation alert
- Calls `dismiss()` after deletion

### MealPlanDetailView
**File:** `RecipesViewPart2.swift`
**Changes:**
- Added `@EnvironmentObject var dataManager`
- Added `@Environment(\.dismiss) var dismiss`
- Added `@State` for sheet and alert presentation
- Added toolbar menu with edit and delete
- Added sheet presentation for EditMealPlanView
- Added delete confirmation alert
- Calls `dismiss()` after deletion

---

## User Workflows

### Editing a Recipe

1. User taps on recipe in list
2. Recipe detail view opens
3. User taps menu button (•••) in top-right
4. User selects "Edit Recipe"
5. Edit sheet appears with all fields populated
6. User makes changes
7. User taps "Save"
8. Recipe updates immediately
9. Sheet dismisses, detail view shows updated info

### Deleting a Recipe

**Method 1 - From List (iPhone):**
1. User swipes left on recipe row
2. Red delete button appears
3. User taps delete
4. Recipe removed immediately
5. List updates

**Method 2 - From Detail View:**
1. User opens recipe detail
2. User taps menu button (•••)
3. User selects "Delete Recipe"
4. Confirmation alert appears
5. User confirms deletion
6. Recipe deleted
7. View dismisses back to list

### Editing a Meal Plan

1. User taps on meal plan in list
2. Meal plan detail view opens
3. User taps menu button (•••) in top-right
4. User selects "Edit Meal Plan"
5. Edit sheet appears with current settings
6. User can change:
   - Plan name
   - Start date
   - Number of days
7. User taps "Save"
8. If dates/days changed → meals regenerate
9. If only name changed → simple rename
10. Sheet dismisses, detail view updates

### Deleting a Meal Plan

**Method 1 - From List:**
1. User swipes left on meal plan row
2. Red delete button appears
3. User taps delete
4. Meal plan removed immediately

**Method 2 - From Detail View:**
1. User opens meal plan detail
2. User taps menu button (•••)
3. User selects "Delete Meal Plan"
4. Confirmation alert appears
5. User confirms deletion
6. Meal plan deleted
7. View dismisses back to list

---

## Files Modified

### 1. **DataManager.swift**
- **Line ~180:** Added `updateMealPlan()` method

### 2. **RecipesViewNew.swift**
- **RecipeDetailView:**
  - Added state variables for sheets and alerts
  - Replaced favorite button with menu
  - Added edit and delete functionality
  - Added EditRecipeView sheet presentation
  - Added delete confirmation alert

- **NEW: EditRecipeView** (~200 lines)
  - Complete recipe editing interface
  - Pre-populated form
  - Preserves ID and favorite status

### 3. **RecipesViewPart2.swift**
- **MealPlanDetailView:**
  - Added DataManager environment object
  - Added dismiss environment
  - Added state variables for sheets and alerts
  - Added toolbar menu
  - Added edit and delete functionality
  - Added sheet and alert presentations

- **NEW: EditMealPlanView** (~100 lines)
  - Meal plan editing interface
  - Smart regeneration logic
  - Pre-populated form

---

## Edge Cases Handled

### Recipe Editing
✅ Empty fields validation
✅ Number parsing (prep time, cook time, servings)
✅ Favorite status preservation
✅ Recipe ID preservation (critical!)
✅ Ingredient/instruction list management

### Recipe Deletion
✅ Confirmation before deletion
✅ Meal plans using deleted recipe show empty slot
✅ Shopping list items remain (ingredients are copies)
✅ View dismisses after deletion from detail

### Meal Plan Editing
✅ Date changes regenerate schedule
✅ Existing meals preserved when possible
✅ Random recipes assigned to new days
✅ Simple name-only updates don't regenerate
✅ Creation date preserved

### Meal Plan Deletion
✅ Confirmation before deletion
✅ Associated recipes not deleted (correct behavior)
✅ View dismisses after deletion from detail
✅ List updates immediately

---

## Data Persistence

All changes persist immediately:
- `updateRecipe()` → `saveRecipes()` → UserDefaults
- `updateMealPlan()` → `saveMealPlans()` → UserDefaults
- `deleteRecipe()` → `saveRecipes()` → UserDefaults
- `deleteMealPlan()` → `saveMealPlans()` → UserDefaults

---

## UI/UX Considerations

### Consistency
✅ Edit views match Add views in appearance
✅ Delete confirmation on destructive actions
✅ Menu pattern used consistently
✅ Swipe actions work as users expect

### Discoverability
✅ Menu button prominently placed
✅ Swipe actions standard iOS pattern
✅ Icons clearly indicate actions
✅ Confirmation prevents accidents

### Feedback
✅ Changes reflect immediately
✅ Views update automatically
✅ Alerts confirm destructive actions
✅ Smooth transitions and dismissals

---

## Testing Checklist

### Recipe Management
- [ ] Edit recipe from detail view
- [ ] All fields editable and save correctly
- [ ] Favorite status preserved after edit
- [ ] Recipe ID stays the same after edit
- [ ] Delete recipe from list (swipe)
- [ ] Delete recipe from detail view
- [ ] Deletion confirmation works
- [ ] View dismisses after detail delete
- [ ] Recipe list updates immediately

### Meal Plan Management
- [ ] Edit meal plan from detail view
- [ ] Name-only edit works (simple update)
- [ ] Date change regenerates meals
- [ ] Duration change regenerates meals
- [ ] Existing meals preserved where possible
- [ ] Creation date preserved after edit
- [ ] Delete meal plan from list (swipe)
- [ ] Delete meal plan from detail view
- [ ] Deletion confirmation works
- [ ] View dismisses after detail delete
- [ ] Meal plan list updates immediately

### Edge Cases
- [ ] Edit then immediately delete
- [ ] Delete last recipe
- [ ] Delete last meal plan
- [ ] Edit meal plan with no recipes available
- [ ] Cancel edit without saving
- [ ] Invalid number inputs handled

---

## Benefits to Users

1. **Full Control** - Users can modify any recipe or meal plan
2. **Mistake Correction** - Easy to fix typos or errors
3. **Flexibility** - Meal plans can be adjusted without starting over
4. **Safety** - Confirmation alerts prevent accidental deletion
5. **Speed** - Swipe actions for quick deletion
6. **Consistency** - Edit interface familiar from add screens

---

## Future Enhancements (Optional)

- Duplicate recipe feature
- Bulk delete/edit
- Undo deletion (with toast notification)
- Recipe version history
- Meal plan templates
- Drag-and-drop meal reordering
- Share recipe as text
- Export meal plan to calendar

---

## Summary

✅ **Recipes:** Full edit and delete capability
✅ **Meal Plans:** Full edit and delete capability  
✅ **Lists:** Swipe-to-delete on both
✅ **Detail Views:** Menu with all actions
✅ **Data Safety:** Confirmations before deletion
✅ **Persistence:** All changes saved immediately
✅ **UX:** Smooth, intuitive, iOS-standard patterns

Users now have complete control over their recipes and meal plans! 🎉
