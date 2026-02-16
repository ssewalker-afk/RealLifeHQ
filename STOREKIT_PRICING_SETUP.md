# StoreKit Configuration for RealLifeHQ - Updated Pricing

## 📱 Subscription Pricing
- **Monthly:** $1.99/month with 7-day free trial
- **Yearly:** $19.99/year with 7-day free trial (Save 17%)

## 🛠️ Setting Up StoreKit Configuration File

### Step 1: Create StoreKit Configuration File in Xcode

1. **In Xcode**, go to File → New → File
2. Search for "StoreKit Configuration File"
3. Name it: `RealLifeHQ.storekit`
4. Save it in your project

### Step 2: Add Subscription Products

Click the **"+"** button at the bottom left and select **"Add Auto-Renewable Subscription"**

#### Product 1: Monthly Subscription
```
Product ID: com.reallifehq.monthly
Reference Name: RealLife HQ Monthly
Type: Auto-Renewable Subscription
Price: $1.99 USD
Subscription Duration: 1 Month
Subscription Group: RealLifeHQ Subscriptions

Introductory Offer:
- Type: Free Trial
- Duration: 7 Days
- Eligible: New Subscribers
```

#### Product 2: Yearly Subscription  
```
Product ID: com.reallifehq.yearly
Reference Name: RealLife HQ Yearly
Type: Auto-Renewable Subscription
Price: $19.99 USD
Subscription Duration: 1 Year
Subscription Group: RealLifeHQ Subscriptions

Introductory Offer:
- Type: Free Trial
- Duration: 7 Days
- Eligible: New Subscribers
```

### Step 3: Configure Subscription Group

1. Click on "Subscription Group"
2. Name: `RealLifeHQ Subscriptions`
3. Ensure both subscriptions are in the same group
4. Set upgrade/downgrade rules:
   - Monthly → Yearly: Upgrade (immediate)
   - Yearly → Monthly: Downgrade (at end of period)

### Step 4: Select Configuration File in Scheme

1. **Product** → **Scheme** → **Edit Scheme**
2. Select **Run** in the left sidebar
3. Under **Options** tab
4. Find **"StoreKit Configuration"**
5. Select: `RealLifeHQ.storekit`

### Step 5: Test in Simulator

1. Run the app in Simulator
2. You should see the subscription screen with:
   - 7-day free trial message
   - $1.99/month option
   - $19.99/year option with "Save 17%" badge

3. **Debug Menu in Simulator:**
   - **Xcode** → **Debug** → **StoreKit** → **Manage Transactions**
   - Here you can:
     - View active subscriptions
     - Expire subscriptions
     - Refund purchases
     - Clear purchases

## 📝 App Store Connect Setup

### Creating Subscriptions in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to **Features** → **In-App Purchases**
4. Create a **Subscription Group**: "RealLifeHQ Subscriptions"

#### Monthly Subscription
```
Product ID: com.reallifehq.monthly
Reference Name: RealLife HQ Monthly
Subscription Duration: 1 Month
Price: $1.99 USD (Tier 4)

Introductory Offer:
- Type: Free
- Duration: 7 Days
- Offer Eligibility: New Subscribers

Localized Information:
Display Name: Monthly
Description: Full access to RealLifeHQ with all features
```

#### Yearly Subscription
```
Product ID: com.reallifehq.yearly
Reference Name: RealLife HQ Yearly
Subscription Duration: 1 Year
Price: $19.99 USD (Tier 19)

Introductory Offer:
- Type: Free
- Duration: 7 Days
- Offer Eligibility: New Subscribers

Localized Information:
Display Name: Annual (Best Value)
Description: Full access to RealLifeHQ with all features - Save 17%
```

### Subscription Group Settings

**App Name:** RealLifeHQ
**Group Display Name:** RealLifeHQ Premium

**Localized Description:**
```
Get full access to all RealLifeHQ features:
• Smart Calendar with sync
• Habit Tracker with streaks
• Daily Journal with prompts
• Budget Tracker
• Secure Vault with encryption
• Life Reminder Wizard
• Cloud sync across devices

Try free for 7 days, then $1.99/month or $19.99/year.
Cancel anytime.
```

## 🧪 Testing Scenarios

### Scenario 1: New User
1. Open app → See paywall
2. Select Monthly or Yearly
3. Tap "Start 7-Day Free Trial"
4. Should show StoreKit payment sheet
5. Confirm (test mode = no charge)
6. Should enter app

