# App Store Submission Checklist

## Pre-Submission Checklist

Use this checklist before submitting RealLifeHQ to the App Store.

---

## 📄 Legal Documents

### Privacy Policy
- [ ] Privacy Policy is complete and accurate
- [ ] All placeholder text `[Your XXX]` has been replaced
- [ ] Contact email is set up and monitored
- [ ] Privacy Policy is hosted online at a public URL
- [ ] URL uses HTTPS (required by Apple)
- [ ] URL doesn't require login to view
- [ ] Privacy Policy covers all app features
- [ ] "Last Updated" date is current

**Privacy Policy URL:** _________________________

### Terms of Service (Optional but Recommended)
- [ ] Terms of Service is complete
- [ ] All placeholders are replaced
- [ ] Hosted online at public URL
- [ ] Linked from app (if applicable)

**Terms of Service URL:** _________________________

---

## 🔧 Code Updates

### Info.plist Permissions
Add these to your Info.plist file:

- [ ] **NSUserNotificationsUsageDescription**
  ```
  RealLifeHQ uses notifications to remind you of upcoming calendar events. All notifications are scheduled locally on your device.
  ```

- [ ] **NSPhotoLibraryUsageDescription**
  ```
  RealLifeHQ needs access to your photo library to attach photos to Vault items. Photos are stored securely on your device and never transmitted.
  ```

- [ ] **NSFaceIDUsageDescription**
  ```
  RealLifeHQ uses Face ID to provide secure access to your Vault. Biometric data is processed by iOS and never accessed by the app.
  ```

### In-App Links
Update these files with your actual URLs:

#### SettingsView.swift
- [ ] Privacy Policy URL updated
- [ ] Terms of Service URL updated (if applicable)
- [ ] URLs tested and working

#### MoreView.swift
- [ ] Privacy Policy URL updated
- [ ] Link tested and working

#### ContentView.swift (if applicable)
- [ ] Any privacy-related links updated

---

## 🏪 App Store Connect

### App Information
- [ ] App Name: RealLifeHQ (or your chosen name)
- [ ] Subtitle (if applicable)
- [ ] Privacy Policy URL entered
- [ ] App Description written
- [ ] Keywords selected
- [ ] Support URL entered
- [ ] Marketing URL entered (optional)
- [ ] Copyright information

### App Privacy Details

**Important:** Select "No" for ALL data collection since everything stays on device.

#### Contact Info
- [ ] Name: **No**
- [ ] Email Address: **No**
- [ ] Phone Number: **No**
- [ ] Physical Address: **No**
- [ ] Other User Contact Info: **No**

#### Health & Fitness
- [ ] Health: **No**
- [ ] Fitness: **No**

#### Financial Info
- [ ] Payment Info: **No**
- [ ] Credit Info: **No**
- [ ] Other Financial Info: **No**

#### Location
- [ ] Precise Location: **No**
- [ ] Coarse Location: **No**

#### Sensitive Info
- [ ] Sensitive Info: **No**

#### Contacts
- [ ] Contacts: **No**

#### User Content
- [ ] Emails or Text Messages: **No**
- [ ] Photos or Videos: **No**
- [ ] Audio Data: **No**
- [ ] Gameplay Content: **No**
- [ ] Customer Support: **No**
- [ ] Other User Content: **No**

#### Browsing History
- [ ] Browsing History: **No**

#### Search History
- [ ] Search History: **No**

#### Identifiers
- [ ] User ID: **No**
- [ ] Device ID: **No**

#### Purchases
- [ ] Purchase History: **No**

#### Usage Data
- [ ] Product Interaction: **No**
- [ ] Advertising Data: **No**
- [ ] Other Usage Data: **No**

#### Diagnostics
- [ ] Crash Data: **No**
- [ ] Performance Data: **No**
- [ ] Other Diagnostic Data: **No**

#### Other Data
- [ ] Other Data Types: **No**

