# Google Calendar OAuth - Quick Fix Checklist ✓

## The Error You're Seeing
```
Error 400: redirect_uri_mismatch
Request details: flowName=GeneralOAuthFlow
```

---

## ⚡ QUICK FIX (5 Minutes)

### □ Step 1: Google Cloud Console
1. Go to https://console.cloud.google.com/
2. Select your project
3. Navigate to: **APIs & Services** → **Credentials**
4. Click on your OAuth 2.0 Client ID
5. Under **Authorized redirect URIs**, add:
   ```
   com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect
   ```
6. Click **SAVE**

### □ Step 2: Xcode - Add URL Scheme
1. Open your project in Xcode
2. Select your project → Select your app target → **Info** tab
3. Scroll down to **URL Types** and expand it
4. Click **+** to add a new URL Type
5. Fill in:
   - **Identifier**: `com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404`
   - **URL Schemes**: `com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404`
   - **Role**: `Editor`

### □ Step 3: Clean & Rebuild
1. In Xcode: **Product** → **Clean Build Folder** (⇧⌘K)
2. **Product** → **Build** (⌘B)
3. Run your app

### □ Step 4: Test
1. Navigate to Settings → Google Calendar Sync
2. Tap "Connect Google Calendar"
3. Sign in with Google
4. Should redirect back to your app ✅

---

## 🔍 Verification

After completing the steps above, verify these match:

| Location | Value |
|----------|-------|
| **Google Console - Redirect URI** | `com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect` |
| **Code (GoogleCalendarManager.swift)** | `com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect` |
| **Info.plist - URL Scheme** | `com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404` |

---

## ❓ Still Not Working?

### Common Issues:

**1. "This app is blocked"**
- Solution: Add your email as a test user in OAuth consent screen

**2. Different Client ID**
- Make sure you're using the iOS OAuth client, not web or Android

**3. Typo in redirect URI**
- Check for extra spaces, wrong dashes, or case sensitivity

**4. URL scheme not registered**
- Make sure Info.plist was saved and app was rebuilt

**5. Wrong callback URL scheme**
- In `GoogleCalendarManager.swift`, the `callbackURLScheme` parameter should match the URL scheme

---

## 📸 Visual Guide

### Google Cloud Console - Where to Add Redirect URI:

```
APIs & Services → Credentials
↓
Click on your OAuth 2.0 Client ID
↓
Authorized redirect URIs section
↓
Click "+ ADD URI"
↓
Paste: com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect
↓
Click "SAVE"
```

### Xcode - Where to Add URL Scheme:

```
Project Navigator → Your Project
↓
Select Target (RealLifeHQ)
↓
Info Tab
↓
URL Types section (expand it)
↓
Click "+"
↓
Fill in Identifier and URL Schemes
↓
Done
```

---

## 🎯 What Changed

I've already updated `GoogleCalendarManager.swift` with the correct redirect URI:

**Old (broken):**
```swift
private let redirectURI = "com.googleusercontent.apps.657493089268:/oauth2redirect/google"
```

**New (fixed):**
```swift
private let redirectURI = "com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect"
```

The key difference:
- ✅ Includes the full unique identifier (`-qmc643b5jlhet355mg2ktnu0o6b0a404`)
- ✅ Uses standard path (`/oauth2redirect` instead of `/oauth2redirect/google`)

---

## ✅ Success Looks Like:

1. Tap "Connect Google Calendar" → Safari/web view opens
2. Google sign-in page appears
3. Enter credentials and allow permissions
4. **Automatically redirected back to your app** ← This is the key moment
5. Settings shows "Connected" with your email

---

## 📞 Need More Help?

See the detailed guide: `GOOGLE_CALENDAR_OAUTH_FIX.md`

Or check the example Info.plist: `Info.plist.example`

Good luck! 🚀
