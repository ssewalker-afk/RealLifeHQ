import SwiftUI

// MARK: - PremiumToggleRow
//
// A reusable toggle row for features that are only available to premium subscribers.
//
// HOW TO USE IT:
//   PremiumToggleRow(
//       title: "Daily Reminders",
//       icon: "bell.fill",
//       subtitle: "Get notified when it's time",  // optional
//       isOn: $myBoolValue
//   )
//
// WHAT IT DOES FOR EACH USER TYPE:
//   • Premium user  → works exactly like a normal Toggle. They can turn it on or off freely.
//   • Free user     → the toggle is shown but always appears "off" with a lock icon.
//                     Tapping anywhere on the row opens the PaywallView sheet.
//   • Downgrade case (was premium, cancelled) → if they had this feature enabled before
//                     cancelling, the toggle appears "off" and locked the next time
//                     the view appears, and the feature will not run.

struct PremiumToggleRow: View {

    // MARK: - Parameters

    /// The main label shown on the row (e.g. "Daily Cleaning Reminders").
    let title: String

    /// The SF Symbol name for the icon on the left side (e.g. "bell.fill").
    let icon: String

    /// An optional shorter description shown below the title in smaller text.
    var subtitle: String? = nil

    /// The actual on/off boolean this toggle controls.
    /// PremiumToggleRow only writes to this when the user is premium.
    @Binding var isOn: Bool

    // MARK: - Environment

    /// Reads whether the user has an active subscription.
    /// Injected at the app root in RealLifeHQApp.swift via .environment(subscriptionManager).
    @Environment(SubscriptionManager.self) private var subscriptionManager

    /// Used to apply the app's current theme colour to the toggle.
    @EnvironmentObject var themeManager: ThemeManager

    // MARK: - Private State

    /// Controls whether the PaywallView upgrade sheet is visible.
    @State private var showingPaywall = false

    // MARK: - Body

    var body: some View {
        HStack {

            // Left side: icon + title (and optional subtitle below)
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } icon: {
                Image(systemName: icon)
            }

            Spacer()

            // Show a small lock icon for free users so it's obvious this is a paid feature.
            if !subscriptionManager.isPremium {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // The toggle control.
            // • Premium users: connected to the real binding — fully interactive.
            // • Free users: always shows as "off" (via premiumBinding below)
            //   and is disabled so it can't be flipped by tapping the toggle directly.
            Toggle("", isOn: premiumBinding)
                .labelsHidden()                                   // we provide our own label above
                .tint(themeManager.currentTheme.primaryColor)
                .disabled(!subscriptionManager.isPremium)
        }
        // For free users: place a transparent, invisible button over the entire row.
        // This intercepts all taps — including taps on the disabled toggle — and
        // opens the paywall sheet instead. Color.clear is invisible but still
        // receives touch events, which is exactly what we need here.
        .overlay {
            if !subscriptionManager.isPremium {
                Button {
                    showingPaywall = true
                } label: {
                    Color.clear
                }
            }
        }
        // Present the PaywallView as a sheet when showingPaywall becomes true.
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
    }

    // MARK: - Premium Binding

    /// A custom Binding that wraps the real isOn value with a premium check.
    ///
    /// get: Returns false when the user is not premium, so the toggle always
    ///      appears "off" for free users — even if the stored data says it's
    ///      on (this is the downgrade case: was premium → cancelled).
    ///
    /// set: Only writes the new value when the user is premium.
    ///      If they're not premium, we do nothing here because the transparent
    ///      overlay button above already handles routing them to the paywall.
    private var premiumBinding: Binding<Bool> {
        Binding(
            get: {
                // Show the real stored value only if the user is premium.
                // Free users always see "off" regardless of what's stored.
                subscriptionManager.isPremium && isOn
            },
            set: { newValue in
                if subscriptionManager.isPremium {
                    isOn = newValue
                }
                // Not premium → do nothing. The overlay button handles the tap.
            }
        )
    }
}
