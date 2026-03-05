# Keeping Google Calendar Sync Connected - Implementation Guide

## 🎯 Overview

This guide explains the improvements made to keep your Google Calendar sync connection stable and persistent.

---

## ✅ What Was Fixed

### 1. **Token Expiration Tracking** 
**Problem:** Access tokens expire after 1 hour, but the app didn't track when they would expire.

**Solution:** 
- Now tracking `tokenExpirationDate` for each access token
- Stored in UserDefaults alongside the token
- Automatically checked before making API calls

### 2. **Proactive Token Refresh**
**Problem:** Tokens were only refreshed when API calls failed with 401 errors.

**Solution:**
- App now automatically refreshes tokens 5 minutes before expiration
- Uses background Task to schedule refresh
- Prevents API call failures due to expired tokens

### 3. **Better Token Validation**
**Problem:** No validation before making API calls.

**Solution:**
- New `ensureValidToken()` method called before each API request
- Checks if token is expired or expiring soon
- Automatically refreshes if needed

### 4. **Invalid Refresh Token Handling**
**Problem:** If refresh token becomes invalid (revoked by user or expired after 6 months), the app had no graceful way to handle it.

**Solution:**
- Detects 400 errors when refreshing tokens
- Automatically signs user out and clears credentials
- Provides clear error message prompting re-authentication
- New error case: `.refreshTokenInvalid`

### 5. **Improved Credential Management**
**Problem:** Didn't properly clean up tokens and scheduled tasks.

**Solution:**
- `signOut()` now cancels any scheduled refresh tasks
- Clears all token-related data including expiration dates
- Proper cleanup in `deinit`

---

## 🔧 Technical Changes

### New Properties Added

```swift
private var tokenExpirationDate: Date?
private let tokenExpirationKey = "googleCalendarTokenExpiration"
private var tokenRefreshTask: Task<Void, Never>?
```

### New Methods Added

```swift
// Check if token needs refreshing
private func isTokenExpiredOrExpiring() -> Bool

// Schedule automatic token refresh
private func scheduleTokenRefreshIfNeeded()

// Ensure valid token before API calls
private func ensureValidToken() async throws
```

### Updated Methods

#### `loadStoredCredentials()`
- Now loads token expiration date
- Checks if loaded token is expired
- Automatically refreshes if needed on app launch

#### `saveCredentials()`
- Now accepts `expiresIn` parameter
- Calculates and stores expiration date
- Schedules automatic refresh

#### `refreshAccessToken()`
- Better error handling for invalid refresh tokens
- Detects 400 status codes (invalid refresh token)
- Updates expiration date after refresh
- Handles case where Google provides new refresh token
- Automatically signs out if refresh fails

#### `signOut()`
- Cancels scheduled refresh tasks
- Clears expiration date
- Proper cleanup

#### All API Methods (`fetchEvents`, `createEvent`, etc.)
- Now call `ensureValidToken()` before making requests
- Proactively refresh tokens instead of waiting for 401 errors

---

## 📱 How It Works

