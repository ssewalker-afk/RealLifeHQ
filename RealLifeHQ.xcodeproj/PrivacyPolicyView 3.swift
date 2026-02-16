import SwiftUI

// MARK: - Privacy Policy View
// Displays the app's privacy policy

struct PrivacyPolicyView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .padding(.bottom, 8)
                
                Text("Last Updated: February 14, 2026")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 16)
                
                // Introduction
                privacySection(
                    title: "Your Privacy Matters",
                    content: """
                    RealLifeHQ is committed to protecting your privacy. This Privacy Policy explains how we handle your personal information and data when you use our app.
                    
                    We believe in transparency and your right to control your personal information. This policy describes what data we collect, how we use it, and your choices regarding your information.
                    """
                )
                
                // Data Collection
                privacySection(
                    title: "What Data We Collect",
                    content: """
                    RealLifeHQ stores all your data locally on your device. We collect and process:
                    
                    • Calendar events and appointments you create
                    • Habits you track and their completion history
                    • Journal entries you write
                    • Budget information and expense tracking
                    • Secure notes stored in the Vault (encrypted)
                    • App preferences and theme settings
                    • Notification preferences
                    
                    Optional External Services:
                    • If you enable Apple Calendar sync, we access your calendar data through Apple's EventKit framework
                    • If you enable Google Calendar sync, we access your Google Calendar data through Google's Calendar API
                    
                    We do NOT collect:
                    • Your name, email, or contact information
                    • Location data
                    • Device identifiers for tracking
                    • Analytics or usage statistics
                    • Any data for advertising purposes
                    """
                )
                
                // Data Storage
                privacySection(
                    title: "How We Store Your Data",
                    content: """
                    Local Storage:
                    All your data is stored locally on your device using Apple's secure storage systems. Your data never leaves your device unless you explicitly enable cloud sync or calendar integrations.
                    
                    Encryption:
                    • Vault entries are encrypted using industry-standard encryption
                    • Biometric authentication (Face ID/Touch ID) protects access to sensitive features
                    • Your data is protected by your device's built-in security features
                    
                    Cloud Storage (Optional):
                    If you enable iCloud sync (through iOS Settings), your data may be stored in your personal iCloud account. This is entirely optional and controlled by you through iOS system settings.
                    """
                )
                
                // Data Usage
                privacySection(
                    title: "How We Use Your Data",
                    content: """
                    We use your data solely to:
                    • Display your events, habits, journal entries, and budget information
                    • Send you notifications for reminders you've set
                    • Sync with Apple Calendar or Google Calendar if you enable those features
                    • Provide app functionality and improve your experience
                    
                    We do NOT:
                    • Share your data with third parties
                    • Sell your data to advertisers or data brokers
                    • Use your data for marketing or advertising
                    • Track your usage patterns or behavior
                    • Access your data on our servers (we don't have servers!)
                    """
                )
                
                // Calendar Integration
                privacySection(
                    title: "Calendar Integration",
                    content: """
                    Apple Calendar:
                    When you enable Apple Calendar sync, the app requests permission to access your calendar events through iOS. This integration uses Apple's EventKit framework and is subject to Apple's privacy policies.
                    
                    Google Calendar:
                    When you enable Google Calendar sync, you'll be redirected to Google's authentication page to grant permission. We only access calendar data you explicitly authorize. This integration is subject to Google's privacy policies.
                    
                    You can revoke calendar permissions at any time through:
                    • iOS Settings > RealLifeHQ > Calendars
                    • RealLifeHQ Settings > Integrations
                    """
                )
                
                // Notifications
                privacySection(
                    title: "Notifications",
                    content: """
                    RealLifeHQ uses local notifications to remind you of:
                    • Upcoming events and appointments
                    • Habit reminders you've set
                    • Budget alerts you've configured
                    
                    All notifications are generated locally on your device. We do not use push notifications or send data to external servers.
                    
                    You can control notification permissions through:
                    • iOS Settings > Notifications > RealLifeHQ
                    • RealLifeHQ Settings > Notifications
                    """
                )
                
                // Data Security
                privacySection(
                    title: "Data Security",
                    content: """
                    We take your security seriously:
                    
                    • All data is stored locally using Apple's secure storage APIs
                    • Vault entries use AES-256 encryption
                    • Biometric authentication protects sensitive features
                    • No data transmission to external servers (except calendar sync if enabled)
                    • Regular security updates through App Store
                    
                    While we implement strong security measures, no system is 100% secure. We recommend:
                    • Keep your device updated with the latest iOS version
                    • Use a strong device passcode
                    • Enable Face ID or Touch ID for additional protection
                    • Regularly back up your device
                    """
                )
                
                // Your Rights
                privacySection(
                    title: "Your Rights and Choices",
                    content: """
                    You have complete control over your data:
                    
                    Access: View all your data directly in the app
                    Export: Export your data through Settings > Export Data
                    Delete: Delete individual items or all data through Settings > Clear All Data
                    Control: Enable or disable features like calendar sync, notifications, and biometric authentication
                    
                    Since all data is stored locally on your device, you can also:
                    • Delete the app to remove all local data
                    • Manage iCloud sync through iOS Settings
                    • Revoke calendar permissions at any time
                    """
                )
                
                // Third-Party Services
                privacySection(
                    title: "Third-Party Services",
                    content: """
                    RealLifeHQ may integrate with:
                    
                    Apple Services:
                    • EventKit (Calendar sync) - Subject to Apple's Privacy Policy
                    • iCloud (Optional sync) - Subject to Apple's Privacy Policy
                    • StoreKit (Subscription management) - Subject to Apple's Privacy Policy
                    
                    Google Services (Optional):
                    • Google Calendar API - Subject to Google's Privacy Policy
                    
                    When you use these integrations, you're also agreeing to their respective privacy policies. We recommend reviewing them.
                    """
                )
                
                // Children's Privacy
                privacySection(
                    title: "Children's Privacy",
                    content: """
                    RealLifeHQ is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If you believe we have inadvertently collected information from a child under 13, please contact us immediately.
                    """
                )
                
                // Changes to Policy
                privacySection(
                    title: "Changes to This Policy",
                    content: """
                    We may update this Privacy Policy from time to time. When we do:
                    • We'll update the "Last Updated" date at the top
                    • We'll notify you through the app if there are significant changes
                    • The updated policy will be available in Settings > Privacy Policy
                    
                    Continued use of the app after changes indicates acceptance of the updated policy.
                    """
                )
                
                // Contact
                privacySection(
                    title: "Contact Us",
                    content: """
                    If you have questions about this Privacy Policy or how we handle your data:
                    
                    • Open the app and go to Settings > Support
                    • Email: support@reallifehq.app
                    • Visit: https://yourwebsite.com/privacy
                    
                    We'll respond to privacy inquiries within 48 hours.
                    """
                )
                
                // California Privacy Rights
                privacySection(
                    title: "California Privacy Rights (CCPA)",
                    content: """
                    If you're a California resident, you have additional rights under the California Consumer Privacy Act (CCPA):
                    
                    • Right to know what personal information we collect
                    • Right to access your personal information
                    • Right to delete your personal information
                    • Right to opt-out of data sales (we never sell data)
                    
                    Since we don't collect or share personal information beyond what's necessary for app functionality, these rights are inherently protected in how we've built the app.
                    """
                )
                
                // European Privacy Rights
                privacySection(
                    title: "European Privacy Rights (GDPR)",
                    content: """
                    If you're in the European Economic Area (EEA), you have rights under GDPR:
                    
                    • Right to access your data
                    • Right to rectification (correct your data)
                    • Right to erasure ("right to be forgotten")
                    • Right to data portability
                    • Right to object to processing
                    
                    Since all data is stored locally on your device, you have complete control over these rights through the app's built-in features.
                    """
                )
                
                Spacer(minLength: 40)
            }
            .padding()
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func privacySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(themeManager.currentTheme.primaryColor)
            
            Text(content)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 8)
    }
}

#Preview {
    NavigationView {
        PrivacyPolicyView()
            .environmentObject(ThemeManager())
    }
}
