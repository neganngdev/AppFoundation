// AppFoundationError.swift
// AppFoundation
//
// Custom error types for the AppFoundation package.

import Foundation

// MARK: - AppFoundationError

/// Errors that can occur within the AppFoundation package.
public enum AppFoundationError: LocalizedError, Equatable, Sendable {
    /// A validation error occurred.
    case validation(ValidationError)
    
    /// A storage error occurred.
    case storage(StorageError)
    
    /// A configuration error occurred.
    case configuration(ConfigurationError)
    
    /// An unknown error occurred.
    case unknown(String)
    
    public var errorDescription: String? {
        switch self {
        case .validation(let error):
            return error.localizedDescription
        case .storage(let error):
            return error.localizedDescription
        case .configuration(let error):
            return error.localizedDescription
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .validation(let error):
            return error.failureReason
        case .storage(let error):
            return error.failureReason
        case .configuration(let error):
            return error.failureReason
        case .unknown:
            return "An unexpected error occurred"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .validation(let error):
            return error.recoverySuggestion
        case .storage(let error):
            return error.recoverySuggestion
        case .configuration(let error):
            return error.recoverySuggestion
        case .unknown:
            return "Please try again"
        }
    }
}


// MARK: - Validation Errors

/// Errors related to data validation.
public enum ValidationError: LocalizedError, Equatable, Sendable {
    /// A required field is empty.
    case emptyField(fieldName: String)
    
    /// A value is invalid.
    case invalidValue(fieldName: String, reason: String)
    
    /// An email address is invalid.
    case invalidEmail
    
    /// A URL is invalid.
    case invalidURL
    
    /// A value is out of the allowed range.
    case outOfRange(fieldName: String, min: String, max: String)
    
    /// A value exceeds the maximum length.
    case tooLong(fieldName: String, maxLength: Int)
    
    /// A value is shorter than the minimum length.
    case tooShort(fieldName: String, minLength: Int)
    
    /// A pattern match failed.
    case patternMismatch(fieldName: String, pattern: String)
    
    public var errorDescription: String? {
        switch self {
        case .emptyField(let fieldName):
            return "\(fieldName) cannot be empty"
        case .invalidValue(let fieldName, let reason):
            return "\(fieldName) is invalid: \(reason)"
        case .invalidEmail:
            return "Invalid email address"
        case .invalidURL:
            return "Invalid URL"
        case .outOfRange(let fieldName, let min, let max):
            return "\(fieldName) must be between \(min) and \(max)"
        case .tooLong(let fieldName, let maxLength):
            return "\(fieldName) must be at most \(maxLength) characters"
        case .tooShort(let fieldName, let minLength):
            return "\(fieldName) must be at least \(minLength) characters"
        case .patternMismatch(let fieldName, _):
            return "\(fieldName) has an invalid format"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .emptyField:
            return "The field was left empty"
        case .invalidValue(_, let reason):
            return reason
        case .invalidEmail:
            return "The email address format is incorrect"
        case .invalidURL:
            return "The URL format is incorrect"
        case .outOfRange:
            return "The value is outside the allowed range"
        case .tooLong:
            return "The value exceeds the maximum allowed length"
        case .tooShort:
            return "The value is shorter than the minimum required length"
        case .patternMismatch:
            return "The value doesn't match the required format"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .emptyField(let fieldName):
            return "Please enter a value for \(fieldName)"
        case .invalidValue:
            return "Please correct the value"
        case .invalidEmail:
            return "Please enter a valid email address (e.g., user@example.com)"
        case .invalidURL:
            return "Please enter a valid URL (e.g., https://example.com)"
        case .outOfRange(_, let min, let max):
            return "Please enter a value between \(min) and \(max)"
        case .tooLong(_, let maxLength):
            return "Please shorten your input to \(maxLength) characters or less"
        case .tooShort(_, let minLength):
            return "Please enter at least \(minLength) characters"
        case .patternMismatch(_, let pattern):
            return "Please match the format: \(pattern)"
        }
    }
}

// MARK: - Storage Errors

/// Errors related to data storage operations.
public enum StorageError: LocalizedError, Equatable, Sendable {
    /// Failed to encode data for storage.
    case encodingFailed(String)
    
    /// Failed to decode stored data.
    case decodingFailed(String)
    
    /// The requested item was not found.
    case notFound(key: String)
    
    /// Storage is full or quota exceeded.
    case quotaExceeded
    
    /// A file operation failed.
    case fileOperationFailed(String)
    
    /// Access to storage was denied.
    case accessDenied
    
    public var errorDescription: String? {
        switch self {
        case .encodingFailed(let details):
            return "Failed to encode data: \(details)"
        case .decodingFailed(let details):
            return "Failed to decode data: \(details)"
        case .notFound(let key):
            return "Item not found: \(key)"
        case .quotaExceeded:
            return "Storage quota exceeded"
        case .fileOperationFailed(let details):
            return "File operation failed: \(details)"
        case .accessDenied:
            return "Storage access denied"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .encodingFailed:
            return "The data could not be converted to storage format"
        case .decodingFailed:
            return "The stored data could not be read"
        case .notFound:
            return "The requested item does not exist"
        case .quotaExceeded:
            return "There is not enough storage space"
        case .fileOperationFailed:
            return "The file system operation failed"
        case .accessDenied:
            return "Permission to access storage was denied"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .encodingFailed:
            return "Check that the data is valid"
        case .decodingFailed:
            return "The stored data may be corrupted"
        case .notFound:
            return "Verify the key is correct"
        case .quotaExceeded:
            return "Free up storage space and try again"
        case .fileOperationFailed:
            return "Check file permissions and try again"
        case .accessDenied:
            return "Grant storage permissions in Settings"
        }
    }
}

// MARK: - Configuration Errors

/// Errors related to configuration.
public enum ConfigurationError: LocalizedError, Equatable, Sendable {
    /// A required configuration value is missing.
    case missingValue(key: String)
    
    /// A configuration value is invalid.
    case invalidValue(key: String, reason: String)
    
    /// The configuration file could not be loaded.
    case loadFailed(String)
    
    /// Environment configuration is invalid.
    case invalidEnvironment(String)
    
    public var errorDescription: String? {
        switch self {
        case .missingValue(let key):
            return "Missing configuration: \(key)"
        case .invalidValue(let key, let reason):
            return "Invalid configuration for \(key): \(reason)"
        case .loadFailed(let details):
            return "Failed to load configuration: \(details)"
        case .invalidEnvironment(let details):
            return "Invalid environment: \(details)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .missingValue:
            return "A required configuration value was not provided"
        case .invalidValue(_, let reason):
            return reason
        case .loadFailed:
            return "The configuration file could not be read"
        case .invalidEnvironment:
            return "The environment setting is not valid"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .missingValue(let key):
            return "Add the '\(key)' value to your configuration"
        case .invalidValue:
            return "Correct the configuration value"
        case .loadFailed:
            return "Check that the configuration file exists and is valid"
        case .invalidEnvironment:
            return "Use one of: development, staging, production"
        }
    }
}
