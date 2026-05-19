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
                        answer: "Go to Settings > Integrations > Apple Calendar Sync and enable the toggle. You'll be asked to grant calendar access permissions. Once enabled, your RealLifeHQ events will sync bidirectionally with Apple Calendar."
                    )
                    
                    faqItem(
                        question: "How does the Cleaning Tracker work?",
                        answer: "The Cleaning Tracker helps you maintain a clean home with scheduled tasks. Set up your cleaning schedule in the wizard, and the app will assign tasks daily. Complete tasks to build streaks and track your progress over time."
                    )
                    
                    faqItem(
                        question: "What is the Life Reminder Wizard?",
                        answer: "The Life Reminder Wizard asks you questions about your life (pets, vehicles, health, etc.) and automatically creates important recurring reminders for things like vet visits, oil changes, tax deadlines, and more."
                    )
                    
                    faqItem(
                        question: "How do I use the Recipe & Meal Planning features?",
                        answer: "Add recipes manually or import them. Create meal plans by scheduling recipes for specific dates and meal types (breakfast, lunch, dinner, snack). Shopping list items are automatically generated from your meal plans and can be checked off as you shop."
                    )
                    
                    faqItem(
                        question: "How do I back up my data?",
                        answer: "Your data is stored locally on your device for maximum privacy and security. All data is automatically included in your device's iCloud backup if enabled. There is no cloud sync to protect your privacy."
                    )
                    
                    faqItem(
                        question: "How do I set up recurring events?",
                        answer: "When creating or editing an event, toggle 'Recurring Event' and choose your preferred frequency (daily, weekly, monthly, or yearly). You can also use the Life Reminder Wizard to set up common recurring events automatically."
                    )
                    
                    faqItem(
                        question: "What's the difference between Events and Habits?",
                        answer: "Events are one-time or recurring appointments with specific dates and times. Habits are daily activities you want to track and build streaks for. Think of Events as your schedule and Habits as your goals."
                    )
                    
                    faqItem(
                        question: "How secure is the Vault?",
                        answer: "Vault passwords and secure notes are stored in iOS Keychain, Apple's most secure storage system, with hardware-level encryption. You can enable Face ID/Touch ID for additional protection. All data stays on your device and is never transmitted."
                    )
                    
                    faqItem(
                        question: "Can I use RealLifeHQ offline?",
                        answer: "Yes! RealLifeHQ is designed to work completely offline. All your data is stored locally on your device for maximum privacy and reliability. No internet connection is required for any feature."
                    )
                    
                    faqItem(
                        question: "How do Budget Categories work?",
                        answer: "Set up your monthly budget with income and category limits. Track expenses by category throughout the month. The Budget view shows remaining amounts, spending trends, and alerts you when approaching limits."
                    )
                    
                    faqItem(
                        question: "Can I set recurring expenses?",
                        answer: "Yes! When adding an expense, toggle 'Recurring' and choose the frequency (daily, weekly, monthly, or yearly). Recurring expenses are automatically added to your budget calculations."
                    )
                    
                    faqItem(
                        question: "How do I change my subscription?",
                        answer: "You can manage your subscription through the App Store. Go to iPhone Settings > [Your Name] > Subscriptions > RealLifeHQ to change plans, cancel, or restore purchases."
                    )
                    
                    faqItem(
                        question: "How do I delete my data?",
                        answer: "Go to Settings > Data > Clear All Data. This will permanently delete all your events, habits, journal entries, recipes, meal plans, budget data, and vault items. This action cannot be undone."
                    )
                    
                    faqItem(
                        question: "Why am I not receiving notifications?",
                        answer: "Check that notifications are enabled in both iOS Settings > Notifications > RealLifeHQ and within the app at Settings > Notifications. Also ensure Do Not Disturb/Focus modes are not blocking notifications."
                    )
                    
                    faqItem(
                        question: "What data does RealLifeHQ collect?",
                        answer: "None! All your data stays on your device. We don't collect, transmit, or share any personal information. See our Privacy Policy for complete details on our privacy-first approach."
                    )
                    
                    faqItem(
                        question: "Can I customize the app theme?",
                        answer: "Yes! Go to Settings > Theme to choose from multiple color themes. Pick colors that match your style and make the app feel personalized to you."
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
                        title: "Calendar & Events",
                        description: "Create one-time or recurring events with times, notes, and reminders. Sync bidirectionally with Apple Calendar. Use the Life Reminder Wizard for automatic life event setup."
                    )
                    
                    featureGuide(
                        icon: "target",
                        title: "Habit Tracker",
                        description: "Track daily habits, build streaks, and set custom reminders. Choose icons and colors to personalize each habit. View statistics and maintain consistency with streak tracking."
                    )
                    
                    featureGuide(
                        icon: "sparkles",
                        title: "Cleaning Tracker",
                        description: "Maintain a clean home with rotating task schedules. Complete daily tasks to build streaks. Track statistics including completion rates, streaks, and task history."
                    )
                    
                    featureGuide(
                        icon: "book.closed.fill",
                        title: "Journal",
                        description: "Write daily entries with optional mood tracking and tags. Get daily journal prompts for inspiration. Reflect on your thoughts and experiences privately."
                    )
                    
                    featureGuide(
                        icon: "dollarsign.circle.fill",
                        title: "Budget & Expenses",
                        description: "Set monthly budgets with category limits. Track expenses and recurring payments. View spending trends, remaining budgets, and financial insights throughout the month."
                    )
                    
                    featureGuide(
                        icon: "fork.knife",
                        title: "Recipes & Meal Planning",
                        description: "Save recipes with ingredients, instructions, and prep times. Plan meals for the week. Generate shopping lists automatically from meal plans and check items off as you shop."
                    )
                    
                    featureGuide(
                        icon: "lock.shield.fill",
                        title: "Secure Vault",
                        description: "Store passwords, secure notes, and sensitive photos safely. Protected by iOS Keychain encryption and optional Face ID/Touch ID. Your data never leaves your device."
                    )
                    
                    featureGuide(
                        icon: "house.fill",
                        title: "Home Dashboard",
                        description: "See all your important information at a glance. Quick access to today's events, habits, cleaning tasks, journal prompts, budget status, and more. Optimized for both iPhone and iPad."
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
                        icon: "wand.and.stars",
                        title: "Use the Life Reminder Wizard",
                        tip: "Answer a few quick questions about your life (pets, vehicles, health, property, etc.) and the wizard will automatically create personalized recurring reminders for important tasks like vet visits, oil changes, tax deadlines, and home maintenance."
                    )
                    
                    tipCard(
                        icon: "sparkles",
                        title: "Set Up Your Cleaning Schedule",
                        tip: "Use the Cleaning Setup Wizard to create a personalized cleaning schedule based on your home size and preferences. Complete tasks daily to build streaks and maintain a consistently clean home."
                    )
                    
                    tipCard(
                        icon: "calendar.badge.plus",
                        title: "Sync with Apple Calendar",
                        tip: "Enable Apple Calendar sync in Settings > Integrations to see your RealLifeHQ events alongside your other calendars. Changes sync bidirectionally so you can manage events from either app."
                    )
                    
                    tipCard(
                        icon: "fork.knife",
                        title: "Plan Your Meals",
                        tip: "Add your favorite recipes to RealLifeHQ, then use the meal planner to schedule them throughout the week. Shopping lists are automatically generated from your meal plans, making grocery shopping easier."
                    )
                    
                    tipCard(
                        icon: "bell.fill",
                        title: "Set Strategic Reminders",
                        tip: "For events, set reminders 1-2 hours before to give yourself time to prepare. For habits, set reminders at times when you're most likely to complete them, like morning routines or before bed."
                    )
                    
                    tipCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Track Your Progress",
                        tip: "Build momentum with habit and cleaning streaks. Check your statistics to see completion rates and patterns. Don't break the chain! Even if you miss a day, get right back to it."
                    )
                    
                    tipCard(
                        icon: "dollarsign.circle.fill",
                        title: "Set Realistic Budget Categories",
                        tip: "Break down your monthly budget into realistic category limits. The app will alert you when you're approaching limits, helping you stay on track with your financial goals."
                    )
                    
                    tipCard(
                        icon: "repeat",
                        title: "Use Recurring Expenses",
                        tip: "Set up recurring expenses for subscriptions, rent, utilities, and other regular payments. These are automatically factored into your monthly budget, giving you accurate spending forecasts."
                    )
                    
                    tipCard(
                        icon: "lock.shield.fill",
                        title: "Protect Your Vault",
                        tip: "Enable Face ID or Touch ID for your Vault in Settings for quick, secure access. Your passwords and notes are stored in iOS Keychain with hardware-level encryption."
                    )
                    
                    tipCard(
                        icon: "paintbrush.fill",
                        title: "Customize Your Theme",
                        tip: "Go to Settings > Theme to choose colors that match your style. Pick a theme that makes you happy to use the app daily. Themes apply across the entire app instantly."
                    )
                    
                    tipCard(
                        icon: "house.fill",
                        title: "Use the Home Dashboard",
                        tip: "The Home tab gives you a bird's-eye view of everything happening today. Check it each morning to see your events, habits, cleaning tasks, journal prompt, and budget status all in one place."
                    )
                    
                    tipCard(
                        icon: "ipad.and.iphone",
                        title: "iPad Sidebar Navigation",
                        tip: "On iPad, RealLifeHQ uses a sidebar for quick navigation between features. All features are optimized for the larger screen with grid layouts and enhanced views."
                    )
                    
                    tipCard(
                        icon: "shield.checkmark.fill",
                        title: "Your Privacy is Protected",
                        tip: "All your data stays on your device. RealLifeHQ doesn't collect, transmit, or share any personal information. No analytics, no ads, no tracking. Your data is yours alone."
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
                        contactInfo(icon: "envelope.fill", text: "sarah@thereallifehq.com")
                        contactInfo(icon: "globe", text: "www.thereallifehq.com")
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
        let email = "sarah@thereallifehq.com"
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
