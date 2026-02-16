# Budget Editing - Developer Quick Reference

## File Structure

```
EditBudgetView.swift
├── EditBudgetView (Main view)
├── EditCategoryRow (Category editor)
├── AddCategorySheet (Add new category)
└── IconPickerView (Icon & color selection)
```

## Key Components

### EditBudgetView
**Purpose**: Main editing interface for budget configuration

**@State Properties**:
- `monthlyIncome: String` - User's monthly take-home pay
- `needsPercent: Double` - Percentage for needs (0-100)
- `wantsPercent: Double` - Percentage for wants (0-100)
- `savingsPercent: Double` - Percentage for savings (0-100)
- `editingCategories: [BudgetCategory]` - Local copy of categories being edited
- `showingAddCategory: Bool` - Sheet presentation flag
- `selectedCategoryType: BudgetCategory.CategoryType` - Type for new category
- `showingDeleteAlert: Bool` - Delete confirmation flag
- `categoryToDelete: BudgetCategory?` - Category pending deletion

**Computed Properties**:
```swift
totalPercentage: Double           // Sum of all percentages
isValidBudget: Bool               // Validates total = 100% and income > 0
needsAmount: Double               // Dollar amount for needs
wantsAmount: Double               // Dollar amount for wants
savingsAmount: Double             // Dollar amount for savings
categoriesForType(_:): [BudgetCategory]  // Filter by type
totalAllocated(for:): Double      // Sum category limits by type
availableAmount(for:): Double     // Total available for type
```

**Key Methods**:
```swift
saveBudget()                      // Save all changes to DataManager
resetToDefaults()                 // Reset percentages to 50/30/20
deleteCategory(_:)                // Remove category from editing list
binding(for:): Binding<Category>  // Create binding for category in array
```

### EditCategoryRow
**Purpose**: Inline editor for individual category

**Properties**:
- `@Binding var category: BudgetCategory` - Two-way binding to category
- `let onDelete: () -> Void` - Callback for deletion
- `@State private var showingIconPicker: Bool` - Icon picker presentation

**Features**:
- Inline name editing with TextField
- Inline limit editing with currency formatting
- Icon/color change button
- Delete button

### AddCategorySheet
**Purpose**: Form for creating new category

**Properties**:
- `let categoryType: BudgetCategory.CategoryType` - Pre-selected type
- `let onSave: (BudgetCategory) -> Void` - Callback with new category
- `@State` variables for name, icon, color, limit

**Validation**:
- Name cannot be empty
- Limit must be valid number
- Add button disabled until valid

### IconPickerView
**Purpose**: Visual picker for icon and color

**Properties**:
- `@Binding var selectedIcon: String` - SF Symbol name
- `@Binding var selectedColor: String` - Color name as string

**Assets**:
- 32 icons in grid layout
- 10 colors in grid layout
- Live preview section

## Data Flow

```
1. EditBudgetView.onAppear
   └─> Load from DataManager
       ├─> budgetSetup → @State variables
       └─> budgetCategories → editingCategories

2. User Makes Changes
   └─> Updates @State variables
       └─> Computed properties auto-update
           └─> UI reflects changes instantly

3. EditCategoryRow Changes
   └─> Updates @Binding
       └─> editingCategories array updates
           └─> Section totals recalculate

4. User Taps Save
   └─> saveBudget() called
       ├─> Update budgetSetup in DataManager
       ├─> Update/Add changed categories
       ├─> Delete removed categories
       └─> dismiss()

5. DataManager Persistence
   └─> Automatically saves to UserDefaults
       └─> Budget Dashboard reflects new values
```

## Integration Points

### DataManager Methods
```swift
// Budget Setup
func saveBudgetSetup(_ setup: BudgetSetup)

// Category Management  
func addBudgetCategory(_ category: BudgetCategory)
func updateBudgetCategory(_ category: BudgetCategory)
func deleteBudgetCategory(_ category: BudgetCategory)
```

### Access Pattern
```swift
// From BudgetDashboard
.sheet(isPresented: $showingEditBudget) {
    EditBudgetView()
}
```

### Environment Objects Required
```swift
.environmentObject(DataManager())
.environmentObject(ThemeManager())
```

## Validation Rules

