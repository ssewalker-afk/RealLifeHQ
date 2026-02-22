# URL Scheme Configuration - Visual Guide

## 🎯 THE KEY RULE

**Info.plist URL Schemes = JUST the scheme identifier (NO paths)**

Think of it like this:
- Your scheme is like a "channel" that iOS opens
- The path (`/oauth2redirect`) is just "data" sent through that channel
- You register the channel, not the data

---

## 📊 SIDE-BY-SIDE COMPARISON

### ❌ WRONG (What causes the error)

```
Info.plist:
└─ CFBundleURLSchemes
   └─ com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      ❌ This includes the path - Apple rejects this
```

### ✅ CORRECT (What Apple requires)

```
Info.plist:
└─ CFBundleURLSchemes
   └─ com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      ✅ Just the scheme - Apple accepts this
```

---

## 🔄 HOW IT ACTUALLY WORKS

### Registration Phase (Info.plist)
```
You tell iOS: "Hey, I want to handle URLs that start with 
'com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404'"

iOS responds: "Got it! I'll open your app when I see URLs starting with that."
```

### Redirect Phase (When OAuth completes)
```
Google sends user to:
com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect?code=ABC123

iOS thinks: "Hmm, this URL starts with a registered scheme!"
iOS opens: Your app
iOS passes: Full URL (including /oauth2redirect?code=ABC123) to your app
Your app: Extracts the authorization code
```

The key: iOS **matches the scheme part only**, but passes the **full URL** to your app.

---

## 📝 WHAT GOES WHERE - COMPLETE BREAKDOWN

### 1. Info.plist (URL Scheme Registration)

```xml
<key>CFBundleURLSchemes</key>
<array>
    <string>com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404</string>
    <!--     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
             JUST THIS PART - The scheme identifier
             No colon, no slashes, no paths -->
</array>
```

**Purpose:** Tell iOS which scheme your app handles  
**Format:** Just the scheme identifier  
**Must contain:** Only letters, numbers, `.`, `-`, `+`  
**Cannot contain:** `:`, `/`, or other special characters

---

### 2. GoogleCalendarManager.swift (Redirect URI)

```swift
private let redirectURI = "com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect"
//                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//                        FULL URI - Scheme + separator + path
```

**Purpose:** Tell Google where to redirect after authentication  
**Format:** Full URI with `://` separator and path  
**Why full URI?** This is what Google redirects to

---

### 3. Google Cloud Console (Authorized Redirect URI)

```
Authorized redirect URIs:
com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Must EXACTLY match the redirectURI in code
```

**Purpose:** Tell Google which redirect URIs are allowed for your app  
**Format:** Full URI (same as code)  
**Security:** Prevents unauthorized apps from intercepting your OAuth flow

---

### 4. ASWebAuthenticationSession (Code)

```swift
let session = ASWebAuthenticationSession(
    url: authURL,
    callbackURLScheme: redirectURI.components(separatedBy: ":").first
    //                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    //                 This extracts just: com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404
) { callbackURL, error in
    // ...
}
```

**Purpose:** Tell ASWebAuthenticationSession which scheme to intercept  
**Format:** Just the scheme (extracted from full redirect URI)  
**Why extract?** ASWebAuthenticationSession expects just the scheme

---

## 🎨 VISUAL BREAKDOWN

```
Full Redirect URI:
┌────────────────────────────────────────────────────────────┐
│ com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404 : /oauth2redirect │
└────────────────────────────────────────────────────────────┘
 ▲                                                              ▲   ▲
 │                                                              │   │
 Scheme Identifier                                             │   Path
 (This goes in Info.plist)                                     │
                                                        Separator
                                                        (: not ://)

Where each part goes:
┌─────────────────────┬────────────────────────────────────────────────────────────┐
│ Location            │ What to use                                                │
├─────────────────────┼────────────────────────────────────────────────────────────┤
│ Info.plist          │ com.googleusercontent.apps.657493089268-qmc643b5jlhet...   │
│ (URL Schemes)       │ (scheme only)                                              │
├─────────────────────┼────────────────────────────────────────────────────────────┤
│ GoogleCalendar      │ com.googleusercontent.apps.657493089268-qmc643b5jlhet...   │
│ Manager.swift       │ :/oauth2redirect (full URI)                                │
├─────────────────────┼────────────────────────────────────────────────────────────┤
│ Google Cloud        │ com.googleusercontent.apps.657493089268-qmc643b5jlhet...   │
│ Console             │ :/oauth2redirect (full URI)                                │
├─────────────────────┼────────────────────────────────────────────────────────────┤
│ ASWebAuth           │ com.googleusercontent.apps.657493089268-qmc643b5jlhet...   │
│ Session param       │ (scheme only - extracted automatically in code)            │
└─────────────────────┴────────────────────────────────────────────────────────────┘
```

