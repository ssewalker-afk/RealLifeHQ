# Fixing "Access blocked: RealLife HQ has not completed the Google verification process"

## 🚨 What This Error Means

Google shows this error when:
1. Your OAuth app is in **Production** mode
2. You're using **sensitive or restricted scopes** (like Calendar API)
3. Your app **hasn't been verified** by Google

## ✅ Quick Fix: Switch to Testing Mode

For development, beta testing, or apps with <100 users, you don't need verification!

---

## Step-by-Step Solution

### Step 1: Go to Google Cloud Console

1. Navigate to: **https://console.cloud.google.com/**
2. Select your project (the one with your OAuth credentials)
3. Click **APIs & Services** → **OAuth consent screen**

---

### Step 2: Check Current Publishing Status

You'll see one of these statuses:

**Current Status Options:**
- 🔴 **In Production** - This is why you're getting the error!
- 🟡 **Testing** - What you need for now
- 🟢 **Published** - Fully verified (not needed unless public app)

---

### Step 3: Switch to Testing Mode

#### If Currently in Production:

1. **On the OAuth consent screen page**, look for the **Publishing status** card at the top
2. Click the button that says **"BACK TO TESTING"** or **"Unpublish"**
3. Confirm the action
4. Your app is now in **Testing** mode

#### If Setting Up for First Time:

1. On the **OAuth consent screen** page
2. Choose **User Type**: 
   - **External** (for any Google account - recommended)
   - **Internal** (only for Google Workspace organization)
3. Click **Create**

---

### Step 4: Configure OAuth Consent Screen

Fill in the required information:

#### App Information:
```
App name: RealLife HQ
User support email: [Your email address]
App logo: [Optional - upload your app icon]
```

#### App Domain (Optional but Recommended):
```
Application home page: [Your website if you have one]
Application privacy policy link: [If you have one]
Application terms of service link: [If you have one]
```

If you don't have these, you can skip them for Testing mode.

#### Developer contact information:
```
Email addresses: [Your email address]
```

Click **SAVE AND CONTINUE**

---

### Step 5: Add Scopes

1. Click **ADD OR REMOVE SCOPES**

2. Search for and select these scopes:
   ```
   https://www.googleapis.com/auth/calendar
   https://www.googleapis.com/auth/calendar.events
   ```

3. Or manually add them in the text box at bottom:
   ```
   https://www.googleapis.com/auth/calendar
   https://www.googleapis.com/auth/calendar.events
   ```

4. Click **UPDATE** at the bottom

5. Click **SAVE AND CONTINUE**

---

### Step 6: Add Test Users ⚠️ CRITICAL

**This is the most important step for Testing mode!**

1. On the **Test users** section
2. Click **+ ADD USERS**
3. Add the Gmail addresses that will use your app:
   ```
   your-email@gmail.com
   another-tester@gmail.com
   ```
4. Click **ADD**
5. Click **SAVE AND CONTINUE**

⚠️ **IMPORTANT:** Only the email addresses you add here can sign in to your app while it's in Testing mode. You can add up to **100 test users**.

---

### Step 7: Review and Verify

1. Review the summary page
2. Click **BACK TO DASHBOARD**
3. Verify the status shows:
   ```
   Publishing status: Testing
   ```

---

## 🧪 Testing It Works

1. **Clear Your App Data**
   - Delete and reinstall your app, OR
   - Sign out of Google Calendar sync in your app

2. **Try Signing In Again**
   - Open your app
   - Go to Google Calendar sync settings
   - Tap "Connect Google Calendar"
   - Sign in with one of your **test user** email addresses

3. **Expected Result:**
   - ✅ Google sign-in page appears
   - ✅ Shows: "RealLife HQ wants to access your Google Account"
   - ✅ Shows warning: "Google hasn't verified this app" with "Continue" button
   - ✅ After clicking Continue, you can grant permissions
   - ✅ Successfully redirected back to your app

---

## 📋 Visual Guide

### What You Should See in Testing Mode:

```
┌──────────────────────────────────────────────────────┐
│  OAuth consent screen                                │
│                                                      │
│  Publishing status                                   │
│  ┌────────────────────────────────────────────┐    │
│  │  🟡 Testing                                 │    │
│  │                                             │    │
│  │  While in testing, only users added to     │    │
│  │  the test users list can access this app.  │    │
│  │                                             │    │
│  │  [PUBLISH APP]                              │    │
│  └────────────────────────────────────────────┘    │
│                                                      │
│  App information                                     │
│  App name: RealLife HQ                              │
│  User support email: you@example.com                │
│                                                      │
│  [EDIT APP REGISTRATION]                             │
└──────────────────────────────────────────────────────┘
```

---

## 🎯 Testing Mode vs Production Mode

### Testing Mode (What You Need Now)
- ✅ Up to 100 test users
- ✅ No verification required
- ✅ Perfect for development and beta testing
- ✅ Test users see "Google hasn't verified this app" warning
- ✅ They can click "Continue" to proceed
- ⚠️ Only explicitly added test users can sign in

### Production Mode (For Public Apps)
- ❌ Requires Google verification process
- ❌ Takes 4-6 weeks
- ❌ Requires privacy policy and terms of service
- ❌ Requires security assessment
- ❌ Requires video demonstration
- ✅ Anyone can sign in
- ✅ No warnings shown

