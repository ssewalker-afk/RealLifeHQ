# Google OAuth Testing Mode - Quick Setup Guide

## 🎯 Goal: Fix "Access blocked" Error

**Problem:** "Access blocked: RealLife HQ has not completed the Google verification process"

**Solution:** Use Testing Mode (no verification needed!)

---

## 🚀 5-Minute Fix

### Step 1: Open Google Cloud Console
```
🌐 https://console.cloud.google.com/
```

### Step 2: Navigate to OAuth Consent Screen
```
Left menu → APIs & Services → OAuth consent screen
```

### Step 3: Check Publishing Status

Look at the top of the page. You'll see one of these:

```
┌────────────────────────────────────────┐
│ Publishing status                      │
│ ┌────────────────────────────────────┐ │
│ │ 🔴 In Production                   │ │  ← BAD (causes error)
│ │ [BACK TO TESTING]                  │ │
│ └────────────────────────────────────┘ │
└────────────────────────────────────────┘

OR

┌────────────────────────────────────────┐
│ Publishing status                      │
│ ┌────────────────────────────────────┐ │
│ │ 🟡 Testing                         │ │  ← GOOD (what you need)
│ │ [PUBLISH APP]                      │ │
│ └────────────────────────────────────┘ │
└────────────────────────────────────────┘
```

### Step 4: Switch to Testing Mode

If you see "In Production":
1. Click **"BACK TO TESTING"** button
2. Confirm when prompted

If you see "Testing":
1. ✅ Already in Testing mode! Continue to next step

---

### Step 5: Add Test Users (CRITICAL!)

Scroll down to the **Test users** section:

```
┌─────────────────────────────────────────────────┐
│ Test users                                      │
│                                                 │
│ While publishing status is "Testing", only     │
│ these users can access the app. You can add    │
│ up to 100 users.                               │
│                                                 │
│ [+ ADD USERS]                                   │
│                                                 │
│ Test users:                                     │
│ • your-email@gmail.com                         │
│ • colleague@gmail.com                          │
│                                                 │
└─────────────────────────────────────────────────┘
```

1. Click **+ ADD USERS**
2. Enter email addresses (one per line):
   ```
   your-email@gmail.com
   colleague@gmail.com
   tester@gmail.com
   ```
3. Click **ADD**
4. Click **SAVE**

---

### Step 6: Verify Scopes

Make sure you have the calendar scopes:

1. Click **EDIT APP** (at the top)
2. Click through to **Scopes** page
3. Should see:
   ```
   ✅ https://www.googleapis.com/auth/calendar
   ✅ https://www.googleapis.com/auth/calendar.events
   ```

If missing:
1. Click **ADD OR REMOVE SCOPES**
2. Search for "calendar"
3. Select both scopes
4. Click **UPDATE**
5. Click **SAVE AND CONTINUE**

---

## ✅ You're Done!

### Now Test It:

1. **Delete your app** from iOS device (or sign out in app)
2. **Reinstall and open** your app
3. **Go to Google Calendar sync** settings
4. **Tap "Connect Google Calendar"**
5. **Sign in** with one of your test user emails
6. **You'll see this warning:**

```
┌─────────────────────────────────────────────┐
│  ⚠️  Google hasn't verified this app        │
│                                             │
│  This app hasn't been verified by Google    │
│  yet. Only continue if you know and trust   │
│  the developer.                             │
│                                             │
│  [Continue]  [Back to safety]              │
└─────────────────────────────────────────────┘
```

7. **Click "Continue"** (this is normal and expected!)
8. **Grant permissions**
9. **You'll be redirected back** to your app
10. **✅ Connected successfully!**

---

## 🤔 Common Questions

### Q: Why do I see "Google hasn't verified this app"?
**A:** This is normal in Testing mode. Users click "Continue" to proceed. This warning goes away only if you complete Google's verification process (takes 4-6 weeks and requires documentation).

### Q: Can other people use my app?
**A:** Yes, but only if their email is added to your Test users list. You can add up to 100 test users.

### Q: Do I need to verify my app?
**A:** Only if you want:
- More than 100 users
- Remove the warning message
- Public release without test user restrictions

For personal use, beta testing, or apps with <100 users, Testing mode is perfect!

### Q: How long does Testing mode last?
**A:** Indefinitely! You can keep your app in Testing mode forever if you want.

### Q: Can I publish to the App Store with Testing mode?
**A:** Yes! Users will see the "not verified" warning, but it works. For the best user experience with many users, you'd want verification, but it's not required.

---

## 🐛 Troubleshooting

### Still Getting "Access blocked"?

#### Check #1: Correct Email?
Make sure you're signing in with an email that's in your test users list.

