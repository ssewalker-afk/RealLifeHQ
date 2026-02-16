# Habit Tracker: Notifications & Edit/Delete Features

## Overview
Added comprehensive notification reminders and full edit/delete functionality to the Habit Tracker, matching the frequency settings of each habit.

## New Features

### 1. Notification Reminders ✅

**When Creating a Habit:**
- Toggle to enable "Daily Reminder"
- Time picker to set reminder time
- Notifications match habit frequency automatically
- Permission request handled gracefully

**Notification Behavior:**
- **Daily habits:** Reminder every day at chosen time
- **Specific days:** Reminders only on selected days
- **Weekly habits:** Reminder on first selected day each week

### 2. Edit Habits ✅

**Access:**
- Tap any habit in the list to edit
- Full editing of all habit properties
- Changes save immediately

**Editable Fields:**
- Habit name
- Icon
- Frequency (Daily/Specific Days/Weekly)
- Selected days (if applicable)
- Reminder on/off
- Reminder time

### 3. Delete Habits ✅

**Methods:**
- Swipe left on habit → Delete
- Edit habit → Scroll down → Delete button
- Confirmation alert before deletion

**What Gets Deleted:**
- The habit itself
- All completion history
- All scheduled notifications

---

## Technical Implementation

### Models.swift

**Updated Habit struct:**
```swift
struct Habit: Identifiable, Codable {
    var id = UUID()
    var name: String
    var icon: String
    var color: String
    var frequency: Frequency
    var selectedDays: Set<Int> = Set([1, 2, 3, 4, 5, 6, 7])
    var completedDates: [Date] = []
    var reminderEnabled: Bool = false  // NEW
    var reminderTime: Date?  // NEW
    var notificationIdentifiers: [String] = []  // NEW
    
    enum Frequency: String, Codable, CaseIterable {
        case daily = "Daily"
        case specificDays = "Specific Days"
        case weekly = "Weekly"
    }
}
```

**New Fields:**
- `reminderEnabled`: Whether notifications are on
- `reminderTime`: What time to send reminders
- `notificationIdentifiers`: Array of scheduled notification IDs for cleanup

### NotificationManager.swift

**New Methods:**

```swift
// Schedule habit reminders based on frequency
func scheduleHabitReminders(for habit: Habit) async -> [String]

// Cancel habit reminders by IDs
func cancelHabitReminders(identifiers: [String])

// Internal: Schedule single notification for a day/time
private func scheduleHabitNotification(
    habitName: String, 
    hour: Int, 
    minute: Int, 
    weekday: Int
) async -> String?
```

**Scheduling Logic:**
- **Daily:** 7 notifications (one per day of week)
- **Specific Days:** 1-7 notifications (one per selected day)
- **Weekly:** 1 notification (on first selected day)
- All use `repeats: true` for recurring notifications

### DataManager.swift

**Updated Methods:**

```swift
// Add habit with notifications
func addHabit(_ habit: Habit) {
    // Append to array
    // Schedule notifications if enabled
    // Store returned notification IDs
    // Save
}

// Update habit and reschedule notifications
func updateHabit(_ habit: Habit) {
    // Cancel old notifications
    // Update habit in array
    // Schedule new notifications if enabled
    // Store new notification IDs
    // Save
}

// Delete habit and cancel notifications
func deleteHabit(_ habit: Habit) {
    // Cancel all notifications
    // Remove from array
    // Save
}
```

### HabitsView.swift

**Enhanced AddHabitView:**
- Added reminder toggle section
- Time picker for reminder time
- Permission handling with alert
- Async notification scheduling

**New EditHabitView:**
- Pre-populates all existing habit data
- Full editing capability
- Delete button at bottom
- Confirmation alerts
- Notification rescheduling on save

**Updated HabitDetailRow:**
- Now wrapped in NavigationLink to EditHabitView
- Tap to edit
- Swipe to delete still available

---

## User Experience

### Creating a Habit with Reminders

**Flow:**
1. Tap **+** to add habit
2. Enter name, choose icon
3. Select frequency
4. Toggle **"Daily Reminder"** ON
5. Choose reminder time (e.g., 8:00 AM)
6. Tap **Save**
7. Permission prompt appears (first time)
8. Allow notifications
9. Habit created with reminders scheduled

**Result:**
- Notifications sent at 8:00 AM every day (or on selected days)
- Notification title: "Habit Reminder"
- Notification body: "Time to do: [Habit Name]"

### Editing a Habit

**Flow:**
1. Tap on any habit in the list
2. Edit screen opens with current values
3. Change any fields (name, icon, frequency, reminder, etc.)
4. Tap **Save**
5. Old notifications canceled
6. New notifications scheduled
7. Changes saved immediately

### Deleting a Habit

**Method 1 - Swipe:**
1. Swipe left on habit
2. Tap **Delete**
3. Habit removed immediately
4. Notifications canceled

**Method 2 - Edit Screen:**
1. Tap habit to edit
2. Scroll to bottom
3. Tap **Delete Habit** (red button)
4. Confirmation alert appears
5. Confirm deletion
6. Habit deleted, view dismisses
7. Notifications canceled

---

## Notification Scheduling Examples

### Daily Habit
**Settings:**
- Frequency: Daily
- Reminder: 8:00 AM

**Scheduled Notifications:**
- Sunday 8:00 AM (repeats weekly)
- Monday 8:00 AM (repeats weekly)
- Tuesday 8:00 AM (repeats weekly)
- Wednesday 8:00 AM (repeats weekly)
- Thursday 8:00 AM (repeats weekly)
- Friday 8:00 AM (repeats weekly)
- Saturday 8:00 AM (repeats weekly)

**Total:** 7 recurring notifications

