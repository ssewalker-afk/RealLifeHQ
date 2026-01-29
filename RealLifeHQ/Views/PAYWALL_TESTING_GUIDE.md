# Complete Paywall Testing Guide

## Quick Start Testing (5 Minutes)

### Method 1: StoreKit Testing in Xcode (Recommended for Development)

This is the fastest way to test your paywall without any App Store Connect setup.

#### Step 1: Create StoreKit Configuration File

1. **In Xcode**: File → New → File
2. **Search for**: "StoreKit Configuration File"
3. **Name**: `Products.storekit`
4. **Save** in your project

#### Step 2: Add Your Products

Click the **+** button in the StoreKit Configuration editor:

1. **Select**: "Add Auto-Renewable Subscription"
2. **Create Subscription Group**: "Premium Subscription"

**Add Monthly Product:**
```
Reference Name: Monthly Premium
Product ID: com.reallifehq.monthly
Price: $9.99
Duration: 1 Month
```

**Add Yearly Product:**
```
Reference Name: Yearly Premium  
Product ID: com.reallifehq.yearly
Price: $99.99
Duration: 1 Year
```

**Add Free Trial (Optional):**
1. Select each product
2. In Inspector → Introductory Offers
3. Click **+**
4. Type: Free Trial
5. Duration: 7 Days

#### Step 3: Enable StoreKit Configuration

1. **Click your scheme** (next to device selector, top of Xcode)
2. **Edit Scheme...**
3. **Run → Options**
4. **StoreKit Configuration**: Select `Products.storekit`
5. **Close**

#### Step 4: Run and Test!

