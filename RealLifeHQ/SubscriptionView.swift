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
    @State private var storeManager = StoreManager.shared
    @State private var selectedProduct: Product?
    @State private var showError = false
    
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
                .foregroundStyle(.blue)
            
            Text("Get Your Life Organized")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            
            Text("Start your 7-day free trial")
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
                icon: "dollarsign.circle.fill",
                title: "Budget Tracker",
                description: "Take control of your finances"
            )
            
            FeatureRow(
                icon: "fork.knife.circle.fill",
                title: "Meal Planner",
                description: "Plan meals and save money"
            )
            
            FeatureRow(
                icon: "lock.shield.fill",
                title: "The Vault",
                description: "Store important documents securely"
            )
            
            FeatureRow(
                icon: "calendar.circle.fill",
                title: "Planner & Calendar",
                description: "Stay organized and on track"
            )
            
            FeatureRow(
                icon: "chart.line.uptrend.xyaxis.circle.fill",
                title: "Habit Tracker",
                description: "Build better routines"
            )
            
            FeatureRow(
                icon: "book.circle.fill",
                title: "Journal",
                description: "Reflect and grow daily"
            )
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
                // Yearly subscription (show first as best value)
                if let yearly = storeManager.yearlySubscription {
                    SubscriptionCard(
                        product: yearly,
                        isSelected: selectedProduct?.id == yearly.id,
                        badge: "Save 17%",
                        onTap: { selectedProduct = yearly }
                    )
                }
                
                // Monthly subscription
                if let monthly = storeManager.monthlySubscription {
                    SubscriptionCard(
                        product: monthly,
                        isSelected: selectedProduct?.id == monthly.id,
                        onTap: { selectedProduct = monthly }
                    )
                }
            }
            
            // Subscribe button
            subscribeButton
        }
    }
    
    private var subscribeButton: some View {
        Button {
            Task {
                guard let product = selectedProduct else { return }
                do {
                    try await storeManager.purchase(product)
                    if storeManager.isSubscribed {
                        // Mark onboarding as complete
                        var settings = dataManager.settings
                        settings.hasCompletedOnboarding = true
                        dataManager.updateSettings(settings)
                        
                        // Close if not onboarding, otherwise ContentView will update
                        if !isOnboarding {
                            dismiss()
                        }
                    }
                } catch {
                    showError = true
                }
            }
        } label: {
            HStack {
                if storeManager.isPurchasing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Start 7-Day Free Trial")
                        .font(.headline)
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
        VStack(spacing: 12) {
            // Trial and pricing info
            if let selected = selectedProduct {
                if let subscription = selected.subscription,
                   let introOffer = subscription.introductoryOffer,
                   introOffer.paymentMode == .freeTrial {
                    Text("7 days free, then \(selected.displayPrice)/\(periodString(for: subscription.subscriptionPeriod))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
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
            .foregroundStyle(.secondary)
            
            Text("Cancel anytime. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
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
    var badge: String?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        // Show simplified name
                        Text(product.displayName.replacingOccurrences(of: "RealLife HQ ", with: ""))
                            .font(.headline)
                        
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
                    if let subscription = product.subscription {
                        Text("\(product.displayPrice)/\(periodString(for: subscription.subscriptionPeriod))")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                }
                
                Spacer()
                
                // Checkmark for selected
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
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
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
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

#Preview {
    SubscriptionView()
}
