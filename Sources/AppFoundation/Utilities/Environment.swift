// Environment.swift
// AppFoundation
//
// Environment configuration system supporting development, staging, and production environments.

import Foundation

// MARK: - Environment

/// Represents the application environment.
///
/// The environment can be determined from:
/// 1. Scheme/build configuration environment variables
/// 2. Info.plist values
/// 3. Default fallback to `.development` in DEBUG builds
///
/// ```swift
/// // Access current environment
/// let env = Environment.current
///
/// // Use environment-specific values
/// let apiURL = env.baseURL(for: .production, value: "https://api.example.com")
/// ```
public enum Environment: String, CaseIterable, Sendable {
    /// Development environment for local testing.
    case development
    /// Staging environment for pre-production testing.
    case staging
    /// Production environment for live/released apps.
    case production
    
    // MARK: - Current Environment
    
    /// The current application environment.
    ///
    /// Determined by checking (in order):
    /// 1. `APP_ENVIRONMENT` environment variable
    /// 2. `AppEnvironment` key in Info.plist
    /// 3. Falls back to `.development` in DEBUG, `.production` otherwise
    public static var current: Environment {
        // Check for override from environment variable
        if let envString = ProcessInfo.processInfo.environment["APP_ENVIRONMENT"],
           let env = Environment(rawValue: envString.lowercased()) {
            return env
        }
        
        // Check Info.plist
        if let envString = Bundle.main.object(forInfoDictionaryKey: "AppEnvironment") as? String,
           let env = Environment(rawValue: envString.lowercased()) {
            return env
        }
        
        // Default based on build configuration
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
    
    // MARK: - Properties
    
    /// A human-readable name for the environment.
    public var displayName: String {
        switch self {
        case .development: return "Development"
        case .staging: return "Staging"
        case .production: return "Production"
        }
    }
    
    /// Short identifier for the environment.
    public var shortName: String {
        switch self {
        case .development: return "DEV"
        case .staging: return "STG"
        case .production: return "PROD"
        }
    }
    
    /// Whether this is a development environment.
    public var isDevelopment: Bool {
        self == .development
    }
    
    /// Whether this is a production environment.
    public var isProduction: Bool {
        self == .production
    }
    
    /// Whether debug features should be enabled.
    public var isDebugEnabled: Bool {
        self != .production
    }
}

// MARK: - EnvironmentConfigurable Protocol

/// A protocol for types that provide environment-specific configuration.
///
/// Implement this protocol to create configuration objects that vary by environment.
///
/// ```swift
/// struct APIConfiguration: EnvironmentConfigurable {
///     static var development: APIConfiguration {
///         APIConfiguration(baseURL: "http://localhost:8080")
///     }
///
///     static var staging: APIConfiguration {
///         APIConfiguration(baseURL: "https://staging-api.example.com")
///     }
///
///     static var production: APIConfiguration {
///         APIConfiguration(baseURL: "https://api.example.com")
///     }
///
///     let baseURL: String
/// }
///
/// // Access current configuration
/// let config = APIConfiguration.current
/// ```
public protocol EnvironmentConfigurable {
    /// Configuration for development environment.
    static var development: Self { get }
    
    /// Configuration for staging environment.
    static var staging: Self { get }
    
    /// Configuration for production environment.
    static var production: Self { get }
}

public extension EnvironmentConfigurable {
    /// Returns the configuration for the current environment.
    static var current: Self {
        switch Environment.current {
        case .development: return development
        case .staging: return staging
        case .production: return production
        }
    }
    
    /// Returns the configuration for a specific environment.
    ///
    /// - Parameter environment: The environment to get configuration for.
    /// - Returns: The configuration for the specified environment.
    static func configuration(for environment: Environment) -> Self {
        switch environment {
        case .development: return development
        case .staging: return staging
        case .production: return production
        }
    }
}

// MARK: - Environment Value Provider

/// A property wrapper that provides environment-specific values.
///
/// ```swift
/// struct MyConfig {
///     @EnvironmentValue(
///         development: "http://localhost:8080",
///         staging: "https://staging.example.com",
///         production: "https://api.example.com"
///     )
///     var apiBaseURL: String
/// }
/// ```
@propertyWrapper
public struct EnvironmentValue<Value> {
    private let development: Value
    private let staging: Value
    private let production: Value
    
    public var wrappedValue: Value {
        switch Environment.current {
        case .development: return development
        case .staging: return staging
        case .production: return production
        }
    }
    
    public init(
        development: Value,
        staging: Value,
        production: Value
    ) {
        self.development = development
        self.staging = staging
        self.production = production
    }
}

// MARK: - Feature Flags

/// A simple feature flag system with environment awareness.
///
/// ```swift
/// extension FeatureFlag {
///     static let newOnboarding = FeatureFlag(
///         name: "new_onboarding",
///         enabledIn: [.development, .staging]
///     )
/// }
///
/// if FeatureFlag.newOnboarding.isEnabled {
///     // Show new onboarding
/// }
/// ```
public struct FeatureFlag: Sendable {
    /// The name of the feature flag.
    public let name: String
    
    /// The environments where this flag is enabled.
    public let enabledEnvironments: Set<Environment>
    
    /// Whether the flag is enabled in the current environment.
    public var isEnabled: Bool {
        enabledEnvironments.contains(Environment.current)
    }
    
    /// Creates a new feature flag.
    ///
    /// - Parameters:
    ///   - name: The name of the feature flag.
    ///   - enabledIn: The environments where this flag should be enabled.
    public init(name: String, enabledIn environments: Set<Environment>) {
        self.name = name
        self.enabledEnvironments = environments
    }
    
    /// Creates a feature flag enabled in development only.
    public static func developmentOnly(_ name: String) -> FeatureFlag {
        FeatureFlag(name: name, enabledIn: [.development])
    }
    
    /// Creates a feature flag enabled in development and staging.
    public static func preProduction(_ name: String) -> FeatureFlag {
        FeatureFlag(name: name, enabledIn: [.development, .staging])
    }
    
    /// Creates a feature flag enabled in all environments.
    public static func always(_ name: String) -> FeatureFlag {
        FeatureFlag(name: name, enabledIn: Set(Environment.allCases))
    }
}

// MARK: - Environment Override

/// Allows temporarily overriding the environment for testing purposes.
///
/// This should only be used in tests and debug builds.
public enum EnvironmentOverride {
    private static var _override: Environment?
    
    /// Sets an environment override.
    ///
    /// - Parameter environment: The environment to override with, or `nil` to clear.
    public static func set(_ environment: Environment?) {
        #if DEBUG
        _override = environment
        #endif
    }
    
    /// Returns the current override, if any.
    public static var current: Environment? {
        #if DEBUG
        return _override
        #else
        return nil
        #endif
    }
    
    /// Clears any environment override.
    public static func clear() {
        #if DEBUG
        _override = nil
        #endif
    }
}

// MARK: - Environment Extension for Override Support

public extension Environment {
    /// The effective environment, taking into account any override.
    static var effective: Environment {
        EnvironmentOverride.current ?? current
    }
}
