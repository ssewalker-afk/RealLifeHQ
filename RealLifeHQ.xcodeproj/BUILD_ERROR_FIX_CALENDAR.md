# Build Error Fix - HabitCalendarManager Setup

## Issue
Build errors showing "Cannot find 'HabitCalendarManager' in scope"

## Root Cause
The new `HabitCalendarManager.swift` file needs to be added to your Xcode project target.

---

## ✅ Solution: Add File to Xcode Project

### Step 1: Add File to Project
1. **Open Xcode**
2. **In Project Navigator** (left sidebar), find `HabitCalendarManager.swift`
3. If you don't see it:
   - **Right-click** on your project folder
   - Select **"Add Files to [Project Name]..."**
   - Navigate to find `HabitCalendarManager.swift`
   - Click **"Add"**

### Step 2: Verify Target Membership
1. **Select** `HabitCalendarManager.swift` in Project Navigator
2. **Open File Inspector** (right sidebar, or View → Inspectors → Show File Inspector)
3. Under **"Target Membership"**, ensure your app target is **checked**
4. If unchecked, **check the box** next to your app target name

### Step 3: Clean and Build
1. **Clean Build Folder**: `Product → Clean Build Folder` (Shift+Cmd+K)
2. **Build Project**: `Product → Build` (Cmd+B)
3. **Run**: `Product → Run` (Cmd+R)

---

## Alternative: Quick Fix

If the file still isn't recognized, you can temporarily inline the code:

### Option A: Add to DataManager.swift

Add this at the end of `DataManager.swift` (before the closing brace):

```swift
// MARK: - Habit Calendar Manager

@MainActor
class HabitCalendarManager {
    static let shared = HabitCalendarManager()
    private let eventStore = EKEventStore()
    
    private init() {}
    
    func requestCalendarAccess() async -> Bool {
        if #available(iOS 17.0, *) {
            do {
                return try await eventStore.requestFullAccessToEvents()
            } catch {
                print("Calendar permission error: \(error)")
                return false
            }
        } else {
            return await withCheckedContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, error in
                    if let error = error {
                        print("Calendar permission error: \(error)")
                    }
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    func authorizationStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: .event)
    }
    
    func addHabitToCalendar(habit: Habit) async -> [String] {
        guard await requestCalendarAccess() else {
            print("Calendar access denied")
            return []
        }
        
        guard let reminderTime = habit.reminderTime else {
            print("No reminder time set for habit")
            return []
        }
        
        var eventIdentifiers: [String] = []
        
        switch habit.frequency {
        case .daily:
            if let eventId = await createRecurringEvent(
                title: habit.name,
                time: reminderTime,
                duration: habit.calendarDuration,
                recurrenceRule: .daily,
                daysOfWeek: nil
            ) {
                eventIdentifiers.append(eventId)
            }
            
        case .specificDays, .weekly:
            if let eventId = await createRecurringEvent(
                title: habit.name,
                time: reminderTime,
                duration: habit.calendarDuration,
                recurrenceRule: .weekly,
                daysOfWeek: Array(habit.selectedDays).sorted()
            ) {
                eventIdentifiers.append(eventId)
            }
        }
        
        return eventIdentifiers
    }
    
    private func createRecurringEvent(
        title: String,
        time: Date,
        duration: Int,
        recurrenceRule: EKRecurrenceFrequency,
        daysOfWeek: [Int]?
    ) async -> String? {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        let now = Date()
        let startDate = calendar.date(bySettingHour: timeComponents.hour ?? 9,
                                      minute: timeComponents.minute ?? 0,
                                      second: 0,
                                      of: now) ?? now
        
        event.startDate = startDate
        event.endDate = startDate.addingTimeInterval(TimeInterval(duration * 60))
        
        var daysOfWeekForRule: [EKRecurrenceDayOfWeek]?
        if let days = daysOfWeek {
            daysOfWeekForRule = days.map { dayNumber in
                let weekday = EKWeekday(rawValue: dayNumber) ?? .sunday
                return EKRecurrenceDayOfWeek(weekday)
            }
        }
        
        let recurrence = EKRecurrenceRule(
            recurrenceWith: recurrenceRule,
            interval: 1,
            daysOfTheWeek: daysOfWeekForRule,
            daysOfTheMonth: nil,
            monthsOfTheYear: nil,
            weeksOfTheYear: nil,
            daysOfTheYear: nil,
            setPositions: nil,
            end: nil
        )
        
        event.addRecurrenceRule(recurrence)
        event.notes = "🎯 Habit Tracker: \(title)"
        
        do {
            try eventStore.save(event, span: .futureEvents)
            return event.eventIdentifier
        } catch {
            print("Error saving event to calendar: \(error)")
            return nil
        }
    }
    
    func removeHabitFromCalendar(eventIdentifiers: [String]) async -> Bool {
        guard await requestCalendarAccess() else {
            return false
        }
        
        var success = true
        
        for identifier in eventIdentifiers {
            if let event = eventStore.event(withIdentifier: identifier) {
                do {
                    try eventStore.remove(event, span: .futureEvents)
                } catch {
                    print("Error removing event from calendar: \(error)")
                    success = false
                }
            }
        }
        
        return success
    }
    
    func updateHabitInCalendar(habit: Habit, oldEventIds: [String]) async -> [String] {
        _ = await removeHabitFromCalendar(eventIdentifiers: oldEventIds)
        
        if habit.addToCalendar {
            return await addHabitToCalendar(habit: habit)
        }
        
        return []
    }
}
```

Don't forget to add import at the top of DataManager.swift:
```swift
import EventKit
```

---

## ✅ Verification

After adding the file, verify it works:

1. **No build errors** related to `HabitCalendarManager`
2. **Autocomplete works** - type `HabitCalendarManager.` and you should see suggestions
3. **App builds successfully**

---

## 🔍 Common Issues

### Issue: File exists but not in target
**Solution**: Select file → File Inspector → Check target membership

### Issue: File in wrong location
**Solution**: Move file to same folder as other Swift files in project

### Issue: Import EventKit missing
**Solution**: Add `import EventKit` at top of HabitCalendarManager.swift

### Issue: Still getting errors after adding
**Solution**: 
1. Clean Build Folder (Shift+Cmd+K)
2. Delete Derived Data: Xcode → Preferences → Locations → Derived Data → Delete
3. Restart Xcode
4. Rebuild

---

## 📋 Files That Should Exist

Ensure these files are in your project:
- ✅ `HabitCalendarManager.swift` (NEW)
- ✅ `Models.swift` (updated with calendar fields)
- ✅ `HabitsView.swift` (updated with calendar integration)
- ✅ `DataManager.swift` (should already exist)

---

## 🎯 Expected Behavior After Fix

Once fixed, you should be able to:
1. Add habits with calendar integration
2. See "Add to Calendar" toggle in Add/Edit Habit screens
3. Choose duration for calendar events
4. Grant calendar permission when prompted
5. See habit events in Calendar app

---

## Need More Help?

If still having issues:
1. Check Xcode console for specific error messages
2. Verify EventKit framework is linked (shouldn't need manual linking on iOS)
3. Ensure deployment target is iOS 15.0+
4. Check Info.plist has calendar usage description

---

Your build should now work correctly! 🎉
