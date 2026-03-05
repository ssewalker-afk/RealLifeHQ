# Google Calendar Sync - Quick Fix Checklist

## 🚨 If Users Are Getting Disconnected

### Immediate Checks

1. **Is the token being refreshed?**
   ```swift
   // Add this logging to refreshAccessToken() to verify
   print("🔄 Attempting token refresh...")
   print("✅ Token refreshed! Expires: \(tokenExpirationDate ?? Date())")
   ```

2. **Is the refresh token stored?**
   ```swift
   // Check in saveCredentials()
   print("💾 Saved access token: \(accessToken?.prefix(20) ?? "none")...")
   print("💾 Saved refresh token: \(refreshToken?.prefix(20) ?? "none")...")
   ```

3. **Is the scheduled refresh working?**
   ```swift
   // Add to scheduleTokenRefreshIfNeeded()
   print("⏰ Next refresh scheduled for: \(refreshTime)")
   print("⏰ That's in \(delay) seconds")
   ```

---

## 🔧 Common Fixes

### Fix #1: Token Expires Too Quickly
**Symptom:** Users disconnected after 1 hour

**Cause:** Token not being refreshed automatically

**Solution:**
- Verify `scheduleTokenRefreshIfNeeded()` is being called after token save
- Check that `tokenRefreshTask` is not being cancelled prematurely
- Ensure `ensureValidToken()` is called before API requests

### Fix #2: Refresh Token Missing
**Symptom:** Can't refresh, must re-authenticate

**Cause:** Not requesting offline access

**Solution:**
```swift
// In authenticate() method, verify this line exists:
let authURL = "https://accounts.google.com/o/oauth2/v2/auth?" +
    "client_id=\(clientID)" +
    "&redirect_uri=\(redirectURI)" +
    "&response_type=code" +
    "&scope=\(scopeString)" +
    "&access_type=offline" +  // ← THIS IS CRITICAL
    "&prompt=consent"         // ← THIS TOO
```

### Fix #3: Refresh Token Revoked
**Symptom:** "Refresh token is invalid" error

**Cause:** User revoked access in Google settings, or 6 months of inactivity

**Solution:**
- This is expected behavior
- App now handles it gracefully by signing out
- User needs to re-authenticate
- Show friendly message: "Please reconnect your Google Calendar"

### Fix #4: UserDefaults Being Cleared
**Symptom:** Disconnected after app update or reinstall

**Cause:** UserDefaults cleared or app data deleted

**Solution:**
- Move to Keychain for better persistence
- Add migration code to preserve old tokens
- Document that reinstalls require re-authentication

---

## 🎯 Quick Tests

### Test 1: Basic Connection (30 seconds)
```
1. Sign in to Google Calendar
2. Check console: Should see token saved
3. Navigate to events
4. Verify events load
```

### Test 2: Token Refresh (5 minutes)
```
1. Sign in
2. Note expiration time in console
3. Wait until 5 minutes before expiration
4. Try to create an event
5. Should see token refresh in console
6. Event should be created successfully
```

### Test 3: Expired Token Handling (2 hours)
```
1. Sign in
2. Force expiration: Set device time forward 2 hours
3. Try to view events
4. Should auto-refresh and work
5. Reset device time
```

### Test 4: Invalid Refresh Token (1 minute)
```
1. Sign in
2. Go to Google Account → Security → Third-party access
3. Revoke app access
4. Return to app and try to sync
5. Should sign out gracefully
6. Show error: "Please reconnect your Google Calendar"
```

---

## 📋 Pre-Deployment Checklist

Before releasing to users:

- [ ] OAuth properly configured in Google Console
- [ ] `access_type=offline` in auth URL
- [ ] `prompt=consent` in auth URL (forces refresh token)
- [ ] Token expiration tracking enabled
- [ ] Automatic refresh scheduling implemented
- [ ] `ensureValidToken()` called before all API requests
- [ ] Error handling for invalid refresh tokens
- [ ] User-friendly error messages
- [ ] Tested with real Google account
- [ ] Tested token refresh (wait 56+ minutes)
- [ ] Tested app relaunch after token expiration
- [ ] Tested invalid refresh token scenario
- [ ] Console logging added for debugging
- [ ] UI shows connection status
- [ ] UI handles disconnection gracefully