### Budget Percentages
```swift
// Must equal 100%
abs(totalPercentage - 100) < 0.01

// Individual percentages: 0-100
needsPercent in 0...100
wantsPercent in 0...100
savingsPercent in 0...100
```

### Income
```swift
// Must be positive
(Double(monthlyIncome) ?? 0) > 0
```

### Categories
```swift
// Name cannot be empty
!category.name.isEmpty

// Limit must be valid number
Double(limitString) != nil

// Limit can be zero (allowed)
category.limit >= 0
```

## State Management Patterns

### Array Binding Pattern
```swift
// Problem: Need @Binding to array element
// Solution: Create binding using index
private func binding(for category: BudgetCategory) -> Binding<BudgetCategory> {
    guard let index = editingCategories.firstIndex(where: { $0.id == category.id }) else {
        return .constant(category)
    }
    return $editingCategories[index]
}

// Usage:
EditCategoryRow(category: binding(for: category))
```

### Local Editing Pattern
```swift
// Load data into local @State
.onAppear {
    editingCategories = dataManager.budgetCategories
}

// Edit local copy
editingCategories.append(newCategory)

// Save on user confirmation
saveBudget() // Writes back to DataManager
```

## UI Patterns

### Section with Header Calculation
```swift
Section {
    categorySection(for: .needs)
} header: {
    HStack {
        Text("Needs Categories")
        Spacer()
        Text(totalAllocated(for: .needs).formatted(.currency(code: "USD")))
        Text("of")
        Text(needsAmount.formatted(.currency(code: "USD")))
    }
}
```

### Dynamic Footer Messages
```swift
footer: {
    let difference = availableAmount - totalAllocated
    if abs(difference) > 0.01 {
        Text(difference > 0 
            ? "💡 \(difference.formatted(.currency(code: "USD"))) unallocated"
            : "⚠️ Over budget by \(abs(difference).formatted(.currency(code: "USD")))")
            .foregroundColor(difference > 0 ? .secondary : .red)
    }
}
```

### Conditional Save Button
```swift
Button("Save") {
    saveBudget()
}
.disabled(!isValidBudget)  // Gray out when invalid
```

## Color Handling

### String to Color Conversion
```swift
// Colors stored as strings in model
category.color = "blue"

// Convert to SwiftUI Color
Color(category.color)  // Works with standard color names

// Available colors
["blue", "purple", "pink", "red", "orange", 
 "yellow", "green", "teal", "indigo", "cyan"]
```

### Category Type Colors
```swift
private func colorForType(_ type: BudgetCategory.CategoryType) -> Color {
    switch type {
    case .needs: return .blue
    case .wants: return .purple
    case .savings: return .green
    }
}
```

## Icon Handling

### SF Symbols
```swift
// Icons stored as SF Symbol names
category.icon = "house.fill"

// Display
Image(systemName: category.icon)

// Available icons (32 total)
["house.fill", "car.fill", "cart.fill", "fork.knife",
 "film.fill", "gamecontroller.fill", "paintbrush.fill", ...]
```

## Form Layout Structure

```swift
Form {
    // Income Section
    Section("Income") { ... }
    
    // Percentages Section
    Section("Budget Distribution") { ... }
    
    // Needs Section
    Section(header: needsHeader) {
        categorySection(for: .needs)
    } footer: {
        allocationFooter(for: .needs)
    }
    
    // Wants Section (same pattern)
    
    // Savings Section (same pattern)
    
    // Reset Section
    Section { resetButton() }
}
```

## Alert Patterns

### Delete Confirmation
```swift
.alert("Delete Category", isPresented: $showingDeleteAlert) {
    Button("Cancel", role: .cancel) { }
    Button("Delete", role: .destructive) {
        if let category = categoryToDelete {
            deleteCategory(category)
        }
    }
} message: {
    Text("Are you sure you want to delete '\(category.name)'?")
}
```

## Sheet Patterns

### Add Category
```swift
.sheet(isPresented: $showingAddCategory) {
    AddCategorySheet(categoryType: selectedCategoryType) { newCategory in
        editingCategories.append(newCategory)
    }
}
```

### Icon Picker
```swift
.sheet(isPresented: $showingIconPicker) {
    IconPickerView(selectedIcon: $category.icon, 
                   selectedColor: $category.color)
}
```

## Formatting

