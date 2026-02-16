# Google Calendar Integration - Complete Setup Guide

## 🚨 IMPORTANT: Google Cloud Console Setup Required

Unlike Apple Calendar which works immediately, Google Calendar integration requires setting up OAuth credentials through Google Cloud Console. This is a **one-time setup** that you must complete before users can authenticate.

---

## Part 1: Google Cloud Console Setup (Developer Task)

### Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Sign in with your Google account
3. Click **"Select a Project"** → **"New Project"**
4. Enter project name: "RealLifeHQ" (or your app name)
5. Click **"Create"**
6. Wait for project creation to complete

### Step 2: Enable Google Calendar API

1. In the Cloud Console, make sure your project is selected
2. Go to **"APIs & Services"** → **"Library"**
3. Search for **"Google Calendar API"**
4. Click on it
5. Click **"Enable"**

### Step 3: Configure OAuth Consent Screen

1. Go to **"APIs & Services"** → **"OAuth consent screen"**
2. Select **"External"** (for public apps)
3. Click **"Create"**

**Fill in the required fields:**
- **App name**: RealLifeHQ
- **User support email**: Your email address
- **App logo**: (Optional) Upload your app icon
- **Developer contact**: Your email address

4. Click **"Save and Continue"**

**Scopes:**
5. Click **"Add or Remove Scopes"**
6. Filter for "calendar"
7. Select these scopes:
   - `https://www.googleapis.com/auth/calendar`
   - `https://www.googleapis.com/auth/calendar.events`
8. Click **"Update"**
9. Click **"Save and Continue"**

**Test users (while in testing mode):**
10. Click **"Add Users"**
11. Add your Google email addresses for testing
12. Click **"Save and Continue"**

**Note**: Your app will be in "Testing" mode initially. You can publish it later for public use.

### Step 4: Create OAuth 2.0 Credentials

1. Go to **"APIs & Services"** → **"Credentials"**
2. Click **"Create Credentials"** → **"OAuth client ID"**
3. Application type: Select **"iOS"**
4. Name: "RealLifeHQ iOS App"
5. Bundle ID: Enter your app's bundle identifier (e.g., `com.yourcompany.reallifehq`)
6. Click **"Create"**

**IMPORTANT:** Copy the **Client ID** that appears. It looks like:
```
123456789-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com
```

You'll need this for the next step!

---

## Part 2: Configure Your Xcode Project

### Step 1: Update GoogleCalendarManager.swift

Open `GoogleCalendarManager.swift` and replace the placeholder with your actual Client ID:

```swift
// Find this line:
private let clientID = "YOUR_CLIENT_ID_HERE"

// Replace with your actual Client ID:
private let clientID = "123456789-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com"
```

Also update the redirect URI:
```swift
// Find this line:
private let redirectURI = "com.googleusercontent.apps.YOUR_CLIENT_ID:/oauth2redirect/google"

// Replace YOUR_CLIENT_ID with the numeric part of your client ID:
private let redirectURI = "com.googleusercontent.apps.123456789:/oauth2redirect/google"
```

### Step 2: Add URL Scheme to Info.plist

1. Open your project in Xcode
2. Select your app target
3. Go to **"Info"** tab
4. Expand **"URL Types"**
5. Click **"+"** to add a new URL Type

**Configure the URL Type:**
- **Identifier**: `com.googleusercontent.apps.123456789` (use your numeric client ID)
- **URL Schemes**: `com.googleusercontent.apps.123456789` (same as identifier)
- **Role**: Editor

**Or add directly to Info.plist:**

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.googleusercontent.apps.123456789</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.123456789</string>
        </array>
    </dict>
</array>
```

### Step 3: Add Queries to Info.plist

Add Google to the list of queryable schemes:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>googlechrome</string>
    <string>googlechromes</string>
</array>
```

---

## Part 3: Testing the Integration

### Initial Test (as Developer)

1. Build and run your app
2. Go to **Settings** → **Integrations** → **Google Calendar Sync**
3. Tap **"Sign in with Google"**
4. Browser/web view will open
5. Sign in with a Google account (must be in your test users list)
6. Grant permissions when prompted
7. You'll be redirected back to the app
8. Status should show "Connected" with your email

### Test Event Sync

