# Budget Editing Feature - Visual Flow Diagram

## Screen Flow

```
Budget Dashboard
       │
       │ (Tap Menu → Edit Budget)
       ▼
┌─────────────────────────────────────┐
│     Edit Budget View                │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ Monthly Income                │ │
│  │ $4,000.00                     │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ Budget Distribution           │ │
│  │                               │ │
│  │ Needs     ━━━━━━━━━○──  50%  │ │
│  │           $2,000              │ │
│  │                               │ │
│  │ Wants     ━━━━○──────  30%    │ │
│  │           $1,200              │ │
│  │                               │ │
│  │ Savings   ━━○────────  20%    │ │
│  │           $800                │ │
│  │                               │ │
│  │ Total: 100% ✓                 │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ Needs Categories              │ │
│  │ $2,000 of $2,000              │ │
│  │                               │ │
│  │ 🏠 Rent             $1,200    │ │
│  │ 🛒 Food             $500      │ │
│  │ 🚗 Transportation   $300      │ │
│  │                               │ │
│  │ ➕ Add Category               │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ Wants Categories              │ │
│  │ $1,100 of $1,200              │ │
│  │                               │ │
│  │ 🎬 Entertainment    $400      │ │
│  │ 🍽️  Dining Out       $700      │ │
│  │                               │ │
│  │ 💡 $100 unallocated           │ │
│  │ ➕ Add Category               │ │
│  └───────────────────────────────┘ │
│                                     │
│  [Cancel]              [Save ✓]    │
└─────────────────────────────────────┘
       │
       │ (Tap category icon)
       ▼
┌─────────────────────────────────────┐
│   Icon & Color Picker               │
│                                     │
│  Choose Icon                        │
│  ┌───┬───┬───┬───┬───┐            │
│  │🏠 │🚗 │🛒 │🍽️│🎬 │            │
│  ├───┼───┼───┼───┼───┤            │
│  │💼 │📚 │🎮 │✈️ │🛏️│            │
│  └───┴───┴───┴───┴───┘            │
│                                     │
│  Choose Color                       │
│  ● ● ● ● ● ● ● ● ● ●              │
│                                     │
│  Preview                            │
│  🏠 (Blue)                          │
│                                     │
│           [Done]                    │
└─────────────────────────────────────┘
       │
       │ (Tap Add Category)
       ▼
┌─────────────────────────────────────┐
│   Add Category                      │
│                                     │
│  Category Name                      │
│  ┌───────────────────────────────┐ │
│  │ Coffee & Treats               │ │
│  └───────────────────────────────┘ │
│                                     │
│  Icon           🎯 Change           │
│                                     │
│  Budget Limit                       │
│  ┌───────────────────────────────┐ │
│  │ $150.00                       │ │
│  └───────────────────────────────┘ │
│                                     │
│  [Cancel]              [Add]        │
└─────────────────────────────────────┘
```

## Data Flow

```
┌──────────────────┐
│   DataManager    │
│                  │
│ • budgetSetup    │◄───┐
│ • categories     │    │
└──────────────────┘    │
         │              │
         │ Load         │ Save
         ▼              │
┌──────────────────┐    │
│ EditBudgetView   │────┘
│                  │
│ State Variables: │
│ • monthlyIncome  │
│ • needsPercent   │
│ • wantsPercent   │
│ • savingsPercent │
│ • categories[]   │
└──────────────────┘
         │
         │ Pass to
         ▼
┌──────────────────┐
│ EditCategoryRow  │
│                  │
│ @Binding         │
│ category         │
└──────────────────┘
```

## Category Editing Detail

```
Edit Category Row
┌─────────────────────────────────────────┐
│ [🏠] [Rent____________] [🗑️]           │
│      ^                  ^               │
│      │                  │               │
│   Tap to            Tap to              │
│   change icon       delete              │
│                                         │
│ Budget Limit        [$1,200.00]         │
│                          ^              │
│                          │              │
│                      Tap to edit        │
└─────────────────────────────────────────┘
```

## Validation States

