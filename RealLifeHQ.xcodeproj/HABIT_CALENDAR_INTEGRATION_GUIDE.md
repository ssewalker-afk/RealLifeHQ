# Habit Calendar Integration - Complete Guide

## ✨ New Features Added

### 1. **Calendar Integration**
   - Add habits as recurring events to your device's system calendar
   - Automatic synchronization with Apple Calendar
   - Events appear in Calendar app with habit emoji 🎯

### 2. **Customizable Duration**
   - Set how long each habit session should last
   - Options: 15, 30, 45 minutes, 1 hour, 1.5 hours, 2 hours
   - Perfect for time-blocking your day

### 3. **Complete Edit Control**
   - Edit habit name, icon, frequency, days
   - Enable/disable calendar integration anytime
   - Remove calendar events when disabling integration
   - All changes sync automatically

### 4. **Smart Calendar Management**
   - Recurring events created based on frequency
   - Daily habits = daily recurring event
   - Specific days = weekly recurring on selected days
   - Events update when you change habit settings

---

## 📱 User Guide

### Adding a New Habit with Calendar

1. **Tap the + button** in Habits view
2. **Fill in habit details:**
   - Name (e.g., "Morning Run")
   - Icon (choose from categories)
   - Frequency (Daily or Specific Days)
   - Select days if using Specific Days

3. **Enable Notifications:**
   - Toggle "Daily Reminder" ON
   - Set the time you want to do the habit
   - Grant notification permission if prompted

4. **Add to Calendar:**
   - Toggle "Add to Calendar" ON
   - Choose duration from picker
   - Grant calendar permission if prompted

5. **Save** - Your habit is now in both the app AND your calendar!

### Editing an Existing Habit

1. **Long press** on any habit in the list
2. **Tap "Edit Habit"**
3. **Make your changes:**
   - Update name, icon, or frequency
   - Change reminder time
   - Enable/disable calendar integration
   - Adjust duration

4. **Save changes** - Calendar events update automatically

### Removing from Calendar

To remove a habit from your calendar:

1. **Edit the habit**
2. **Toggle "Add to Calendar" OFF**
3. **Save** - All calendar events are automatically removed

### Deleting a Habit

When you delete a habit:
- ✅ All calendar events are automatically removed
- ✅ Notification reminders are canceled
- ✅ Completion history is deleted

---

## 🔧 Technical Implementation

### Architecture

```
Habit Model (Updated)
├── addToCalendar: Bool
├── calendarEventIdentifiers: [String]
└── calendarDuration: Int

HabitCalendarManager
├── requestCalendarAccess()
├── addHabitToCalendar()
├── updateHabitInCalendar()
└── removeHabitFromCalendar()

Views
├── AddHabitView (with calendar toggle)
└── EditHabitView (with calendar management)
```

### Key Files Modified

1. **Models.swift**
   - Added `addToCalendar`, `calendarEventIdentifiers`, `calendarDuration` to `Habit`

2. **HabitCalendarManager.swift** (NEW)
   - Manages all EventKit interactions
   - Handles permissions
   - Creates/updates/deletes calendar events

3. **HabitsView.swift**
   - Updated `AddHabitView` with calendar section
   - Updated `EditHabitView` with calendar management
   - Added permission alerts

---

## 🗓️ How Calendar Events Work

### Daily Habits
```swift
Habit: "Morning Run"
Frequency: Daily
Time: 7:00 AM
Duration: 30 minutes

Creates: 
→ Single recurring event
→ Repeats every day
→ 7:00 AM - 7:30 AM
→ No end date (until habit deleted)
```

### Specific Days Habits
```swift
Habit: "Gym Workout"
Frequency: Specific Days
Days: Mon, Wed, Fri
Time: 6:00 PM
Duration: 1 hour

Creates:
→ Single recurring event
→ Repeats weekly on M/W/F
→ 6:00 PM - 7:00 PM
→ No end date
```

### Event Metadata
All calendar events include:
- 📝 Title: Habit name
- 🗓️ Start/End: Based on reminder time + duration
- 🔁 Recurrence: Daily or weekly pattern
- 📋 Notes: "🎯 Habit Tracker: [Habit Name]"

