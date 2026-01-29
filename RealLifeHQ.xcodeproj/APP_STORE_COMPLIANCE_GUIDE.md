# App Store Privacy & Legal Compliance Guide

## Overview

This guide helps you implement the Privacy Policy and Terms of Service for RealLifeHQ to meet Apple App Store requirements.

## Required Actions Before Submission

### 1. Host Your Privacy Policy Online

Apple requires a publicly accessible URL for your Privacy Policy.

#### Options:

**A. GitHub Pages (Free)**
1. Create a new repository (e.g., `reallifehq-privacy`)
2. Upload `PRIVACY_POLICY.md` 
3. Enable GitHub Pages in repository Settings
4. Your URL will be: `https://[username].github.io/reallifehq-privacy/`

**B. Your Own Website**
1. Create a dedicated page on your website
2. URL example: `https://yourwebsite.com/privacy-policy`

**C. Privacy Policy Hosting Services**
- iubenda.com
- termly.io
- freeprivacypolicy.com

### 2. Update Contact Information

**In BOTH documents, replace these placeholders:**
- `[Your Support Email]` → Your actual support email
- `[Your Website]` → Your website URL
- `[Your Jurisdiction]` → Your legal jurisdiction (e.g., "the State of California")

Example:
```markdown
**Email**: support@reallifehq.com  
**Website**: https://www.reallifehq.com
```

### 3. Update App Links in SettingsView.swift

Replace the placeholder URLs in `SettingsView.swift`:

```swift
Link(destination: URL(string: "https://yourwebsite.com/privacy-policy")!) {
    HStack {
        Text("Privacy Policy")
        Spacer()
        Image(systemName: "arrow.up.right")
            .font(.caption)
    }
}

Link(destination: URL(string: "https://yourwebsite.com/terms-of-service")!) {
    HStack {
        Text("Terms of Service")
        Spacer()
        Image(systemName: "arrow.up.right")
            .font(.caption)
    }
}
```

### 4. Update MoreView.swift

Similarly update the Privacy Policy link in `MoreView.swift`:

```swift
Link(destination: URL(string: "https://yourwebsite.com/privacy-policy")!) {
    HStack {
        Text("Privacy Policy")
        Spacer()
        Image(systemName: "arrow.up.right")
            .font(.caption)
    }
}
```

## App Store Connect Configuration

### App Privacy Section

When filling out "App Privacy" in App Store Connect, declare:

#### Data Not Collected
Select "No, we do not collect data from this app" for all categories since all data stays on device.

#### Data Types to Mark as "Not Collected":
- ✅ Contact Info
- ✅ Health & Fitness  
- ✅ Financial Info
- ✅ Location
- ✅ Sensitive Info
- ✅ Contacts
- ✅ User Content
- ✅ Browsing History
- ✅ Search History
- ✅ Identifiers
- ✅ Purchases
- ✅ Usage Data
- ✅ Diagnostics
- ✅ Other Data

### Privacy Policy URL

In App Store Connect → App Information → General Information:
- Enter your hosted Privacy Policy URL
- This is **required** for App Store submission

### App Description

Consider adding to your App Store description:
```
🔒 Privacy First
Your data stays on your device. We don't collect, transmit, or share any of your personal information. What you create is yours alone.
```

## Required Permissions in Info.plist

Add descriptions for the permissions your app uses:

### NSUserNotificationsUsageDescription
```xml
<key>NSUserNotificationsUsageDescription</key>
<string>RealLifeHQ uses notifications to remind you of upcoming calendar events. All notifications are scheduled locally on your device.</string>
```

