import SwiftUI

import SwiftUI

// MARK: - Terms of Service View
// Full terms of service displayed in-app

struct TermsOfServiceView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Terms of Service")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Last Updated: January 25, 2026")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 10)
                
                // Agreement to Terms
                TermsSection(title: "Agreement to Terms") {
                    Text("By downloading, installing, or using RealLifeHQ (the \"App\"), you agree to be bound by these Terms of Service (\"Terms\"). If you do not agree to these Terms, do not use the App.")
                        .fontWeight(.semibold)
                }
                
                // Description of Service
                TermsSection(title: "Description of Service") {
                    Text("RealLifeHQ is a personal organization and productivity application that provides the following features:")
                        .padding(.bottom, 8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        TermsBullet(text: "Calendar and event management")
                        TermsBullet(text: "Habit tracking")
                        TermsBullet(text: "Journal and mood tracking")
                        TermsBullet(text: "Budget and expense management")
                        TermsBullet(text: "Recipe storage and meal planning")
                        TermsBullet(text: "Secure vault for sensitive information")
                    }
                    
                    Text("\nAll data created within the App is stored locally on your device.")
                        .fontWeight(.semibold)
                        .padding(.top, 8)
                }
                
                // License Grant
                TermsSection(title: "License Grant") {
                    Text("Subject to your compliance with these Terms, we grant you a limited, non-exclusive, non-transferable, revocable license to:")
                        .padding(.bottom, 8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        TermsBullet(text: "Download and install the App on devices that you own or control")
                        TermsBullet(text: "Use the App for personal, non-commercial purposes")
                    }
                }
                
                // Restrictions
                TermsSection(title: "Restrictions") {
                    Text("You agree NOT to:")
                        .fontWeight(.semibold)
                        .padding(.bottom, 8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        RestrictedItem(text: "Copy, modify, or create derivative works of the App")
                        RestrictedItem(text: "Reverse engineer, decompile, or disassemble the App")
                        RestrictedItem(text: "Remove, alter, or obscure any proprietary notices on the App")
                        RestrictedItem(text: "Use the App for any illegal or unauthorized purpose")
                        RestrictedItem(text: "Rent, lease, lend, sell, or sublicense the App")
                    }
                }
                
                // User Content and Data
                TermsSection(title: "User Content and Data") {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Data")
                                .font(.headline)
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                TermsBullet(text: "You retain all rights to the data you create within the App")
                                TermsBullet(text: "All data is stored locally on your device")
                                TermsBullet(text: "You are solely responsible for backing up your data")
                                TermsBullet(text: "We are not responsible for any loss of data")
                            }
                        }
                        .padding()
                        .background(themeManager.currentTheme.cardColor)
                        .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Data Backup Responsibility")
                                .font(.headline)
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                TermsBullet(text: "The App stores data locally on your device")
                                TermsBullet(text: "You should regularly back up your device through iCloud or iTunes")
                                TermsBullet(text: "We recommend using the \"Export Data\" feature for additional backups")
                                TermsBullet(text: "We are not liable for any data loss")
                            }
                        }
                        .padding()
                        .background(themeManager.currentTheme.cardColor)
                        .cornerRadius(8)
                    }
                }
                
                // Disclaimer of Warranties
                TermsSection(title: "Disclaimer of Warranties") {
                    Text("THE APP IS PROVIDED \"AS IS\" AND \"AS AVAILABLE\" WITHOUT WARRANTIES OF ANY KIND")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(8)
                    
                    Text("\nSpecific Feature Disclaimers:")
                        .fontWeight(.semibold)
                        .padding(.top, 8)
                    
                    DisclaimerCard(
                        icon: "lock.shield.fill",
                        title: "Vault Security",
                        description: "While we implement security measures, no system is completely secure. You are responsible for maintaining the security of your device."
                    )
                    
                    DisclaimerCard(
                        icon: "dollarsign.circle.fill",
                        title: "Budget Features",
                        description: "The App provides tools for personal financial tracking. It is not a substitute for professional financial advice."
                    )
                    
                    DisclaimerCard(
                        icon: "fork.knife",
                        title: "AI Recipe Generator",
                        description: "Generated recipes are suggestions only. Always verify ingredients and cooking methods for safety."
                    )
                    
                    DisclaimerCard(
                        icon: "heart.fill",
                        title: "Health & Wellness Features",
                        description: "Habit tracking and mood journaling are for personal use only. The App is not a medical device or substitute for professional healthcare."
                    )
                }
                
                // Limitation of Liability
                TermsSection(title: "Limitation of Liability") {
                    VStack(alignment: .leading, spacing: 12) {
                        LiabilityItem(
                            number: 1,
                            title: "No Liability for Damages",
                            description: "We shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of or inability to use the App"
                        )
                        
                        LiabilityItem(
                            number: 2,
                            title: "Maximum Liability",
                            description: "Our total liability to you for any claims arising from use of the App shall not exceed the amount you paid for the App (or $100 if the App is free)"
                        )
                        
                        LiabilityItem(
                            number: 3,
                            title: "Data Loss",
                            description: "We are not liable for any loss of data, even if we have been advised of the possibility of such loss"
                        )
                    }
                }
                
                // Privacy
                TermsSection(title: "Privacy") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your privacy is important to us. Please review our Privacy Policy, which explains:")
                            .padding(.bottom, 4)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            TermsBullet(text: "What data the App stores locally on your device")
                            TermsBullet(text: "How we protect your information")
                            TermsBullet(text: "Your rights regarding your data")
                        }
                        
                        NavigationLink(destination: PrivacyPolicyView()) {
                            HStack {
                                Image(systemName: "lock.shield.fill")
                                Text("View Privacy Policy")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }
                            .padding()
                            .background(themeManager.currentTheme.primaryColor.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding(.top, 8)
                        
                        Text("By using the App, you also agree to our Privacy Policy.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                
                // Termination
                TermsSection(title: "Termination") {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("By You")
                                .font(.headline)
                            TermsBullet(text: "You may stop using the App at any time")
                            TermsBullet(text: "Delete the App from your device to terminate your license")
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Effect of Termination")
                                .font(.headline)
                            TermsBullet(text: "Upon termination, your license to use the App ends immediately")
                            TermsBullet(text: "You must delete the App from all devices")
                        }
                    }
                }
                
                // Apple App Store Terms
                TermsSection(title: "Apple App Store") {
                    Text("If you downloaded the App from the Apple App Store, you acknowledge that:")
                        .padding(.bottom, 8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        TermsBullet(text: "These Terms are between you and us, not Apple")
                        TermsBullet(text: "The license granted is limited to use on Apple-branded devices you own or control")
                        TermsBullet(text: "We, not Apple, are responsible for the App and its content")
                        TermsBullet(text: "Apple has no warranty obligation for the App")
                        TermsBullet(text: "We, not Apple, are responsible for addressing claims related to the App")
                    }
                }
                
                // Contact Information
                TermsSection(title: "Contact Information") {
                    Text("For questions about these Terms, please contact us:")
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
                        
                        Text("Response Time: We aim to respond to all inquiries within 48 hours.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .padding()
                    .background(themeManager.currentTheme.cardColor)
                    .cornerRadius(8)
                }
                
                // Acknowledgment
                VStack(alignment: .leading, spacing: 12) {
                    Text("Acknowledgment")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("BY USING THE APP, YOU ACKNOWLEDGE THAT YOU HAVE READ THESE TERMS OF SERVICE AND AGREE TO BE BOUND BY THEM.")
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
                Text("Effective Date: This Terms of Service is effective as of January 25, 2026 and applies to all users of RealLifeHQ.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
            }
            .padding()
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Supporting Views for Terms

struct TermsSection<Content: View>: View {
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

struct TermsBullet: View {
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

struct RestrictedItem: View {
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

struct DisclaimerCard: View {
    let icon: String
    let title: String
    let description: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
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

struct LiabilityItem: View {
    let number: Int
    let title: String
    let description: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number).")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(themeManager.currentTheme.primaryColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
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
        TermsOfServiceView()
            .environmentObject(ThemeManager())
    }
}