### Pricing and Availability
- [ ] Price tier selected (or Free)
- [ ] Countries/regions selected
- [ ] Pre-order settings (if applicable)

### Age Rating
Recommended rating: **4+**

Complete the Age Rating Questionnaire:
- [ ] Violence: None
- [ ] Sexual Content: None
- [ ] Profanity: None
- [ ] Horror/Fear: None
- [ ] Mature/Suggestive Themes: None
- [ ] Alcohol, Tobacco, Drugs: None
- [ ] Gambling: None
- [ ] Medical/Treatment: None (habit tracking is not medical)
- [ ] Unrestricted Web Access: No
- [ ] Made for Kids: No (optional)

---

## 📱 App Binary

### Build Preparation
- [ ] Version number set (e.g., 1.0)
- [ ] Build number set (e.g., 1)
- [ ] All features tested
- [ ] No crashes or critical bugs
- [ ] Works on multiple device sizes (iPhone, iPad if applicable)
- [ ] Dark mode support checked
- [ ] Accessibility features tested
- [ ] Performance is acceptable
- [ ] App icon is set (1024x1024 for App Store)
- [ ] Launch screen is configured

### Testing
- [ ] Tested on real device(s)
- [ ] Tested all main features:
  - [ ] Calendar/Events
  - [ ] Habits
  - [ ] Journal
  - [ ] Budget
  - [ ] Recipes
  - [ ] Vault with biometrics
  - [ ] Settings
- [ ] Notifications work correctly
- [ ] Photo picker works
- [ ] Biometric authentication works
- [ ] Data persistence works (close and reopen app)
- [ ] All navigation flows work
- [ ] Links open correctly

---

## 🎨 App Store Assets

### Screenshots Required
Minimum required (iPhone):
- [ ] 6.7" Display (iPhone 15 Pro Max, 14 Pro Max, etc.)
- [ ] 6.5" Display (iPhone 11 Pro Max, XS Max, etc.)

Recommended to include:
- [ ] 5.5" Display (iPhone 8 Plus, etc.)
- [ ] iPad Pro (if universal app)

Screenshots should show:
- [ ] Home screen
- [ ] Calendar view
- [ ] Habits view
- [ ] Journal view
- [ ] Budget view
- [ ] Recipes view
- [ ] Vault view (with blur on sensitive data)

### App Preview Video (Optional)
- [ ] 15-30 second preview created
- [ ] Shows key features
- [ ] No copyrighted music
- [ ] Correct dimensions for each device size

### App Icon
- [ ] 1024x1024 pixels
- [ ] No transparency
- [ ] No rounded corners (iOS adds them)
- [ ] Looks good at small sizes
- [ ] Recognizable and unique

---

## 📝 App Description

### Essential Elements
Your description should include:

- [ ] **Opening Hook**: What makes your app special
  ```
  Example: "RealLifeHQ is your all-in-one personal organization app that keeps your data private and secure on your device."
  ```

- [ ] **Key Features**: Bullet list of main features
  - Calendar & Event Management
  - Habit Tracking with Streaks
  - Private Journal with Mood Tracking
  - Budget & Expense Tracking
  - Recipe Manager & Meal Planning
  - Secure Vault for Passwords

- [ ] **Privacy Statement**: Emphasize data privacy
  ```
  Example: "🔒 Your Privacy Matters: All your data stays on your device. We don't collect, track, or share any of your information."
  ```

- [ ] **Call to Action**: Encourage download

### Keywords
Select up to 100 characters of keywords (comma-separated):
```
habit,tracker,journal,calendar,budget,recipe,vault,productivity,organization,planner,diary,finance,secure,private,password,meal
```

---

## ✅ Final Checks

