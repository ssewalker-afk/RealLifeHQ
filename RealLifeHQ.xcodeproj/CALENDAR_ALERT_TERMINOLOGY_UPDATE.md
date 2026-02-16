# Calendar Event Terminology Update - "Reminder" → "Alert"

## ✨ Change Summary

Updated calendar event notifications terminology from **"Reminder"** to **"Alert"** for better clarity and consistency with iOS conventions.

---

## 📝 What Changed

### Terminology Updates

| Before | After | Context |
|--------|-------|---------|
| "Set Reminder" | "Set Alert" | Toggle label |
| "Remind me" | "Alert me" | Picker label |
| `ReminderOption` | `AlertOption` | Enum name |
| `hasReminder` | `hasAlert` | State variable |
| `reminderOption` | `alertOption` | State variable |
| "Reminder" | "Alert" | Section header |
| "reminders to work" | "alerts to work" | Footer text |
| "event reminders" | "event alerts" | Alert message |

### Why "Alert" Instead of "Reminder"?

1. **iOS Consistency**: 
   - Calendar app uses "Alert" for event notifications
   - Reminders app is a separate app for todo lists
   - Avoids confusion between the two

2. **Clarity**:
   - "Alert" = notification at specific time
   - "Reminder" = could mean todo item or recurring task
   - More precise terminology

3. **User Expectations**:
   - Users familiar with iOS Calendar expect "Alert"
   - Matches system calendar terminology
   - Professional and standard

---

## 🎨 UI Changes

### Add Event Screen

**Before:**
```
┌────────────────────────────┐
│ Reminder                   │
├────────────────────────────┤
│ Set Reminder        [ ON ] │
│ Remind me    15 min before │
└────────────────────────────┘
```

**After:**
```
┌────────────────────────────┐
│ Alert                      │
├────────────────────────────┤
│ Set Alert           [ ON ] │
│ Alert me     15 min before │
└────────────────────────────┘
```

### Edit Event Screen

**Same changes apply** - consistent throughout the app

---

## 💻 Code Changes

### Files Modified
- **CalendarView.swift**
  - `AddEventView` struct
  - `EditEventView` struct

### Changes in AddEventView

#### Enum Renamed
```swift
// Before
enum ReminderOption: Int, CaseIterable {
    case atTime = 0
    case fiveMinutes = 5
    // ...
}

// After
enum AlertOption: Int, CaseIterable {
    case atTime = 0
    case fiveMinutes = 5
    // ...
}
```

#### State Variables Renamed
```swift
// Before
@State private var hasReminder = false
@State private var reminderOption: ReminderOption = .fifteenMinutes

// After
@State private var hasAlert = false
@State private var alertOption: AlertOption = .fifteenMinutes
```

#### UI Updates
```swift
// Before
Section {
    Toggle("Set Reminder", isOn: $hasReminder)
    if hasReminder {
        Picker("Remind me", selection: $reminderOption) {
            // ...
        }
    }
} header: {
    Text("Reminder")
}

// After
Section {
    Toggle("Set Alert", isOn: $hasAlert)
    if hasAlert {
        Picker("Alert me", selection: $alertOption) {
            // ...
        }
    }
} header: {
    Text("Alert")
}
```

#### Save Logic Updated
```swift
// Before
if hasReminder {
    // Check permissions and schedule
}

// After
if hasAlert {
    // Check permissions and schedule
}
```

### Changes in EditEventView

**Same pattern** - all references updated consistently

---

## ✅ Verification

### What Still Works
- ✅ Notifications trigger at correct times
- ✅ Permission requests work properly
- ✅ Alert options (5 min, 15 min, etc.) unchanged
- ✅ Event saving and editing functions normally
- ✅ All notification scheduling intact

### What Changed
- ✅ UI labels more clear and iOS-consistent
- ✅ Better user understanding
- ✅ Professional terminology
- ✅ Code more maintainable

---

## 🧪 Testing Checklist

### Add Event
- ✅ "Set Alert" toggle visible
- ✅ "Alert me" picker appears when enabled
- ✅ Alert options display correctly
- ✅ Section header says "Alert"
- ✅ Notifications still work

### Edit Event
- ✅ "Set Alert" toggle shows correct state
- ✅ Alert picker shows saved value
- ✅ Changes save properly
- ✅ Notifications update correctly

### Notifications
- ✅ Alerts fire at correct times
- ✅ Permission requests still prompt
- ✅ Alert content unchanged
- ✅ Canceling alerts works

---

## 📱 User Impact

### User Benefits
✨ **Clearer Language** - "Alert" is more precise  
✨ **iOS Consistency** - Matches system Calendar app  
✨ **No Confusion** - Distinct from Reminders app  
✨ **Professional** - Standard industry terminology  

### No Breaking Changes
- Existing events with notifications still work
- All functionality preserved
- Only UI text changed
- No data migration needed

---

## 🔍 Technical Details

### What Didn't Change

**Data Model:**
```swift
struct Event {
    // Still uses reminderMinutesBefore for storage
    var reminderMinutesBefore: Int?
    // This field name intentionally kept for backwards compatibility
}
```

**Why?**
- Data model field name is internal
- UI presentation is what users see
- Changing storage field would require migration
- Current name is descriptive enough internally

**Notification System:**
- Still uses same NotificationManager methods
- `scheduleEventReminder()` method name unchanged
- Internal implementation unaffected
- Only UI references updated

### Backwards Compatibility

✅ **Existing events load correctly**  
✅ **Old notifications still fire**  
✅ **No data loss**  
✅ **No migration required**  

---

## 📊 Terminology Comparison

### Apple's Native Apps

| App | Term Used | For What |
|-----|-----------|----------|
| **Calendar** | Alert | Event notifications |
| **Reminders** | Reminder | Todo list items |
| **Clock** | Alarm | Time-based wake-ups |
| **Settings** | Notification | System-level alerts |

### Our App (Updated)
| Feature | Term | Matches |
|---------|------|---------|
| **Calendar Events** | Alert | ✅ Apple Calendar |
| **Habit Tracking** | Reminder | ✅ Daily prompts |
| **Journal** | Notification | ✅ Optional prompts |

---

## 💡 User-Facing Changes

### Add Event Screen
```
When creating an event:

1. Fill in title and date
2. Add time (required for alerts)
3. Toggle "Set Alert" ON
4. Choose when to be alerted:
   • At time of event
   • 5, 10, 15, 30 minutes before
   • 1, 2 hours before
   • 1 day before
```

### Edit Event Screen
```
Same interface for editing:
- Toggle alert on/off
- Change alert timing
- Update event details
- Delete event (removes alert)
```

---

## 🎓 User Education

### Help Text Updated

**Before:**
> "Set Reminder - You'll receive a notification"

**After:**
> "Set Alert - You'll receive a notification"

**Permission Message (Updated):**
> "Notifications must be enabled in Settings for alerts to work"

---

## ✨ Summary

**Changed:**
- 🔤 UI terminology: "Reminder" → "Alert"
- 💬 Help text updated
- 🏷️ Code variable names updated
- 📋 Section headers updated

**Unchanged:**
- 💾 Data storage format
- 🔔 Notification system
- ⚙️ Functionality
- 📊 User data

**Result:**
- ✅ More iOS-consistent
- ✅ Clearer for users
- ✅ Professional appearance
- ✅ No breaking changes

---

**Implementation Date:** February 14, 2026  
**Status:** ✅ Complete
**Testing:** ✅ Verified
**Impact:** Low (cosmetic only)
