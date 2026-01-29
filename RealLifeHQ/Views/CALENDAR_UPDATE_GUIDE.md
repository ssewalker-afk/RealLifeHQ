# Calendar View Update - Hourly Daily View with Reminders

## What Changed

### 1. **Event Model (Models.swift)**
Added reminder functionality to the Event struct:
- `reminderMinutesBefore: Int?` - Stores how many minutes before the event to send a notification
- `notificationIdentifier: String?` - Unique ID for canceling notifications
- `eventDateTime: Date` - Computed property that combines date and time for accurate scheduling

### 2. **NotificationManager.swift** (New File)
Created a new notification manager to handle all reminder functionality:
- `requestAuthorization()` - Asks user for notification permissions
- `scheduleEventReminder(for:)` - Schedules a notification for an event
- `cancelEventReminder(identifier:)` - Cancels a specific notification
- Uses iOS's `UserNotifications` framework for native notification support

### 3. **CalendarView.swift** - Complete Redesign
Transformed from a list view to an hourly daily schedule:

#### New Features:
- **Hourly Layout**: Shows all 24 hours of the day (12 AM - 11 PM)
- **Navigation**: 
  - Previous/Next day buttons
  - "Today" button to jump to current date
  - Tap date to open calendar picker
- **Auto-Scroll**: Automatically scrolls to current hour when viewing today
- **Visual Indicators**:
  - Current hour is highlighted
  - Color-coded event markers
  - Bell icon shows which events have reminders
  - Checkmark for completed events
- **Event Cards**: Shows events inline with their hour slot

#### New Components:
- `HourRowView` - Displays each hour row with events
- `HourlyEventCard` - Individual event card with time, title, notes, and actions
- `DatePickerSheet` - Full-screen calendar picker

### 4. **AddEventView** - Enhanced with Reminders
New reminder options when creating events:
- Toggle to enable/disable reminders
- Picker with 8 reminder timing options:
  - At time of event
  - 5, 10, 15, 30 minutes before
  - 1 hour, 2 hours, or 1 day before
- Permission handling with user-friendly alerts
- Bell icon indicator to show reminder is set

### 5. **App Launch (RealLifeHQApp.swift)**
Added automatic notification permission request when app launches

## How to Use

### For Users:

#### Creating an Event with Reminder:
1. Tap the "+" button in Calendar view
2. Enter event title
3. Select date and time (reminders require a time)
4. Toggle "Set Reminder" ON
5. Choose when you want to be reminded
6. Tap "Save"
7. Grant notification permissions when prompted (first time only)

#### Viewing Events:
1. Navigate between days using arrow buttons or "Today" button
2. Tap the date to open calendar picker for any date
3. Scroll through hours to see your schedule
4. Events appear in their time slot with:
   - Time
   - Title
   - Notes (if any)
   - Bell icon (if reminder is set)
   - Checkmark button to mark complete

#### Managing Events:
- **Complete**: Tap the circle/checkmark button
- **Delete**: Long-press the event card and select "Delete"
- Notifications are automatically canceled when you delete an event

### For Developers:

#### Testing Notifications:
1. Run the app on a real device or simulator
2. Create an event 2-5 minutes in the future
3. Set a reminder for "5 minutes before"
4. Close or background the app
5. You should receive a notification at the reminder time

#### Important Notes:
- Notifications require user permission (handled automatically)
- Past events won't trigger notifications
- Deleting an event cancels its notification
- Notification identifiers are stored with events for proper cleanup

## Technical Details

### Notification Scheduling
- Uses `UNCalendarNotificationTrigger` for precise timing
- Notifications include event title and notes
- Each event gets a unique notification identifier (UUID)
- Automatically skips scheduling for past events

### Data Persistence
- Reminder settings are saved with the event
- Notification IDs are preserved across app launches
- Events can be updated without losing reminder information

### UI/UX Improvements
- Color-coded current hour for easy orientation
- Smooth scrolling and animations
- Responsive to theme changes
- Accessible with VoiceOver (standard SwiftUI support)

## Testing Checklist

- [ ] Create event with reminder - notification appears on time
- [ ] Create event without reminder - no notification sent
- [ ] Delete event with reminder - notification is canceled
- [ ] Navigate between days - events display correctly
- [ ] Complete events - checkmark updates properly
- [ ] Theme changes - all colors update
- [ ] Scroll to current hour - auto-scrolls on app launch
- [ ] Calendar picker - can select any date
- [ ] Permission denied - app still functions, shows alert

## Future Enhancements (Ideas)

- Edit existing events
- Recurring events (daily, weekly, monthly)
- Custom reminder times (not just preset options)
- Multiple reminders per event
- Event categories/colors
- Search and filter events
- Week view option
- Month view option
- Export to calendar app
- Event sharing

## Troubleshooting

**Notifications not appearing?**
- Check Settings > Notifications > RealLifeHQ is enabled
- Ensure event time is in the future
- Verify reminder time is set correctly
- Check iOS "Focus" modes aren't blocking notifications

**Auto-scroll not working?**
- Only scrolls when viewing "today"
- May need a moment after view appears
- Try tapping "Today" button

**Events not showing in correct hour?**
- Ensure event has a time set (not just date)
- Check time zone settings
- Verify date and time are correct when creating event