```
❌ signing-in@gmail.com (not in test users)
✅ your-test-email@gmail.com (in test users)
```

#### Check #2: Status is Testing?
Go to OAuth consent screen and verify:
```
Publishing status: 🟡 Testing
```

If it says "In Production", click "BACK TO TESTING"

#### Check #3: Clear Browser Cache
1. Open Safari on your iOS device
2. Settings → Safari → Clear History and Website Data
3. Try signing in again

#### Check #4: Remove Old Permissions
1. Go to: https://myaccount.google.com/permissions
2. Find "RealLife HQ"
3. Click **Remove Access**
4. Try signing in again through your app

---

## 📊 Status Check

### ✅ Checklist

Run through this before testing:

- [ ] Go to console.cloud.google.com
- [ ] Select correct project
- [ ] OAuth consent screen shows "Testing" status
- [ ] At least one test user email added
- [ ] Test user email is the one you'll sign in with
- [ ] Calendar scopes are added
- [ ] Calendar API is enabled (APIs & Services → Library)
- [ ] OAuth client credentials created (iOS type)
- [ ] App info complete (app name, support email)

### 🎯 Expected Flow

```
App → "Connect Google Calendar"
  ↓
Safari opens with Google sign-in
  ↓
Enter test user email + password
  ↓
Warning: "Google hasn't verified this app"
  ↓
Click "Continue"
  ↓
"Allow RealLife HQ to access your calendar?"
  ↓
Click "Allow"
  ↓
Redirecting back to app...
  ↓
✅ Connected! Shows user email in settings
```

---

## 💾 Save This Configuration

Once you have it working, document your settings:

```
Project Name: [Your GCP project name]
Project ID: [Your project ID]
Client ID: 657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404.apps.googleusercontent.com
Publishing Status: Testing
Test Users: 
  - your-email@gmail.com
  - [add more as needed]
Scopes:
  - https://www.googleapis.com/auth/calendar
  - https://www.googleapis.com/auth/calendar.events
```

---

## 🎓 Understanding Testing vs Production

### Testing Mode (Your Current Setup)
```
┌─────────────────────────────────────────────┐
│ Who can sign in?                            │
│ • Up to 100 explicitly added test users    │
│                                             │
│ What do they see?                           │
│ • Warning: "Google hasn't verified..."     │
│ • Must click "Continue"                     │
│                                             │
│ Requirements?                                │
│ • None! Just add test users                 │
│                                             │
│ Verification needed?                         │
│ • No                                        │
│                                             │
│ Good for?                                    │
│ • Development                               │
│ • Beta testing                              │
│ • Personal use                              │
│ • Small teams (<100 users)                  │
└─────────────────────────────────────────────┘
```

### Production Mode (If You Verify)
```
┌─────────────────────────────────────────────┐
│ Who can sign in?                            │
│ • Anyone with a Google account              │
│                                             │
│ What do they see?                           │
│ • Clean OAuth screen                        │
│ • No warnings                               │
│                                             │
│ Requirements?                                │
│ • Privacy policy (public URL)               │
│ • Terms of service (public URL)             │
│ • Homepage                                  │
│ • Video demonstration                       │
│ • Security assessment                       │
│                                             │
│ Verification needed?                         │
│ • Yes (4-6 weeks process)                   │
│                                             │
│ Good for?                                    │
│ • Public apps                               │
│ • Large user base (>100)                    │
│ • App Store releases (optional)             │
└─────────────────────────────────────────────┘
```

---

## 🚀 Next Steps

### Immediate (You're Done!)
✅ Testing mode enabled
✅ Test users added
✅ App works for your test users

### Near Future (As You Grow)
- Add more test users as needed (up to 100)
- Test with multiple accounts
- Monitor for any OAuth errors

### Later (If Needed for Public Release)
- Prepare privacy policy
- Prepare terms of service
- Create video demonstration
- Submit for Google verification
- Wait 4-6 weeks

---

## 📞 Need Help?

If you still get "Access blocked" after following these steps:

1. Double-check test users list includes your email
2. Verify status is "Testing" (not "In Production")
3. Clear Safari cache and Google permissions
4. Try with a different test user email
5. Check that Calendar API is enabled

---

## ✨ Success!

Once you see "🟡 Testing" status and have added test users, you're all set! 

Your test users can sign in, they'll see a warning (which is normal), click "Continue", and connect successfully.

No Google verification needed for Testing mode! 🎉

---

**Remember:** The "Google hasn't verified this app" warning is NORMAL and EXPECTED in Testing mode. Users just click "Continue" to proceed. This is perfectly fine for development, testing, and even production use with <100 users.
