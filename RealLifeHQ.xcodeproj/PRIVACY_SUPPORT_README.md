# Privacy Policy & Support Documentation

This directory contains the Privacy Policy and Support documentation for RealLifeHQ in both SwiftUI (for the iOS app) and HTML (for web/GitHub hosting) formats.

## Files Created

### iOS App (SwiftUI)
- **PrivacyPolicyView.swift** - Privacy Policy view for the iOS app
- **SupportView.swift** - Support & Help view for the iOS app

### Web/GitHub (HTML)
- **privacy-policy.html** - Privacy Policy page for hosting on GitHub Pages or your website
- **support.html** - Support page for hosting on GitHub Pages or your website

## Integration with iOS App

### 1. Add Files to Xcode
The SwiftUI files (`PrivacyPolicyView.swift` and `SupportView.swift`) are ready to use in your Xcode project:

1. Make sure both files are added to your Xcode target
2. The SettingsView.swift has been updated to include links to both views
3. Users can access them via: Settings → Privacy Policy / Support & Help

### 2. Navigation Flow
```
Settings
  └─ Legal
      ├─ Privacy Policy → PrivacyPolicyView
      └─ Support & Help → SupportView
```

## Hosting HTML Files on GitHub

### Option 1: GitHub Pages (Recommended)

1. **Create a docs folder in your repository:**
   ```bash
   mkdir docs
   mv privacy-policy.html docs/
   mv support.html docs/
   ```

2. **Enable GitHub Pages:**
   - Go to your repository on GitHub
   - Settings → Pages
   - Source: Deploy from a branch
   - Branch: main (or master) → /docs
   - Save

3. **Access your pages:**
   - Privacy: `https://yourusername.github.io/yourrepo/privacy-policy.html`
   - Support: `https://yourusername.github.io/yourrepo/support.html`

### Option 2: Root Directory Hosting

1. **Place HTML files in repository root:**
   ```bash
   # Files are already in root
   git add privacy-policy.html support.html
   git commit -m "Add privacy policy and support pages"
   git push
   ```

2. **Enable GitHub Pages:**
   - Settings → Pages
   - Source: Deploy from a branch
   - Branch: main → / (root)
   - Save

3. **Access your pages:**
   - Privacy: `https://yourusername.github.io/yourrepo/privacy-policy.html`
   - Support: `https://yourusername.github.io/yourrepo/support.html`

## Customization

### Update Contact Information

**In iOS App (both Swift files):**
- Search for: `support@reallifehq.app`
- Replace with your actual email

**In HTML files:**
- Search for: `support@reallifehq.app`
- Replace with your actual email
- Update website URLs: `www.reallifehq.app` → your actual domain

### Update Colors (HTML only)

The HTML files use these primary colors:
- Primary Green: `#10b981` (Emerald)
- Secondary Purple: `#8b5cf6` (Violet)
- Accent Orange: `#f59e0b` (Amber)

To change colors, find and replace these hex codes in the `<style>` section.

### Update App Store Links

Replace placeholder links:
- `https://apps.apple.com/app/reallifehq` → Your actual App Store URL
- `https://www.reallifehq.app` → Your actual website URL

## App Store Requirements

For App Store submission, you'll need to provide:

1. **Privacy Policy URL:**
   - Use your GitHub Pages URL: `https://yourusername.github.io/yourrepo/privacy-policy.html`
   - Or host on your own domain

2. **Support URL:**
   - Use your GitHub Pages URL: `https://yourusername.github.io/yourrepo/support.html`
   - Or host on your own domain

Add these URLs in App Store Connect:
- App Information → Privacy Policy URL
- App Information → Support URL

## Testing

### Test iOS Views
```swift
// Preview in Xcode
#Preview {
    NavigationView {
        PrivacyPolicyView()
            .environmentObject(ThemeManager())
    }
}
```

### Test HTML Pages
1. Open HTML files in any web browser
2. Check all links work correctly
3. Verify responsive design on mobile devices
4. Test email links (`mailto:` links)

## Updates and Maintenance

### When to Update

Update both files when:
- Adding new features that collect data
- Changing data handling practices
- Adding new third-party integrations
- Changing support contact information
- Updating app version numbers

### Update Checklist

- [ ] Update "Last Updated" date in Privacy Policy
- [ ] Update version number in Support page
- [ ] Update iOS Swift files
- [ ] Update HTML files
- [ ] Commit and push to GitHub
- [ ] Update URLs in App Store Connect (if changed)
- [ ] Notify users of significant privacy changes

## Legal Compliance

The privacy policy includes sections for:
- ✅ GDPR (European Union)
- ✅ CCPA (California)
- ✅ COPPA (Children's privacy)
- ✅ Data collection transparency
- ✅ User rights and choices
- ✅ Third-party service disclosures

**Note:** While this privacy policy is comprehensive, you should have it reviewed by a legal professional before submitting to the App Store, especially if you operate a business or collect any personal data.

## Support Email Setup

Make sure your support email is active:
1. Create email: `support@yourdomain.com`
2. Set up auto-responder acknowledging receipt
3. Commit to 48-hour response time (as stated in policy)
4. Monitor regularly for support requests

## Additional Resources

- [Apple App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Apple Privacy Policy Requirements](https://developer.apple.com/app-store/review/guidelines/#privacy)
- [GDPR Compliance Guide](https://gdpr.eu/)
- [CCPA Compliance Guide](https://oag.ca.gov/privacy/ccpa)

## Questions?

If you need help with these files:
1. Check that files are properly added to your Xcode target
2. Verify all placeholder text has been replaced
3. Test email links and navigation
4. Ensure GitHub Pages is properly configured

---

**Last Updated:** February 14, 2026
**Version:** 1.0.0