### Token Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│ 1. User Signs In                                            │
│    ↓                                                         │
│    Access Token + Refresh Token received                    │
│    Expiration: Now + 1 hour                                 │
│    ↓                                                         │
│    Schedule refresh for: Expiration - 5 minutes             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 2. App Makes API Call (55 minutes later)                   │
│    ↓                                                         │
│    ensureValidToken() checks expiration                     │
│    ↓                                                         │
│    Token expires in < 5 minutes → Refresh now               │
│    ↓                                                         │
│    New access token received                                │
│    ↓                                                         │
│    Schedule next refresh                                    │
│    ↓                                                         │
│    API call proceeds with fresh token                       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 3. Background Refresh (55 minutes after last refresh)      │
│    ↓                                                         │
│    Scheduled task wakes up                                  │
│    ↓                                                         │
│    Calls refreshAccessToken()                               │
│    ↓                                                         │
│    New access token received                                │
│    ↓                                                         │
│    Schedule next refresh                                    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 4. App Relaunches After Days                               │
│    ↓                                                         │
│    loadStoredCredentials() loads tokens                     │
│    ↓                                                         │
│    Checks expiration date                                   │
│    ↓                                                         │
│    Token expired → Refresh immediately                      │
│    ↓                                                         │
│    If refresh succeeds: Connected ✅                        │
│    If refresh fails: Sign out, need to re-authenticate      │
└─────────────────────────────────────────────────────────────┘
```

---

## ⚠️ Important Notes

### When Users Need to Re-Authenticate

Users will need to sign in again if:

1. **Refresh token expires** (after 6 months of inactivity)
2. **User revokes access** (in Google Account settings)
3. **Password changed** (requires re-authentication)
4. **App reinstalled** (tokens are lost)

### Token Refresh Limitations

- **Access tokens** expire after 1 hour
- **Refresh tokens** can last indefinitely if used regularly
- **Refresh tokens** expire after 6 months of inactivity
- Google may issue new refresh tokens during refresh (handled automatically)

### Buffer Time

We refresh tokens **5 minutes before expiration** to:
- Account for clock drift
- Handle network delays
- Prevent race conditions
- Ensure smooth user experience

---

## 🔐 Security Considerations

### Current Implementation (UserDefaults)

**Pros:**
- Simple to implement
- Works across app launches
- Easy to debug

**Cons:**
- Not as secure as Keychain
- Visible to anyone with device access
- Vulnerable if device is jailbroken

### Recommended Enhancement: Move to Keychain

For production apps, consider moving token storage to Keychain:

```swift
import Security

class KeychainManager {
    static func save(key: String, value: String) {
        let data = value.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary) // Delete old
        SecItemAdd(query as CFDictionary, nil) // Add new
    }
    
    static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
```

Replace UserDefaults calls with KeychainManager calls in `GoogleCalendarManager`.

---

## 🧪 Testing Guide

### Test Scenarios

#### 1. Normal Operation
```
✅ Sign in
✅ Create/view events
✅ Wait 56 minutes
✅ Create/view events (should auto-refresh)
✅ Verify no errors
```

#### 2. App Relaunch with Expired Token
```
✅ Sign in
✅ Close app
✅ Wait 2 hours
✅ Relaunch app
✅ Try to view events
✅ Should auto-refresh and work
```

#### 3. Invalid Refresh Token
```
✅ Sign in
✅ Go to Google Account settings
✅ Revoke app access
✅ Return to app
✅ Try to view events
✅ Should sign out and prompt re-authentication
```

#### 4. Network Issues
```
✅ Sign in
✅ Enable Airplane Mode
✅ Wait for refresh attempt
✅ Should handle gracefully
✅ Disable Airplane Mode
✅ Should recover and refresh
```

### Monitoring

Add logging to track token lifecycle:

```swift
// In ensureValidToken()
print("🔑 Token expiration: \(tokenExpirationDate ?? Date())")
print("🔑 Time until expiration: \(tokenExpirationDate?.timeIntervalSinceNow ?? 0)s")

// In refreshAccessToken()
print("🔄 Refreshing access token...")
print("✅ Token refreshed successfully")

