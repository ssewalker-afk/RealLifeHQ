# Google Calendar Integration - Quick Reference

## 🚀 For Developers

### Quick Setup Checklist

- [ ] Create Google Cloud project
- [ ] Enable Google Calendar API  
- [ ] Configure OAuth consent screen
- [ ] Create OAuth 2.0 credentials (iOS)
- [ ] Copy Client ID
- [ ] Update `GoogleCalendarManager.swift` with Client ID
- [ ] Add URL scheme to Info.plist
- [ ] Add LSApplicationQueriesSchemes to Info.plist
- [ ] Test authentication
- [ ] Test event syncing

**Estimated setup time**: 15-20 minutes

### Essential URLs

- [Google Cloud Console](https://console.cloud.google.com/)
- [Google Calendar API Docs](https://developers.google.com/calendar/api)
- [OAuth 2.0 Playground](https://developers.google.com/oauthplayground/)

---

## 📱 For Users

### Enable Google Calendar Sync

1. Open **Settings** → **Integrations** → **Google Calendar Sync**
2. Tap **"Sign in with Google"**
3. Sign in to your Google account
4. Grant calendar permissions
5. Toggle **"Sync with Google Calendar"** ON

**That's it!** Events now sync automatically.

### What Gets Synced

✅ Event title  
✅ Date and time  
✅ All-day events  
✅ Start/end times  
✅ Event notes  
✅ Recurring events  
✅ Reminders  

### Common Tasks

#### Create Synced Event
1. Open Calendar tab
2. Tap **+** button
3. Fill in details
4. Tap **Save**
→ Event appears in Google Calendar!

#### Import Existing Events
1. Settings → Google Calendar Sync
2. Tap **"Import Events"**
3. Select date range
4. Tap **Import**
→ Google events copied to app

#### Sign Out
1. Settings → Google Calendar Sync
2. Tap **"Sign Out"**
3. Confirm
→ Your events remain in Google Calendar

---

## 🔧 Troubleshooting

### Can't Sign In

**Try this:**
1. Check internet connection
2. Make sure you're using correct Google account
3. Verify app is on "Test users" list (during testing)
4. Clear app data and try again

### Events Not Syncing

**Check these:**
- [ ] Settings shows "Connected" ✅
- [ ] Sync toggle is ON
- [ ] Internet connection active
- [ ] Google Calendar app shows same account

### "This app isn't verified"

**This is normal** during development. Two options:
- Click "Advanced" → "Go to RealLifeHQ (unsafe)"
- Or ask developer to add you as test user

---

## 📊 Feature Comparison

| Feature | Apple Calendar | Google Calendar |
|---------|----------------|-----------------|
| Setup | Automatic | Requires sign-in |
| Platform | Apple devices only | All platforms |
| Sync speed | Instant (local) | Fast (cloud) |
| Offline | ✅ Works | ❌ Needs internet |
| Access | Calendar app | Web, mobile, everywhere |
| Sharing | Via iCloud | Via Google |

**Pro Tip**: Enable both for maximum compatibility!

---

## 🎯 Use Cases

### Use Apple Calendar If:
- You only use Apple devices
- Want fastest sync (local)
- Prefer privacy (on-device)
- Don't want to sign in

### Use Google Calendar If:
- You use multiple platforms (Android, Web, etc.)
- Want access from anywhere
- Share calendars with others
- Use Gmail integration

### Use Both If:
- Want maximum compatibility
- Switch between Apple and non-Apple devices
- Want backup redundancy
- Like having options! 😄

---

## 🔐 Privacy & Security

### What Access Does the App Have?

**Calendar data only:**
- Can read your calendar events
- Can create/edit/delete events
- **Cannot** access email, contacts, files, etc.

### Where Are Tokens Stored?

- Locally on your device
- In UserDefaults (encrypted by iOS)
- Never sent to app developer
- Only used to talk to Google

### Can I Revoke Access?

**Yes! Anytime:**
1. Go to [myaccount.google.com/permissions](https://myaccount.google.com/permissions)
2. Find "RealLifeHQ"
3. Click "Remove Access"

Or just sign out in the app.

---

## 💡 Pro Tips

### Tip 1: Import Before Enabling Sync
If you have existing Google Calendar events:
1. Import them first
2. Then enable sync
This avoids duplicates!

### Tip 2: Use Both Services
Enable both Apple and Google Calendar sync for:
- Automatic backup
- Cross-platform access
- Extra reliability

### Tip 3: Check Sync Status
Look for badges in Calendar view:
- 🍏 = Apple Calendar syncing
- G = Google Calendar syncing

### Tip 4: Primary Calendar Only
Google Calendar sync uses your "primary" calendar. To change:
1. Open Google Calendar app/web
2. Settings → Primary calendar
3. Select the one you want

---

## 📞 Getting Help

### Authentication Issues
See: [GOOGLE_CALENDAR_SETUP_GUIDE.md](GOOGLE_CALENDAR_SETUP_GUIDE.md) - Part 2

### Sync Not Working
Check Settings → Google Calendar Sync shows:
- ✅ Connected (green checkmark)
- Email address displayed
- Sync toggle ON (green)

### Developer Setup
See: [GOOGLE_CALENDAR_SETUP_GUIDE.md](GOOGLE_CALENDAR_SETUP_GUIDE.md) - Part 1

---

## ⚠️ Known Limitations

1. **Primary calendar only**: Syncs with Google's primary calendar
2. **Internet required**: Google Calendar needs internet (unlike Apple Calendar)
3. **Testing mode**: During development, only test users can sign in
4. **One-way sync**: Currently app → Google Calendar (import for reverse)

---

## 🚀 Future Enhancements

Potential future features:
- [ ] Select which Google calendar to use
- [ ] Two-way sync (Google → app automatically)
- [ ] Offline queue for sync when back online
- [ ] Calendar color sync
- [ ] Attendees and event invites
- [ ] Google Meet link integration

---

## 📈 Statistics

**Lines of Code Added**: ~580  
**API Calls per Event**: 1-2  
**Authentication Flow**: OAuth 2.0  
**Token Lifetime**: 1 hour (auto-refresh)  
**Rate Limit**: 10 requests/second (plenty!)  

---

**Happy syncing!** 🎉

Your events are now accessible:
- On all your devices (Apple Calendar)
- From anywhere in the world (Google Calendar)  
- In Gmail
- On Android
- On the web
- Literally everywhere! 🌍
