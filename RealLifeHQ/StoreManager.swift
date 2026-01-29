//
//  StoreManager.swift
//  RealLifeHQ
//
//  Created by Sarah Walker on 1/10/26.
//

import Foundation
import StoreKit

@MainActor
@Observable
class StoreManager {
    static let shared = StoreManager()
    
    // Subscription states
    enum SubscriptionStatus {
        case notSubscribed
        case subscribed(Product)
        case inFreeTrial
        case expired
    }
    
    // Your product IDs - update these to match your App Store Connect configuration
    private let monthlySubscriptionID = "com.reallifehq.monthly"
    private let yearlySubscriptionID = "com.reallifehq.yearly"
    
    // Available products
    var monthlySubscription: Product?
    var yearlySubscription: Product?
    
    // Current subscription status
    var subscriptionStatus: SubscriptionStatus = .notSubscribed
    var isSubscribed: Bool {
        switch subscriptionStatus {
        case .subscribed, .inFreeTrial:
            return true
        default:
            return false
        }
    }
    
    // Track purchase state
    var isPurchasing = false
    var purchaseError: Error?
    
    private nonisolated(unsafe) var updateListenerTask: Task<Void, Never>?
    
    private init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Load Products
    
    func loadProducts() async {
        do {
            print("🔄 Loading products with IDs: [\(self.monthlySubscriptionID), \(self.yearlySubscriptionID)]")
            
            // Add timeout to prevent infinite loading
            let products = try await withTimeout(seconds: 10) {
                try await Product.products(for: [self.monthlySubscriptionID, self.yearlySubscriptionID])
            }
            
            print("📦 Found \(products.count) products")
            
            for product in products {
                print("  - \(product.id): \(product.displayName) - \(product.displayPrice)")
                switch product.id {
                case monthlySubscriptionID:
                    monthlySubscription = product
                case yearlySubscriptionID:
                    yearlySubscription = product
                default:
                    break
                }
            }
            
            if monthlySubscription == nil && yearlySubscription == nil {
                print("⚠️ WARNING: No products were loaded! Check your StoreKit configuration.")
                print("💡 TIP: In Simulator, go to Xcode → Debug → StoreKit → Manage StoreKit Configuration")
            }
        } catch {
            print("❌ Failed to load products: \(error)")
            print("💡 This is normal in Simulator without StoreKit configuration file")
        }
    }
    
    // Helper function to add timeout to async operations
    private func withTimeout<T>(
        seconds: TimeInterval,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError()
            }
            
            guard let result = try await group.next() else {
                throw TimeoutError()
            }
            
            group.cancelAll()
            return result
        }
    }
    
    struct TimeoutError: Error {}
    
    // MARK: - Purchase Subscription
    
    func purchase(_ product: Product) async throws {
        isPurchasing = true
        purchaseError = nil
        
        defer {
            isPurchasing = false
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Verify the transaction
                let transaction = try checkVerified(verification)
                
                // Update subscription status
                await updateSubscriptionStatus()
                
                // Always finish a transaction
                await transaction.finish()
                
            case .userCancelled:
                // User cancelled the purchase
                break
                
            case .pending:
                // Purchase is pending (e.g., awaiting approval)
                break
                
            @unknown default:
                break
            }
        } catch {
            purchaseError = error
            throw error
        }
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }
    
    // MARK: - Update Subscription Status
    
    func updateSubscriptionStatus() async {
        // Ensure products are loaded before checking status
        guard monthlySubscription != nil || yearlySubscription != nil else {
            subscriptionStatus = .notSubscribed
            return
        }
        
        // Check subscription status for both products
        var currentSubscription: Product?
        var hasActiveSubscription = false
        var isInFreeTrial = false
        
        // Get all current entitlements
        for await result in StoreKit.Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            // Check if this is one of our subscription products
            if transaction.productID == monthlySubscriptionID,
               let product = monthlySubscription {
                currentSubscription = product
                hasActiveSubscription = true
            } else if transaction.productID == yearlySubscriptionID,
                      let product = yearlySubscription {
                currentSubscription = product
                hasActiveSubscription = true
            }
            
            // Check if it's a free trial
            // Note: A transaction is in free trial if it has an introductory offer
            // and the purchase date is recent enough to still be in the trial period
            if let offerType = transaction.offerType, offerType == .introductory {
                isInFreeTrial = true
            }
        }
        
        // Update status
        if hasActiveSubscription {
            if isInFreeTrial {
                subscriptionStatus = .inFreeTrial
            } else if let subscription = currentSubscription {
                subscriptionStatus = .subscribed(subscription)
            } else {
                subscriptionStatus = .notSubscribed
            }
        } else {
            subscriptionStatus = .notSubscribed
        }
    }
    
    // MARK: - Listen for Transactions
    
    private func listenForTransactions() -> Task<Void, Never> {
        return Task.detached {
            for await result in StoreKit.Transaction.updates {
                do {
                    guard case .verified(let transaction) = result else {
                        continue
                    }
                    
                    // Update subscription status when a new transaction comes through
                    await self.updateSubscriptionStatus()
                    
                    // Always finish a transaction
                    await transaction.finish()
                } catch {
                    print("Transaction update error: \(error)")
                }
            }
        }
    }
    
    // MARK: - Verification
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Store Errors

enum StoreError: Error {
    case failedVerification
    case purchaseFailed
}

extension StoreError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        case .purchaseFailed:
            return "Purchase could not be completed"
        }
    }
}
