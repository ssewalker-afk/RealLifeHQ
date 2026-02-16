import SwiftUI

// MARK: - Privacy Policy View
// Display RealLifeHQ's complete privacy policy

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 60))
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 8)
                    
                    Text("Privacy Policy")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                    
                    Text("Last Updated: January 29, 2026")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 8)
                
                Divider()
                
                // Introduction
                PolicySection(
                    title: "Our Commitment to Your Privacy",
                    content: """
                    At RealLifeHQ, your privacy is our top priority. This policy explains how we handle your personal information. The short version: We don't collect, store, or share your personal data with anyone. Everything stays on your device.
                    """
                )
                
                // What We Collect
                PolicySection(
                    title: "Information We Collect",
                    content: """
                    RealLifeHQ is designed with privacy-first principles. All your data is stored locally on your device and never transmitted to our servers or any third parties.
                    """
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Data Stored Locally on Your Device:")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    DataTypeRow(
                        icon: "calendar",
                        title: "Calendar Events",
                        description: "Events, dates, times, notes, and reminders you create"
                    )
                    
                    DataTypeRow(
                        icon: "target",
                        title: "Habit Tracking",
                        description: "Your habits, completion dates, and streak information"
                    )
                    
                    DataTypeRow(
                        icon: "book.closed.fill",
                        title: "Journal Entries",
                        description: "Your personal journal content and mood tracking"
                    )
                    
                    DataTypeRow(
                        icon: "dollarsign.circle.fill",
                        title: "Budget & Finances",
                        description: "Income, expenses, transactions, and budget categories"
                    )
                    
                    DataTypeRow(
                        icon: "fork.knife",
                        title: "Recipes & Meal Plans",
                        description: "Recipes, meal plans, and shopping lists you save"
                    )
                    
                    DataTypeRow(
                        icon: "key.fill",
                        title: "Vault Items",
                        description: "Passwords and secure notes (stored in iOS Keychain)"
                    )
                    
                    DataTypeRow(
                        icon: "gear",
                        title: "App Preferences",
                        description: "Your theme choice, notification settings, and preferences"
                    )
                }
                
                // What We Don't Collect
                PolicySection(
                    title: "What We DON'T Collect",
                    content: """
                    We want to be crystal clear about what we don't do:
                    
                    • We don't collect your name, email, phone number, or contact information
                    • We don't track your location
                    • We don't use analytics or tracking tools
                    • We don't collect device identifiers for advertising
                    • We don't access your contacts, photos, or other apps
                    • We don't use cookies or web tracking
                    • We don't build user profiles
                    • We don't sell or share your data with anyone
                    """
                )
                
                // Data Security
                PolicySection(
                    title: "How We Protect Your Data",
                    content: """
                    Your security is paramount. Here's how we protect your information:
                    """
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    SecurityFeature(
                        icon: "iphone",
                        title: "Local Storage Only",
                        description: "All data stays on your device. We have no servers or cloud storage."
                    )
                    
                    SecurityFeature(
                        icon: "lock.shield.fill",
                        title: "iOS Keychain Encryption",
                        description: "All passwords and secure notes from the Vault are stored in iOS Keychain, Apple's most secure storage system with hardware-backed encryption."
                    )
                    
                    SecurityFeature(
                        icon: "faceid",
                        title: "Biometric Protection",
                        description: "Optional Face ID or Touch ID protection for accessing your Vault."
                    )
                    
                    SecurityFeature(
                        icon: "arrow.up.arrow.down.circle",
                        title: "No Network Transmission",
                        description: "Your personal data never leaves your device. No servers, no cloud sync."
                    )
                    
                    SecurityFeature(
                        icon: "checkmark.shield.fill",
                        title: "iOS Security",
                        description: "Protected by iOS sandboxing and encryption at rest."
                    )
                }
                
                // In-App Purchases
                PolicySection(
                    title: "In-App Purchases",
                    content: """
                    RealLifeHQ offers optional subscriptions through Apple's StoreKit framework.
                    
                    • Subscription transactions are processed entirely by Apple
                    • We never see or store your payment information
                    • Purchase history is managed by Apple, not us
                    • You can manage subscriptions through iOS Settings > Apple ID > Subscriptions
                    """
                )
                
                // Notifications
                PolicySection(
                    title: "Notifications",
                    content: """
                    RealLifeHQ can send you local notifications for event reminders.
                    
                    • All notifications are generated locally on your device
                    • No data is sent to remote servers for notifications
                    • You can disable notifications anytime in iOS Settings or within the app
                    • Notification preferences are stored locally on your device
                    """
                )
                
                // AI Features
                PolicySection(
                    title: "AI Recipe Generation",
                    content: """
                    RealLifeHQ includes an AI-powered recipe generator feature.
                    
                    • Currently uses intelligent template-based generation (all processing is local)
                    • Future versions may use Apple's on-device Foundation Models API
                    • No recipe data or ingredients are ever sent to external servers
                    • All AI processing happens on your device using Apple Intelligence
                    • Your recipe preferences and data remain completely private
                    """
                )
                
                // Data Backup
                PolicySection(
                    title: "Backups & Data Portability",
                    content: """
                    Your RealLifeHQ data is included in iOS device backups:
                    
                    • iCloud Backups: Your app data is backed up by Apple (not by us)
                    • iTunes/Finder Backups: Included in local computer backups
                    • Keychain Data: Vault passwords are backed up securely by iOS
                    • No Third-Party Backups: We don't create or store backups of your data
                    
                    Note: If you restore your device or switch to a new device and restore from backup, your RealLifeHQ data will be restored automatically by iOS.
                    """
                )
                
                // Children's Privacy
                PolicySection(
                    title: "Children's Privacy",
                    content: """
                    RealLifeHQ is suitable for users of all ages. Since we don't collect any personal information from anyone, including children, we are compliant with COPPA (Children's Online Privacy Protection Act) and similar regulations worldwide.
                    """
                )
                
                // Third-Party Services
                PolicySection(
                    title: "Third-Party Services",
                    content: """
                    RealLifeHQ does not integrate with any third-party services, analytics platforms, advertising networks, or social media. The only Apple service we use is StoreKit for processing subscription purchases, which is handled entirely by Apple with their privacy protections.
                    """
                )
                
                // Your Rights
                PolicySection(
                    title: "Your Rights & Control",
                    content: """
                    Since all your data is stored locally on your device, you have complete control:
                    
                    • Access: All your data is accessible within the app at any time
                    • Export: Use the "Export Data" feature in Settings (if needed for backup)
                    • Delete: Use "Clear All Data" in Settings to permanently delete everything
                    • Uninstall: Simply delete the app to remove all local data
                    • Vault Data: Delete the app to remove Keychain data (with device passcode)
                    
                    You don't need to contact us to exercise these rights because you're already in control of your data.
                    """
                )
                
                // Data Retention
                PolicySection(
                    title: "Data Retention",
                    content: """
                    Your data remains on your device until you:
                    
                    • Manually delete items within the app
                    • Use "Clear All Data" in Settings
                    • Uninstall the app
                    • Erase your device
                    
                    We have no servers, so there's nothing for us to retain or delete. You have complete control over your data's lifecycle.
                    """
                )
                
                // International Users
                PolicySection(
                    title: "International Users",
                    content: """
                    RealLifeHQ can be used anywhere in the world. Since all data stays on your device, there are no international data transfers, and you're protected by your local data protection laws (GDPR, CCPA, etc.).
                    """
                )
                
                // Changes to Privacy Policy
                PolicySection(
                    title: "Changes to This Policy",
                    content: """
                    We may update this privacy policy from time to time to reflect changes in the app or legal requirements. When we make significant changes, we'll update the "Last Updated" date at the top of this policy and notify you through an in-app message.
                    
                    Your continued use of the app after changes means you accept the updated policy.
                    """
                )
                
                // Contact
                PolicySection(
                    title: "Contact Us",
                    content: """
                    If you have questions about this privacy policy or your data, you can contact us at:
                    
                    Email: privacy@reallifehq.app
                    Website: www.reallifehq.app
                    
                    We typically respond within 2-3 business days.
                    """
                )
                
                // Summary
                VStack(alignment: .leading, spacing: 12) {
                    Text("Privacy Summary")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        SummaryPoint(icon: "checkmark.circle.fill", text: "All data stored locally on your device", color: .green)
                        SummaryPoint(icon: "checkmark.circle.fill", text: "No servers, no cloud, no tracking", color: .green)
                        SummaryPoint(icon: "checkmark.circle.fill", text: "Passwords secured in iOS Keychain", color: .green)
                        SummaryPoint(icon: "checkmark.circle.fill", text: "No data sharing with third parties", color: .green)
                        SummaryPoint(icon: "checkmark.circle.fill", text: "You have complete control", color: .green)
                    }
                }
                .padding()
                .background(themeManager.currentTheme.primaryColor.opacity(0.1))
                .cornerRadius(12)
                
                Text("Thank you for trusting RealLifeHQ with your personal organization!")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
            }
            .padding()
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Supporting Views

struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(content)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct DataTypeRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct SecurityFeature: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.green)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct SummaryPoint: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
                .font(.subheadline)
        }
    }
}

// MARK: - Terms of Service View

struct TermsOfServiceView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 60))
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 8)
                    
                    Text("Terms of Service")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                    
                    Text("Last Updated: January 29, 2026")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 8)
                
                Divider()
                
                PolicySection(
                    title: "Agreement to Terms",
                    content: """
                    By downloading, installing, or using RealLifeHQ, you agree to these Terms of Service. If you don't agree, please don't use the app.
                    """
                )
                
                PolicySection(
                    title: "Use of the App",
                    content: """
                    RealLifeHQ is a personal organization app for managing your calendar, habits, journal, budget, recipes, and secure information.
                    
                    You may use RealLifeHQ for personal, non-commercial purposes. You may not:
                    
                    • Reverse engineer, decompile, or disassemble the app
                    • Use the app for any illegal purposes
                    • Attempt to bypass subscription requirements
                    • Copy, modify, or distribute the app
                    """
                )
                
                PolicySection(
                    title: "Subscriptions",
                    content: """
                    RealLifeHQ offers optional monthly and yearly subscriptions.
                    
                    • Payment is charged to your Apple ID account
                    • Subscriptions auto-renew unless canceled 24 hours before renewal
                    • Manage subscriptions in iOS Settings > Apple ID > Subscriptions
                    • No refunds for unused subscription time
                    • Prices may change with 30 days notice
                    """
                )
                
                PolicySection(
                    title: "Your Data",
                    content: """
                    You retain all rights to the content you create in RealLifeHQ (journal entries, notes, recipes, etc.). We never claim ownership of your data.
                    
                    You're responsible for:
                    • Maintaining your own backups (via iOS backup)
                    • The accuracy of information you enter
                    • Keeping your device secure
                    """
                )
                
                PolicySection(
                    title: "Disclaimer",
                    content: """
                    RealLifeHQ is provided "as is" without warranties of any kind.
                    
                    • We don't guarantee the app will be error-free or always available
                    • We're not liable for data loss (keep backups!)
                    • Budget and financial features are for personal tracking only, not professional financial advice
                    • Journal and mood tracking are not substitutes for professional mental health care
                    """
                )
                
                PolicySection(
                    title: "Limitation of Liability",
                    content: """
                    To the maximum extent permitted by law, we're not liable for any indirect, incidental, or consequential damages arising from your use of RealLifeHQ.
                    """
                )
                
                PolicySection(
                    title: "Changes to Terms",
                    content: """
                    We may update these terms from time to time. We'll notify you of significant changes through the app. Continued use means you accept the updated terms.
                    """
                )
                
                PolicySection(
                    title: "Termination",
                    content: """
                    You can stop using RealLifeHQ at any time by deleting the app. We may terminate or suspend access if you violate these terms.
                    """
                )
                
                PolicySection(
                    title: "Contact",
                    content: """
                    Questions about these terms? Contact us at:
                    
                    Email: support@reallifehq.app
                    Website: www.reallifehq.app
                    """
                )
            }
            .padding()
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        PrivacyPolicyView()
            .environmentObject(ThemeManager())
    }
}