### Currency Display
```swift
// Income and limits
Text(amount.formatted(.currency(code: "USD")))
// Output: "$1,234.56"

// With TextField binding
TextField("$0.00", text: $limitString)
    .keyboardType(.decimalPad)
```

### Percentage Display
```swift
Text("\(Int(percentage))%")
// Output: "50%"

// For sliders
Slider(value: $needsPercent, in: 0...100, step: 1)
```

## Performance Tips

### Only Save on Confirmation
```swift
// ❌ Don't do this
.onChange(of: needsPercent) { _, _ in
    dataManager.saveBudgetSetup(...)  // Too many saves!
}

// ✅ Do this instead
func saveBudget() {
    // All changes saved at once
    dataManager.saveBudgetSetup(...)
}
```

### Computed Properties for Calculations
```swift
// ✅ Good - recalculates automatically
private var needsAmount: Double {
    (Double(monthlyIncome) ?? 0) * (needsPercent / 100)
}

// ❌ Avoid - requires manual updates
@State private var needsAmount: Double = 0
```

## Testing Checklist

```swift
// Budget Validation
□ Total percentages = 100%
□ Total percentages ≠ 100% (disabled save)
□ Zero income (disabled save)
□ Negative income (should not be possible)

// Category Operations
□ Add new category
□ Edit category name
□ Edit category limit
□ Change category icon
□ Delete category with confirmation

// Percentage Adjustments
□ Move sliders smoothly
□ Dollar amounts update in real-time
□ All three percentages adjust independently
□ Reset to defaults works

// Allocation Tracking
□ Under-allocated shows unallocated amount
□ Perfectly allocated shows no message
□ Over-allocated shows warning
□ Totals calculate correctly

// UI/UX
□ Cancel discards changes
□ Save preserves changes
□ Keyboard dismisses properly
□ Sheet presentations work
□ Alerts show and dismiss
```

## Common Gotchas

### 1. Binding to Array Elements
```swift
// ❌ This doesn't work
ForEach($editingCategories) { $category in
    EditCategoryRow(category: $category)  // Can't pass binding this way
}

// ✅ Use helper method
ForEach(categoriesForType(type)) { category in
    EditCategoryRow(category: binding(for: category))
}
```

### 2. Float Precision with Percentages
```swift
// ❌ Exact equality fails with floats
if totalPercentage == 100 { ... }

// ✅ Use tolerance
if abs(totalPercentage - 100) < 0.01 { ... }
```

### 3. String to Double Conversion
```swift
// ❌ Force unwrap crashes
let income = Double(monthlyIncome)!

// ✅ Optional with default
let income = Double(monthlyIncome) ?? 0
```

### 4. Environment Object in Init
```swift
// ❌ Can't access in init
init() {
    monthlyIncome = dataManager.budgetSetup.monthlyIncome  // Error!
}

// ✅ Load in onAppear
.onAppear {
    monthlyIncome = String(dataManager.budgetSetup.monthlyIncome)
}
```

## Extension Points

### Add New Features
```swift
// Budget Templates
struct BudgetTemplate {
    let name: String
    let needsPercent: Double
    let wantsPercent: Double
    let savingsPercent: Double
}

// Category Suggestions
func suggestCategories(for type: CategoryType) -> [BudgetCategory]

// Budget History
struct BudgetSnapshot {
    let date: Date
    let setup: BudgetSetup
    let categories: [BudgetCategory]
}
```

## SwiftUI Best Practices Used

1. **@State for local changes**: All edits happen in local state
2. **@Binding for child views**: Pass data down to edit rows
3. **Computed properties**: Auto-updating calculations
4. **Form sections**: Organized, scrollable layout
5. **Conditional views**: Show/hide based on state
6. **Sheet presentations**: Modal editing flows
7. **Alert confirmations**: Prevent accidental deletions
8. **Environment objects**: Global data access
9. **onAppear loading**: Initialize state from environment
10. **Dismiss on save**: Clean navigation flow

## Summary

The EditBudgetView provides a comprehensive, well-structured interface for budget customization. Key architectural decisions:

- **Local state editing** prevents half-saved changes
- **Computed properties** ensure consistent calculations
- **Validation before save** prevents invalid data
- **Component reusability** (icon picker, category row)
- **Clear data flow** (load → edit → save)
- **User-friendly feedback** at every step

This design makes the code maintainable, testable, and extensible while providing an excellent user experience.
