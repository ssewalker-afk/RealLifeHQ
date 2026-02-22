# Google OAuth Flow Diagram & Troubleshooting

## 🔄 How Google OAuth Works in Your App

```
┌─────────────────────────────────────────────────────────────────┐
│                    GOOGLE OAUTH FLOW                            │
└─────────────────────────────────────────────────────────────────┘

1️⃣  User taps "Connect Google Calendar"
    │
    └──> App calls GoogleCalendarManager.authenticate()
         │
         └──> Creates authorization URL:
              https://accounts.google.com/o/oauth2/v2/auth?
                client_id=657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404.apps.googleusercontent.com
                &redirect_uri=com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect
                &response_type=code
                &scope=calendar...
              
2️⃣  ASWebAuthenticationSession opens Safari/web view
    │
    └──> User sees Google sign-in page
         │
         └──> User enters credentials
              │
              └──> Google validates credentials
                   │
                   └──> User grants calendar permissions

3️⃣  Google redirects back to app
    │
    └──> Redirect URL: com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect?code=AUTH_CODE
         │
         │  ⚠️  THIS IS WHERE ERROR 400 HAPPENS IF MISMATCH!
         │
         └──> iOS checks Info.plist for URL scheme
              │
              ├─ ✅ If registered: Opens your app
              │
              └─ ❌ If not registered: Error or nothing happens

4️⃣  App receives callback
    │
    └──> Extracts authorization code from URL
         │
         └──> Exchanges code for access token:
              POST https://oauth2.googleapis.com/token
              {
                code: AUTH_CODE,
                client_id: YOUR_CLIENT_ID,
                redirect_uri: SAME_REDIRECT_URI,  ← Must match!
                grant_type: authorization_code
              }

5️⃣  Google returns tokens
    │
    └──> Access token (for API calls)
    │
    └──> Refresh token (for renewing access)

6️⃣  App is authenticated ✅
    │
    └──> Can now make Google Calendar API calls
```

---

## 🔴 WHERE THE ERROR HAPPENS

```
┌──────────────────────────────────────────────────────────────┐
│  ERROR 400: redirect_uri_mismatch                            │
└──────────────────────────────────────────────────────────────┘

This error occurs at Step 2 when Google validates your request.

Google checks:
  ┌─────────────────────────────────────────────┐
  │ Is this redirect_uri registered in          │
  │ Google Cloud Console for this client_id?    │
  └─────────────────────────────────────────────┘
           │                        │
           │                        │
          ✅ YES                   ❌ NO
           │                        │
    Proceed with                Return:
    authentication              Error 400
                                redirect_uri_mismatch
```

---

## ✅ WHAT NEEDS TO MATCH

### Three Places, One Value:

```
┌────────────────────────────────────────────────────────────────┐
│  1. GOOGLE CLOUD CONSOLE                                       │
│     APIs & Services → Credentials → OAuth 2.0 Client ID        │
│     Authorized redirect URIs:                                  │
│                                                                │
│     com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect
│                                                                │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│  2. CODE (GoogleCalendarManager.swift)                         │
│     Line ~24:                                                  │
│                                                                │
│     private let redirectURI = "com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect"
│                                                                │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│  3. INFO.PLIST (URL Scheme - without the :/oauth2redirect)    │
│     CFBundleURLTypes → CFBundleURLSchemes:                     │
│                                                                │
│     com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

**Note:** Info.plist only needs the scheme part (before `://`), not the full path

---

## 🔍 WHY THE OLD VALUE WAS WRONG

```
❌ OLD (Broken):
   com.googleusercontent.apps.657493089268:/oauth2redirect/google
                                      ↑                      ↑
                              Missing full ID         Extra path segment

✅ NEW (Fixed):
   com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect
                                      ↑                                      ↑
                              Full unique identifier                Standard path
```

**What was wrong:**
1. Missing the unique identifier suffix (`-qmc643b5jlhet355mg2ktnu0o6b0a404`)
2. Using non-standard path (`/oauth2redirect/google` instead of `/oauth2redirect`)

**Why it failed:**
- Google couldn't find this redirect URI in your registered URIs
- Resulted in Error 400: redirect_uri_mismatch

---

## 🛠️ DEBUGGING CHECKLIST

### Step 1: Verify Google Cloud Console

```bash
# Navigate to:
https://console.cloud.google.com/apis/credentials

# Look for your OAuth 2.0 Client ID
# Click on it
# Check "Authorized redirect URIs"

✅ Should see: com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect
❌ If different or missing → ADD IT and SAVE
```

