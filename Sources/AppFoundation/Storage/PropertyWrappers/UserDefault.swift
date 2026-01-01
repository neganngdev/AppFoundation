// UserDefault.swift
// AppFoundation
//
// Property wrapper for type-safe UserDefaults access.

import Foundation

// MARK: - UserDefault Property Wrapper

/// A property wrapper that provides type-safe access to UserDefaults.
///
/// Unlike `@AppStorage`, this works outside of SwiftUI and supports Codable types.
///
/// ```swift
/// class Settings {
///     @UserDefault(key: "hasSeenOnboarding", defaultValue: false)
///     static var hasSeenOnboarding: Bool
///
///     @UserDefault(key: "username", defaultValue: "Guest")
///     static var username: String
///
///     @UserDefault(key: "currentUser", defaultValue: nil)
///     static var currentUser: User?
/// }
///
/// // Usage
/// Settings.hasSeenOnboarding = true
/// print(Settings.username)
/// ```
@propertyWrapper
public struct UserDefault<T: Codable> {
    
    // MARK: - Properties
    
    private let key: String
    private let defaultValue: T
    private let userDefaults: UserDefaults
    
    // MARK: - Initialization
    
    /// Creates a new UserDefault property wrapper.
    ///
    /// - Parameters:
    ///   - key: The key to use in UserDefaults.
    ///   - defaultValue: The default value if no value is stored.
    ///   - userDefaults: The UserDefaults instance to use. Defaults to `.standard`.
    public init(
        key: String,
        defaultValue: T,
        userDefaults: UserDefaults = .standard
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }
    
    // MARK: - Property Wrapper
    
    public var wrappedValue: T {
        get {
            // Handle primitive types directly for performance
            if T.self == String.self {
                return (userDefaults.string(forKey: key) as? T) ?? defaultValue
            } else if T.self == Int.self {
                guard userDefaults.object(forKey: key) != nil else { return defaultValue }
                return (userDefaults.integer(forKey: key) as? T) ?? defaultValue
            } else if T.self == Double.self {
                guard userDefaults.object(forKey: key) != nil else { return defaultValue }
                return (userDefaults.double(forKey: key) as? T) ?? defaultValue
            } else if T.self == Bool.self {
                guard userDefaults.object(forKey: key) != nil else { return defaultValue }
                return (userDefaults.bool(forKey: key) as? T) ?? defaultValue
            } else if T.self == Data.self {
                return (userDefaults.data(forKey: key) as? T) ?? defaultValue
            } else {
                // Use Codable for complex types
                return userDefaults.getCodable(T.self, forKey: key) ?? defaultValue
            }
        }
        set {
            // Handle primitive types directly
            if let stringValue = newValue as? String {
                userDefaults.set(stringValue, forKey: key)
            } else if let intValue = newValue as? Int {
                userDefaults.set(intValue, forKey: key)
            } else if let doubleValue = newValue as? Double {
                userDefaults.set(doubleValue, forKey: key)
            } else if let boolValue = newValue as? Bool {
                userDefaults.set(boolValue, forKey: key)
            } else if let dataValue = newValue as? Data {
                userDefaults.set(dataValue, forKey: key)
            } else {
                // Use Codable for complex types
                _ = userDefaults.setCodableSafe(newValue, forKey: key)
            }
        }
    }
    
    public var projectedValue: UserDefault<T> {
        self
    }
}

// MARK: - Optional UserDefault

/// A property wrapper for optional UserDefaults values.
///
/// This variant doesn't require a default value and returns `nil` if not set.
///
/// ```swift
/// @UserDefault(key: "optionalUsername")
/// static var username: String?
///
/// @UserDefault(key: "optionalUser")
/// static var currentUser: User?
/// ```
@propertyWrapper
public struct OptionalUserDefault<T: Codable> {
    
    // MARK: - Properties
    
    private let key: String
    private let userDefaults: UserDefaults
    
    // MARK: - Initialization
    
    /// Creates a new optional UserDefault property wrapper.
    ///
    /// - Parameters:
    ///   - key: The key to use in UserDefaults.
    ///   - userDefaults: The UserDefaults instance to use. Defaults to `.standard`.
    public init(
        key: String,
        userDefaults: UserDefaults = .standard
    ) {
        self.key = key
        self.userDefaults = userDefaults
    }
    
    // MARK: - Property Wrapper
    
    public var wrappedValue: T? {
        get {
            // Handle primitive types directly
            if T.self == String.self {
                return userDefaults.string(forKey: key) as? T
            } else if T.self == Int.self {
                guard userDefaults.object(forKey: key) != nil else { return nil }
                return userDefaults.integer(forKey: key) as? T
            } else if T.self == Double.self {
                guard userDefaults.object(forKey: key) != nil else { return nil }
                return userDefaults.double(forKey: key) as? T
            } else if T.self == Bool.self {
                guard userDefaults.object(forKey: key) != nil else { return nil }
                return userDefaults.bool(forKey: key) as? T
            } else if T.self == Data.self {
                return userDefaults.data(forKey: key) as? T
            } else {
                // Use Codable for complex types
                return userDefaults.getCodable(T.self, forKey: key)
            }
        }
        set {
            if let newValue = newValue {
                // Handle primitive types directly
                if let stringValue = newValue as? String {
                    userDefaults.set(stringValue, forKey: key)
                } else if let intValue = newValue as? Int {
                    userDefaults.set(intValue, forKey: key)
                } else if let doubleValue = newValue as? Double {
                    userDefaults.set(doubleValue, forKey: key)
                } else if let boolValue = newValue as? Bool {
                    userDefaults.set(boolValue, forKey: key)
                } else if let dataValue = newValue as? Data {
                    userDefaults.set(dataValue, forKey: key)
                } else {
                    // Use Codable for complex types
                    _ = userDefaults.setCodableSafe(newValue, forKey: key)
                }
            } else {
                // Remove value if set to nil
                userDefaults.removeObject(forKey: key)
            }
        }
    }
    
    public var projectedValue: OptionalUserDefault<T> {
        self
    }
}

// MARK: - UserDefault Extensions

public extension UserDefault {
    /// Removes the stored value and resets to default.
    func reset() {
        userDefaults.removeObject(forKey: key)
    }
    
    /// Checks if a value has been explicitly set.
    var hasValue: Bool {
        userDefaults.object(forKey: key) != nil
    }
}

public extension OptionalUserDefault {
    /// Removes the stored value.
    func reset() {
        userDefaults.removeObject(forKey: key)
    }
    
    /// Checks if a value has been explicitly set.
    var hasValue: Bool {
        userDefaults.object(forKey: key) != nil
    }
}