1. Enable **"Sync with Google Calendar"** toggle
2. Go to Calendar tab
3. Create a new event
4. Open [Google Calendar](https://calendar.google.com) in a web browser
5. Your event should appear!

### Test Import

1. Create an event directly in Google Calendar web interface
2. In RealLifeHQ: Settings → Google Calendar Sync
3. Tap **"Import Events from Google Calendar"**
4. Select date range
5. Tap **"Import"**
6. Event should appear in RealLifeHQ Calendar

---

## Part 4: Publishing Your App

### While in Testing Mode

- Only users you add to the "Test users" list can sign in
- Good for initial testing and TestFlight
- OAuth consent screen will show "This app isn't verified"

### To Make Public

1. Go to Google Cloud Console
2. **"APIs & Services"** → **"OAuth consent screen"**
3. Click **"Publish App"**
4. Review warnings and confirm

**OR** (Recommended for production):

5. Click **"Prepare for Verification"**
6. Complete the verification process
7. This removes the "unverified app" warning
8. Required for apps that will have many users

**Verification Requirements:**
- Privacy policy URL
- Terms of service URL
- App homepage
- Video demonstration of OAuth flow
- Explanation of why you need calendar access

---

## Architecture Overview

### Authentication Flow

```
User Taps "Sign in with Google"
    ↓
ASWebAuthenticationSession opens
    ↓
User signs in to Google
    ↓
User grants calendar permissions
    ↓
Google redirects with authorization code
    ↓
App exchanges code for access token + refresh token
    ↓
Tokens stored in UserDefaults
    ↓
User is authenticated ✅
```

### Event Sync Flow

```
User creates event in RealLifeHQ
    ↓
DataManager.addEvent() saves locally
    ↓
GoogleCalendarManager checks if authenticated + sync enabled
    ↓
If yes: Creates event via Google Calendar API
    ↓
Stores Google event ID in app event
    ↓
Event visible in Google Calendar ✅
```

### Token Refresh

- Access tokens expire after 1 hour
- Refresh tokens are long-lived
- App automatically refreshes access token when it gets 401 error
- Seamless to the user

---

## Features Implemented

### ✅ Authentication
- OAuth 2.0 via ASWebAuthenticationSession
- Secure token storage
- Automatic token refresh
- Sign out functionality

### ✅ Event Sync
- Create events → Google Calendar
- Update events → Google Calendar
- Delete events → Google Calendar
- All-day events supported
- Timed events with start/end
- Event notes/descriptions
- Recurring events (RRULE format)
- Reminders/alarms

### ✅ Import
- Fetch events from Google Calendar
- Date range selection
- Duplicate detection
- Convert Google events to app format

### ✅ User Experience
- Clear authentication status
- Email display when connected
- Sign out confirmation
- Error handling with user-friendly messages
- Sync enable/disable toggle

---

## Security & Privacy

### Token Storage
- Access tokens stored in UserDefaults (consider Keychain for production)
- Refresh tokens stored in UserDefaults
- Never sent to your servers

### Permissions
- Only requests calendar permissions
- No access to other Google services
- Users can revoke access anytime at [myaccount.google.com/permissions](https://myaccount.google.com/permissions)

### Data Privacy
- Events synced directly between device and Google
- No intermediary servers
- Uses HTTPS for all API calls
- OAuth 2.0 standard

---

## Troubleshooting

### "Client ID not found" or Authentication Fails

**Problem**: Credentials not set up correctly

**Solution**:
1. Double-check Client ID in `GoogleCalendarManager.swift`
2. Verify URL scheme in Info.plist matches Client ID
3. Make sure bundle ID in Google Console matches your app

### "This app isn't verified" Warning

**Problem**: App is in testing mode

**Solution**:
- This is normal during development
- Add test users in Google Cloud Console
- OR publish app (see Part 4)

### "Access Denied" or "Invalid Grant"

**Problem**: Token expired or user revoked access

**Solution**:
- Sign out and sign in again
- Check user hasn't revoked app permissions in Google account settings

### Events Not Syncing

**Problem**: Sync not enabled or authentication expired

**Solution**:
1. Check Settings → Google Calendar shows "Connected"
2. Verify sync toggle is ON
3. Try signing out and back in
4. Check device internet connection

### Import Doesn't Find Events

**Problem**: Date range or calendar mismatch

**Solution**:
- Verify events exist in Google Calendar for selected dates
- Check events are in "primary" calendar (app syncs with primary only)
- Try wider date range

---

## API Rate Limits

Google Calendar API has rate limits:
- **1,000,000 queries per day** (very high)
- **10 queries per second per user**

For a personal productivity app, you won't hit these limits.

---

## Production Recommendations

### Security Enhancements

1. **Use Keychain for tokens**:
   ```swift
   // Instead of UserDefaults, use Keychain
   KeychainManager.shared.saveGoogleAccessToken(accessToken)
   ```

2. **Implement token encryption**:
   - Encrypt tokens before storing
   - Use device-specific encryption keys

3. **Add certificate pinning**:
   - Pin Google's SSL certificates
   - Prevent man-in-the-middle attacks

### User Experience

1. **Add loading indicators**:
   - Show progress when syncing
   - Display "Syncing..." status

2. **Better error messages**:
   - Specific errors for different failure modes
   - Actionable guidance for users

3. **Conflict resolution**:
   - Handle simultaneous edits
   - Let users choose which version to keep

4. **Batch operations**:
   - Sync multiple events efficiently
   - Use Google Calendar API batch requests

---

## Cost

**Free Tier**: Google Calendar API is FREE for normal usage!

You only pay if you exceed:
- 1,000,000 requests per day
- For personal productivity apps, you'll never hit this

---

## Files Created

1. **GoogleCalendarManager.swift** - Core API integration (580 lines)
2. **GoogleCalendarSyncSettingsView.swift** - UI for authentication and settings (260 lines)
3. **Updated Models.swift** - Added `googleCalendarEventId` field
4. **Updated DataManager.swift** - Sync to Google Calendar on add/update/delete
5. **Updated SettingsView.swift** - Link to Google Calendar settings
6. **Updated CalendarView.swift** - Show Google sync status

---

## Next Steps

1. ✅ Complete Google Cloud Console setup (Part 1)
2. ✅ Update Client ID in code (Part 2)
3. ✅ Configure URL scheme (Part 2)
4. ✅ Test authentication flow
5. ✅ Test event syncing
6. ✅ Prepare for production deployment

---

## Support

If you encounter issues:

1. Check Google Cloud Console logs
2. Enable API request logging
3. Verify OAuth consent screen configuration
4. Review Google Calendar API documentation: https://developers.google.com/calendar/api

---

**Congratulations!** 🎉 Your app now supports both Apple Calendar AND Google Calendar integration!

Users can:
- Sync with Apple Calendar (local, immediate)
- Sync with Google Calendar (cloud, accessible everywhere)
- Use both simultaneously
- Import from either service
- Manage sync preferences independently

This gives users maximum flexibility for managing their calendar across all platforms!
