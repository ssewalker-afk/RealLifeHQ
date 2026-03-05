import SwiftUI
import StoreKit

// MARK: - PaywallView
//
// Shown as a sheet whenever a free user taps a premium feature.
// Follows Apple App Store Review Guidelines §3.1.2:
//   - Clear pricing, trial length, and billing frequency before the buy button
//   - Auto-renewal disclosure
//   - Restore Purchases button
//   - Links to Terms of Use and Privacy Policy
//
// Layout (top → bottom):
//   X button  →  Headline  →  Features  →  Plan cards  →  CTA  →  Links  →  Legal

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @EnvironmentObject var themeManager: ThemeManager

    // Which plan card is highlighted — monthly is the default (it has the free trial)
    @State private var selectedProductID = SubscriptionManager.ProductID.monthly.rawValue

    // Holds an error string so we can show an alert if the purchase fails
    @State private var errorMessage: String?

    // Controls the in-app Terms / Privacy sheets
    @State private var showingTerms   = false
    @State private var showingPrivacy = false

    private var isMonthlySelected: Bool {
        selectedProductID == SubscriptionManager.ProductID.monthly.rawValue
    }

    private var selectedProduct: Product? {
        subscriptionManager.products.first { $0.id == selectedProductID }
    }

    var body: some View {
        // ZStack lets the X button float above everything else
        ZStack(alignment: .topTrailing) {

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 28) {
                    // Push content below the floating X button
                    Spacer().frame(height: 36)

                    headerSection
                    featuresSection
                    planSection
                    ctaSection
                    linksSection
                    legalSection
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
            .background(Color(.systemBackground).ignoresSafeArea())

            // ── X Close Button ──────────────────────────────────────────────
            // Sits in the top-right corner and dismisses the sheet
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color(.systemGray3))
            }
            .padding(.top, 16)
            .padding(.trailing, 20)
        }
        // As soon as the purchase succeeds, close the paywall automatically
        .onChange(of: subscriptionManager.isPremium) { _, isPremium in
            if isPremium { dismiss() }
        }
        // Mirror any manager-level errors into local state for the alert
        .onChange(of: subscriptionManager.lastError) { _, error in
            errorMessage = error
        }
        .alert("Something went wrong", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .sheet(isPresented: $showingTerms)   { TermsOfServiceView() }
        .sheet(isPresented: $showingPrivacy) { PrivacyPolicyView() }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: - Header
    // Icon + headline + subheadline. Clean, no gradient.
    // ─────────────────────────────────────────────────────────────────────────

    private var headerSection: some View {
        VStack(spacing: 12) {
            // Gradient-filled star icon using the current theme's colours
            Image(systemName: "star.circle.fill")
                .font(.system(size: 52))
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

            Text("Unlock RealLife HQ Premium")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Everything you need to organize your life — in one place.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: - Features
    // Five rows: SF Symbol icon on the left, bold title + description on the right.
    // ─────────────────────────────────────────────────────────────────────────

    // (SF Symbol name, bold title, short description)
    private let features: [(String, String, String)] = [
        (
            "bell.badge",
            "Life Reminders",
            "Set reminders for important dates and events so nothing slips through the cracks."
        ),
        (
            "calendar",
            "Apple Calendar Sync",
            "Sync your RealLife HQ calendar with your Apple Calendar for one unified view."
        ),
        (
            "book.closed",
            "Unlimited Journal Entries + PDF Export",
            "Write as much as you want and export your entries as a PDF anytime."
        ),
        (
            "checkmark.circle",
            "Unlimited Habits + Habit Reminders",
            "Track unlimited habits and get reminders to keep your streaks alive."
        ),
        (
            "sparkles",
            "Cleaning Reminders + Calendar Sync",
            "Get notified for cleaning tasks and add them to your Apple Calendar automatically."
        ),
    ]

    private var featuresSection: some View {
        VStack(spacing: 18) {
            ForEach(Array(features.enumerated()), id: \.offset) { _, feature in
                HStack(alignment: .top, spacing: 14) {
                    // Themed icon — fixed width keeps all titles left-aligned
                    Image(systemName: feature.0)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .frame(width: 28, alignment: .center)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(feature.1)
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text(feature.2)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()
                }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: - Plan Selector
    // Two side-by-side cards. Monthly is selected by default.
    // ─────────────────────────────────────────────────────────────────────────

    @ViewBuilder
    private var planSection: some View {
        if subscriptionManager.products.isEmpty {
            // Products haven't loaded from App Store Connect yet — show a spinner
            HStack {
                Spacer()
                ProgressView("Loading plans…")
                Spacer()
            }
            .padding(.vertical)
        } else {
            HStack(spacing: 14) {
                // Always show Monthly on the left, Lifetime on the right.
                // We can't rely on alphabetical order because "lifetime" < "monthly".
                let displayOrder: [String] = [
                    SubscriptionManager.ProductID.monthly.rawValue,
                    SubscriptionManager.ProductID.lifetime.rawValue
                ]
                let sorted = subscriptionManager.products.sorted { a, b in
                    let ai = displayOrder.firstIndex(of: a.id) ?? Int.max
                    let bi = displayOrder.firstIndex(of: b.id) ?? Int.max
                    return ai < bi
                }
                ForEach(sorted) { product in
                    PlanCard(
                        product: product,
                        isSelected: product.id == selectedProductID,
                        onSelect: { selectedProductID = product.id }
                    )
                }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: - CTA Button
    // Label swaps between "Start Free Trial" and "Buy Lifetime Access"
    // depending on which plan card is selected.
    // ─────────────────────────────────────────────────────────────────────────

    private var ctaSection: some View {
        VStack(spacing: 10) {
            Button {
                guard let product = selectedProduct else { return }
                // Kick off the StoreKit purchase sheet
                Task { await subscriptionManager.purchase(product) }
            } label: {
                ZStack {
                    if subscriptionManager.isPurchasing {
                        ProgressView().tint(.white)
                    } else {
                        Text(isMonthlySelected ? "Start Free Trial" : "Buy Lifetime Access")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
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
                .cornerRadius(16)
            }
            .disabled(subscriptionManager.isPurchasing || selectedProduct == nil)
            .buttonStyle(PlainButtonStyle())

            // Small contextual note shown only for the monthly plan
            if isMonthlySelected {
                Text("7-day free trial, then $1.99/month. Cancel anytime.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: - Secondary Links
    // Apple requires all three: Restore Purchases, Terms of Use, Privacy Policy.
    // ─────────────────────────────────────────────────────────────────────────

    private var linksSection: some View {
        HStack(spacing: 6) {
            Button {
                Task { await subscriptionManager.restorePurchases() }
            } label: {
                Text("Restore Purchases")
                    .font(.footnote)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            .disabled(subscriptionManager.isPurchasing)

            Text("·")
                .font(.footnote)
                .foregroundColor(.secondary)

            Button { showingTerms = true } label: {
                Text("Terms of Use")
                    .font(.footnote)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }

            Text("·")
                .font(.footnote)
                .foregroundColor(.secondary)

            Button { showingPrivacy = true } label: {
                Text("Privacy Policy")
                    .font(.footnote)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: - Legal Disclosure
    // Required verbatim by Apple App Store Review Guidelines §3.1.2.
    // ─────────────────────────────────────────────────────────────────────────

    private var legalSection: some View {
        VStack(spacing: 10) {
            Divider()

            Text("""
Your 7-day free trial converts to a $1.99/month subscription unless canceled at least 24 hours before the trial ends. Payment will be charged to your Apple ID at confirmation of purchase. Your subscription automatically renews each month at $1.99 unless canceled at least 24 hours before the end of the current period. You can manage or cancel your subscription anytime in your Apple ID Account Settings. Lifetime Access is a one-time purchase of $24.99 and does not auto-renew.
""")
            .font(.caption2)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Plan Card
//
// A tappable card for one pricing option.
// Monthly card  → "BEST VALUE" green badge, shows trial + monthly price
// Lifetime card → "LIFETIME" badge, shows one-time price
//
// Selected card gets a coloured border and a slight scale-up for visual feedback.

private struct PlanCard: View {
    let product: Product
    let isSelected: Bool
    let onSelect: () -> Void

    @EnvironmentObject var themeManager: ThemeManager

    private var isMonthly: Bool {
        product.id == SubscriptionManager.ProductID.monthly.rawValue
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {

                // ── Top badge ────────────────────────────────────────────────
                if isMonthly {
                    Text("BEST VALUE")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.5)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .cornerRadius(20)
                } else {
                    Text("LIFETIME")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.5)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(themeManager.currentTheme.primaryColor.opacity(0.12))
                        .cornerRadius(20)
                }

                // ── Price block ──────────────────────────────────────────────
                if isMonthly {
                    // Monthly: show the trial details stacked
                    VStack(spacing: 2) {
                        Text("7 days")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(isSelected ? themeManager.currentTheme.primaryColor : .primary)
                        Text("free")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("then $1.99")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(isSelected ? themeManager.currentTheme.primaryColor : .primary)
                        Text("per month")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    // Lifetime: show the one-time price
                    VStack(spacing: 2) {
                        Text(product.displayPrice)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(isSelected ? themeManager.currentTheme.primaryColor : .primary)
                        Text("one-time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("yours forever")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected
                        ? themeManager.currentTheme.primaryColor.opacity(0.06)
                        : Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? themeManager.currentTheme.primaryColor : Color(.systemGray4),
                        lineWidth: isSelected ? 2.5 : 1
                    )
            )
            // Slight scale-up when selected so the choice feels tactile
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