// In scheduleTokenRefreshIfNeeded()
print("⏰ Scheduled token refresh for: \(refreshTime)")
```

---

## 📊 Troubleshooting

### Issue: Token Refresh Fails Immediately

**Symptoms:**
- Sign in works
- Immediately signed out
- "Refresh token is invalid" error

**Causes:**
1. Refresh token not saved properly
2. Google OAuth consent screen issues
3. App not properly configured in Google Console

**Solutions:**
1. Check that `refreshToken` is being saved in `saveCredentials()`
2. Verify OAuth consent screen includes calendar scopes
3. Ensure app is in "Testing" or "Published" mode
4. Check that `access_type=offline` is in auth URL

### Issue: App Keeps Asking to Sign In

**Symptoms:**
- Successful sign in
- App works for a while
- Randomly asks to sign in again

**Causes:**
1. Refresh token not persisting
2. Token refresh failing silently
3. UserDefaults being cleared

**Solutions:**
1. Check that `refreshToken` is in UserDefaults after sign in
2. Add logging to `refreshAccessToken()` to see why it fails
3. Verify app is not clearing UserDefaults elsewhere
4. Consider moving to Keychain for persistence

### Issue: API Calls Fail with 401

**Symptoms:**
- Sign in successful
- First few API calls work
- Later calls fail with 401

**Causes:**
1. Token not being refreshed
2. `ensureValidToken()` not being called
3. Clock drift issues

**Solutions:**
1. Verify all API methods call `ensureValidToken()`
2. Check `scheduleTokenRefreshIfNeeded()` is being called
3. Verify device clock is correct
4. Check `tokenExpirationDate` is accurate

### Issue: Background Refresh Not Working

**Symptoms:**
- Token refresh only happens during API calls
- No proactive refresh

**Causes:**
1. Task being cancelled prematurely
2. App suspended by iOS
3. Memory pressure causing task cancellation

**Solutions:**
1. Verify `tokenRefreshTask` is not being set to nil
2. Consider using background refresh capability
3. Check that `scheduleTokenRefreshIfNeeded()` is called after each refresh
4. Add logging to see when task executes

---

## 🚀 Next Steps

### Immediate Actions

1. **Test the Updated Code**
   - Sign in to Google Calendar
   - Monitor console logs for token refresh
   - Wait 56 minutes and verify auto-refresh
   - Test API calls before and after refresh

2. **Handle UI Updates**
   - Show connection status in settings
   - Display token expiration time (for debugging)
   - Add refresh button for manual token refresh
   - Show clear error messages when re-auth needed

3. **Add User Notifications**
   - Notify users when refresh token expires
   - Prompt for re-authentication
   - Show connection health in UI

### Future Enhancements

1. **Move to Keychain**
   - More secure token storage
   - Better persistence across app updates
   - Industry standard practice

2. **Background Refresh**
   - Use BGTaskScheduler for periodic refresh
   - Keeps tokens fresh even when app not running
   - Better user experience

3. **Connection Health Monitoring**
   - Track last successful sync
   - Show connection status indicator
   - Alert users to connection issues

4. **Exponential Backoff**
   - Implement retry logic with backoff
   - Handle transient network errors
   - Reduce server load

5. **Analytics**
   - Track token refresh success/failure rates
   - Monitor connection stability
   - Identify common failure patterns

---

## 📝 Summary

### What Changed
- ✅ Added token expiration tracking
- ✅ Implemented proactive token refresh
- ✅ Added automatic refresh scheduling
- ✅ Improved error handling for invalid refresh tokens
- ✅ Better credential cleanup on sign out
- ✅ Token validation before API calls

### Benefits
- 🎯 Maintains persistent connection to Google Calendar
- 🎯 Prevents API call failures due to expired tokens
- 🎯 Gracefully handles token revocation
- 🎯 Provides clear feedback when re-authentication needed
- 🎯 Better user experience with fewer interruptions

### User Experience
- Users stay signed in longer
- Fewer "Please sign in again" prompts
- Seamless background token refresh
- Clear messaging when action required

---

## 🔗 Related Files

- `GoogleCalendarManager.swift` - Main implementation
- `GoogleCalendarSyncSettingsView.swift` - UI for sync settings
- `GOOGLE_CALENDAR_OAUTH_FIX.md` - OAuth setup guide
- `OAUTH_FLOW_DIAGRAM.md` - OAuth flow documentation

---

## ✨ Success Metrics

Your Google Calendar sync is working well when:

- ✅ Users can sign in once and stay signed in for months
- ✅ Token refreshes happen automatically in the background
- ✅ API calls succeed without 401 errors
- ✅ Users only need to re-authenticate when necessary (token revoked, etc.)
- ✅ Clear error messages when re-authentication is needed

---

## 📞 Support

If you encounter issues:

1. Check console logs for error messages
2. Verify Google Cloud Console configuration
3. Test with the scenarios in Testing Guide section
4. Review Troubleshooting section for common issues

---

**Last Updated:** February 27, 2026
**Version:** 2.0 - Enhanced Token Management