---

## 🐛 Debug Commands

Add these to your code for troubleshooting:

```swift
// In GoogleCalendarManager

// Check current token status
func debugTokenStatus() {
    print("=== TOKEN STATUS ===")
    print("Authenticated: \(isAuthenticated)")
    print("Sync Enabled: \(syncEnabled)")
    print("Access Token: \(accessToken?.prefix(30) ?? "none")...")
    print("Refresh Token: \(refreshToken?.prefix(30) ?? "none")...")
    print("User Email: \(userEmail ?? "none")")
    
    if let expirationDate = tokenExpirationDate {
        print("Expires at: \(expirationDate)")
        print("Time until expiration: \(expirationDate.timeIntervalSinceNow)s")
        print("Is expired/expiring: \(isTokenExpiredOrExpiring())")
    } else {
        print("No expiration date set")
    }
    
    print("Refresh task running: \(tokenRefreshTask != nil)")
    print("===================")
}

// Manual refresh for testing
func debugRefreshToken() async {
    print("🧪 Manual token refresh test...")
    do {
        try await refreshAccessToken()
        print("✅ Refresh successful!")
        debugTokenStatus()
    } catch {
        print("❌ Refresh failed: \(error)")
    }
}
```

Call these from your UI during testing:

```swift
// Add to your settings view
#if DEBUG
Button("Debug Token Status") {
    GoogleCalendarManager.shared.debugTokenStatus()
}

Button("Test Token Refresh") {
    Task {
        await GoogleCalendarManager.shared.debugRefreshToken()
    }
}
#endif
```

---

## 📊 Monitoring Connection Health

### Add to Your Settings View

```swift
struct GoogleCalendarSyncSettingsView: View {
    @ObservedObject var manager = GoogleCalendarManager.shared
    
    // Add these computed properties
    var connectionHealthText: String {
        guard manager.isAuthenticated else {
            return "Not Connected"
        }
        
        // You'll need to expose tokenExpirationDate or create a public getter
        return "Connected - Token valid"
    }
    
    var connectionHealthColor: Color {
        guard manager.isAuthenticated else {
            return .red
        }
        
        // Check if token is expiring soon
        // return isExpiring ? .orange : .green
        return .green
    }
    
    var body: some View {
        // Your existing view...
        
        // Add this section
        Section {
            HStack {
                Circle()
                    .fill(connectionHealthColor)
                    .frame(width: 12, height: 12)
                Text(connectionHealthText)
                    .foregroundColor(.secondary)
                Spacer()
            }
        } header: {
            Text("Connection Status")
        }
    }
}
```

---

## 🆘 Emergency Fixes

### If Everything Is Broken

1. **Clear All Data**
   ```swift
   // Add this method to GoogleCalendarManager
   func debugClearAllData() {
       signOut()
       UserDefaults.standard.removeObject(forKey: accessTokenKey)
       UserDefaults.standard.removeObject(forKey: refreshTokenKey)
       UserDefaults.standard.removeObject(forKey: tokenExpirationKey)
       UserDefaults.standard.removeObject(forKey: userEmailKey)
       UserDefaults.standard.removeObject(forKey: syncEnabledKey)
       print("🗑️ All Google Calendar data cleared")
   }
   ```

2. **Verify Google Console Config**
   - Go to console.cloud.google.com
   - Check OAuth client is iOS type
   - Verify redirect URI exactly matches code
   - Confirm Calendar API is enabled
   - Check OAuth consent screen has calendar scopes

3. **Reset OAuth Consent**
   - In Google Console → OAuth consent screen
   - If in Testing mode, remove and re-add test users
   - Or switch to Testing mode if in Production without verification