### NSPhotoLibraryUsageDescription
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>RealLifeHQ needs access to your photo library to attach photos to Vault items. Photos are stored securely on your device and never transmitted.</string>
```

### NSFaceIDUsageDescription
```xml
<key>NSFaceIDUsageDescription</key>
<string>RealLifeHQ uses Face ID to provide secure access to your Vault. Biometric data is processed by iOS and never accessed by the app.</string>
```

## Marketing & Communication

### App Store Screenshots

Consider adding privacy badges to screenshots:
- "Private & Secure"
- "No Data Collection"
- "Offline First"

### Website Copy

If you have a website, ensure it mentions:
- Privacy-first design
- Local-only data storage
- No tracking or analytics
- Apple platform exclusive

## Legal Considerations

### Professional Review (Recommended)

Consider having a lawyer review if:
- You plan to monetize significantly
- You expand to collect data in the future
- You operate in multiple jurisdictions with strict laws (EU, California, etc.)

### GDPR Compliance

The current privacy policy addresses GDPR because:
- No data leaves the device = minimal GDPR concerns
- Users have complete control over their data
- Right to deletion is easily exercised

### CCPA Compliance

The policy addresses CCPA requirements for California users:
- Transparent about data practices (none collected)
- Clear rights enumeration
- Easy data deletion

### Children's Privacy (COPPA)

The app is COPPA-compliant because:
- No data collection = no children's data concerns
- Can safely be rated 4+ in App Store

## Version Control

### When to Update Privacy Policy

Update the policy when:
- Adding new features that use device permissions
- Integrating third-party services
- Adding analytics or tracking
- Implementing cloud sync
- Adding social features

### Version History

Keep a record of policy changes:
```markdown
## Version History

### Version 1.1 - [Date]
- Added support for cloud sync
- Updated data collection information

### Version 1.0 - January 25, 2026
- Initial privacy policy
```

### Notify Users

When making material changes:
1. Update the "Last Updated" date
2. Show an in-app alert on first launch after update
3. Require users to acknowledge changes for significant updates

## Testing Checklist

Before submission, verify:

- [ ] Privacy Policy is hosted and publicly accessible
- [ ] Terms of Service is hosted (optional but recommended)
- [ ] All placeholder text is replaced with actual information
- [ ] In-app links work correctly
- [ ] App Store Connect privacy section is complete
- [ ] Info.plist has all required permission descriptions
- [ ] Privacy Policy URL is entered in App Store Connect
- [ ] Age rating is appropriate (4+ suggested)

## Common App Review Issues

### Issue: "Privacy Policy URL Not Working"
**Solution**: Ensure URL is HTTPS and doesn't require login

### Issue: "Missing Permission Description"
**Solution**: Add all NSXXXUsageDescription strings to Info.plist

### Issue: "Privacy Labels Don't Match Policy"
**Solution**: Ensure App Privacy section matches what privacy policy states

### Issue: "Data Collection Claims"
**Solution**: If truly no data collected, clearly state this in policy and labels

## Additional Resources

### Apple Documentation
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)
- [User Privacy and Data Use](https://developer.apple.com/app-store/user-privacy-and-data-use/)

### Privacy Regulations
- [GDPR Overview](https://gdpr.eu/)
- [CCPA Overview](https://oag.ca.gov/privacy/ccpa)
- [COPPA Overview](https://www.ftc.gov/legal-library/browse/rules/childrens-online-privacy-protection-rule-coppa)

## Support Email Setup

Create a dedicated support email:
- support@reallifehq.com
- hello@reallifehq.com
- privacy@reallifehq.com

Respond to inquiries within 48 hours as stated in the policy.

## Ongoing Compliance

### Annual Review
- Review privacy policy annually
- Update for new iOS features
- Ensure compliance with new regulations

### Monitor Changes
- Apple App Store guidelines
- Privacy regulations
- iOS permission requirements

### User Requests
Be prepared to handle:
- Data export requests (use your Export Data feature)
- Data deletion requests (user can delete or uninstall)
- Privacy questions (respond via support email)

## Quick Implementation Checklist

1. **TODAY**
   - [ ] Replace all placeholder text in policy documents
   - [ ] Set up support email
   - [ ] Create website/GitHub page for hosting

2. **THIS WEEK**
   - [ ] Host privacy policy online
   - [ ] Update in-app URLs
   - [ ] Add Info.plist descriptions
   - [ ] Test all links

3. **BEFORE SUBMISSION**
   - [ ] Complete App Privacy section in App Store Connect
   - [ ] Add Privacy Policy URL to App Store Connect
   - [ ] Review all documents one final time
   - [ ] Take screenshots showing privacy features

## Questions?

If you need help with:
- Specific legal requirements for your jurisdiction
- Monetization and privacy implications
- Third-party service integration
- Cloud features and data sync

Consider consulting:
- A tech-focused attorney
- Privacy compliance specialist
- App Store submission consultant

---

**Remember**: The provided privacy policy reflects your current app architecture (local-only storage). If you add cloud sync, analytics, or third-party services, you MUST update the privacy policy accordingly.

**Good luck with your App Store submission! 🚀**
