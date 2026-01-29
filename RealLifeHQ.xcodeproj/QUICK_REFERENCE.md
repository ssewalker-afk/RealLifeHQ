# 🎯 QUICK REFERENCE - Your Base44 App

## ✅ YOUR URL IS CONFIGURED

**Base44 Website:** `https://reallifehq-6410e686.base44.app`

This URL is now hardcoded into your iOS app!

---

## 🚀 BUILD & RUN NOW

```
⇧⌘K  - Clean Build
⌘B   - Build Project
⌘R   - Run in Simulator
```

---

## 📱 WHAT HAPPENS WHEN YOU RUN

### 1. App Opens → Paywall Screen
- Shows "Welcome to RealLifeHQ"
- Lists premium features
- Big "Try 7 Days Free" button

### 2. Tap "Try 7 Days Free" → Subscription View
- Shows Monthly ($9.99) and Yearly ($99.99) options
- 7-day free trial on both
- Beautiful gradient design

### 3. Complete Purchase → Your Website Loads
- Full Base44 website appears
- Can navigate all pages
- Green checkmark in toolbar
- Native iOS experience

---

## ⚠️ BEFORE TESTING PURCHASES

Create StoreKit config file (one-time setup):

1. File → New → File
2. Search "storekit"
3. Name: `Products.storekit`
4. Add products:
   - Monthly: `com.reallifehq.monthly` - $9.99
   - Yearly: `com.reallifehq.yearly` - $99.99
5. Add 7-day free trial to both
6. Edit Scheme → Run → Options → Select config

---

## 📁 PROJECT FILES

```
WebView.swift           ← Your Base44 URL is here
WebContentView.swift    ← Paywall + Website display
SubscriptionView.swift  ← Subscription purchase UI
StoreManager.swift      ← StoreKit logic
RealLifeHQApp.swift     ← App entry point
```

---

## 🔧 QUICK CHANGES

**Change website URL:**
Edit `WebView.swift` line 61:
```swift
static let websiteURL = "https://your-new-url.com"
```

**Remove paywall (free app):**
Edit `RealLifeHQApp.swift`:
```swift
WindowGroup {
    NavigationStack {
        WebView(
            url: URL(string: AppConfiguration.websiteURL)!,
            isLoading: .constant(false)
        )
    }
}
```

**Change app name in toolbar:**
Edit `WebContentView.swift` line 55:
```swift
.navigationTitle("Your App Name")
```

---

## 📋 TESTING CHECKLIST

- [ ] App builds (⌘B)
- [ ] App runs (⌘R)
- [ ] Paywall appears
- [ ] StoreKit config created
- [ ] Products load in subscription view
- [ ] Can complete test purchase
- [ ] Website loads after purchase
- [ ] All website pages work
- [ ] Navigation works

---

## 🌐 YOUR URLS

| Type | URL |
|------|-----|
| Main Site | https://reallifehq-6410e686.base44.app |
| Privacy | https://reallifehq-6410e686.base44.app/privacy |
| Terms | https://reallifehq-6410e686.base44.app/terms |
| Support | support@reallifehq.com |

Make sure these pages exist on your Base44 site!

---

## 🆘 TROUBLESHOOTING

**Build error?**
→ Check all files are added to target (File Inspector)

**Website blank?**
→ Verify URL works in Safari first

**Products don't load?**
→ Create StoreKit configuration file

**Subscription doesn't work?**
→ Debug → StoreKit → Manage Transactions → Reset

---

## 📤 READY FOR APP STORE?

1. Archive: Product → Archive
2. Validate App
3. Distribute → App Store Connect
4. Upload
5. Go to appstoreconnect.apple.com
6. Wait for build to appear in TestFlight

---

## 📖 MORE INFO

- `YOUR_APP_IS_READY.md` - Complete guide
- `BASE44_INTEGRATION.md` - Web integration details
- `STOREKIT_SETUP_GUIDE.md` - Subscription setup

---

**Ready to test? Press ⌘R and see your Base44 site in the app! 🚀**