### Specific Days (Weekdays Only)
**Settings:**
- Frequency: Specific Days
- Selected: Mon, Tue, Wed, Thu, Fri
- Reminder: 7:00 AM

**Scheduled Notifications:**
- Monday 7:00 AM (repeats weekly)
- Tuesday 7:00 AM (repeats weekly)
- Wednesday 7:00 AM (repeats weekly)
- Thursday 7:00 AM (repeats weekly)
- Friday 7:00 AM (repeats weekly)

**Total:** 5 recurring notifications

### Weekly Habit
**Settings:**
- Frequency: Weekly
- Selected: Sunday
- Reminder: 9:00 AM

**Scheduled Notifications:**
- Sunday 9:00 AM (repeats weekly)

**Total:** 1 recurring notification

---

## Permission Handling

### First Time
1. User enables reminder toggle
2. App requests notification permission
3. System alert appears
4. User allows or denies

### If Denied
- Toggle turns back off
- Alert explains user needs to enable in Settings
- "Open Settings" button provided
- Can try again later

### If Already Granted
- Notifications schedule immediately
- No additional prompts

---

## Files Modified

### 1. **Models.swift**
- Added `reminderEnabled`, `reminderTime`, `notificationIdentifiers` to `Habit` struct

### 2. **NotificationManager.swift**
- Added `scheduleHabitReminders()` method
- Added `cancelHabitReminders()` method
- Added private `scheduleHabitNotification()` helper
- Returns notification IDs for storage

### 3. **DataManager.swift**
- Updated `addHabit()` to schedule notifications and store IDs
- Added `updateHabit()` method for editing
- Updated `deleteHabit()` to cancel notifications

### 4. **HabitsView.swift**
- Enhanced `AddHabitView` with notification section
- Created `EditHabitView` (new, ~200 lines)
- Updated `HabitDetailRow` with NavigationLink
- Added permission alert handling
- Added async notification scheduling

---

## UI Changes

### Add Habit Screen
**New Section:**
```
┌─────────────────────────────┐
│ Notifications               │
├─────────────────────────────┤
│ Daily Reminder      [Toggle]│
│ Reminder Time       8:00 AM │
│                             │
│ You'll receive a reminder   │
│ at this time on the days    │
│ you've selected...          │
└─────────────────────────────┘
```

### Edit Habit Screen (NEW)
```
┌─────────────────────────────┐
│ ← Edit Habit          Save  │
├─────────────────────────────┤
│ Habit Details               │
│ • Habit Name                │
│ • Icon                      │
├─────────────────────────────┤
│ Frequency                   │
│ • Daily/Specific/Weekly     │
├─────────────────────────────┤
│ Days of the Week (if needed)│
├─────────────────────────────┤
│ Notifications               │
│ • Toggle & Time             │
├─────────────────────────────┤
│ [Delete Habit] (red)        │
└─────────────────────────────┘
```

### Habit List
**Before:** Tap → Nothing  
**After:** Tap → Edit Screen

**Swipe Actions:** Delete (unchanged)

---

## Testing Checklist

### Notifications
- [ ] Create habit with reminder enabled
- [ ] Permission prompt appears
- [ ] Grant permission
- [ ] Notifications schedule successfully
- [ ] Daily habit gets 7 notifications
- [ ] Specific days habit gets correct count
- [ ] Weekly habit gets 1 notification
- [ ] Notifications fire at correct time
- [ ] Notification shows correct habit name

### Editing
- [ ] Tap habit opens edit screen
- [ ] All fields pre-populated correctly
- [ ] Can change name
- [ ] Can change icon
- [ ] Can change frequency
- [ ] Can toggle reminder on/off
- [ ] Can change reminder time
- [ ] Save button works
- [ ] Changes persist after save
- [ ] Old notifications canceled
- [ ] New notifications scheduled

### Deleting
- [ ] Swipe left shows delete
- [ ] Swipe delete works immediately
- [ ] Edit screen has delete button
- [ ] Delete button shows confirmation
- [ ] Confirming deletes habit
- [ ] Canceling keeps habit
- [ ] View dismisses after delete
- [ ] Notifications canceled on delete

### Permission Handling
- [ ] First time shows permission prompt
- [ ] Denying turns toggle off
- [ ] Alert explains Settings needed
- [ ] "Open Settings" button works
- [ ] Already granted skips prompt
- [ ] Can enable reminder later

---

## Edge Cases Handled

✅ Permission denied → Toggle disabled, alert shown  
✅ Notifications canceled when habit deleted  
✅ Old notifications canceled when habit edited  
✅ Frequency change updates notification count  
✅ Days change updates which days get notifications  
✅ Time change reschedules at new time  
✅ Reminder disabled → No notifications scheduled  
✅ Empty selected days → Save button disabled  

---

## Benefits

1. **Accountability:** Reminders help users stick to habits
2. **Flexibility:** Match notifications to habit frequency
3. **Control:** Full edit capability for changing needs
4. **Clean Slate:** Delete removes everything cleanly
5. **Privacy:** All on-device, no cloud sync needed
6. **Smart Scheduling:** Automatic multi-day scheduling
7. **No Spam:** Only notifies on relevant days

---

## Future Enhancements (Optional)

- Custom notification sounds per habit
- Notification actions (Complete from notification)
- Reminder before streak breaks
- Multiple reminders per day
- Smart reminder timing based on completion patterns
- Notification grouping
- Rich notifications with habit progress

---

## Summary

✅ **Notifications:** Fully implemented with frequency matching  
✅ **Edit:** Complete editing functionality  
✅ **Delete:** Two methods with confirmation  
✅ **Permission:** Graceful handling  
✅ **Scheduling:** Smart multi-day logic  
✅ **Cleanup:** Notifications canceled properly  

**Users can now set reminders for their habits and have full control to edit or delete them!** 🎯🔔
