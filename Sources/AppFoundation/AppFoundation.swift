// AppFoundation.swift
// AppFoundation
//
// Main module file that re-exports all public APIs.

import Foundation

/// AppFoundation provides a collection of utilities, extensions, and protocols
/// for building iOS applications.
///
/// ## Extensions
///
/// The package includes extensions for common Foundation types:
/// - `String`: Validation, trimming, localization
/// - `Date`: Formatting, relative time, day boundaries
/// - `Collection`: Safe subscript, chunking, deduplication
/// - `Optional`: Nil/empty checking utilities
/// - `UserDefaults`: Typed access and Codable support
///
/// ## Logging
///
/// A flexible logging system with multiple destinations:
///
/// ```swift
/// // Use the shared logger
/// Logger.shared.info("User logged in")
///
/// // Create a custom logger
/// let logger = Logger(
///     minimumLevel: .debug,
///     destinations: [ConsoleDestination(), PrintDestination()]
/// )
/// logger.error("Something went wrong")
/// ```
///
/// ## Environment Configuration
///
/// Environment-aware configuration:
///
/// ```swift
/// // Access current environment
/// let env = Environment.current
///
/// // Create environment-specific configurations
/// struct APIConfig: EnvironmentConfigurable {
///     static var development: APIConfig { ... }
///     static var staging: APIConfig { ... }
///     static var production: APIConfig { ... }
/// }
///
/// let config = APIConfig.current
/// ```
///
/// ## Error Handling
///
/// Comprehensive error types with localized descriptions:
///
/// ```swift
/// throw AppFoundationError.validation(.invalidEmail)
/// throw AppFoundationError.storage(.notFound(key: "user"))
/// ```
public enum AppFoundation {
    /// The current version of the AppFoundation package.
    public static let version = "1.0.0"
    
    /// A short description of the package.
    public static let description = "Core utilities and extensions for iOS apps"
}
