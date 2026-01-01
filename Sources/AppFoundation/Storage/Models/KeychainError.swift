// KeychainError.swift
// AppFoundation
//
// Custom error types for Keychain operations.

import Foundation
import Security

// MARK: - Keychain Error

/// Errors that can occur during Keychain operations.
public enum KeychainError: LocalizedError, Equatable, Sendable {
    /// The requested item was not found in the keychain.
    case itemNotFound
    
    /// An item with the same key already exists.
    case duplicateItem
    
    /// The data retrieved from the keychain is invalid or corrupted.
    case invalidData
    
    /// Failed to encode data for storage.
    case encodingFailed
    
    /// Failed to decode data from storage.
    case decodingFailed
    
    /// An unhandled system error occurred.
    case unhandledError(status: OSStatus)
    
    /// The operation is not implemented or not supported.
    case notImplemented
    
    /// Access to the keychain was denied.
    case accessDenied
    
    /// The keychain is not available (e.g., device locked).
    case keychainUnavailable
    
    // MARK: - LocalizedError Conformance
    
    public var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "Keychain item not found"
        case .duplicateItem:
            return "Keychain item already exists"
        case .invalidData:
            return "Invalid keychain data"
        case .encodingFailed:
            return "Failed to encode data for keychain"
        case .decodingFailed:
            return "Failed to decode keychain data"
        case .unhandledError(let status):
            return "Keychain error: \(status) - \(Self.messageForStatus(status))"
        case .notImplemented:
            return "Operation not implemented"
        case .accessDenied:
            return "Keychain access denied"
        case .keychainUnavailable:
            return "Keychain is not available"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .itemNotFound:
            return "The requested item does not exist in the keychain"
        case .duplicateItem:
            return "An item with this key already exists"
        case .invalidData:
            return "The keychain data is corrupted or in an invalid format"
        case .encodingFailed:
            return "The data could not be converted to a storable format"
        case .decodingFailed:
            return "The stored data could not be converted back to the original type"
        case .unhandledError(let status):
            return "System error code: \(status)"
        case .notImplemented:
            return "This operation is not supported"
        case .accessDenied:
            return "The app does not have permission to access the keychain"
        case .keychainUnavailable:
            return "The device may be locked or keychain is disabled"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .itemNotFound:
            return "Verify the key is correct or check if the item was previously saved"
        case .duplicateItem:
            return "Delete the existing item first or use update instead of save"
        case .invalidData:
            return "The keychain data may be corrupted. Try deleting and re-saving"
        case .encodingFailed:
            return "Ensure the data conforms to Encodable properly"
        case .decodingFailed:
            return "The stored data format may have changed. Check data compatibility"
        case .unhandledError:
            return "Check system logs for more details"
        case .notImplemented:
            return "Use an alternative method or update the framework"
        case .accessDenied:
            return "Check app entitlements and keychain access groups"
        case .keychainUnavailable:
            return "Unlock the device and try again"
        }
    }
    
    // MARK: - Helper Methods
    
    /// Creates a KeychainError from an OSStatus code.
    ///
    /// - Parameter status: The OSStatus returned from a keychain operation.
    /// - Returns: The appropriate KeychainError.
    public static func from(status: OSStatus) -> KeychainError {
        switch status {
        case errSecSuccess:
            fatalError("Should not create error from success status")
        case errSecItemNotFound:
            return .itemNotFound
        case errSecDuplicateItem:
            return .duplicateItem
        case errSecAuthFailed:
            return .accessDenied
        case errSecInteractionNotAllowed:
            return .keychainUnavailable
        case errSecDecode:
            return .invalidData
        default:
            return .unhandledError(status: status)
        }
    }
    
    /// Returns a human-readable message for an OSStatus code.
    private static func messageForStatus(_ status: OSStatus) -> String {
        switch status {
        case errSecSuccess:
            return "Success"
        case errSecItemNotFound:
            return "Item not found"
        case errSecDuplicateItem:
            return "Duplicate item"
        case errSecAuthFailed:
            return "Authentication failed"
        case errSecInteractionNotAllowed:
            return "Interaction not allowed"
        case errSecDecode:
            return "Decode error"
        case errSecParam:
            return "Invalid parameter"
        case errSecAllocate:
            return "Memory allocation failed"
        case errSecNotAvailable:
            return "Not available"
        case errSecReadOnly:
            return "Read only"
        case errSecNoSuchAttr:
            return "No such attribute"
        case errSecInvalidItemRef:
            return "Invalid item reference"
        case errSecInvalidSearchRef:
            return "Invalid search reference"
        case errSecNoSuchClass:
            return "No such class"
        case errSecNoDefaultKeychain:
            return "No default keychain"
        case errSecInteractionRequired:
            return "Interaction required"
        case errSecDataNotAvailable:
            return "Data not available"
        case errSecDataNotModifiable:
            return "Data not modifiable"
        case errSecCreateChainFailed:
            return "Create chain failed"
        default:
            return "Unknown error"
        }
    }
}
