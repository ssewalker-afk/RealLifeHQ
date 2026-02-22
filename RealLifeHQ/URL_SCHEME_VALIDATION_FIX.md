# Fix for App Store Validation Error - URL Scheme Format

## 🚨 ERROR MESSAGE
```
The following URL schemes found in your app are not in the correct format: 
[com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect]

URL schemes need to begin with an alphabetic character, and be comprised of 
alphanumeric characters, the period, the hyphen or the plus sign only.
```

---

## ❌ THE PROBLEM

Your Info.plist currently has the **full redirect URI** including the path:
```
com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect
```

But Apple only wants the **scheme part** (before the `://`):
```
com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404
```

The `:/oauth2redirect` part should NOT be in Info.plist - that's only used in the Google Console and in code.

---

## ✅ THE FIX

### Step 1: Update Info.plist

**Option A: Using Xcode UI**

1. Select your project in Xcode
2. Select your app target
3. Go to the **Info** tab
4. Expand **URL Types**
5. Find the Google Calendar entry
6. Update the **URL Schemes** field to:
   ```
   com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404
   ```
   (Remove the `:/oauth2redirect` part)

**Option B: Edit Info.plist Directly**

Open your Info.plist file and update the `CFBundleURLSchemes` to:

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

**Key point:** The URL scheme should be just the reverse-DNS part, with NO colon, NO slashes, NO path.

---

## 🔍 WHAT GOES WHERE

Here's the breakdown of where each format is used:

### 1. **Info.plist (URL Scheme)**
```
com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404
```
- No colon
- No slashes  
- No path
- Just the scheme identifier

### 2. **GoogleCalendarManager.swift (Redirect URI)**
```swift
private let redirectURI = "com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect"
```
- Has `://` separator
- Has `/oauth2redirect` path
- This is the full redirect URI

### 3. **Google Cloud Console (Authorized redirect URI)**
```
com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect
```
- Same as code redirect URI
- Full URI with scheme and path

### 4. **ASWebAuthenticationSession (callbackURLScheme parameter)**
```swift
ASWebAuthenticationSession(
    url: url,
    callbackURLScheme: "com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404"
) { ... }
```
- Just the scheme (no colon, no path)
- Currently extracted in code with: `redirectURI.components(separatedBy: ":").first`

---

## 📋 VALIDATION RULES

According to RFC1738 and Apple's requirements, URL schemes must:

✅ Begin with an alphabetic character (a-z, A-Z)
✅ Contain only:
   - Letters (a-z, A-Z)
   - Numbers (0-9)
   - Period (.)
   - Hyphen (-)
   - Plus (+)

❌ Cannot contain:
   - Colon (:)
   - Forward slash (/)
   - Any other special characters

---

## 🧪 HOW TO VERIFY THE FIX

### 1. Check Info.plist
```bash
# View your Info.plist CFBundleURLSchemes
# Should show only the scheme part, no colons or slashes
```

In Xcode:
1. Select Info.plist
2. Find `CFBundleURLTypes` → `Item 0` → `CFBundleURLSchemes` → `Item 0`
3. Value should be: `com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404`
4. Should NOT have any `:` or `/` characters

### 2. Verify the Code Still Works

The `GoogleCalendarManager.swift` code should still work because:

```swift
let session = ASWebAuthenticationSession(
    url: url,
    callbackURLScheme: redirectURI.components(separatedBy: ":").first
) { ... }
```

This extracts just the scheme part from the full redirect URI:
- Input: `com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect`
- Output: `com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404`

### 3. Test OAuth Flow

1. Clean build (⇧⌘K)
2. Run app
3. Navigate to Settings → Google Calendar Sync
4. Tap "Connect Google Calendar"
5. Should open Google sign-in
6. After sign-in, should redirect back to app successfully

---

## 🔐 GOOGLE CONSOLE - NO CHANGES NEEDED

**Important:** You do NOT need to change anything in Google Cloud Console.

The Google Console should still have:
```
com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect
```

This is correct for Google's OAuth system.

---

## 💾 BEFORE AND AFTER

### Before (Wrong) ❌
```xml
<key>CFBundleURLSchemes</key>
<array>
    <string>com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect</string>
</array>
```

### After (Correct) ✅
```xml
<key>CFBundleURLSchemes</key>
<array>
    <string>com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404</string>
</array>
```

**What changed:** Removed `:/oauth2redirect` from the URL scheme.

---

## 🚀 RESUBMIT TO APP STORE

After making this fix:

1. ✅ Clean build folder
2. ✅ Archive your app
3. ✅ Upload to App Store Connect
4. ✅ Validation should now pass

The validation error should be resolved.

---

## 📱 WHY THIS HAPPENS

iOS URL schemes work like this:

1. **App registers a URL scheme** in Info.plist (e.g., `myapp`)
2. **Any URL starting with that scheme** can open the app (e.g., `myapp://anything`)
3. **The path part is optional** - it's just data passed to your app

For OAuth:
- You register: `com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404`
- Google redirects to: `com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect?code=...`
- iOS sees the scheme matches, opens your app, passes full URL to your app
- Your app extracts the authorization code from the URL

The scheme registration is just the identifier - the path/query parameters come later.

---

## 🎯 COMMON MISTAKES

### Mistake 1: Including the full redirect URI in Info.plist
```
❌ com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect
✅ com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404
```

### Mistake 2: Adding `://` format
```
❌ com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404://
✅ com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404
```

### Mistake 3: Mixing up where each format goes
- Info.plist: Scheme only
- Code: Full redirect URI  
- Google Console: Full redirect URI

---

## ✅ FINAL CHECKLIST

Before resubmitting:

- [ ] Info.plist URL scheme has NO colon
- [ ] Info.plist URL scheme has NO slashes
- [ ] Info.plist URL scheme has NO path
- [ ] GoogleCalendarManager.swift still has full redirect URI
- [ ] Google Console still has full redirect URI
- [ ] Clean build performed
- [ ] App tested and OAuth still works
- [ ] App archived successfully
- [ ] Ready to upload to App Store Connect

---

## 🎉 RESULT

After this fix:
- ✅ App Store validation will pass
- ✅ Google OAuth will still work correctly
- ✅ URL scheme properly registered with iOS
- ✅ App can be submitted and approved

The key insight: **URL schemes in Info.plist are just identifiers, not full URLs.**
