//
//  SubscriptionView.swift
//  RealLifeHQ
//
//  Created by Sarah Walker on 1/10/26.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedProduct: Product?
    @State private var showError = false
    
    // Use @State with the shared instance for @Observable objects
    private let storeManager = StoreManager.shared
    
    var isOnboarding: Bool {
        !dataManager.settings.hasCompletedOnboarding
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        headerView
                        
                        // Features
                        featuresView
                        
                        // Trial information
                        trialInfoView
                        
                        // Subscription options
                        subscriptionOptionsView
                        
                        // Terms and restore
                        bottomView
                    }
                    .padding()
                }
            }
            .navigationTitle("RealLife HQ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Only show close button if not onboarding (existing users can dismiss)
                if !isOnboarding {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
            }
            .alert("Purchase Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                if let error = storeManager.purchaseError {
                    Text(error.localizedDescription)
                }
            }
        }
        .interactiveDismissDisabled(isOnboarding) // Prevent swipe-to-dismiss on onboarding
        .onAppear {
            // Auto-select yearly by default (best value)
            if selectedProduct == nil {
                selectedProduct = storeManager.yearlySubscription ?? storeManager.monthlySubscription
            }
            
            // Debug logging
            print("📱 SubscriptionView appeared")
            print("📦 Products loaded: monthly=\(storeManager.monthlySubscription != nil), yearly=\(storeManager.yearlySubscription != nil)")
            print("✅ Selected product: \(selectedProduct?.id ?? "none")")
            print("🔒 isPurchasing: \(storeManager.isPurchasing)")
            print("🎯 isOnboarding: \(isOnboarding)")
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // App icon or logo
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Organize Your Entire Life")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            
            Text("Calendar, habits, journal, budget, vault & reminders — all in one place.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Features View
    
    private var featuresView: some View {
        VStack(alignment: .leading, spacing: 16) {
            FeatureRow(
                icon: "calendar.circle.fill",
                title: "Smart Calendar & Events",
                description: "Sync with Apple Calendar, set reminders"
            )
            
            FeatureRow(
                icon: "wand.and.stars",
                title: "Life Reminder Wizard",
                description: "Auto-create important life reminders"
            )
            
            FeatureRow(
                icon: "target",
                title: "Habit Tracker",
                description: "Build streaks and stay consistent"
            )
            
            FeatureRow(
                icon: "sparkles",
                title: "Cleaning Tracker",
                description: "Rotating schedule & streak tracking"
            )
            
            FeatureRow(
                icon: "book.circle.fill",
                title: "Daily Journal",
                description: "Reflect with guided prompts"
            )
            
            FeatureRow(
                icon: "dollarsign.circle.fill",
                title: "Budget & Expenses",
                description: "Track spending, set category limits"
            )
            
            FeatureRow(
                icon: "fork.knife.circle.fill",
                title: "Recipes & Meal Planning",
                description: "Plan meals, auto-generate shopping lists"
            )
            
            FeatureRow(
                icon: "lock.shield.fill",
                title: "Secure Vault",
                description: "iOS Keychain encryption + Face ID"
            )
            
            FeatureRow(
                icon: "house.circle.fill",
                title: "Home Dashboard",
                description: "See everything at a glance"
            )
            
            FeatureRow(
                icon: "paintbrush.fill",
                title: "Custom Themes",
                description: "Personalize with color themes"
            )
            
            FeatureRow(
                icon: "shield.checkmark.fill",
                title: "Complete Privacy",
                description: "All data stays on your device"
            )
            
            FeatureRow(
                icon: "ipad.and.iphone",
                title: "iPhone & iPad Optimized",
                description: "Beautiful on all screen sizes"
            )
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Trial Info View
    
    private var trialInfoView: some View {
        VStack(spacing: 12) {
            Text("Start your 7-day free trial")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            
            Text("Your free trial applies to either subscription plan. After the 7-day trial ends, you will be charged the price of the plan you select unless you cancel at least 24 hours before the trial ends.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            // Extra clarity statement
            Text("Cancel anytime during the 7-day trial to avoid being charged.")
                .font(.subheadline.bold())
                .foregroundStyle(.blue)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Subscription Options View
    
    private var subscriptionOptionsView: some View {
        VStack(spacing: 16) {
            // Show loading or error state if products aren't loaded
            if storeManager.monthlySubscription == nil && storeManager.yearlySubscription == nil {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading subscription options...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    VStack(spacing: 8) {
                        Text("If this persists:")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        
                        Text("1. Check StoreKit Configuration File")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("2. Simulator: Xcode → Debug → StoreKit")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("3. Or skip for testing")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    
                    // Add "Skip for Testing" button (simulator/debug only)
                    #if DEBUG
                    Button {
                        // Skip subscription requirement for testing
                        var settings = dataManager.settings
                        settings.hasCompletedOnboarding = true
                        dataManager.updateSettings(settings)
                        
                        if !isOnboarding {
                            dismiss()
                        }
                    } label: {
                        Text("Skip for Testing (Debug Only)")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.orange)
                            .cornerRadius(12)
                    }
                    .padding(.top)
                    #endif
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            } else {
                // Monthly subscription
                if let monthly = storeManager.monthlySubscription {
                    SubscriptionCard(
                        product: monthly,
                        isSelected: selectedProduct?.id == monthly.id,
                        planName: "Monthly Plan",
                        onTap: {
                            print("📱 Monthly plan tapped")
                            selectedProduct = monthly
                            print("📱 Selected product updated to: \(selectedProduct?.id ?? "none")")
                        }
                    )
                }
                
                // Yearly subscription (show as best value)
                if let yearly = storeManager.yearlySubscription {
                    SubscriptionCard(
                        product: yearly,
                        isSelected: selectedProduct?.id == yearly.id,
                        planName: "Yearly Plan",
                        badge: "Save 16%",
                        onTap: {
                            print("📱 Yearly plan tapped")
                            selectedProduct = yearly
                            print("📱 Selected product updated to: \(selectedProduct?.id ?? "none")")
                        }
                    )
                }
            }
            
            // Subscribe button
            subscribeButton
        }
    }
    
    private var subscribeButton: some View {
        Button {
            print("🔵 Subscribe button tapped")
            print("🔵 Selected product: \(selectedProduct?.id ?? "none")")
            print("🔵 isPurchasing: \(storeManager.isPurchasing)")
            
            Task {
                guard let product = selectedProduct else {
                    print("❌ No product selected")
                    return
                }
                
                print("🔄 Starting purchase for: \(product.id)")
                
                do {
                    try await storeManager.purchase(product)
                    
                    print("✅ Purchase completed")
                    print("✅ isSubscribed: \(storeManager.isSubscribed)")
                    
                    if storeManager.isSubscribed {
                        // Mark onboarding as complete
                        var settings = dataManager.settings
                        settings.hasCompletedOnboarding = true
                        dataManager.updateSettings(settings)
                        
                        print("✅ Onboarding marked as complete")
                        
                        // Close if not onboarding, otherwise ContentView will update
                        if !isOnboarding {
                            dismiss()
                        }
                    } else {
                        print("⚠️ Purchase succeeded but not subscribed - possible user cancellation")
                    }
                } catch {
                    print("❌ Purchase error: \(error.localizedDescription)")
                    showError = true
                }
            }
        } label: {
            HStack {
                if storeManager.isPurchasing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    // Dynamic button text based on selected plan
                    if let product = selectedProduct, let subscription = product.subscription {
                        VStack(spacing: 4) {
                            Text("Start Free Trial")
                                .font(.headline)
                            Text("\(product.displayPrice)/\(periodString(for: subscription.subscriptionPeriod)) after")
                                .font(.caption)
                        }
                    } else {
                        Text("Start Free Trial")
                            .font(.headline)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedProduct != nil ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(selectedProduct == nil || storeManager.isPurchasing)
    }
    
    // MARK: - Bottom View
    
    private var bottomView: some View {
        VStack(spacing: 16) {
            // Restore Purchases button
            Button("Restore Purchases") {
                Task {
                    await storeManager.restorePurchases()
                    
                    // If subscription was restored, mark onboarding complete
                    if storeManager.isSubscribed {
                        var settings = dataManager.settings
                        settings.hasCompletedOnboarding = true
                        dataManager.updateSettings(settings)
                        
                        if !isOnboarding {
                            dismiss()
                        }
                    }
                }
            }
            .font(.subheadline)
            .foregroundStyle(.blue)
            
            // Complete legal disclosure
            VStack(spacing: 12) {
                Text("Payment will be charged to your Apple ID account at confirmation of purchase.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("Your subscription includes a 7-day free trial and automatically renews at the selected plan price unless cancelled at least 24 hours before the end of the trial or current billing period.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("Your account will be charged for renewal within 24 hours prior to the end of the current period.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("You can manage or cancel your subscription anytime in your App Store account settings.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            // REQUIRED: Links to Privacy Policy and Terms of Use
            HStack(spacing: 16) {
                NavigationLink(destination: PrivacyPolicyView()) {
                    Text("Privacy Policy")
                        .font(.caption)
                        .underline()
                        .foregroundStyle(.secondary)
                }
                
                Text("•")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                NavigationLink(destination: TermsOfServiceView()) {
                    Text("Terms of Use")
                        .font(.caption)
                        .underline()
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 4)
        }
        .padding(.vertical)
    }
    
    private func periodString(for period: Product.SubscriptionPeriod) -> String {
        switch period.unit {
        case .day:
            return period.value == 1 ? "day" : "\(period.value) days"
        case .week:
            return period.value == 1 ? "week" : "\(period.value) weeks"
        case .month:
            return period.value == 1 ? "month" : "\(period.value) months"
        case .year:
            return period.value == 1 ? "year" : "\(period.value) years"
        @unknown default:
            return "period"
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Subscription Card

struct SubscriptionCard: View {
    let product: Product
    let isSelected: Bool
    var planName: String?
    var badge: String?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            print("🎯 SubscriptionCard button action fired for: \(product.id)")
            onTap()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        // Show plan name if provided, otherwise use product name
                        Text(planName ?? product.displayName.replacingOccurrences(of: "RealLife HQ ", with: ""))
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let badge = badge {
                            Text(badge)
                                .font(.caption.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.green)
                                .foregroundStyle(.white)
                                .cornerRadius(4)
                        }
                    }
                    
                    // Show pricing clearly
                    Text(product.displayPrice + " per " + periodName(for: product.subscription?.subscriptionPeriod))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Checkmark for selected
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                } else {
                    Image(systemName: "circle")
                        .font(.title2)
                        .foregroundStyle(.gray.opacity(0.3))
                }
            }
            .padding()
            .background {
                if isSelected {
                    Color.blue.opacity(0.2)
                } else {
                    Color.clear.background(.ultraThinMaterial)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle()) // Make entire card tappable
    }
    }
    
    private func periodName(for period: Product.SubscriptionPeriod?) -> String {
        guard let period = period else { return "period" }
        
        switch period.unit {
        case .day:
            return period.value == 1 ? "day" : "\(period.value) days"
        case .week:
            return period.value == 1 ? "week" : "\(period.value) weeks"
        case .month:
            return period.value == 1 ? "month" : "\(period.value) months"
        case .year:
            return period.value == 1 ? "year" : "\(period.value) years"
        @unknown default:
            return "period"
        }
    }
    
    private func periodString(for period: Product.SubscriptionPeriod) -> String {
        switch period.unit {
        case .day:
            return period.value == 1 ? "day" : "\(period.value) days"
        case .week:
            return period.value == 1 ? "week" : "\(period.value) weeks"
        case .month:
            return period.value == 1 ? "month" : "\(period.value) months"
        case .year:
            return period.value == 1 ? "year" : "\(period.value) years"
        @unknown default:
            return "period"
        }
    }


#Preview {
    SubscriptionView()
}
