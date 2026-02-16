import SwiftUI

import SwiftUI

// MARK: - Privacy Policy View
// Full privacy policy displayed in-app

struct PrivacyPolicyView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Privacy Policy")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Last Updated: January 29, 2026")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 10)
                
                // Introduction
                SectionView(title: "Introduction") {
                    Text("RealLifeHQ (\"we,\" \"our,\" or \"the App\") is committed to protecting your privacy. This Privacy Policy explains how we handle your personal information when you use our iOS application.")
                    
                    HighlightBox(text: "Your privacy is paramount to us. All data created and stored within RealLifeHQ remains exclusively on your device. We do not collect, transmit, store, or share any of your personal data with third parties or our servers. Sensitive information like passwords is protected using iOS Keychain, Apple's most secure storage system.")
                }
                
                // Information We Collect
                SectionView(title: "Information We Collect") {
                    Text("RealLifeHQ stores the following types of data locally on your device using iOS's secure local storage:")
                        .padding(.bottom, 8)
                    
                    DataTypeCard(title: "Calendar Events", items: [
                        "Event titles, dates, times, and notes",
                        "Completion status",
                        "Reminder settings"
                    ])
                    
                    DataTypeCard(title: "Habit Tracking Data", items: [
                        "Habit names, icons, and colors",
                        "Completion dates and streaks",
                        "Frequency and schedule settings"
                    ])
                    
                    DataTypeCard(title: "Journal Entries", items: [
                        "Entry content and dates",
                        "Mood tracking information",
                        "Tags for categorization"
                    ])
                    
                    DataTypeCard(title: "Budget & Financial Information", items: [
                        "Budget setup and income information",
                        "Expense transactions and categories",
                        "Recurring expense schedules",
                        "Category limits and spending data"
                    ])
                    
                    DataTypeCard(title: "Recipe Information", items: [
                        "Recipe names, ingredients, and instructions",
                        "Cooking times and servings",
                        "Meal plans and shopping lists",
                        "Favorite recipe selections"
                    ])
                    
                    DataTypeCard(title: "Vault Items (Secure Storage)", items: [
                        "Titles and categories",
                        "Usernames and website URLs",
                        "Passwords (stored securely in iOS Keychain)",
                        "Secure notes (stored securely in iOS Keychain)",
                        "Attached photos (stored as encrypted data)"
                    ])
                    
                    DataTypeCard(title: "App Settings & Preferences", items: [
                        "Theme preferences",
                        "Notification settings",
                        "Biometric authentication preferences",
                        "Dashboard widget configurations"
                    ])
                }
                
                // Data NOT Collected
                SectionView(title: "Data NOT Collected") {
                    VStack(alignment: .leading, spacing: 8) {
                        NotCollectedItem(text: "No Personal Identifiers: We do not collect names, email addresses, phone numbers, or any other personal identifiers")
                        NotCollectedItem(text: "No Location Data: We do not access or collect your location information")
                        NotCollectedItem(text: "No Analytics: We do not use analytics services to track your app usage")
                        NotCollectedItem(text: "No Advertising Data: We do not collect data for advertising purposes")
                        NotCollectedItem(text: "No Device Information: We do not collect information about your device beyond what iOS provides for app functionality")
                    }
                }
                
                // How We Use Your Information
                SectionView(title: "How We Use Your Information") {
                    Text("All data you create within RealLifeHQ is:")
                        .fontWeight(.semibold)
                        .padding(.bottom, 8)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        NumberedItem(number: 1, text: "Stored Locally: All information is stored exclusively on your device using iOS's secure local storage mechanisms")
                        NumberedItem(number: 2, text: "User-Controlled: You have complete control over your data and can delete it at any time")
                        NumberedItem(number: 3, text: "Never Transmitted: Your data is never sent to external servers, cloud services, or third parties")
                        NumberedItem(number: 4, text: "Not Shared: We do not share, sell, rent, or trade your information with anyone")
                    }
                }
                
                // Data Security
                SectionView(title: "Data Security") {
                    Text("We implement multiple layers of security to protect your information:")
                        .padding(.bottom, 8)
                    
                    SecurityFeature(title: "iOS Keychain Protection", description: "All passwords and secure notes from the Vault are stored in iOS Keychain, Apple's most secure storage system. This data is encrypted and protected by your device's security features, including hardware-based encryption.")
                    
                    SecurityFeature(title: "Local Storage Security", description: "Other app data is stored using iOS's secure UserDefaults storage mechanism. All data remains on your device and is protected by iOS's app sandbox.")
                    
                    SecurityFeature(title: "Biometric Protection", description: "Optional Face ID/Touch ID protection for the Vault feature, leveraging iOS's secure biometric authentication system. Your biometric data never leaves your device.")
                    
                    SecurityFeature(title: "Device-Level Encryption", description: "All data stored on your device benefits from iOS's built-in encryption when your device is locked. This includes FileVault encryption on the device storage level.")
                    
                    SecurityFeature(title: "No Cloud Transmission", description: "Because data never leaves your device, it cannot be intercepted during transmission or accessed by unauthorized parties through network attacks.")
                }
                
                // Your Privacy Rights
                SectionView(title: "Your Privacy Rights") {
                    Text("You have complete control over your data:")
                        .fontWeight(.semibold)
                        .padding(.bottom, 8)
                    
                    PrivacyRight(title: "Access Your Data", description: "All your data is accessible within the app at any time")
                    
                    PrivacyRight(title: "Delete Your Data", description: "Delete any items individually, use 'Clear All Data' in Settings, or uninstall the app to remove all associated data")
                    
                    PrivacyRight(title: "Export Your Data", description: "Use the 'Export Data' feature in Settings to create a backup of your information")
                    
                    PrivacyRight(title: "Control Permissions", description: "Manage notifications, photos, and biometrics through iOS Settings or in-app Settings")
                }
                
                // Third-Party Services
                SectionView(title: "Third-Party Services") {
                    Text("RealLifeHQ does NOT integrate with any third-party services, including:")
                        .padding(.bottom, 8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        BulletPoint(text: "Analytics platforms")
                        BulletPoint(text: "Advertising networks")
                        BulletPoint(text: "Cloud storage providers")
                        BulletPoint(text: "Social media platforms")
                        BulletPoint(text: "Payment processors (other than Apple's in-app purchase system)")
                    }
                    
                    Text("\nThe app uses only standard iOS frameworks:")
                        .fontWeight(.semibold)
                        .padding(.top, 8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        BulletPoint(text: "iOS Keychain (for secure password storage)")
                        BulletPoint(text: "Local Notifications (data remains on device)")
                        BulletPoint(text: "Photo Library (your choice)")
                        BulletPoint(text: "Biometric Authentication (processed by iOS)")
                        BulletPoint(text: "StoreKit (for subscriptions, managed by Apple)")
                    }
                }
                
                // Children's Privacy
                SectionView(title: "Children's Privacy") {
                    Text("RealLifeHQ is suitable for users of all ages. Because we do not collect any personal information from users, we do not knowingly collect personal information from children under 13. Parents can allow children to use the app with confidence that no data is being collected or transmitted.")
                }
                
                // Contact
                SectionView(title: "Contact Us") {
                    Text("If you have questions, concerns, or requests regarding this Privacy Policy or your privacy:")
                        .padding(.bottom, 8)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Email:")
                                .fontWeight(.semibold)
                            Text("sarah@thereallifehq.com")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                        
                        HStack {
                            Text("Website:")
                                .fontWeight(.semibold)
                            Text("www.thereallifehq.com")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                        
                        Text("Response Time: We aim to respond to all privacy inquiries within 48 hours.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .padding()
                    .background(themeManager.currentTheme.cardColor)
                    .cornerRadius(8)
                }
                
                // Summary
                VStack(alignment: .leading, spacing: 12) {
                    Text("Summary")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("The Bottom Line: RealLifeHQ is a completely private, offline-first app. Everything you create, store, and manage stays on your device. We don't collect, transmit, or share any of your data. Your information is yours alone.")
                        .fontWeight(.semibold)
                }
                .padding()
                .background(themeManager.currentTheme.primaryColor.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeManager.currentTheme.primaryColor, lineWidth: 2)
                )
                
                // Footer
                Text("Effective Date: This privacy policy is effective as of January 29, 2026 and applies to all users of RealLifeHQ.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
            }
            .padding()
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Supporting Views

struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    @EnvironmentObject var themeManager: ThemeManager
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(themeManager.currentTheme.primaryColor)
            
            content
        }
        .padding(.bottom, 8)
    }
}

struct HighlightBox: View {
    let text: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Text(text)
            .fontWeight(.semibold)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(themeManager.currentTheme.primaryColor.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(themeManager.currentTheme.primaryColor, lineWidth: 2)
            )
    }
}

struct DataTypeCard: View {
    let title: String
    let items: [String]
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.primaryColor)
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(items, id: \.self) { item in
                    BulletPoint(text: item)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(8)
    }
}

struct NotCollectedItem: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
                .font(.body)
            Text(text)
                .font(.subheadline)
        }
    }
}

struct NumberedItem: View {
    let number: Int
    let text: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number).")
                .fontWeight(.bold)
                .foregroundColor(themeManager.currentTheme.primaryColor)
            Text(text)
                .font(.subheadline)
        }
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .fontWeight(.bold)
            Text(text)
                .font(.subheadline)
        }
    }
}

struct SecurityFeature: View {
    let title: String
    let description: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(themeManager.currentTheme.accentColor)
                Text(title)
                    .font(.headline)
            }
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(8)
    }
}

struct PrivacyRight: View {
    let title: String
    let description: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text(title)
                    .font(.headline)
            }
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(8)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        PrivacyPolicyView()
            .environmentObject(ThemeManager())
    }
}
