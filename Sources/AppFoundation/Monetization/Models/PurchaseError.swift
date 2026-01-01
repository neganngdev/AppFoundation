// PurchaseError.swift
// AppFoundation
//
// Errors for purchase operations.

import Foundation

// MARK: - Purchase Error

/// Errors that can occur during purchase operations.
public enum PurchaseError: LocalizedError {
    /// User cancelled the purchase.
    case cancelled
    
    /// Network error occurred.
    case networkError
    
    /// Store problem (App Store issue).
    case storeProblem
    
    /// RevenueCat not configured.
    case notConfigured
    
    /// Product not found.
    case productNotFound
    
    /// Receipt error.
    case receiptError
    
    /// Unknown error.
    case unknown(Error)
    
    // MARK: - LocalizedError
    
    public var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Purchase was cancelled"
        case .networkError:
            return "Network error occurred"
        case .storeProblem:
            return "App Store problem"
        case .notConfigured:
            return "Purchase system not configured"
        case .productNotFound:
            return "Product not found"
        case .receiptError:
            return "Receipt validation failed"
        case .unknown(let error):
            return "Purchase failed: \(error.localizedDescription)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .cancelled:
            return "The user cancelled the purchase"
        case .networkError:
            return "Unable to connect to the App Store"
        case .storeProblem:
            return "The App Store encountered an error"
        case .notConfigured:
            return "RevenueCat SDK not initialized"
        case .productNotFound:
            return "The requested product is not available"
        case .receiptError:
            return "Unable to validate the purchase receipt"
        case .unknown:
            return "An unexpected error occurred"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .cancelled:
            return "Try purchasing again"
        case .networkError:
            return "Check your internet connection and try again"
        case .storeProblem:
            return "Try again later"
        case .notConfigured:
            return "Contact support"
        case .productNotFound:
            return "The product may no longer be available"
        case .receiptError:
            return "Try restoring purchases"
        case .unknown:
            return "Try again or contact support"
        }
    }
}
