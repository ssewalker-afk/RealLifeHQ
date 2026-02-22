# Google Calendar OAuth Error 400: redirect_uri_mismatch - FIX GUIDE

## 🚨 Problem
Users getting error when trying to sync Google Calendar:
```
Error 400: redirect_uri_mismatch
Request details: flowName=GeneralOAuthFlow
```

This means the redirect URI in your code doesn't match what's registered in Google Cloud Console.

---

## ✅ SOLUTION (Step-by-Step)

### Step 1: Update Google Cloud Console

1. **Go to Google Cloud Console**
   - Navigate to: https://console.cloud.google.com/

2. **Select Your Project**
   - If you don't have a project, create one

3. **Enable Google Calendar API**
   - Go to **APIs & Services** → **Library**
   - Search for "Google Calendar API"
   - Click **Enable** (if not already enabled)

4. **Configure OAuth Consent Screen** (if not already done)
   - Go to **APIs & Services** → **OAuth consent screen**
   - Choose **External** (for testing) or **Internal** (for organization)
   - Fill in required fields:
     - App name: **RealLife HQ**
     - User support email: Your email
     - Developer contact: Your email
   - Add scopes:
     - `https://www.googleapis.com/auth/calendar`
     - `https://www.googleapis.com/auth/calendar.events`
   - Add test users (if External): Add your test Gmail accounts
   - Click **Save and Continue**

5. **Configure OAuth 2.0 Client ID**
   - Go to **APIs & Services** → **Credentials**
   - Click **+ CREATE CREDENTIALS** → **OAuth client ID**
   - Application type: **iOS**
   - Name: **RealLife HQ iOS**
   - Bundle ID: Your app's bundle identifier (e.g., `com.sarahwalker.RealLifeHQ`)
   
6. **Add Redirect URI** ⚠️ **CRITICAL STEP**
   - After creating the credential, click on it to edit
   - Under **Authorized redirect URIs**, click **+ ADD URI**
   - Add this EXACT URI (based on your client ID):
     ```
     com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect
     ```
   - Click **Save**

7. **Copy Your Client ID**
   - It should look like: `657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404.apps.googleusercontent.com`
   - Make sure it matches what's in `GoogleCalendarManager.swift`

---

### Step 2: Configure Your Xcode Project

1. **Open Your Project in Xcode**

2. **Add URL Scheme to Info.plist** ⚠️ **IMPORTANT**
   - Select your project in the navigator
   - Select your target
   - Go to **Info** tab
   - Expand **URL Types**
   - Click **+** to add a new URL Type
   - Set:
     - **Identifier**: `com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404`
     - **URL Schemes**: `com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404` ⚠️ **NO COLON, NO /oauth2redirect**
     - **Role**: Editor

   ⚠️ **CRITICAL:** The URL scheme should be JUST the reverse-DNS identifier, with NO colon (:), NO slashes (/), and NO path. Do NOT include `:/oauth2redirect` here - that goes only in Google Console and in code.

   Alternatively, edit Info.plist directly:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleTypeRole</key>
           <string>Editor</string>
           <key>CFBundleURLName</key>
           <string>com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404</string>
           </array>
       </dict>
   </array>
   ```

3. **Verify GoogleCalendarManager.swift**
   - I've already updated this file with the correct redirect URI
   - It should now have:
     ```swift
     private let clientID = "657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404.apps.googleusercontent.com"
     private let redirectURI = "com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect"
     ```

---

### Step 3: Test the Fix

1. **Clean Build Folder**
   - In Xcode: **Product** → **Clean Build Folder** (Shift + Cmd + K)

2. **Rebuild and Run**
   - Build and run your app on a device or simulator

3. **Test Google Calendar Sync**
   - Navigate to Settings → Google Calendar Sync
   - Tap "Connect Google Calendar"
   - You should see the Google sign-in page
   - Sign in with your Google account
   - Grant calendar permissions
   - You should be redirected back to your app successfully

---

## 🔍 Troubleshooting

### Still Getting Error 400?

**Check the following:**

1. **Redirect URI Exact Match**
   - The redirect URI in Google Cloud Console MUST exactly match the one in code
   - No extra slashes, no typos
   - Case-sensitive

2. **URL Scheme in Info.plist**
   - Must match the part before `:/oauth2redirect`
   - Should be: `com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404`

3. **Client ID Mismatch**
   - Make sure the client ID in code matches your Google Cloud Console
   - Full format: `[PROJECT_NUMBER]-[UNIQUE_ID].apps.googleusercontent.com`

4. **OAuth Consent Screen**
   - If using External type, make sure your test users are added
   - Make sure calendar scopes are added

5. **Clean Build**
   - Sometimes Xcode caches old Info.plist
   - Clean build folder and restart Xcode

### Error: "This app is blocked"

If you see this error:
1. Go to OAuth consent screen in Google Cloud Console
2. Make sure your app is in "Testing" mode
3. Add your Gmail account as a test user
4. Or publish the app (requires verification for production)

### Error: "Access blocked: RealLife HQ has not completed the Google verification process"

This happens if you have too many users. Solutions:
1. Keep app in Testing mode with test users
2. Or complete Google's verification process (for production apps)

---

## 📋 Quick Reference

### Your Configuration Values

```
Client ID: 657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404.apps.googleusercontent.com