1. **Build and Run** your app (Cmd+R)
2. Your paywall should appear or be accessible
3. **Tap a subscription option**
4. **Confirm purchase** (it's fake, no money charged!)
5. **Verify** that premium features unlock

### Method 2: Sandbox Testing (More Realistic)

This tests with Apple's sandbox environment (like production but not real money).

#### Step 1: Set Up Sandbox Test Account

1. Go to **App Store Connect**
2. **Users and Access** → **Sandbox Testers**
3. Click **+** to add tester
4. Fill in details:
   - Email: use a real email you can access
   - Password: create a password
   - First/Last Name
   - Country/Region
5. **Save**

#### Step 2: Sign Out of Real Apple ID on Device

**On iPhone/iPad:**
1. Settings → App Store
2. Tap your Apple ID at top
3. **Sign Out**
4. **DON'T sign in with sandbox account yet**

#### Step 3: Build to Device

1. Connect your iPhone/iPad
2. Select it as deployment target
3. Build and Run (Cmd+R)

#### Step 4: Test Purchase

1. Open your app
2. Navigate to paywall
3. **Tap subscription option**
4. When prompted to sign in: **Use sandbox test account**
5. Complete purchase
6. Verify features unlock

**Important:** Sandbox purchases are FREE - no real money charged!

## Testing Checklist

### Visual Testing

- [ ] Paywall displays correctly
- [ ] Monthly price shows correctly
- [ ] Yearly price shows correctly
- [ ] "Best Value" badge appears on yearly (if you have one)
- [ ] Free trial text appears (if applicable)
- [ ] Feature list is readable
- [ ] Colors match your theme
- [ ] Works on different device sizes
- [ ] Works in light and dark mode

### Functional Testing

#### Purchase Flow
- [ ] Tap monthly subscription opens purchase dialog
- [ ] Tap yearly subscription opens purchase dialog
- [ ] Can complete purchase (in test mode)
- [ ] Loading indicator appears during purchase
- [ ] Success state shows after purchase
- [ ] Premium features unlock immediately
- [ ] App remembers subscription after restart

#### Restore Purchases
- [ ] "Restore Purchases" button works
- [ ] Previous purchases are restored
- [ ] Features unlock after restore
- [ ] Works after deleting and reinstalling app

#### Error Handling
- [ ] Cancel purchase works (doesn't crash)
- [ ] Error message shows if purchase fails
- [ ] Can retry failed purchase
- [ ] Network error handled gracefully

#### Subscription Status
- [ ] Correct status shown when not subscribed
- [ ] Correct status shown when subscribed
- [ ] Correct status shown during free trial
- [ ] Expired subscription handled properly

### Edge Cases

- [ ] Multiple rapid taps don't cause issues
- [ ] Purchase while offline shows error
- [ ] Already subscribed user sees correct state
- [ ] Subscription status persists across app launches
- [ ] Switch between monthly/yearly works correctly

## Using Xcode's Transaction Manager

This is incredibly useful for testing subscription states!

### Open Transaction Manager

**While app is running:**
Debug → StoreKit → Manage Transactions...

### What You Can Do:

#### 1. View All Transactions
- See all test purchases
- Check transaction status
- View subscription details

#### 2. Clear Purchases
- Click transaction
- Press **Delete** or right-click → Delete
- Resets to non-subscribed state

#### 3. Test Subscription Renewal
- Select transaction
- Click **Renew**
- Tests auto-renewal

#### 4. Test Expiration
- Select transaction
- Click **Expire**
- Tests what happens when subscription ends

#### 5. Fast-Forward Time
- Tools → Time Travel
- Advance days/months
- Test trial expiration, renewals, etc.

#### 6. Test Refund
- Select transaction
- Click **Refund**
- Tests refund handling

## Testing Scenarios

### Scenario 1: First-Time User

**Steps:**
1. Fresh install app
2. Should see paywall or premium button
3. Tap subscription option
4. Complete purchase
5. Verify: Features unlock
6. Close and reopen app
7. Verify: Still subscribed

**Expected:** Smooth purchase flow, features unlock, status persists

### Scenario 2: Free Trial User

**Steps:**
1. Fresh install
2. Subscribe with free trial
3. Verify: Shows "Free Trial" status
4. Use Transaction Manager to expire trial
5. Verify: Prompts to subscribe

**Expected:** Trial works, then prompts for paid subscription

### Scenario 3: Restore Purchases

**Steps:**
1. Subscribe to premium
2. Delete app
3. Reinstall app
4. Tap "Restore Purchases"
5. Verify: Subscription restored

**Expected:** Previous purchase restored without new payment

### Scenario 4: Subscription Expiration

**Steps:**
1. Subscribe
2. Use Transaction Manager → Expire
3. Verify: Returns to free tier
4. Verify: Can re-subscribe

**Expected:** Graceful handling of expired subscription

### Scenario 5: Cancel Purchase

**Steps:**
1. Tap subscribe
2. Cancel dialog
3. Verify: No errors
4. Verify: Still on free tier
5. Verify: Can try again

**Expected:** No crash, can retry

## Common Testing Issues & Solutions

### Issue: Products Don't Load

**Symptoms:** Paywall shows "Loading..." or no products

**Solutions:**
1. Verify product IDs in StoreManager match StoreKit config:
   - `com.reallifehq.monthly`
   - `com.reallifehq.yearly`
2. Clean build folder (Shift+Cmd+K)
3. Restart Xcode
4. Check StoreKit config is selected in scheme
5. Check console for errors

### Issue: Purchase Doesn't Complete

**Symptoms:** Tap subscribe, nothing happens

**Solutions:**
1. Check console for errors
2. Verify In-App Purchase capability is added:
   - Project → Target → Signing & Capabilities → + Capability → In-App Purchase
3. Make sure you're not already subscribed
4. Clear transactions in Transaction Manager
5. Try different product (monthly vs yearly)

### Issue: Features Don't Unlock

**Symptoms:** Purchase succeeds but content still locked

**Solutions:**
1. Check `isSubscribed` state in StoreManager
2. Verify `updateSubscriptionStatus()` is called
3. Add logging to track subscription status
4. Check if UI is observing StoreManager correctly

### Issue: "Cannot Connect to App Store"

**Symptoms:** Error when testing on device

**Solutions:**
1. **Using Sandbox?** Make sure signed into sandbox account
2. **Using StoreKit Config?** Check it's selected in scheme
3. Check internet connection
4. Sign out and back in to test account

### Issue: Restore Doesn't Work

**Symptoms:** Restore button does nothing

**Solutions:**
1. Make sure there's a purchase to restore
2. Check you're using same sandbox account
3. Call `StoreManager.shared.restorePurchases()` is implemented
4. Verify transactions exist in Transaction Manager

## Testing on Physical Device vs Simulator

### Simulator Testing
**Pros:**
- ✅ Fast and easy
- ✅ Works with StoreKit Configuration
- ✅ No Apple ID needed
- ✅ Great for UI testing

**Cons:**
- ❌ Can't test real App Store flow
- ❌ Can't test biometric purchase confirmation
- ❌ May have different performance

**Best For:** Rapid development and UI testing

### Physical Device Testing
**Pros:**
- ✅ More realistic
- ✅ Tests actual purchase flow
- ✅ Better performance testing
- ✅ Face ID/Touch ID works

**Cons:**
- ❌ Requires sandbox account
- ❌ Slightly slower to test
- ❌ Need to manage test accounts

**Best For:** Final testing before release

## Monitoring & Debugging

### Check Console Logs

Your StoreManager includes helpful logging:

```
🔄 Loading products with IDs: [com.reallifehq.monthly, com.reallifehq.yearly]
📦 Found 2 products
  - com.reallifehq.monthly: Monthly Premium - $9.99
  - com.reallifehq.yearly: Yearly Premium - $99.99
```

**Look for:**
- Product loading messages
- Purchase success/failure
- Transaction verification
- Subscription status updates

### Add Breakpoints

Set breakpoints in:
- `StoreManager.purchase(_:)` - Track purchase flow
- `updateSubscriptionStatus()` - Track status changes
- `checkVerified(_:)` - Track verification

### Print Subscription Status

Add temporary button to print status:
```swift
Button("Debug Status") {
    print("Subscribed: \(StoreManager.shared.isSubscribed)")
    print("Status: \(StoreManager.shared.subscriptionStatus)")
}
```

## Pre-Release Checklist

Before submitting to App Store:

### StoreKit Configuration
- [ ] Product IDs match App Store Connect exactly
- [ ] Pricing is correct
- [ ] Free trial duration is correct
- [ ] Subscription groups are set up

### Code
- [ ] Remove test/debug code
- [ ] Verify product IDs are correct
- [ ] Error handling is complete
- [ ] Loading states work properly
- [ ] Restore purchases is accessible

### Testing
- [ ] Tested in sandbox thoroughly
- [ ] Tested on multiple devices
- [ ] Tested in TestFlight
- [ ] Beta testers confirmed it works
- [ ] All scenarios tested (purchase, restore, cancel, expire)

### App Store Connect
- [ ] Paid Applications Agreement signed
- [ ] Banking info added
- [ ] Tax forms completed
- [ ] Subscriptions created and match code
- [ ] Subscription submitted for review
- [ ] Screenshots show subscription features
- [ ] App description mentions subscription

## Quick Reference Commands

### Clear All Test Purchases
```
Debug → StoreKit → Manage Transactions → Delete All
```

### Reset Subscription Eligibility
```
Debug → StoreKit → Reset Eligibility
```

### Enable StoreKit Messages
```
Debug → StoreKit → Enable StoreKit Messages
```

### View StoreKit Logs
```
Console app → Filter: "StoreKit"
```

## Next Steps

1. **Start with StoreKit Configuration** (5 minutes)
2. **Test basic purchase flow** (10 minutes)
3. **Test all scenarios** (30 minutes)
4. **Test on physical device** (15 minutes)
5. **Set up sandbox account** (when ready)
6. **TestFlight beta testing** (before release)

## Resources

- **StoreKit Docs**: https://developer.apple.com/storekit/
- **Testing Guide**: https://developer.apple.com/documentation/storekit/in-app_purchase/testing_in-app_purchases
- **Transaction Manager**: https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode
- **Sandbox Testing**: https://developer.apple.com/apple-pay/sandbox-testing/

## Need Help?

Common questions:

**Q: Do I need App Store Connect to test?**
A: No! Use StoreKit Configuration file for testing

**Q: Will I be charged?**
A: No! Test purchases are always free

**Q: How do I reset test state?**
A: Use Transaction Manager → Delete All

**Q: Can I test on simulator?**
A: Yes! Works great with StoreKit Configuration

**Q: How do I test free trial?**
A: Add introductory offer in StoreKit config

---

**You're ready to test!** Start with the Quick Start method and work your way through the testing checklist. Good luck! 🚀
