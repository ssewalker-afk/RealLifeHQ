# StoreKit Subscription Setup Guide

## What I've Created For You

I've set up a complete StoreKit subscription system with:

1. **StoreManager.swift** - Handles all StoreKit operations
2. **SubscriptionView.swift** - Beautiful subscription UI with monthly and yearly options
3. **Updated ContentView.swift** - Shows different content based on subscription status

## Next Steps to Complete Setup

### Step 1: Create StoreKit Configuration File (For Testing)

This allows you to test In-App Purchases without setting up App Store Connect first.

1. In Xcode, go to **File > New > File**
2. Search for "StoreKit Configuration File"
3. Name it `Products.storekit`
4. Click **Create**

### Step 2: Add Products to StoreKit Configuration

Once the file is created, add your subscription products:

1. Click the **+** button at the bottom of the editor
2. Select **Add Auto-Renewable Subscription**
3. Create a **Subscription Group** called "Premium Subscription"

#### Add Monthly Subscription:
- **Reference Name**: Monthly Subscription
- **Product ID**: `com.reallifehq.monthly`
- **Price**: $9.99 (or your preferred price)
- **Subscription Duration**: 1 month

#### Add Introductory Offer (Free Trial):
1. Click on the monthly subscription
2. In the inspector, find **Introductory Offers**
3. Click **+** to add an offer
4. Select **Free Trial**
5. Set duration to **7 days**

#### Add Yearly Subscription:
- **Reference Name**: Yearly Subscription
- **Product ID**: `com.reallifehq.yearly`
- **Price**: $99.99 (or your preferred price)
- **Subscription Duration**: 1 year

#### Add Introductory Offer (Free Trial) to Yearly:
1. Same process as monthly
2. Set to **7 days free trial**

### Step 3: Configure Your Xcode Project

1. Select your project in the Project Navigator
2. Select your app target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add **In-App Purchase**

### Step 4: Set Active StoreKit Configuration

1. Click on your scheme (next to the device selector)
2. Select **Edit Scheme...**
3. Go to **Run > Options**
4. Under **StoreKit Configuration**, select `Products.storekit`

### Step 5: Update Product IDs in StoreManager.swift

Make sure the product IDs in `StoreManager.swift` match what you created:

```swift
private let monthlySubscriptionID = "com.reallifehq.monthly"
private let yearlySubscriptionID = "com.reallifehq.yearly"
```

Replace `com.reallifehq` with your actual bundle identifier if different.

### Step 6: Test the App

1. Build and run your app in the simulator or on a device
2. Click the "Unlock Premium Features" button
3. The subscription view should appear
4. Select a subscription plan
5. Click "Start Free Trial"
6. Complete the test purchase

**Note**: When testing with StoreKit Configuration File:
- No real money is charged
- You can test various scenarios (successful purchase, cancellation, etc.)
- Use Xcode's **Debug > StoreKit > Manage Transactions** to reset test data

### Step 7: Testing Different Scenarios

Use Xcode's Transaction Manager to test:

1. **Successful Purchase**: Complete a normal purchase flow
2. **Restore Purchases**: Delete and reinstall the app, then tap "Restore Purchases"
3. **Subscription Expiry**: Fast-forward time in Transaction Manager
4. **Free Trial**: Verify the 7-day trial works correctly

Access Transaction Manager:
- **Debug > StoreKit > Manage Transactions...**

## For Production (App Store Connect Setup)

When ready to publish to the App Store:

### Step 1: Set Up Agreements
1. Go to App Store Connect
2. Complete the **Paid Applications Agreement**
3. Set up your **banking and tax information**

### Step 2: Create Subscription Group
1. Go to your app in App Store Connect
2. Select **Subscriptions**
3. Click **+** next to **Subscription Groups**
4. Name it "Premium Subscription"

### Step 3: Create Subscriptions
Create both monthly and yearly subscriptions with:
- The same Product IDs you used in testing
- Pricing for all territories
- Subscription duration
- Free trial (7 days) as introductory offer

### Step 4: Add App Metadata
- Screenshots showing premium features
- Description of what users get
- Privacy information

### Step 5: Submit for Review
- Test thoroughly with TestFlight
- Submit your subscription for review (separate from app review)
- Once approved, you can release your app

## Product ID Naming Convention

Your product IDs should follow this pattern:
```
[bundle-identifier].[product-type]
```

Examples:
- `com.reallifehq.monthly` (monthly subscription)
- `com.reallifehq.yearly` (yearly subscription)

## Features Included

### StoreManager Features:
- ✅ Automatic product loading
- ✅ Purchase handling
- ✅ Transaction verification
- ✅ Subscription status tracking
- ✅ Restore purchases
- ✅ Free trial detection
- ✅ Automatic transaction listener

### SubscriptionView Features:
- ✅ Beautiful gradient design
- ✅ Feature highlights
- ✅ Monthly and yearly options
- ✅ "Best Value" badge for yearly
- ✅ Clear pricing display
- ✅ Free trial messaging
- ✅ Loading states
- ✅ Error handling
- ✅ Restore purchases button
- ✅ Terms and conditions text

### ContentView Features:
- ✅ Subscription status badge
- ✅ Different UI for free vs. premium users
- ✅ Call-to-action for non-subscribers
- ✅ Premium button in toolbar
- ✅ Locked/unlocked feature indicators

## Customization

### Change Pricing
Update in your StoreKit configuration file or App Store Connect.

### Change Trial Duration
- In StoreKit config: Edit the introductory offer
- In App Store Connect: Edit the subscription's introductory offer

### Change Feature Names
Edit the feature descriptions in `SubscriptionView.swift`:
```swift
FeatureRow(icon: "checkmark.circle.fill", 
          title: "Your Feature Name", 
          description: "Your description")
```

### Change Colors/Design
All views use SwiftUI standard styling. Customize:
- Gradient colors in `SubscriptionView`
- Button colors
- Icon colors
- Material effects

## Testing Checklist

- [ ] Products load correctly
- [ ] Monthly subscription can be purchased
- [ ] Yearly subscription can be purchased
- [ ] Free trial is offered
- [ ] Subscription status updates after purchase
- [ ] Premium content unlocks after purchase
- [ ] Restore purchases works
- [ ] Error messages display correctly
- [ ] UI updates when subscription expires
- [ ] Multiple purchases are prevented

## Common Issues

### Products Don't Load
- Verify product IDs match exactly
- Check StoreKit configuration is selected in scheme
- Restart Xcode and clean build folder

### Purchase Doesn't Complete
- Check for errors in console
- Verify In-App Purchase capability is added
- Make sure you're not already subscribed in tests

### Subscription Status Not Updating
- Check the transaction listener is running
- Verify `updateSubscriptionStatus()` is called after purchase
- Look for verification errors in console

## Additional Resources

- [StoreKit Documentation](https://developer.apple.com/documentation/storekit)
- [Testing In-App Purchases](https://developer.apple.com/documentation/storekit/in-app_purchase/testing_in-app_purchases_with_sandbox)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)

## Support

If you run into issues:
1. Check the Xcode console for error messages
2. Use Transaction Manager to inspect purchase state
3. Verify all product IDs match
4. Make sure StoreKit configuration is properly set up

Good luck with your subscription implementation! 🎉