---

## 🔐 Permissions Required

### Calendar Access
**When:** User toggles "Add to Calendar" ON  
**Purpose:** Create recurring events in system calendar  
**Prompt:** "RealLifeHQ would like to access your calendar"  
**iOS Setting:** Settings → Privacy & Security → Calendars

### Notifications
**When:** User toggles "Daily Reminder" ON  
**Purpose:** Send habit reminder notifications  
**Required for:** Setting calendar event times  
**iOS Setting:** Settings → Notifications → RealLifeHQ

---

## 💡 Usage Examples

### Morning Routine
```
Habit: "Morning Meditation"
Time: 6:30 AM
Duration: 15 minutes
Frequency: Daily
Calendar: ✓ Enabled

Result: Daily 15-min block in calendar at 6:30 AM
```

### Workout Schedule
```
Habit: "Weight Training"
Time: 5:00 PM  
Duration: 1 hour
Frequency: Mon, Wed, Fri
Calendar: ✓ Enabled

Result: 1-hour blocks every M/W/F at 5:00 PM
```

### Study Sessions
```
Habit: "Study Spanish"
Time: 8:00 PM
Duration: 45 minutes
Frequency: Tue, Thu, Sat
Calendar: ✓ Enabled

Result: 45-min study blocks on Tue/Thu/Sat at 8 PM
```

---

## 🎨 UI/UX Design

### Add Habit Screen
```
┌─────────────────────────────┐
│ New Habit          Cancel   │
│                      Save   │
├─────────────────────────────┤
│ Habit Details               │
│ Name: [Morning Run____]     │
│ Icon: 🏃 →                  │
├─────────────────────────────┤
│ Frequency                   │
│ ○ Daily  ● Specific Days    │
├─────────────────────────────┤
│ Days of the Week            │
│ [S][M][T][W][T][F][S]       │
├─────────────────────────────┤
│ Notifications               │
│ Daily Reminder      [ON]    │
│ Reminder Time    7:00 AM    │
├─────────────────────────────┤
│ Calendar                    │
│ Add to Calendar     [ON]    │
│ Duration        30 minutes  │
│                             │
│ ℹ️ Recurring events will be │
│ added to your calendar      │
└─────────────────────────────┘
```

### Edit Habit Screen
```
┌─────────────────────────────┐
│ Edit Habit              Save│
├─────────────────────────────┤
│ ... (same as Add) ...       │
├─────────────────────────────┤
│ Calendar                    │
│ Add to Calendar     [OFF]   │
│                             │
│ ⚠️ Calendar events will be  │
│ removed when you save       │
├─────────────────────────────┤
│    [Delete Habit]           │
└─────────────────────────────┘
```

---

## 🐛 Edge Cases Handled

### Scenario: User Disables Calendar
- All existing calendar events are removed
- `calendarEventIdentifiers` cleared
- No orphaned events left in calendar

### Scenario: User Changes Time/Days
- Old events removed automatically
- New events created with updated schedule
- Seamless transition

### Scenario: Permission Denied
- Toggle reverts to OFF
- Alert shows with "Open Settings" option
- No events created

### Scenario: Habit Deleted
- Calendar events removed first
- Then habit deleted from app
- Clean removal

### Scenario: No Reminder Time Set
- Calendar toggle shows helper text
- Duration picker disabled
- Must enable reminder first

---

## 🔍 Testing Checklist

### Calendar Integration
- ✅ Events appear in Calendar app
- ✅ Events show correct title
- ✅ Events have correct start/end times
- ✅ Recurrence pattern matches frequency
- ✅ Daily habits create daily events
- ✅ Specific days create weekly events

### Permission Handling
- ✅ Calendar permission requested
- ✅ Alert shows if denied
- ✅ "Open Settings" button works
- ✅ Toggle reverts if denied

### Editing
- ✅ Changing time updates events
- ✅ Changing days updates pattern
- ✅ Changing duration updates end time
- ✅ Disabling removes all events
- ✅ Re-enabling creates new events

