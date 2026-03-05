import SwiftUI

// MARK: - Support View
// Help and support resources for users

struct SupportView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingEmailComposer = false
    @State private var scrollToSection: SupportSection? = nil

    enum SupportSection: String, CaseIterable {
        case freePremium = "Free vs. Premium"
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
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        themeManager.currentTheme.primaryColor,
                                        themeManager.currentTheme.accentColor
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text("Support & Help")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Everything you need to make the most of RealLife HQ")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
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
                            description: "Learn how to use RealLife HQ",
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

                    // Getting Started Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Getting Started")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        gettingStartedCard(
                            number: "1",
                            title: "Explore the Home Dashboard",
                            description: "Start on the Home tab to see an overview of everything happening today — your events, habits, cleaning tasks, journal prompt, and budget status at a glance.",
                            icon: "house.fill"
                        )

                        gettingStartedCard(
                            number: "2",
                            title: "Add Your First Items",
                            description: "Create events in Calendar, add habits to track, write in your Journal, or set up your Budget to get started. Free users can add up to 3 habits and 3 journal entries.",
                            icon: "plus.circle.fill"
                        )

                        gettingStartedCard(
                            number: "3",
                            title: "Try the Wizards",
                            description: "Use the Life Reminder Wizard (Settings > Notifications) to auto-create recurring reminders, and the Cleaning Setup Wizard to build your personalized cleaning schedule. Reminders and calendar sync require Premium.",
                            icon: "wand.and.stars"
                        )

                        gettingStartedCard(
                            number: "4",
                            title: "Upgrade to Premium",
                            description: "Unlock unlimited habits, unlimited journal entries, PDF export, life reminders, Apple Calendar sync, and cleaning notifications. Start with a 7-day free trial — cancel anytime.",
                            icon: "star.circle.fill"
                        )

                        gettingStartedCard(
                            number: "5",
                            title: "Customize Your Experience",
                            description: "Go to Settings to choose from 12 themes with unique colors and fonts, enable notifications, and personalize the app to fit your life.",
                            icon: "gear"
                        )
                    }

                    Divider()
                        .padding(.vertical, 8)

                    // Free vs. Premium Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Free vs. Premium")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .id(SupportSection.freePremium.rawValue)

                        Text("RealLife HQ is free to download and use. Premium unlocks the full experience.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)

                        // Free tier card
                        planComparisonCard(
                            tier: "Free",
                            badgeColor: Color(.systemGray),
                            badgeText: "FREE",
                            icon: "lock.open.fill",
                            items: [
                                ("checkmark.circle.fill", "Up to 3 habits", true),
                                ("checkmark.circle.fill", "Up to 3 journal entries", true),
                                ("checkmark.circle.fill", "Full calendar & events", true),
                                ("checkmark.circle.fill", "Budget & expense tracking", true),
                                ("checkmark.circle.fill", "Cleaning schedule & tracker", true),
                                ("checkmark.circle.fill", "Meal planning & recipes", true),
                                ("checkmark.circle.fill", "12 themes & customization", true),
                                ("xmark.circle.fill", "Life Reminders (notifications)", false),
                                ("xmark.circle.fill", "Apple Calendar Sync", false),
                                ("xmark.circle.fill", "Unlimited habits", false),
                                ("xmark.circle.fill", "Unlimited journal entries", false),
                                ("xmark.circle.fill", "Journal PDF export", false),
                                ("xmark.circle.fill", "Cleaning reminders", false),
                                ("xmark.circle.fill", "Habit reminders", false),
                            ]
                        )

                        // Premium tier card
                        planComparisonCard(
                            tier: "Premium",
                            badgeColor: themeManager.currentTheme.primaryColor,
                            badgeText: "PREMIUM",
                            icon: "star.circle.fill",
                            items: [
                                ("checkmark.circle.fill", "Everything in Free", true),
                                ("checkmark.circle.fill", "Unlimited habits + reminders", true),
                                ("checkmark.circle.fill", "Unlimited journal entries", true),
                                ("checkmark.circle.fill", "Journal PDF export (print, email, save)", true),
                                ("checkmark.circle.fill", "Life Reminders with notifications", true),
                                ("checkmark.circle.fill", "Apple Calendar Sync (bidirectional)", true),
                                ("checkmark.circle.fill", "Cleaning reminders + calendar sync", true),
                            ]
                        )

                        // Pricing card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Pricing")
                                .font(.subheadline)
                                .fontWeight(.bold)

                            pricingRow(
                                title: "Monthly",
                                price: "$1.99/month",
                                note: "7-day free trial included"
                            )
                            Divider()
                            pricingRow(
                                title: "Lifetime Access",
                                price: "$24.99 one-time",
                                note: "Pay once, yours forever"
                            )
                        }
                        .padding()
                        .background(themeManager.currentTheme.cardColor)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    Divider()
                        .padding(.vertical, 8)

                    // FAQ Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Frequently Asked Questions")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .id(SupportSection.faqs.rawValue)

                        faqItem(
                            question: "What's included in the free version?",
                            answer: "The free version gives you full access to Calendar, Budget, Cleaning Tracker, Meal Planning, and Recipes with no limits. Habits and Journal entries are capped at 3 each. Premium-only features (reminders, calendar sync, PDF export) are locked but visible so you know what's available."
                        )

                        faqItem(
                            question: "How do I upgrade to Premium?",
                            answer: "Tap any locked feature (a lock icon or upgrade banner) to open the Premium paywall, or go to Settings > My Plan > Upgrade to Premium. Choose between a Monthly plan ($1.99/month with a 7-day free trial) or Lifetime Access ($24.99 one-time). Your premium status activates instantly after purchase."
                        )

                        faqItem(
                            question: "What happens when I hit the 3-habit or 3-journal limit?",
                            answer: "Free users can create up to 3 habits and 3 journal entries. When you reach the limit, the app shows an upgrade prompt. Your existing items are always safe — upgrading to Premium simply unlocks the ability to add more."
                        )

                        faqItem(
                            question: "How do I export my journal as a PDF?",
                            answer: "This is a Premium feature. Open the Journal tab, tap the share icon in the top-right corner, and choose to export all entries or just the current one. The PDF is formatted and ready to print, email, save to Files, or share via Messages."
                        )

                        faqItem(
                            question: "How do I restore my purchases?",
                            answer: "If you reinstall the app or switch devices, tap 'Restore Purchases' on the paywall screen (or go to Settings > My Plan). The app will sync with the App Store and restore your premium access automatically."
                        )

                        faqItem(
                            question: "How do I manage or cancel my subscription?",
                            answer: "Go to Settings > My Plan and tap 'Manage Subscription'. This takes you directly to your Apple ID subscription settings where you can change plans or cancel. Canceling stops the next renewal — you keep premium access until the end of the paid period."
                        )

                        faqItem(
                            question: "What is Lifetime Access?",
                            answer: "Lifetime Access is a one-time purchase of $24.99 that gives you permanent Premium access with no recurring charges. It's the best value if you plan to use RealLife HQ long-term. It does not auto-renew."
                        )

                        faqItem(
                            question: "How do I sync with Apple Calendar?",
                            answer: "This is a Premium feature. Go to Settings > Integrations > Apple Calendar Sync and enable the toggle. You'll be asked to grant calendar access permissions. Once enabled, your RealLife HQ events sync bidirectionally with Apple Calendar."
                        )

                        faqItem(
                            question: "How does the Cleaning Tracker work?",
                            answer: "The Cleaning Tracker helps you maintain a clean home with a personalized schedule. Run the Cleaning Setup Wizard to choose your cleaning days, focus areas, and assign rooms to specific days. Cleaning reminders and Apple Calendar sync for cleaning tasks require Premium."
                        )

                        faqItem(
                            question: "What is the Life Reminder Wizard?",
                            answer: "The Life Reminder Wizard (Settings > Notifications > Life Reminders) is a Premium feature. Answer a few quick questions about your life — pets, vehicles, health, property — and it automatically creates personalized recurring reminder notifications for things like vet visits, oil changes, and tax deadlines."
                        )

                        faqItem(
                            question: "How do I switch Calendar views?",
                            answer: "In the Calendar tab, use the Day / Week / Month segmented picker at the top to switch views. Day view shows an hourly planner, Week view shows a 7-day strip with your events, and Month view shows a full calendar grid with event dots and a daily event list below."
                        )

                        faqItem(
                            question: "How do I back up my data?",
                            answer: "Your data is stored locally on your device for maximum privacy and security. All data is automatically included in your device's iCloud backup if enabled. There is no cloud sync to protect your privacy."
                        )

                        faqItem(
                            question: "How do I set up recurring events?",
                            answer: "When creating or editing an event, toggle 'Recurring Event' and choose your preferred frequency (daily, weekly, monthly, or yearly). You can also use the Life Reminder Wizard (Premium) to set up common recurring events automatically."
                        )

                        faqItem(
                            question: "What's the difference between Events and Habits?",
                            answer: "Events are one-time or recurring appointments with specific dates and times. Habits are daily activities you want to track and build streaks for. Think of Events as your schedule and Habits as your goals. Free users can track up to 3 habits; Premium users have unlimited habits with optional reminders."
                        )

                        faqItem(
                            question: "Can I use RealLife HQ offline?",
                            answer: "Yes! RealLife HQ is designed to work completely offline. All your data is stored locally on your device for maximum privacy and reliability. No internet connection is required for any feature."
                        )

                        faqItem(
                            question: "How do Budget Categories work?",
                            answer: "Set up your monthly budget with income and category limits. Track expenses by category throughout the month. The Budget view shows remaining amounts, spending trends, and alerts you when approaching limits. Budget tracking is fully available on the free plan."
                        )

                        faqItem(
                            question: "Can I set recurring expenses?",
                            answer: "Yes! When adding an expense, toggle 'Recurring' and choose the frequency (daily, weekly, monthly, or yearly). Recurring expenses are automatically added to your monthly budget calculations."
                        )

                        faqItem(
                            question: "Why am I not receiving notifications?",
                            answer: "Notifications require Premium. If you're a Premium user and not receiving them, check that notifications are enabled in both iOS Settings > Notifications > RealLife HQ and within the app at Settings > Notifications. Also ensure Do Not Disturb or Focus modes are not blocking notifications."
                        )

                        faqItem(
                            question: "What data does RealLife HQ collect?",
                            answer: "None! All your data stays on your device. We don't collect, transmit, or share any personal information. See our Privacy Policy for complete details on our privacy-first approach."
                        )

                        faqItem(
                            question: "Can I customize the app theme?",
                            answer: "Yes! Go to Settings > Appearance > Theme to choose from 12 themes across Light, Dark, and Vibrant categories. Each theme has its own background color, accent color, and font style. Themes are available on both free and premium plans."
                        )

                        faqItem(
                            question: "How do I delete my data?",
                            answer: "Go to Settings > Data > Clear All Data. This will permanently delete all your events, habits, journal entries, budget data, and cleaning history. This action cannot be undone."
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
                            .id(SupportSection.features.rawValue)

                        featureGuide(
                            icon: "calendar",
                            title: "Calendar & Events",
                            description: "Create one-time or recurring events with times, notes, and reminders. Switch between Day, Week, and Month views. Apple Calendar Sync (bidirectional) is a Premium feature.",
                            isPremium: false
                        )

                        featureGuide(
                            icon: "target",
                            title: "Habit Tracker",
                            description: "Track daily habits and build streaks. Free users can track up to 3 habits. Premium unlocks unlimited habits and the ability to set custom reminders for each one.",
                            isPremium: false,
                            premiumNote: "Unlimited habits + reminders"
                        )

                        featureGuide(
                            icon: "sparkles",
                            title: "Cleaning Tracker",
                            description: "Maintain a clean home with a personalized rotating schedule. Assign rooms to specific days using the Setup Wizard. Cleaning reminders and Apple Calendar sync for tasks require Premium.",
                            isPremium: false,
                            premiumNote: "Cleaning reminders + calendar sync"
                        )

                        featureGuide(
                            icon: "book.closed.fill",
                            title: "Journal",
                            description: "Write daily entries with optional mood tracking and tags. Get daily prompts for inspiration. Free users can create up to 3 entries. Premium unlocks unlimited entries and PDF export (shareable via print, email, or Files).",
                            isPremium: false,
                            premiumNote: "Unlimited entries + PDF export"
                        )

                        featureGuide(
                            icon: "bell.badge",
                            title: "Life Reminders",
                            description: "Answer questions about your pets, vehicles, health, and home — the wizard creates personalized recurring reminder notifications automatically. Requires Premium.",
                            isPremium: true
                        )

                        featureGuide(
                            icon: "dollarsign.circle.fill",
                            title: "Budget & Expenses",
                            description: "Set monthly budgets with category limits. Track expenses and recurring payments. View spending trends, remaining budgets, and financial insights. Fully available on the free plan.",
                            isPremium: false
                        )

                        featureGuide(
                            icon: "fork.knife",
                            title: "Meal Planning & Recipes",
                            description: "Browse and save recipes, create weekly meal plans, and build a shopping list. Fully available on the free plan.",
                            isPremium: false
                        )

                        featureGuide(
                            icon: "house.fill",
                            title: "Home Dashboard",
                            description: "See all your important information at a glance. Quick access to today's events, habits, cleaning tasks, journal, and budget. The journal card celebrates when you've already written today's entry.",
                            isPremium: false
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
                            .id(SupportSection.tips.rawValue)

                        tipCard(
                            icon: "star.circle.fill",
                            title: "Start with the Free Trial",
                            tip: "Not sure about Premium? Start a 7-day free trial from the paywall or Settings > My Plan. You get full access to every feature — cancel before the trial ends and you won't be charged anything.",
                            isPremium: true
                        )

                        tipCard(
                            icon: "wand.and.stars",
                            title: "Use the Life Reminder Wizard",
                            tip: "Answer a few quick questions about your life (pets, vehicles, health, property, etc.) and the wizard will automatically create personalized recurring reminders. Find it under Settings > Notifications > Life Reminders. Requires Premium.",
                            isPremium: true
                        )

                        tipCard(
                            icon: "sparkles",
                            title: "Set Up Your Cleaning Schedule",
                            tip: "Use the Cleaning Setup Wizard to create a personalized schedule based on your home and preferences. Assign specific rooms to specific days. Enable cleaning reminders and calendar sync (Premium) so you never forget.",
                            isPremium: false
                        )

                        tipCard(
                            icon: "book.closed.fill",
                            title: "Export Your Journal as PDF",
                            tip: "Premium users can tap the share icon in the Journal tab to export all entries or a single entry as a formatted PDF. Share it via email, print it, or save it to Files — great for reflection or record-keeping.",
                            isPremium: true
                        )

                        tipCard(
                            icon: "calendar.badge.plus",
                            title: "Switch Calendar Views",
                            tip: "Use the Day / Week / Month picker at the top of the Calendar tab to find the view that works best for you. Week view is great for planning ahead; Month view gives you a big-picture look at your schedule.",
                            isPremium: false
                        )

                        tipCard(
                            icon: "calendar.badge.clock",
                            title: "Sync with Apple Calendar",
                            tip: "Enable Apple Calendar sync in Settings > Integrations to see your RealLife HQ events alongside your other calendars. Changes sync bidirectionally so you can manage events from either app. Requires Premium.",
                            isPremium: true
                        )

                        tipCard(
                            icon: "bell.fill",
                            title: "Set Strategic Reminders",
                            tip: "For habits, set reminders at times when you're most likely to complete them — like morning routines or before bed. For cleaning, reminders fire on the days assigned in your schedule. All reminders require Premium.",
                            isPremium: true
                        )

                        tipCard(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Track Your Progress",
                            tip: "Build momentum with habit and cleaning streaks. Check your statistics to see completion rates and patterns. Even if you miss a day, get right back to it — consistency over perfection.",
                            isPremium: false
                        )

                        tipCard(
                            icon: "dollarsign.circle.fill",
                            title: "Set Realistic Budget Categories",
                            tip: "Break down your monthly budget into realistic category limits. The app will alert you when you're approaching limits, helping you stay on track with your financial goals.",
                            isPremium: false
                        )

                        tipCard(
                            icon: "repeat",
                            title: "Use Recurring Expenses",
                            tip: "Set up recurring expenses for subscriptions, rent, utilities, and other regular payments. These are automatically factored into your monthly budget, giving you accurate spending forecasts.",
                            isPremium: false
                        )

                        tipCard(
                            icon: "paintbrush.fill",
                            title: "Customize Your Theme",
                            tip: "Go to Settings > Theme to choose from 12 themes across Light, Dark, and Vibrant categories. Each theme changes background colors, accent colors, and fonts across the entire app. Available on all plans.",
                            isPremium: false
                        )

                        tipCard(
                            icon: "house.fill",
                            title: "Use the Home Dashboard",
                            tip: "The Home tab gives you a bird's-eye view of everything happening today. Check it each morning to see your events, habits, cleaning tasks, journal status, and budget all in one place.",
                            isPremium: false
                        )

                        tipCard(
                            icon: "shield.checkmark.fill",
                            title: "Your Privacy is Protected",
                            tip: "All your data stays on your device. RealLife HQ doesn't collect, transmit, or share any personal information. No analytics, no ads, no tracking. Your data is yours alone.",
                            isPremium: false
                        )
                    }

                    Divider()
                        .padding(.vertical, 8)

                    // Contact Information
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Image(systemName: "envelope.circle.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            themeManager.currentTheme.primaryColor,
                                            themeManager.currentTheme.accentColor
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )

                            Text("Still Need Help?")
                                .font(.title2)
                                .fontWeight(.bold)
                                .id(SupportSection.contact.rawValue)

                            Text("We're here to help! Reach out to us:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        VStack(spacing: 12) {
                            contactInfo(icon: "envelope.fill", text: "sarah@thereallifehq.com")
                            contactInfo(icon: "globe", text: "www.thereallifehq.com")
                            contactInfo(icon: "clock.fill", text: "Response time: Within 48 hours")
                        }
                        .padding()
                        .background(themeManager.currentTheme.cardColor)
                        .cornerRadius(12)

                        Button {
                            sendEmail()
                        } label: {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                Text("Contact Support")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [
                                        themeManager.currentTheme.primaryColor,
                                        themeManager.currentTheme.accentColor
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)

                    // App Info
                    VStack(spacing: 8) {
                        Text("RealLife HQ")
                            .font(.headline)
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Plan Comparison Card

    private func planComparisonCard(
        tier: String,
        badgeColor: Color,
        badgeText: String,
        icon: String,
        items: [(String, String, Bool)]
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(badgeColor)

                Text(tier)
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                Text(badgeText)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.5)
                    .foregroundColor(badgeColor == Color(.systemGray) ? .white : .white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(badgeColor)
                    .cornerRadius(20)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: item.0)
                            .font(.caption)
                            .foregroundColor(item.2 ? .green : Color(.systemGray3))
                            .frame(width: 16)
                        Text(item.1)
                            .font(.caption)
                            .foregroundColor(item.2 ? .primary : Color(.systemGray3))
                    }
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Pricing Row

    private func pricingRow(title: String, price: String, note: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(note)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(price)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(themeManager.currentTheme.primaryColor)
        }
    }

    // MARK: - Getting Started Card

    private func gettingStartedCard(number: String, title: String, description: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                themeManager.currentTheme.primaryColor,
                                themeManager.currentTheme.accentColor
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)

                Text(number)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .font(.subheadline)

                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
        .padding(.horizontal)
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

    private func featureGuide(icon: String, title: String, description: String, isPremium: Bool, premiumNote: String? = nil) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(themeManager.currentTheme.accentColor)
                .frame(width: 40, height: 40)
                .background(themeManager.currentTheme.accentColor.opacity(0.1))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    if isPremium {
                        premiumBadge("PREMIUM")
                    } else if let note = premiumNote {
                        premiumBadge(note)
                    }
                }
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

    private func tipCard(icon: String, title: String, tip: String, isPremium: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isPremium ? themeManager.currentTheme.accentColor : themeManager.currentTheme.primaryColor)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    if isPremium {
                        premiumBadge("PREMIUM")
                    }
                }
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

    // MARK: - Premium Badge

    private func premiumBadge(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 8, weight: .bold))
            .tracking(0.3)
            .foregroundColor(themeManager.currentTheme.primaryColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(themeManager.currentTheme.primaryColor.opacity(0.12))
            .cornerRadius(6)
            .lineLimit(1)
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
        let subject = "RealLife HQ Support Request"
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