### Valid Budget (Can Save)
```
Budget Distribution
━━━━━━━━━━━━━━━━━━━━━━━━
Needs     50%  $2,000
Wants     30%  $1,200  
Savings   20%  $800
━━━━━━━━━━━━━━━━━━━━━━━━
Total: 100% ✅
```

### Invalid Budget (Cannot Save)
```
Budget Distribution
━━━━━━━━━━━━━━━━━━━━━━━━
Needs     50%  $2,000
Wants     35%  $1,400  
Savings   20%  $800
━━━━━━━━━━━━━━━━━━━━━━━━
Total: 105% ❌
⚠️ Total must equal 100%
```

## Category Allocation States

### Perfectly Allocated
```
Needs Categories
$2,000 of $2,000
━━━━━━━━━━━━━━━━━━
🏠 Rent         $1,200
🛒 Food         $500
🚗 Transport    $300
━━━━━━━━━━━━━━━━━━
Total: $2,000 ✅
```

### Under-Allocated (Unallocated Funds)
```
Wants Categories
$1,100 of $1,200
━━━━━━━━━━━━━━━━━━
🎬 Entertainment $400
🍽️  Dining Out    $700
━━━━━━━━━━━━━━━━━━
💡 $100 unallocated
```

### Over-Allocated (Over Budget)
```
Savings Categories
$950 of $800
━━━━━━━━━━━━━━━━━━
🛡️  Emergency    $500
✈️  Vacation     $300
📈 Investment   $150
━━━━━━━━━━━━━━━━━━
⚠️ Over budget by $150
```

## User Interaction Patterns

### Pattern 1: Adjusting Income
```
User Action:        Update income from $4,000 to $5,000
                    ↓
Auto Calculation:   Needs: $2,000 → $2,500
                    Wants: $1,200 → $1,500
                    Savings: $800 → $1,000
                    ↓
User Decision:      Adjust category limits or leave as-is
```

### Pattern 2: Changing Percentages
```
User Action:        Move Needs slider from 50% to 55%
                    ↓
Auto Calculation:   Needs: $2,000 → $2,200 (+$200)
                    ↓
Visual Feedback:    Shows $200 unallocated in Needs section
                    ↓
Suggestion:         "💡 $200 unallocated"
```

### Pattern 3: Adding Category
```
User Taps:          "Add Category" in Wants section
                    ↓
Sheet Opens:        AddCategorySheet (pre-set to Wants type)
                    ↓
User Enters:        Name: "Coffee"
                    Limit: $100
                    Icon: ☕
                    ↓
Result:             Category appears in Wants list
                    Allocation updates: $1,100 → $1,200
```

### Pattern 4: Editing Category Limit
```
Current State:      Rent: $1,200
                    Needs allocated: $2,000 of $2,000
                    ↓
User Changes:       Rent limit to $1,400
                    ↓
Real-time Update:   Needs allocated: $2,200 of $2,000
                    ↓
Visual Feedback:    "⚠️ Over budget by $200" (red)
                    ↓
User Options:       1. Reduce Rent back down
                    2. Reduce other category
                    3. Increase Needs percentage
```

## Color Coding System

```
Category Types:
┌─────────────────┐
│ 🔵 Needs        │  Blue - Essential expenses
└─────────────────┘

┌─────────────────┐
│ 🟣 Wants        │  Purple - Discretionary spending
└─────────────────┘

┌─────────────────┐
│ 🟢 Savings      │  Green - Future planning
└─────────────────┘

Status Indicators:
✅ Valid/Complete    - Green
⚠️  Warning/Issue    - Red
💡 Information/Tip   - Blue
```

## Icon Grid Layout