4. **Check App Bundle ID**
   - OAuth client in Google Console must have your app's bundle ID
   - Must match what's in Xcode

---

## 💡 Pro Tips

### Tip 1: Test with Multiple Accounts
- Test with personal Gmail
- Test with G Suite/Workspace account
- Behavior may differ

### Tip 2: Monitor Google API Usage
- Go to Google Console → APIs & Services → Dashboard
- Check Calendar API request counts
- Look for 401 errors in metrics
- High 401 count = token refresh issues

### Tip 3: Add Analytics
```swift
// Track connection events
func trackConnectionEvent(_ event: String) {
    // Use your analytics service
    print("📊 Analytics: \(event)")
}

// Call in key places:
// trackConnectionEvent("google_auth_success")
// trackConnectionEvent("google_token_refresh_success")
// trackConnectionEvent("google_token_refresh_failed")
// trackConnectionEvent("google_connection_lost")
```

### Tip 4: Version Your Tokens
```swift
private let tokenVersionKey = "googleCalendarTokenVersion"
private let currentTokenVersion = 2

// In loadStoredCredentials()
let savedVersion = UserDefaults.standard.integer(forKey: tokenVersionKey)
if savedVersion < currentTokenVersion {
    // Token format changed, clear and re-authenticate
    signOut()
    UserDefaults.standard.set(currentTokenVersion, forKey: tokenVersionKey)
}
```

---

## 🎓 Understanding the Token Lifecycle

### Normal Flow
```
Sign In → Access Token (1 hour) + Refresh Token (6 months+)
         ↓
      55 min
         ↓
    Auto Refresh → New Access Token (1 hour)
         ↓
      55 min
         ↓
    Auto Refresh → New Access Token (1 hour)
         ↓
        ...continues indefinitely...
```

### What Breaks the Flow
1. **User revokes access** → Need to sign in again
2. **Refresh token expires** (6 months inactive) → Need to sign in again
3. **Password changed** → Need to sign in again
4. **App data cleared** → Need to sign in again

### How to Keep It Going
- ✅ Refresh tokens before they expire
- ✅ Handle refresh errors gracefully
- ✅ Store tokens securely
- ✅ Request `access_type=offline` during auth
- ✅ Use `prompt=consent` to ensure refresh token

---

## 📱 User Communication

### When to Show "Reconnect" Message

```swift
// Good: Clear, actionable
"Your Google Calendar connection expired. Please reconnect to continue syncing."

// Bad: Vague, technical
"Error 401: Unauthorized"
```

### When to Show "Sign In" Again

```swift
// After detecting invalid refresh token
"Your Google Calendar access was revoked. Please sign in again to restore sync."
```

### Auto-Reconnect Option

```swift
// In your settings view
if !manager.isAuthenticated && hasStoredCredentials {
    Button("Reconnect Google Calendar") {
        Task {
            try await manager.authenticate()
        }
    }
    .foregroundColor(.blue)
}
```

---

## ✅ Success Indicators

Your implementation is working correctly when:

1. ✅ Users sign in once and stay connected for weeks/months
2. ✅ No 401 errors in console logs
3. ✅ Token refreshes happen automatically in background
4. ✅ App works immediately after relaunch (no re-auth needed)
5. ✅ Graceful handling when re-auth is actually needed
6. ✅ Users receive clear messages about connection status

---

## 📚 Additional Resources

- See `KEEPING_GOOGLE_SYNC_CONNECTED.md` for detailed implementation guide
- See `GOOGLE_CALENDAR_OAUTH_FIX.md` for OAuth setup
- See `OAUTH_FLOW_DIAGRAM.md` for flow visualization
- [Google OAuth 2.0 for Mobile Apps](https://developers.google.com/identity/protocols/oauth2/native-app)
- [Google Calendar API Reference](https://developers.google.com/calendar/api/v3/reference)

---

**Quick Help:** If users are getting disconnected, start with Fix #1 and work down the list!
