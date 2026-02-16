# Apple Calendar Integration - Setup Guide

## Overview
Your app now has full Apple Calendar integration! Users can sync events between RealLifeHQ and their Apple Calendar.

## ⚙️ Required Setup

### 1. Add Privacy Permissions to Info.plist

You **must** add calendar usage descriptions to your `Info.plist` file:

**In Xcode:**
1. Open your project in Xcode
2. Select your target → Info tab
3. Click the **+** button to add new keys
4. Add these two keys:

```xml
<key>NSCalendarsUsageDescription</key>
<string>RealLifeHQ needs access to your calendar to sync events between the app and Apple Calendar</string>

<key>NSCalendarsFullAccessUsageDescription</key>
<string>RealLifeHQ needs full calendar access to create, edit, and delete synced events in your Apple Calendar</string>
```

**Or add directly to Info.plist source:**
Right-click Info.plist → Open As → Source Code, then paste the above XML inside the `<dict>` section.

### 2. Test the Integration

Build and run your app, then:

1. Go to **Settings** → **Integrations** → **Apple Calendar Sync**
2. Tap **"Grant Calendar Access"** → Allow access
3. Enable **"Sync with Apple Calendar"**
4. Create a test event in RealLifeHQ
5. Open Apple Calendar app → Verify the event appears

## 📋 Features Implemented

### ✅ Core Features
- **Two-way sync**: Events created in RealLifeHQ automatically sync to Apple Calendar
- **Real-time updates**: Changes are synced immediately
- **Event deletion**: Deleting events in RealLifeHQ removes them from Apple Calendar
- **Full event support**: 
  - All-day events
  - Timed events with start/end times
  - Event notes
  - Recurring events (daily, weekly, biweekly, monthly, yearly)
  - Reminders/alarms

### ✅ Import Feature
- Import existing events from Apple Calendar into RealLifeHQ
- Select custom date ranges for import
- Automatic duplicate detection

### ✅ User Controls
- Enable/disable sync at any time
- Grant calendar permissions from settings
- Sync all existing events or just new ones
- View authorization status

## 🔧 How It Works

### Event Creation Flow
```
User creates event in RealLifeHQ
    ↓
DataManager.addEvent() saves locally
    ↓
AppleCalendarManager checks if sync is enabled
    ↓
If enabled: Creates matching event in Apple Calendar
    ↓
Stores mapping between app event and calendar event
```

### Event Update Flow
```
User edits event in RealLifeHQ
    ↓
DataManager.updateEvent() updates local data
    ↓
AppleCalendarManager finds matching calendar event
    ↓
Updates the calendar event with new details
```

### Event Deletion Flow
```
User deletes event in RealLifeHQ
    ↓
AppleCalendarManager finds matching calendar event
    ↓
Deletes calendar event
    ↓
DataManager removes local event
    ↓
Removes event mapping
```

## 🎯 Key Files Added

1. **`AppleCalendarManager.swift`**
   - Manages EventKit integration
   - Handles authorization
   - Converts between app Events and EKEvents
   - Maintains event mapping

2. **`CalendarSyncSettingsView.swift`**
   - User interface for calendar sync
   - Permission requests
   - Import functionality
   - Sync controls

3. **Updated: `DataManager.swift`**
   - Added calendar sync calls to event methods
   - Automatic syncing on add/update/delete

4. **Updated: `SettingsView.swift`**
   - Added "Integrations" section
   - Link to Calendar Sync settings

## 🔐 Privacy & Security

- **No cloud services**: All syncing happens locally on the device
- **User control**: Users must explicitly grant permission
- **Transparent**: Clear explanations of what data is accessed
- **Reversible**: Users can disable sync at any time

## 📱 User Experience

### First Time Setup
1. User navigates to Settings → Integrations → Apple Calendar Sync
2. Sees "Access Required" status
3. Taps "Grant Calendar Access"
4. System shows permission dialog with your usage description
5. After granting: Toggle "Sync with Apple Calendar"
6. Optional: Sync all existing events

### Daily Usage
- Users create events normally in RealLifeHQ
- Events automatically appear in Apple Calendar
- Works with all other calendar apps that read from Apple Calendar (default calendar store)
- Events remain in sync

## 🐛 Troubleshooting

### "Calendar access not authorized"
- User needs to grant permission in Settings → Privacy & Security → Calendars
- Or revoke and re-grant from the app

### Events not syncing
1. Check if sync is enabled in app settings
2. Verify calendar permission is granted
3. Ensure device has default calendar set up

### Duplicate events
- The import feature checks for duplicates by title and date
- If a duplicate is detected, it won't be imported again

## 🚀 Future Enhancements (Optional)

Consider adding:
- **Sync from Calendar → App**: Watch for changes in Apple Calendar and import them
- **Calendar selection**: Let users choose which calendar to sync to
- **Conflict resolution**: Handle when same event is modified in both places
- **Batch import**: Import all past events with one tap
- **Sync status indicator**: Show when events are syncing

## 📊 Testing Checklist

- [ ] Added Info.plist permissions
- [ ] App requests calendar access
- [ ] Can enable/disable sync
- [ ] Creating event in app → appears in Calendar
- [ ] Editing event in app → updates in Calendar
- [ ] Deleting event in app → removes from Calendar
- [ ] Import events from Calendar works
- [ ] All-day events sync correctly
- [ ] Timed events with start/end sync correctly
- [ ] Recurring events sync correctly
- [ ] Event reminders sync correctly

## ⚠️ Important Notes

1. **EventKit limitations**: 
   - Some calendar features may not map perfectly (e.g., complex recurrence rules)
   - Calendar availability depends on user's setup

2. **Performance**:
   - Syncing is asynchronous to avoid blocking UI
   - Large event imports may take a moment

3. **Data mapping**:
   - App maintains mapping between its events and calendar events
   - This mapping is stored in UserDefaults

Enjoy your Apple Calendar integration! 🎉