### Scenario 2: Expired Trial
1. In Simulator: **Debug** → **StoreKit** → **Manage Transactions**
2. Find your subscription
3. Click **Expire Subscription**
4. App should show paywall again

### Scenario 3: Restore Purchase
1. Delete app
2. Reinstall
3. Tap "Restore Purchases"
4. Should recognize existing subscription
5. Should enter app

### Scenario 4: Upgrade/Downgrade
1. Subscribe to Monthly
2. Try to select Yearly
3. Should handle upgrade properly

## 🔒 Sandbox Testing (Real Device)

### Create Sandbox Tester Account

1. **App Store Connect** → **Users and Access** → **Sandbox Testers**
2. Click **"+"** to add tester
3. Use a **new email** (can't be used for real Apple ID)
   - Example: `test.reallifehq@gmail.com`
4. Set region to your target market
5. Save tester

### Test on Real Device

1. **On your iPhone:**
   - Settings → App Store
   - Scroll down to **"Sandbox Account"**
   - Sign out if needed
   
2. **Run your app** from Xcode
3. When prompted to purchase, **sign in with sandbox tester**
4. Complete purchase (test mode - no real charge)
5. Verify subscription works

**Important:** Never sign into sandbox account in Settings → Apple ID! Only in App Store section.

## 💰 Pricing Tiers Reference

For App Store Connect:

| Price | Tier | Monthly | Yearly Equivalent |
|-------|------|---------|-------------------|
| $0.99 | 1    | $0.99   | $11.88           |
| $1.99 | 4    | $1.99   | $23.88           |
| $2.99 | 5    | $2.99   | $35.88           |
| $4.99 | 8    | $4.99   | $59.88           |
| $9.99 | 13   | $9.99   | $119.88          |
| $19.99| 19   | $19.99  | $239.88          |

**Your Pricing:**
- Monthly: Tier 4 ($1.99)
- Yearly: Tier 19 ($19.99)
- Savings: $4.89/year (17% off)

## 📊 Savings Calculation

Monthly price × 12 = $1.99 × 12 = $23.88
Yearly price = $19.99
Savings = $23.88 - $19.99 = $3.89

Percentage savings: ($3.89 / $23.88) × 100 = **16.3%** (rounded to 17%)

## ✅ Verification Checklist

Before submitting to App Store:

- [ ] StoreKit configuration file created with correct product IDs
- [ ] Both subscriptions added with correct prices
- [ ] 7-day free trial configured on both
- [ ] Subscription group created
- [ ] Tested in Simulator successfully
- [ ] Tested with Sandbox account on real device
- [ ] Paywall shows correct pricing
- [ ] "Save 17%" badge shows on yearly
- [ ] Free trial text displays correctly
- [ ] Restore purchases works
- [ ] Products created in App Store Connect
- [ ] Same product IDs in code and App Store Connect
- [ ] Subscription group configured in App Store Connect
- [ ] App Store metadata includes subscription pricing

## 🚨 Common Issues

### Issue: "Cannot connect to App Store"
**Solution:** Make sure StoreKit configuration file is selected in scheme

### Issue: Products not loading
**Solution:** 
1. Check product IDs match exactly in StoreManager.swift
2. Verify StoreKit configuration file is in scheme
3. Try clean build (Cmd+Shift+K)

### Issue: "Invalid Product ID" in Production
**Solution:**
1. Ensure products are "Ready to Submit" in App Store Connect
2. Product IDs must match exactly
3. Wait 2-4 hours after creating products

### Issue: Free trial not showing
**Solution:**
1. Verify introductory offer is configured
2. Check offer is enabled in both StoreKit file and App Store Connect
3. Must be "New Subscribers" eligible

## 📞 Support

If you encounter issues:
1. Check Xcode console for error messages
2. Verify product IDs in StoreManager.swift match StoreKit configuration
3. Try "Debug → StoreKit → Manage Transactions" in Simulator

## 🔗 Useful Links

- [StoreKit Testing Guide](https://developer.apple.com/documentation/storekit/testing)
- [App Store Connect](https://appstoreconnect.apple.com)
- [Subscription Best Practices](https://developer.apple.com/app-store/subscriptions/)

---

**Last Updated:** February 14, 2026  
**Pricing:** $1.99/month, $19.99/year  
**Free Trial:** 7 days
