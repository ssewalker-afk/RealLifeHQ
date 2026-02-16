import SwiftUI

// MARK: - Support View
// Help and support resources for users

struct SupportView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingEmailComposer = false
    @State private var scrollToSection: SupportSection? = nil
    
    enum SupportSection: String, CaseIterable {
        case faqs = "FAQs"
        case features = "Features"
        case tips = "Tips"
        case contact = "Contact"
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "lifepreserver.fill")
                            .font(.system(size: 60))
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        
                        Text("How Can We Help?")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("We're here to support you")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Quick Actions
                    VStack(spacing: 16) {
                        supportActionCard(
                            icon: "envelope.fill",
                            title: "Email Support",
                            description: "Get help via email",
                            color: themeManager.currentTheme.primaryColor
                        ) {
                            withAnimation {
                                proxy.scrollTo(SupportSection.contact.rawValue, anchor: .top)
                            }
                        }
                        
                        supportActionCard(
                            icon: "book.fill",
                            title: "User Guide",
                            description: "Learn how to use RealLifeHQ",
                            color: themeManager.currentTheme.accentColor
                        ) {
                            withAnimation {
                                proxy.scrollTo(SupportSection.tips.rawValue, anchor: .top)
                            }
                        }
                        
                        supportActionCard(
                            icon: "questionmark.circle.fill",
                            title: "FAQs",
                            description: "Common questions answered",
                            color: themeManager.currentTheme.primaryColor
                        ) {
                            withAnimation {
                                proxy.scrollTo(SupportSection.faqs.rawValue, anchor: .top)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // FAQ Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Frequently Asked Questions")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .id(SupportSection.faqs.rawValue) // Scroll anchor
                    
                    faqItem(
                        question: "How do I sync with Apple Calendar?",
                        answer: "Go to Settings > Integrations > Apple Calendar Sync and enable the toggle. You'll be asked to grant calendar access permissions."
                    )
                    
                    faqItem(
                        question: "How do I back up my data?",
                        answer: "Your data is automatically backed up through iCloud if you have iCloud backup enabled for this app. You can also manually export your data from Settings > Export Data."
                    )
                    
                    faqItem(
                        question: "How do I set up recurring events?",
                        answer: "When creating or editing an event, toggle 'Recurring Event' and choose your preferred frequency (daily, weekly, monthly, or yearly)."
                    )
                    
                    faqItem(
                        question: "What's the difference between Events and Habits?",
                        answer: "Events are one-time or recurring appointments with specific dates and times. Habits are daily activities you want to track and build streaks for."
                    )
                    
                    faqItem(
                        question: "How secure is the Vault?",
                        answer: "Vault entries are encrypted using AES-256 encryption and can be protected with Face ID or Touch ID. Your notes are stored securely on your device."
                    )
                    
                    faqItem(
                        question: "Can I use RealLifeHQ offline?",
                        answer: "Yes! RealLifeHQ works completely offline. All your data is stored locally on your device. Internet is only needed for optional calendar sync features."
                    )
                    
                    faqItem(
                        question: "How do I change my subscription?",
                        answer: "You can manage your subscription through the App Store. Go to iPhone Settings > [Your Name] > Subscriptions > RealLifeHQ."
                    )
                    
                    faqItem(
                        question: "How do I delete my data?",
                        answer: "Go to Settings > Data > Clear All Data. This will permanently delete all your local data. If you have iCloud backup enabled, you may need to delete the backup separately."
                    )
                    
                    faqItem(
                        question: "Why am I not receiving notifications?",
                        answer: "Check that notifications are enabled in both iOS Settings > Notifications > RealLifeHQ and within the app at Settings > Notifications. Also ensure Do Not Disturb is not blocking notifications."
                    )
                    
                    faqItem(
                        question: "Can I use RealLifeHQ on multiple devices?",
                        answer: "Yes! If you enable iCloud backup in iOS Settings, your data will sync across all your devices signed into the same Apple ID."
                    )
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                // Feature Guides
                VStack(alignment: .leading, spacing: 16) {
                    Text("Feature Guides")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .id(SupportSection.features.rawValue) // Scroll anchor
                    
                    featureGuide(
                        icon: "calendar",
                        title: "Calendar",
                        description: "Create events with times, set reminders, and sync with Apple Calendar or Google Calendar."
                    )
                    
                    featureGuide(
                        icon: "target",
                        title: "Habits",
                        description: "Track daily habits, build streaks, and set reminders to stay consistent with your goals."
                    )
                    
                    featureGuide(
                        icon: "book.closed.fill",
                        title: "Journal",
                        description: "Write daily entries, use journal prompts, and reflect on your thoughts and experiences."
                    )
                    
                    featureGuide(
                        icon: "dollarsign.circle.fill",
                        title: "Budget",
                        description: "Set monthly budgets, track expenses by category, and monitor your spending patterns."
                    )
                    
                    featureGuide(
                        icon: "lock.shield.fill",
                        title: "Vault",
                        description: "Store sensitive information securely with encryption and biometric authentication."
                    )
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                // Tips & Tricks
                VStack(alignment: .leading, spacing: 16) {
                    Text("Tips & Tricks")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .id(SupportSection.tips.rawValue) // Scroll anchor
                    
                    tipCard(
                        icon: "sparkles",
                        title: "Use the Life Reminder Wizard",
                        tip: "Answer a few questions to get personalized suggestions for important life reminders like oil changes, vet visits, and tax deadlines."
                    )
                    
                    tipCard(
                        icon: "bell.fill",
                        title: "Set Strategic Reminders",
                        tip: "For events, set reminders 1-2 hours before to give yourself time to prepare. For habits, set reminders at times when you're most likely to complete them."
                    )
                    
                    tipCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Track Habit Streaks",
                        tip: "Build momentum by maintaining daily streaks. Don't break the chain! Even if you miss a day, get right back to it."
                    )
                    
                    tipCard(
                        icon: "paintbrush.fill",
                        title: "Customize Your Theme",
                        tip: "Go to Settings > Theme to choose colors that match your style. Pick a theme that makes you happy to use the app daily."
                    )
                    
                    tipCard(
                        icon: "square.and.arrow.up",
                        title: "Regular Backups",
                        tip: "Enable iCloud backup in iOS Settings to ensure your data is always safe. Export data periodically for extra security."
                    )
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                // Contact Information
                VStack(spacing: 16) {
                    Text("Still Need Help?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .id(SupportSection.contact.rawValue) // Scroll anchor
                    
                    Text("We're here to help! Reach out to us:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 12) {
                        contactInfo(icon: "envelope.fill", text: "support@reallifehq.app")
                        contactInfo(icon: "globe", text: "www.reallifehq.app")
                        contactInfo(icon: "clock.fill", text: "Response time: Within 48 hours")
                    }
                    .padding()
                    .background(themeManager.currentTheme.cardColor)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // App Info
                VStack(spacing: 8) {
                    Text("RealLifeHQ")
                        .font(.headline)
                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Support Action Card
    
    private func supportActionCard(icon: String, title: String, description: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(color)
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(themeManager.currentTheme.cardColor)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - FAQ Item
    
    private func faqItem(question: String, answer: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .font(.body)
                
                Text(question)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            Text(answer)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, 28)
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Feature Guide
    
    private func featureGuide(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(themeManager.currentTheme.accentColor)
                .frame(width: 40, height: 40)
                .background(themeManager.currentTheme.accentColor.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Tip Card
    
    private func tipCard(icon: String, title: String, tip: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(themeManager.currentTheme.primaryColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(tip)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Contact Info
    
    private func contactInfo(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(themeManager.currentTheme.primaryColor)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
    
    // MARK: - Email Function
    
    private func sendEmail() {
        let email = "support@reallifehq.app"
        let subject = "RealLifeHQ Support Request"
        let body = "Please describe your issue or question:\n\n"
        
        let coded = "mailto:\(email)?subject=\(subject)&body=\(body)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        if let emailURL = coded.flatMap({ URL(string: $0) }) {
            if UIApplication.shared.canOpenURL(emailURL) {
                UIApplication.shared.open(emailURL)
            }
        }
    }
}

#Preview {
    NavigationView {
        SupportView()
            .environmentObject(ThemeManager())
    }
}
