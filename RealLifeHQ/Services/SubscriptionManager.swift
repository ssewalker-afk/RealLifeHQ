import Foundation
import Observation
import StoreKit

// MARK: - SubscriptionManager
//
// Manages all StoreKit 2 logic for the freemium model.
// Use this as an @State var in your root view, then pass it down with .environment().
//
// Product IDs:
//   com.reallifehq.monthly  — auto-renewable monthly subscription
//   com.reallifehq.lifetime — non-consumable one-time lifetime purchase

@MainActor
@Observable
final class SubscriptionManager {

    // MARK: - Product IDs

    enum ProductID: String, CaseIterable {
        case monthly  = "com.reallifehq.monthly"
        case lifetime = "com.reallifehq.lifetime"
    }

    // MARK: - Plan Tier
    //
    // Represents exactly which plan the user is on.
    // Use this wherever you need to show Free vs Monthly vs Lifetime
    // (e.g. the Settings "My Plan" section).

    enum Plan {
        case free
        case monthly
        case lifetime
    }

    // MARK: - Published State

    /// The loaded products from App Store Connect (populated after loadProducts()).
    private(set) var products: [Product] = []

    /// true when the user has an active subscription OR a lifetime purchase.
    private(set) var isPremium: Bool = false

    /// The specific plan tier the user is currently on.
    /// Defaults to .free until entitlements are checked.
    private(set) var currentPlan: Plan = .free

    /// Set to true while a purchase or restore is in flight.
    private(set) var isPurchasing: Bool = false

    /// Surfaced to the UI so you can show an alert when something goes wrong.
    private(set) var lastError: String?

    // MARK: - Private

    // Retained for the app's lifetime. The listener task uses [weak self],
    // so this reference does not create a retain cycle.
    private var updateListenerTask: Task<Void, Never>?

    // MARK: - Init

    init() {
        // 1. Start the transaction listener FIRST, before doing anything else.
        //    Apple's docs say to start this as early as possible so you don't
        //    miss transactions that arrive at launch (e.g. Ask-to-Buy approvals,
        //    purchases completed on another device).
        updateListenerTask = listenForTransactionUpdates()

        // 2. Load products and check current entitlements in the background.
        Task {
            await loadProducts()
            await refreshPurchaseStatus()
        }
    }

    // MARK: - Load Products

    /// Fetches product metadata (price, description, etc.) from App Store Connect.
    /// Call this before showing your paywall so you can display real prices.
    func loadProducts() async {
        do {
            let ids = ProductID.allCases.map(\.rawValue)
            // Product.products(for:) is the StoreKit 2 way to fetch products.
            products = try await Product.products(for: ids)
            // Sort so monthly appears before lifetime in a list.
            products.sort { $0.id < $1.id }
        } catch {
            lastError = "Couldn't load products: \(error.localizedDescription)"
        }
    }

    // MARK: - Purchase

    /// Initiates a purchase for the given product.
    /// Call this from a "Buy" button in your paywall UI.
    ///
    /// - Returns: `true` if the purchase completed successfully.
    @discardableResult
    func purchase(_ product: Product) async -> Bool {
        isPurchasing = true
        lastError = nil
        defer { isPurchasing = false }

        do {
            // product.purchase() presents the system payment sheet.
            let result = try await product.purchase()

            switch result {
            case .success(let verificationResult):
                // Always verify the transaction — don't trust unverified results.
                guard case .verified(let transaction) = verificationResult else {
                    lastError = "Purchase could not be verified."
                    return false
                }
                // Finish the transaction to remove it from the queue.
                await transaction.finish()
                // Re-check entitlements so isPremium updates immediately.
                await refreshPurchaseStatus()
                return true

            case .userCancelled:
                // User dismissed the payment sheet — not an error.
                return false

            case .pending:
                // Purchase is awaiting approval (e.g. Ask to Buy).
                // isPremium will update later via the transaction listener.
                return false

            @unknown default:
                return false
            }
        } catch {
            lastError = "Purchase failed: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: - Restore Purchases

    /// Syncs the user's transaction history with the App Store and re-checks
    /// entitlements. Use this for your "Restore Purchases" button.
    func restorePurchases() async {
        isPurchasing = true
        lastError = nil
        defer { isPurchasing = false }

        do {
            // AppStore.sync() is the StoreKit 2 equivalent of restoreCompletedTransactions().
            try await AppStore.sync()
            await refreshPurchaseStatus()
        } catch {
            lastError = "Restore failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Convenience Helpers

    /// Returns the loaded Product for a given ProductID, if available.
    func product(for id: ProductID) -> Product? {
        products.first { $0.id == id.rawValue }
    }

    // MARK: - Private: Entitlement Check

    /// Iterates Transaction.currentEntitlements to determine whether the user
    /// currently has access to any premium product.
    ///
    /// currentEntitlements emits:
    ///   • The latest verified, non-expired, non-revoked transaction for each
    ///     non-consumable and auto-renewable subscription the user owns.
    private func refreshPurchaseStatus() async {
        var detectedPlan: Plan = .free

        // Qualify as StoreKit.Transaction to avoid conflict with any local Transaction type.
        for await verificationResult in StoreKit.Transaction.currentEntitlements {
            guard case .verified(let transaction) = verificationResult else {
                // Skip transactions that fail verification.
                continue
            }

            if transaction.productID == ProductID.lifetime.rawValue {
                // Lifetime is the highest tier — lock it in and stop looking.
                detectedPlan = .lifetime
                break
            } else if transaction.productID == ProductID.monthly.rawValue {
                // Monthly found — keep iterating in case there's also a lifetime purchase.
                detectedPlan = .monthly
            }
        }

        currentPlan = detectedPlan
        isPremium   = detectedPlan != .free
    }

    // MARK: - Private: Transaction Listener

    /// Creates a long-lived background Task that listens for transaction updates
    /// from outside the app — purchases on another device, Ask-to-Buy approvals,
    /// subscription renewals, refunds, and revocations.
    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            // Qualify as StoreKit.Transaction to avoid conflict with any local Transaction type.
            for await verificationResult in StoreKit.Transaction.updates {
                await self?.handleUpdate(verificationResult)
            }
        }
    }

    /// Processes a single incoming transaction update.
    private func handleUpdate(_ verificationResult: VerificationResult<StoreKit.Transaction>) async {
        // Only act on cryptographically verified transactions.
        guard case .verified(let transaction) = verificationResult else { return }

        // Finish the transaction so StoreKit stops delivering it.
        await transaction.finish()

        // Re-check the user's full entitlements to keep isPremium accurate.
        await refreshPurchaseStatus()
    }
}
