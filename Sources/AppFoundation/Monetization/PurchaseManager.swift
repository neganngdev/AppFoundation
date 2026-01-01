// PurchaseManager.swift
// AppFoundation
//
// Simplified RevenueCat helper for managing purchases.

import Foundation
import RevenueCat

// MARK: - Purchase Manager

/// Simplified helper for managing in-app purchases with RevenueCat.
///
/// This is a lightweight wrapper around RevenueCat SDK providing essential functionality.
/// For advanced features, use RevenueCat SDK directly.
///
/// ```swift
/// // Configure
/// await PurchaseManager.shared.configure(apiKey: "rc_your_api_key")
///
/// // Purchase
/// try await PurchaseManager.shared.purchase(productId: "monthly_premium")
///
/// // Check subscription
/// let hasSubscription = await PurchaseManager.shared.hasActiveSubscription
/// ```
public actor PurchaseManager {
    
    // MARK: - Singleton
    
    /// Shared purchase manager instance.
    public static let shared = PurchaseManager()
    
    // MARK: - Properties
    
    private var isConfigured = false
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Configuration
    
    /// Configures RevenueCat with your API key.
    ///
    /// Call this once at app launch, before making any purchases.
    ///
    /// - Parameters:
    ///   - apiKey: Your RevenueCat API key.
    ///   - appUserId: Optional app user ID for identified users.
    public func configure(apiKey: String, appUserId: String? = nil) {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: apiKey, appUserID: appUserId)
        isConfigured = true
    }
    
    /// Returns whether RevenueCat is configured.
    public var configured: Bool {
        isConfigured
    }
    
    // MARK: - Purchases
    
    /// Purchases a product by ID.
    ///
    /// - Parameter productId: The product identifier.
    /// - Returns: True if purchase was successful, false if cancelled.
    /// - Throws: `PurchaseError` if purchase fails.
    public func purchase(productId: String) async throws -> Bool {
        guard isConfigured else {
            throw PurchaseError.notConfigured
        }
        
        do {
            let result = try await Purchases.shared.purchase(product: productId)
            return !result.userCancelled
        } catch let error as ErrorCode {
            throw mapError(error)
        } catch {
            throw PurchaseError.unknown(error)
        }
    }
    
    /// Restores previous purchases.
    ///
    /// - Returns: True if any purchases were restored.
    /// - Throws: `PurchaseError` if restore fails.
    @discardableResult
    public func restorePurchases() async throws -> Bool {
        guard isConfigured else {
            throw PurchaseError.notConfigured
        }
        
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            return !customerInfo.activeSubscriptions.isEmpty
        } catch let error as ErrorCode {
            throw mapError(error)
        } catch {
            throw PurchaseError.unknown(error)
        }
    }
    
    // MARK: - Subscription Status
    
    /// Returns whether the user has an active subscription.
    public var hasActiveSubscription: Bool {
        get async {
            guard isConfigured else { return false }
            
            do {
                let customerInfo = try await Purchases.shared.customerInfo()
                return !customerInfo.activeSubscriptions.isEmpty
            } catch {
                return false
            }
        }
    }
    
    /// Checks if a specific entitlement is active.
    ///
    /// - Parameter identifier: The entitlement identifier.
    /// - Returns: True if the entitlement is active.
    public func hasEntitlement(_ identifier: String) async -> Bool {
        guard isConfigured else { return false }
        
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            return customerInfo.entitlements[identifier]?.isActive == true
        } catch {
            return false
        }
    }
    
    /// Returns all active subscription product IDs.
    public var activeSubscriptions: Set<String> {
        get async {
            guard isConfigured else { return [] }
            
            do {
                let customerInfo = try await Purchases.shared.customerInfo()
                return customerInfo.activeSubscriptions
            } catch {
                return []
            }
        }
    }
    
    // MARK: - User Management
    
    /// Identifies the user with a custom user ID.
    ///
    /// - Parameter userId: The user ID.
    public func identify(userId: String) async throws {
        guard isConfigured else {
            throw PurchaseError.notConfigured
        }
        
        do {
            _ = try await Purchases.shared.logIn(userId)
        } catch let error as ErrorCode {
            throw mapError(error)
        } catch {
            throw PurchaseError.unknown(error)
        }
    }
    
    /// Logs out the current user (switches to anonymous).
    public func logout() async throws {
        guard isConfigured else {
            throw PurchaseError.notConfigured
        }
        
        do {
            _ = try await Purchases.shared.logOut()
        } catch let error as ErrorCode {
            throw mapError(error)
        } catch {
            throw PurchaseError.unknown(error)
        }
    }
    
    // MARK: - Error Mapping
    
    private func mapError(_ error: ErrorCode) -> PurchaseError {
        switch error.code {
        case .purchaseCancelledError:
            return .cancelled
        case .networkError:
            return .networkError
        case .storeProblemError:
            return .storeProblem
        case .productNotAvailableForPurchaseError:
            return .productNotFound
        case .receiptAlreadyInUseError, .invalidReceiptError:
            return .receiptError
        default:
            return .unknown(error)
        }
    }
}

// MARK: - Purchase Manager + Convenience

public extension PurchaseManager {
    /// Returns the current user ID.
    var currentUserId: String {
        get async {
            guard isConfigured else { return "" }
            return await Purchases.shared.appUserID
        }
    }
}
