# App Store Validation Error - Quick Fix

## Error Message
```
The following URL schemes found in your app are not in the correct format: 
[com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect]
```

---

## ⚡ Quick Fix (2 minutes)

### Step 1: Open Info.plist in Xcode
1. Select your project → Select target → **Info** tab
2. Expand **URL Types**
3. Find the Google Calendar entry

### Step 2: Fix the URL Scheme
**Change from:**
```
com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect
```

**To:**
```
com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404
```

**What to remove:** `:/oauth2redirect`

### Step 3: Save, Clean, Archive
1. Save Info.plist
2. Clean Build Folder (⇧⌘K)
3. Archive and upload to App Store Connect

---

## 📋 What Goes Where

| Location | Format | Example |
|----------|--------|---------|
| **Info.plist** | Scheme only (no `:` or `/`) | `com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404` |
| **GoogleCalendarManager.swift** | Full redirect URI | `com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect` |
| **Google Cloud Console** | Full redirect URI | `com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect` |

---

## ✅ Correct Info.plist

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

---

## ⚠️ Important Notes

1. **Info.plist:** URL scheme = just the identifier (no colon, no slashes)
2. **Code stays the same:** GoogleCalendarManager.swift keeps full redirect URI
3. **Google Console stays the same:** Keep full redirect URI there too
4. **OAuth will still work:** iOS matches the scheme part automatically

---

## 🎯 Why This Happens

Apple's validation checks URL schemes against RFC1738:
- ✅ Must start with letter
- ✅ Can contain: letters, numbers, period (.), hyphen (-), plus (+)
- ❌ Cannot contain: colon (:), slash (/), or other special chars

The `:/oauth2redirect` part violates this because it has `:` and `/`.

---

## 🧪 How to Verify

1. Open Info.plist
2. Check `CFBundleURLTypes` → `Item 0` → `CFBundleURLSchemes` → `Item 0`
3. Should see: `com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404`
4. Should NOT see any `:` or `/` characters

---

## 🚀 Result

After fix:
- ✅ App Store validation passes
- ✅ Google OAuth still works
- ✅ App can be submitted and approved

See `URL_SCHEME_VALIDATION_FIX.md` for detailed explanation.