---

## 🔧 Troubleshooting

### Still Getting "Access blocked" Error?

#### Problem 1: Signed in with Non-Test User
**Solution:** Make sure the Google account you're signing in with is in your test users list.

Check:
1. Go to OAuth consent screen
2. Scroll to Test users section
3. Verify your email is listed
4. If not, add it and try again

---

#### Problem 2: Changes Not Taking Effect
**Solution:** Clear Google's OAuth cache

1. Sign out of your Google account in Safari (iOS) or Chrome
2. Go to https://myaccount.google.com/permissions
3. Find "RealLife HQ" and remove access
4. Try signing in again through your app

---

#### Problem 3: App Still Shows as "In Production"
**Solution:** Force it back to Testing

1. OAuth consent screen page
2. Look for the Publishing status card
3. If it says "In Production", click **"BACK TO TESTING"**
4. If you don't see that button, you may need to unpublish first

---

### Error: "This app is blocked"

If you see this instead of "Access blocked":

**Cause:** Your app may have been blocked by Google

**Solution:**
1. Check Google Cloud Console for any alerts or messages
2. Ensure Calendar API is enabled
3. Make sure scopes are correctly added
4. Verify you're in Testing mode with test users added

---

## 📱 What Users Will See

### In Testing Mode:

When test users sign in, they'll see:

```
┌─────────────────────────────────────────────┐
│  Google                                     │
│                                             │
│  RealLife HQ wants to access your Google    │
│  Account                                    │
│                                             │
│  ⚠️  Google hasn't verified this app        │
│                                             │
│  This app hasn't been verified by Google    │
│  yet. Only continue if you know and trust   │
│  the developer.                             │
│                                             │
│  [Continue]  [Back to safety]              │
│                                             │
│  This will allow RealLife HQ to:           │
│  • See, edit, share, and permanently       │
│    delete all the calendars you can        │
│    access using Google Calendar            │
│                                             │
│  [your-email@gmail.com ▼]                  │
│                                             │
│  [Cancel]              [Continue]          │
└─────────────────────────────────────────────┘
```

**This is normal and expected!** Test users should click **Continue**.

---

## 🚀 When You Need Verification (Production)

You need to go through Google's verification process if:

1. **Public app** with >100 users
2. **App Store release** to general public
3. **Remove the warning** for all users
4. **Corporate deployment** requiring verified apps

### Verification Requirements:

Google requires:
- ✅ Privacy policy (publicly accessible URL)
- ✅ Terms of service (publicly accessible URL)
- ✅ Application homepage
- ✅ Video demonstration of OAuth flow
- ✅ Explanation of why you need calendar access
- ✅ Security assessment
- ✅ Verification of domain ownership

**Timeline:** 4-6 weeks after submission

**Cost:** Free (but requires significant documentation)

---

## 💡 Recommendations

### For Now (Development/Beta):
1. ✅ Use **Testing mode**
2. ✅ Add your email and beta testers as test users
3. ✅ Users click "Continue" when they see the warning
4. ✅ Limit to <100 users

### Before App Store Launch:
1. Decide if you need verification
2. If yes, start process 2-3 months before launch
3. Prepare all required documentation
4. Consider using TestFlight for pre-launch testing (stays in Testing mode)

### For Personal Use:
- Testing mode is perfectly fine
- Add your own email address
- No verification needed

---

## 📝 Quick Checklist

To fix "Access blocked" error:

- [ ] Go to Google Cloud Console
- [ ] Navigate to APIs & Services → OAuth consent screen
- [ ] Verify/switch publishing status to **Testing**
- [ ] Add required app information (name, support email)
- [ ] Add calendar scopes
- [ ] Add test users (your Gmail addresses)
- [ ] Save and continue through all steps
- [ ] Verify status shows "Testing"
- [ ] Clear app data / sign out
- [ ] Try signing in with test user email
- [ ] Click "Continue" when you see the warning
- [ ] Should successfully connect!

---

## 🆘 Still Having Issues?

### Check These:

1. **Calendar API Enabled?**
   - Go to APIs & Services → Library
   - Search "Google Calendar API"
   - Should show "API enabled"

2. **Correct Scopes?**
   - OAuth consent screen → Scopes
   - Should see calendar scopes listed

3. **Test User Added?**
   - OAuth consent screen → Test users
   - Should see your email address

4. **Signing in with Correct Account?**
   - Make sure you're using a test user email
   - Not any random Google account

5. **OAuth Client Created?**
   - APIs & Services → Credentials
   - Should have an iOS OAuth client

---

## 📚 Additional Resources

- [Google OAuth 2.0 Verification](https://support.google.com/cloud/answer/9110914)
- [OAuth Consent Screen Guide](https://support.google.com/cloud/answer/10311615)
- [Restricted Scopes Documentation](https://support.google.com/cloud/answer/9110914)

---

## ✅ Success!

Once you've switched to Testing mode and added test users, you should be able to sign in without the "Access blocked" error. Users will see a warning that "Google hasn't verified this app," but they can click **Continue** to proceed with authentication.

This is the normal flow for apps in Testing mode and is perfectly acceptable for development, beta testing, and even production apps with <100 users who trust you.

---

**Last Updated:** February 27, 2026
**Status:** Testing Mode (No Verification Required)