Redirect URI (for Google Console): 
com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect

URL Scheme (for Info.plist):
com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404

Required Scopes:
- https://www.googleapis.com/auth/calendar
- https://www.googleapis.com/auth/calendar.events
```

---

## 🎯 What Changed in the Code

### GoogleCalendarManager.swift

**Before:**
```swift
private let redirectURI = "com.googleusercontent.apps.657493089268:/oauth2redirect/google"
```

**After:**
```swift
private let redirectURI = "com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect"
```

**Why?**
- The redirect URI must match the reverse DNS format of your client ID
- It must include the full unique identifier, not just the project number
- The path should be `/oauth2redirect` (standard convention)

---

## 📱 Testing Checklist

Before declaring this fixed:

- [ ] Google Cloud Console has correct redirect URI
- [ ] OAuth consent screen is configured
- [ ] Test users are added (if External)
- [ ] Calendar API is enabled
- [ ] Info.plist has correct URL scheme
- [ ] Code has correct client ID and redirect URI
- [ ] Clean build performed
- [ ] App successfully opens Google sign-in
- [ ] After sign-in, app is redirected back
- [ ] Calendar sync works (can create/fetch events)

---

## 🚀 Next Steps After Fixing

Once OAuth is working:

1. **Test Full Sync Flow**
   - Create event in app → Check Google Calendar
   - Create event in Google Calendar → Check app
   - Update event → Check both places
   - Delete event → Check both places

2. **Error Handling**
   - Test with invalid credentials
   - Test with expired tokens
   - Test sign out and sign back in

3. **Production Preparation**
   - If launching to public, you'll need to verify your app with Google
   - This requires privacy policy, terms of service, and security assessment
   - For now, keep in Testing mode with test users

---

## ⚠️ Important Notes

1. **Client Secret Not Needed**
   - For iOS apps, you typically don't need a client secret
   - Google OAuth uses PKCE (Proof Key for Code Exchange) for mobile apps

2. **Bundle ID Matters**
   - Your iOS OAuth client in Google Console should have your app's bundle ID
   - This adds an extra layer of security

3. **Redirect URI Format**
   - iOS apps use custom URL schemes for OAuth redirects
   - Format: `reverse-DNS-notation:/path`
   - Must be registered in both Info.plist and Google Console

4. **Testing vs Production**
   - Testing mode allows up to 100 test users
   - Production mode requires Google verification
   - For a personal or beta app, Testing mode is fine

---

## 🎉 Success Indicators

You'll know it's working when:
- ✅ Google sign-in page opens in Safari/ASWebAuthenticationSession
- ✅ After signing in, you're redirected back to the app
- ✅ Settings show "Connected" with your email address
- ✅ Events sync between app and Google Calendar
- ✅ No more Error 400 messages

Good luck! 🚀