### Step 2: Verify Code

```swift
// In GoogleCalendarManager.swift, check line ~24:

private let redirectURI = "com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect"

✅ Should exactly match Google Console
❌ If different → UPDATE IT
```

### Step 3: Verify Info.plist

```xml
<!-- In Info.plist, look for CFBundleURLTypes -->

<key>CFBundleURLSchemes</key>
<array>
    <string>com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404</string>
</array>

✅ Should match the scheme part (before ://)
❌ If missing or different → ADD/UPDATE IT
```

### Step 4: Verify ASWebAuthenticationSession

```swift
// In GoogleCalendarManager.swift, authenticate() function:

let session = ASWebAuthenticationSession(
    url: url,
    callbackURLScheme: redirectURI.components(separatedBy: ":").first  // This extracts the scheme
) { ... }

✅ This automatically extracts: com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404
❌ If you hardcoded something different → FIX IT
```

---

## 🧪 TESTING THE FIX

### Manual Test Procedure:

1. **Clean Build**
   ```
   Xcode → Product → Clean Build Folder (⇧⌘K)
   ```

2. **Rebuild**
   ```
   Xcode → Product → Build (⌘B)
   ```

3. **Run on Device/Simulator**
   ```
   Make sure it's a fresh install if possible
   ```

4. **Navigate to Google Calendar Settings**
   ```
   Settings → Integrations → Google Calendar Sync
   ```

5. **Tap "Connect Google Calendar"**
   ```
   Expected: Safari/web view opens with Google sign-in
   ```

6. **Sign In**
   ```
   Enter your Google credentials
   Grant calendar permissions
   ```

7. **Verify Redirect**
   ```
   Expected: Automatically redirected back to app
   Settings shows: ✅ Connected (your-email@gmail.com)
   ```

### What Success Looks Like:

```
[App] → Tap Connect
        ↓
[Safari] → Google sign-in page opens
        ↓
[User] → Enter credentials
        ↓
[Google] → Grant permissions
        ↓
[Safari] → Redirecting...
        ↓
[App] → ✅ Connected! Email shown
```

### What Failure Looks Like:

```
[App] → Tap Connect
        ↓
[Safari] → Google sign-in page opens
        ↓
[User] → Enter credentials
        ↓
[Google] → 🚨 Error 400: redirect_uri_mismatch
```

---

## 📊 COMMON SCENARIOS

### Scenario 1: Brand New Setup
```
□ Create Google Cloud project
□ Enable Calendar API
□ Create OAuth 2.0 Client ID (iOS)
□ Add redirect URI in Google Console
□ Add URL scheme to Info.plist
□ Update code with client ID and redirect URI
□ Test
```

### Scenario 2: Existing Project, Wrong Redirect URI
```
✅ Google Cloud project exists
✅ Calendar API enabled
✅ OAuth client exists
❌ Wrong redirect URI in Google Console
   → Fix: Add correct redirect URI
□ Update URL scheme in Info.plist (if needed)
□ Code already updated
□ Test
```

### Scenario 3: Code Changed, Console Outdated
```
✅ Google Cloud project configured
❌ Code has new redirect URI format
❌ Google Console has old redirect URI
   → Fix: Update Google Console with new redirect URI
□ Update Info.plist to match
□ Test
```

---

## 💡 PRO TIPS

1. **Use Exact Copy-Paste**
   - Don't type redirect URIs manually
   - Copy from code → paste to Google Console
   - Avoids typos

2. **Check All Three Places**
   - Google Console ✓
   - Code ✓
   - Info.plist ✓

3. **Clean Build After Changes**
   - Info.plist changes require rebuild
   - Clean build ensures fresh start

4. **Test User Management**
   - If OAuth consent is External, add test users
   - Your own email should be a test user

5. **Check Logs**
   - Look for print statements in Xcode console
   - Google Calendar Manager logs authentication steps

---

## 🎯 FINAL CHECKLIST

Before declaring victory:

- [ ] Redirect URI in Google Console matches code
- [ ] URL scheme in Info.plist matches (scheme part only)
- [ ] Clean build performed
- [ ] App opens Google sign-in page
- [ ] Can sign in without Error 400
- [ ] Redirected back to app successfully
- [ ] Settings show "Connected" status
- [ ] Can create/sync calendar events

---

## 🚀 YOU'RE DONE!

Once all checkboxes are ticked, your Google Calendar integration should work flawlessly!

If you're still having issues, double-check each step in the detailed guide: `GOOGLE_CALENDAR_OAUTH_FIX.md`