### Deletion
- ✅ Deleting habit removes events
- ✅ No orphaned events remain
- ✅ Calendar cleaned up properly

---

## 📊 Benefits

### For Users
- ⏰ **Time Blocking:** See habits in calendar view
- 📅 **Better Planning:** Visualize habit schedule
- 🔔 **Native Reminders:** System calendar notifications
- 🤝 **Integration:** Works with other calendar apps
- 📱 **Sync:** Events sync across devices via iCloud

### For Developers
- 🏗️ **Modular:** Separate `HabitCalendarManager` class
- 🧹 **Clean:** Proper event lifecycle management
- 🔒 **Safe:** Permission handling built-in
- 🧪 **Testable:** Isolated calendar logic
- 📚 **Documented:** Clear code comments

---

## 🚀 Future Enhancements

Potential improvements for future versions:

1. **Calendar Selection**
   - Let users choose which calendar to use
   - Currently uses default calendar

2. **Event Colors**
   - Match calendar event color to habit color
   - Requires EventKit color API

3. **Completion Sync**
   - Mark calendar event complete when habit checked
   - Two-way sync

4. **Smart Scheduling**
   - AI-suggested best times for habits
   - Based on completion patterns

5. **Multi-Calendar**
   - Add same habit to multiple calendars
   - Useful for shared calendars

6. **Event Reminders**
   - Calendar event alerts separate from app notifications
   - Custom reminder times

7. **Time Zone Support**
   - Handle time zone changes
   - Update events automatically

8. **Import from Calendar**
   - Create habits from existing calendar events
   - Reverse flow

---

## 💬 User Documentation

### FAQ

**Q: Will this work with Google Calendar?**  
A: Yes! Events added to your device calendar sync with Google Calendar if configured.

**Q: Can I change the calendar used?**  
A: Currently uses default calendar. Future update will allow selection.

**Q: What if I change time zones?**  
A: Events use local time. May need manual adjustment after time zone change.

**Q: Do I need notifications enabled?**  
A: Yes, to set the time for calendar events. Reminders provide the event time.

**Q: Can I add past habits to calendar?**  
A: Events only created going forward. Past dates not affected.

**Q: What happens if I delete from Calendar app?**  
A: Events will be recreated next time you edit the habit (if calendar still enabled).

---

## 🎓 Code Examples

### Creating Calendar Events
```swift
// In AddHabitView
if addToCalendar && reminderEnabled {
    let eventIds = await HabitCalendarManager.shared
        .addHabitToCalendar(habit: newHabit)
    newHabit.calendarEventIdentifiers = eventIds
}
```

### Updating Calendar Events
```swift
// In EditHabitView
if needsCalendarUpdate {
    let newEventIds = await HabitCalendarManager.shared
        .updateHabitInCalendar(
            habit: updatedHabit,
            oldEventIds: oldEventIds
        )
    updatedHabit.calendarEventIdentifiers = newEventIds
}
```

### Removing Calendar Events
```swift
// In EditHabitView (Delete)
await HabitCalendarManager.shared
    .removeHabitFromCalendar(
        eventIdentifiers: habit.calendarEventIdentifiers
    )
```

---

## ✅ Summary

### What Was Added
1. ✅ Calendar integration toggle in Add/Edit views
2. ✅ Duration picker for calendar event length
3. ✅ `HabitCalendarManager` for EventKit operations
4. ✅ Automatic event creation/update/deletion
5. ✅ Permission handling with alerts
6. ✅ Smart calendar sync on edit/delete

### What Users Can Do
1. ✅ Add habits to system calendar
2. ✅ Set custom duration for each habit
3. ✅ Edit habits and update calendar automatically
4. ✅ Remove habits from calendar anytime
5. ✅ Delete habits and clean up calendar

### What Developers Get
1. ✅ Clean, modular calendar manager
2. ✅ Proper permission handling
3. ✅ EventKit best practices
4. ✅ Async/await pattern
5. ✅ Error handling throughout

---

Your habits now seamlessly integrate with your calendar for better time management! 🎯📅