---

## 🔍 WHY THE CONFUSION HAPPENS

It's easy to think:
> "Google redirects to `scheme:/oauth2redirect`, so I should put that in Info.plist"

But actually:
1. **Google redirects to:** `scheme:/oauth2redirect?code=ABC`
2. **iOS checks:** "Does this URL start with a registered scheme?"
3. **iOS looks at:** Just `scheme` part
4. **iOS matches:** Against schemes in Info.plist
5. **iOS opens:** Your app
6. **iOS gives your app:** The full URL (including path and query)

So Info.plist only needs the scheme identifier!

---

## 🧪 TESTING AFTER FIX

### 1. Verify Info.plist
```bash
# Open Info.plist in Xcode
# Look at URL Types → Item 0 → URL Schemes → Item 0
# Should see ONLY: com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404
# Should NOT see: : or / characters
```

### 2. Test OAuth Flow
```
1. Run app
2. Go to Settings → Google Calendar Sync
3. Tap "Connect Google Calendar"
4. Sign in with Google
5. After approval, you should be redirected back to app
6. OAuth should complete successfully
```

If OAuth still works, you're good! The scheme registration worked.

---

## 💡 HELPFUL ANALOGY

Think of URL schemes like phone numbers:

**Info.plist (Register your number):**
```
"Hi iOS, my app's number is: 555-1234"
```

**Google Redirect (Someone calls you):**
```
"Calling: 555-1234, message: 'Here's your authorization code'"
```

**iOS (Phone ringing):**
```
"I see a call for 555-1234. I'll route it to that app and give them the message"
```

You register the **number** (scheme), not the **message** (path).

---

## 🎯 VALIDATION RULES EXPLAINED

Apple checks URL schemes against RFC1738, which says:

### Valid Characters:
```
✅ Lowercase letters: a-z
✅ Uppercase letters: A-Z
✅ Numbers: 0-9
✅ Period: .
✅ Hyphen: -
✅ Plus: +
```

### Invalid Characters:
```
❌ Colon: :
❌ Forward slash: /
❌ Backslash: \
❌ Space
❌ Any other special characters
```

### Must Start With:
```
✅ A letter (a-z or A-Z)
❌ Cannot start with number or special character
```

Your scheme **before fix:**
```
com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect
                                                                      ^^
                                                                      ❌ Contains : and /
```

Your scheme **after fix:**
```
com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404
                                                                      ✅ All valid characters
```

---

## 📱 OTHER URL SCHEME EXAMPLES

To help understand the pattern:

### Social Media Apps:
```
Info.plist: fb
Usage: fb://profile/12345
```

### Custom Apps:
```
Info.plist: myapp
Usage: myapp://open/settings
```

### Email:
```
Info.plist: mailto
Usage: mailto:someone@example.com
```

### Google OAuth (Your case):
```
Info.plist: com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404
Usage: com.googleusercontent.apps.657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404:/oauth2redirect?code=...
```

Notice: Info.plist only has the scheme part, never the paths/parameters.

---

## ✅ FINAL CHECKLIST

Before resubmitting to App Store:

- [ ] Info.plist has scheme only (no `:` or `/`)
- [ ] GoogleCalendarManager.swift still has full redirect URI
- [ ] Google Console still has full redirect URI  
- [ ] Clean build performed
- [ ] OAuth tested and works
- [ ] App validated locally (Product → Archive → Validate)
- [ ] No more URL scheme validation errors
- [ ] Ready to upload

---

## 🎉 SUCCESS CRITERIA

You'll know it's fixed when:
1. ✅ App validates without URL scheme errors
2. ✅ Can upload to App Store Connect
3. ✅ Google OAuth still works in your app
4. ✅ App passes App Store review

The fix is simple but crucial: **Info.plist URL schemes = identifiers only, never paths!**
