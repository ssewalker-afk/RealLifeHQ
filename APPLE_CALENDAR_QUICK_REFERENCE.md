# Apple Calendar Integration - Quick Reference

## 🚀 Quick Start

### Enable Calendar Sync (3 steps)
1. Open **Settings** → **Integrations** → **Apple Calendar Sync**
2. Tap **"Grant Calendar Access"** → Allow
3. Toggle **"Sync with Apple Calendar"** ON

That's it! Your events will now sync automatically.

---

## 📱 What Gets Synced

### ✅ Synced to Apple Calendar
- Event title
- Date and time (or all-day flag)
- Start and end times
- Event notes
- Recurring events (daily, weekly, biweekly, monthly, yearly)
- Reminders/alarms

### ❌ Not Synced
- Event completion status (stays in RealLifeHQ only)
- Events are only synced FROM RealLifeHQ TO Apple Calendar (one-way)

---

## 🎯 Common Tasks

### Create an Event (Auto-Synced)
1. Open Calendar tab
2. Tap **+** button
3. Fill in event details
4. Tap **Save**
→ Event automatically appears in Apple Calendar!

### Edit an Event
1. Tap the event in RealLifeHQ
2. Tap **Edit**
3. Make changes
4. Tap **Save**
→ Changes sync to Apple Calendar

### Delete an Event
1. Swipe left on event (or tap event → Delete)
2. Confirm deletion
→ Event is removed from both RealLifeHQ and Apple Calendar

### Import Existing Events
1. Settings → Integrations → Apple Calendar Sync
2. Tap **"Import Events from Apple Calendar"**
3. Select date range
4. Tap **Import**
→ Events are copied to RealLifeHQ

---

## 🔧 Troubleshooting

### Events Not Syncing?

**Check these 4 things:**

1. **Calendar Permission**
   - Settings → Integrations → Apple Calendar Sync
   - Should show "Access Granted" (green checkmark)
   - If not, tap "Grant Calendar Access"

2. **Sync Enabled**
   - Settings → Integrations → Apple Calendar Sync
   - "Sync with Apple Calendar" toggle should be ON (green)

3. **Check System Settings**
   - iOS Settings app → Privacy & Security → Calendars
   - Make sure RealLifeHQ has permission

4. **Default Calendar Exists**
   - Open Apple Calendar app
   - Make sure you have at least one calendar set up

### "Calendar Access Required" Alert?
- Tap **Open Settings**
- Find RealLifeHQ in the list
- Enable Calendar permission
- Return to app and toggle sync ON

### Seeing Duplicate Events?
- Import feature automatically detects duplicates by title and date
- If you see duplicates, you may have imported the same date range twice
- Solution: Delete duplicates in RealLifeHQ or Apple Calendar

---

## 💡 Pro Tips

### Sync All Existing Events
When you first enable sync, you'll see this prompt:
> "Would you like to sync all existing events to Apple Calendar now?"

- **Sync All Events Now**: Adds all your existing RealLifeHQ events to Apple Calendar
- **Sync New Events Only**: Only events created after this point will sync

### View Sync Status
Look for the green **"Synced"** badge in the Calendar view's navigation bar.

### Turn Off Sync Anytime
1. Settings → Integrations → Apple Calendar Sync
2. Toggle "Sync with Apple Calendar" OFF
3. Your existing events in Apple Calendar remain (not deleted)
4. New events won't sync until you re-enable

### Multiple Calendar Apps
Apple Calendar is the system calendar store on iOS. Any app that reads from it (like Fantastical, Calendars 5, etc.) will also see your synced events!

---

## 🔐 Privacy & Security

- **All local**: No cloud servers involved (except iCloud if you use it for your calendars)
- **You control**: Can enable/disable anytime
- **Transparent**: App tells you exactly what it does
- **Reversible**: Deleting from RealLifeHQ also deletes from Apple Calendar

---

## ⚠️ Important Notes

### One-Way Sync
Currently, sync works from **RealLifeHQ → Apple Calendar** only. 

This means:
- ✅ Events created in RealLifeHQ appear in Apple Calendar
- ❌ Events created in Apple Calendar don't automatically appear in RealLifeHQ
- 💡 Use "Import Events" to bring Apple Calendar events into RealLifeHQ

### Calendar Selection
Events are saved to your **default calendar** in Apple Calendar. To change which calendar:
1. Open Apple Calendar app
2. Settings → Default Calendar
3. Select your preferred calendar

### Recurring Events
Recurring events are fully supported! When you create a recurring event in RealLifeHQ, it appears as recurring in Apple Calendar too.

---

## 📊 Feature Comparison

| Feature | RealLifeHQ | Apple Calendar | Synced? |
|---------|-----------|----------------|---------|
| Basic events | ✅ | ✅ | ✅ |
| All-day events | ✅ | ✅ | ✅ |
| Start/end times | ✅ | ✅ | ✅ |
| Event notes | ✅ | ✅ | ✅ |
| Recurring events | ✅ | ✅ | ✅ |
| Reminders/alarms | ✅ | ✅ | ✅ |
| Completion status | ✅ | ❌ | ❌ |
| Event categories | ❌ | ✅ | ❌ |
| Event colors | ❌ | ✅ | ❌ |

---

## 🆘 Need Help?

If you're still having issues:
1. Check the full setup guide: `APPLE_CALENDAR_SETUP_GUIDE.md`
2. Try disabling and re-enabling sync
3. Restart the app
4. Make sure iOS is up to date

---

**Questions?** Check Settings → Integrations → Apple Calendar Sync for setup status and controls.

Happy syncing! 🎉