### Before Clicking Submit
- [ ] All required fields in App Store Connect are complete
- [ ] Screenshots uploaded for all required devices
- [ ] App icon uploaded
- [ ] Privacy Policy URL is live and working
- [ ] Build is uploaded and processed
- [ ] Export compliance information provided
- [ ] Content rights declaration signed
- [ ] App is ready for sale in selected territories

### Post-Submission
- [ ] Monitor App Store Connect for status updates
- [ ] Check email for any communication from Apple
- [ ] Respond to any review questions within 24 hours
- [ ] Be ready to make quick changes if rejected

---

## 🚨 Common Rejection Reasons (How to Avoid)

### 2.1 App Completeness
**Issue**: App crashes or has obvious bugs
**Prevention**: ✅ Thorough testing completed

### 4.0 Design
**Issue**: UI doesn't follow iOS guidelines
**Prevention**: ✅ Using native SwiftUI components

### 5.1.1 Privacy - Data Collection
**Issue**: Privacy labels don't match actual behavior
**Prevention**: ✅ All privacy labels set to "No" correctly

### 5.1.2 Privacy - Privacy Policy
**Issue**: Privacy policy URL doesn't work or is missing
**Prevention**: ✅ Hosted and tested privacy policy URL

### 2.3.10 Other Purchase Issues
**Issue**: Functionality locked behind payment not using in-app purchase
**Prevention**: ✅ No payment functionality (or uses StoreKit)

---

## 📞 Support Preparation

### Set Up Support Channels
- [ ] Support email is active
- [ ] Auto-reply set up (optional)
- [ ] FAQ page created (optional)
- [ ] Response plan for common questions

### Common User Questions
Prepare answers for:
- How do I back up my data?
- How do I restore my data?
- Why does the app need [permission]?
- How do I delete my data?
- Is my data secure?
- Do you collect my information?

---

## 🎯 Marketing Preparation

### Launch Readiness
- [ ] Social media accounts ready (optional)
- [ ] Website/landing page live (optional)
- [ ] Press kit prepared (optional)
- [ ] Beta testers lined up (optional via TestFlight)

### Post-Launch
- [ ] Monitor reviews and ratings
- [ ] Respond to user feedback
- [ ] Plan for updates based on feedback
- [ ] Track download statistics

---

## 📋 Review Timeline

Expected review times:
- **Initial Review**: 24-48 hours (typically)
- **Response to Rejection**: Submit fixes within 14 days
- **Resubmission Review**: Usually faster (hours)

**Status Tracking:**
- Waiting for Review
- In Review
- Pending Developer Release (approved!)
- Ready for Sale

---

## ✨ Submission Day Checklist

### Final Actions
1. [ ] Double-check privacy policy URL one last time
2. [ ] Verify all screenshots look perfect
3. [ ] Read through app description for typos
4. [ ] Confirm pricing is correct
5. [ ] Take a deep breath
6. [ ] Click "Submit for Review"
7. [ ] Cross your fingers! 🤞

### After Submission
- [ ] Screenshot the submission confirmation
- [ ] Note the submission date and time
- [ ] Set up alerts for App Store Connect emails
- [ ] Plan celebration for approval 🎉

---

## 📱 Contact Information

**Apple Support:**
- App Review: https://developer.apple.com/contact/app-store/
- Phone: Through Developer Account

**Emergency Issues:**
- Use "Request Expedited Review" (only for critical issues)
- Available in App Store Connect

---

## 🎓 Resources

### Apple Documentation
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Marketing Resources](https://developer.apple.com/app-store/marketing/guidelines/)

### Useful Tools
- [App Store Connect](https://appstoreconnect.apple.com/)
- [TestFlight](https://developer.apple.com/testflight/)
- [App Analytics](https://analytics.appstoreconnect.apple.com/)

---

**Good luck with your submission! 🚀**

*Remember: Most apps are approved on first submission if you follow the guidelines. If rejected, don't worry - address the issues and resubmit quickly.*

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Jan 25, 2026 | Initial checklist for RealLifeHQ |