```
Icon Picker - 32 Icons in 8x4 Grid
┌───┬───┬───┬───┬───┬───┬───┬───┐
│🏠 │🚗 │🛒 │🍽️│🎬 │🎮 │🎨 │📚 │
├───┼───┼───┼───┼───┼───┼───┼───┤
│❤️ │🏥 │🏃 │🏆 │💼 │📱 │📶 │⚡ │
├───┼───┼───┼───┼───┼───┼───┼───┤
│🍃 │🐾 │🎁 │🎈 │🎓 │✈️ │🛏️ │💡 │
├───┼───┼───┼───┼───┼───┼───┼───┤
│🔧 │✂️ │🎵 │👜 │💳 │💵 │📊 │🛡️│
└───┴───┴───┴───┴───┴───┴───┴───┘

Color Palette - 10 Colors
┌───┬───┬───┬───┬───┐
│🔵 │🟣 │🩷 │🔴 │🟠 │
├───┼───┼───┼───┼───┤
│🟡 │🟢 │🔵 │🟣 │🔵 │
└───┴───┴───┴───┴───┘
```

## Responsive Behaviors

### Small Changes (1-5% adjustment)
```
User slides:    Needs 50% → 52%
Result:         Smooth slide, live dollar update
Feedback:       Minimal - just updated numbers
```

### Large Changes (>20% adjustment)
```
User slides:    Wants 30% → 50%
Result:         Other categories don't auto-adjust
Feedback:       "⚠️ Total must equal 100%"
Action:         User must adjust other sliders
```

### Zero Budget Category
```
User sets:      Entertainment limit to $0
Result:         Category stays but shows $0
Note:           Not deleted, just no budget allocated
Benefit:        Can still track spending, just budgeted $0
```

## Save Behavior

### Successful Save
```
User taps Save → Validation passes → Data saved to DataManager
                  ↓
                  Sheet dismisses
                  ↓
                  Budget Dashboard updates with new values
                  ↓
                  Future expenses use new categories
```

### Failed Save Attempt
```
User taps Save → Validation fails (Total ≠ 100%)
                  ↓
                  Button is disabled (can't tap)
                  ↓
                  Red warning shows: "⚠️ Total must equal 100%"
                  ↓
                  User must fix before saving
```

### Cancel Behavior
```
User makes changes → Taps Cancel → Confirmation dialog (optional)
                      ↓
                      All changes discarded
                      ↓
                      Sheet dismisses
                      ↓
                      Budget unchanged
```

## Edge Cases Handled

1. **Empty category name**: Add button disabled
2. **Non-numeric limit**: TextField only accepts numbers
3. **Negative limits**: Not allowed by decimal pad
4. **Percentages don't add up**: Save disabled + warning shown
5. **Zero income**: Save disabled
6. **Deleting last category**: Allowed (can re-add)
7. **Very large numbers**: Formatted properly with currency
8. **Categories with no budget**: Allowed (shows $0.00)

## Accessibility Features

```
Category Row
┌──────────────────────────────────┐
│ [Icon] [Name____________] [🗑️]   │
└──────────────────────────────────┘
  │      │                  │
  │      │                  └─ VoiceOver: "Delete [Name]"
  │      └─ VoiceOver: "Category name: [Name]. Text field."
  └─ VoiceOver: "Icon: [Icon description]. Button. Tap to change."

Slider
━━━━━━━━━━○────────
VoiceOver: "Needs percentage. 50 percent. Adjustable. Swipe up or down to adjust."
```

## Performance Considerations

```
Real-time Updates:
┌─────────────────┐
│ User Input      │
└────────┬────────┘
         │ Immediate
         ▼
┌─────────────────┐
│ State Update    │ ← @State variables
└────────┬────────┘
         │ Efficient
         ▼
┌─────────────────┐
│ UI Refresh      │ ← SwiftUI auto-updates
└────────┬────────┘
         │ < 16ms (60fps)
         ▼
┌─────────────────┐
│ Smooth UX       │
└─────────────────┘
```

Only on Save:
- DataManager updates
- Persistent storage writes
- Budget calculations refresh

## Summary

The Edit Budget View provides a comprehensive, user-friendly interface for customizing every aspect of a personal budget. The design emphasizes:

1. **Visual Feedback** - Users always know their allocation status
2. **Real-time Validation** - Prevents invalid configurations
3. **Flexibility** - Supports any budgeting style
4. **Simplicity** - Complex calculations hidden behind clean UI
5. **Guidance** - Helpful hints and warnings throughout

The result is a powerful tool that makes budget management accessible and even enjoyable!
