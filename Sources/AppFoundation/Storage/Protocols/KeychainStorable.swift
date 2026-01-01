// KeychainStorable.swift
// AppFoundation
//
// Protocol for Keychain-specific storage operations.

import Foundation
import Security

// MARK: - Keychain Accessible

/// Keychain accessibility options determining when items can be accessed.
///
/// These options control when the keychain item is accessible and whether
/// it synchronizes with iCloud Keychain.
public enum KeychainAccessible: RawRepresentable, Sendable {
    /// Item is accessible only while the device is unlocked.
    case whenUnlocked
    
    /// Item is accessible after the first unlock after device restart.
    case afterFirstUnlock
    
    /// Item is always accessible (not recommended for sensitive data).
    case always
    
    /// Item is accessible only while unlocked and won't sync to iCloud.
    case whenUnlockedThisDeviceOnly
    
    /// Item is accessible after first unlock and won't sync to iCloud.
    case afterFirstUnlockThisDeviceOnly
    
    /// Item is always accessible and won't sync to iCloud.
    case alwaysThisDeviceOnly
    
    public init?(rawValue: CFString) {
        switch rawValue {
        case kSecAttrAccessibleWhenUnlocked:
            self = .whenUnlocked
        case kSecAttrAccessibleAfterFirstUnlock:
            self = .afterFirstUnlock
        case kSecAttrAccessibleAlways:
            self = .always
        case kSecAttrAccessibleWhenUnlockedThisDeviceOnly:
            self = .whenUnlockedThisDeviceOnly
        case kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly:
            self = .afterFirstUnlockThisDeviceOnly
        case kSecAttrAccessibleAlwaysThisDeviceOnly:
            self = .alwaysThisDeviceOnly
        default:
            return nil
        }
    }
    
    public var rawValue: CFString {
        switch self {
        case .whenUnlocked:
            return kSecAttrAccessibleWhenUnlocked
        case .afterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock
        case .always:
            return kSecAttrAccessibleAlways
        case .whenUnlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .afterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .alwaysThisDeviceOnly:
            return kSecAttrAccessibleAlwaysThisDeviceOnly
        }
    }
}

// MARK: - Keychain Configuration

/// Configuration for Keychain storage operations.
public struct KeychainConfiguration: Sendable {
    /// The service identifier for keychain items.
    public let service: String
    
    /// The access group for sharing keychain items between apps.
    public let accessGroup: String?
    
    /// The accessibility level for keychain items.
    public let accessible: KeychainAccessible
    
    /// Whether to synchronize with iCloud Keychain.
    public let synchronizable: Bool
    
    /// Creates a new keychain configuration.
    ///
    /// - Parameters:
    ///   - service: The service identifier (typically bundle ID).
    ///   - accessGroup: Optional access group for app extensions.
    ///   - accessible: When the item can be accessed.
    ///   - synchronizable: Whether to sync with iCloud.
    public init(
        service: String = Bundle.main.bundleIdentifier ?? "AppFoundation",
        accessGroup: String? = nil,
        accessible: KeychainAccessible = .afterFirstUnlock,
        synchronizable: Bool = false
    ) {
        self.service = service
        self.accessGroup = accessGroup
        self.accessible = accessible
        self.synchronizable = synchronizable
    }
}

// MARK: - Keychain Storable Protocol

/// A protocol for types that can interact with Keychain storage.
///
/// This protocol defines the interface for Keychain-specific operations
/// with support for access groups and accessibility options.
public protocol KeychainStorable {
    /// The configuration for this keychain storage.
    var configuration: KeychainConfiguration { get }
    
    /// Saves data to the keychain.
    ///
    /// - Parameters:
    ///   - data: The data to save.
    ///   - key: The key to associate with the data.
    /// - Throws: `KeychainError` if the operation fails.
    func saveData(_ data: Data, forKey key: String) async throws
    
    /// Retrieves data from the keychain.
    ///
    /// - Parameter key: The key associated with the data.
    /// - Returns: The data, or `nil` if not found.
    /// - Throws: `KeychainError` if the operation fails.
    func getData(forKey key: String) async throws -> Data?
    
    /// Deletes data from the keychain.
    ///
    /// - Parameter key: The key to delete.
    /// - Throws: `KeychainError` if the operation fails.
    func deleteData(forKey key: String) async throws
    
    /// Deletes all keychain items for this service.
    ///
    /// - Throws: `KeychainError` if the operation fails.
    func deleteAllData() async throws
}

// MARK: - Keychain Storable Default Implementations

public extension KeychainStorable {
    /// Saves a string to the keychain.
    ///
    /// - Parameters:
    ///   - value: The string to save.
    ///   - key: The key to associate with the string.
    /// - Throws: `KeychainError` if the operation fails.
    func save(_ value: String, forKey key: String) async throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }
        try await saveData(data, forKey: key)
    }
    
    /// Retrieves a string from the keychain.
    ///
    /// - Parameter key: The key associated with the string.
    /// - Returns: The string, or `nil` if not found.
    /// - Throws: `KeychainError` if the operation fails.
    func getString(forKey key: String) async throws -> String? {
        guard let data = try await getData(forKey: key) else {
            return nil
        }
        
        guard let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.decodingFailed
        }
        
        return string
    }
    
    /// Saves a Codable object to the keychain.
    ///
    /// - Parameters:
    ///   - value: The Codable object to save.
    ///   - key: The key to associate with the object.
    /// - Throws: `KeychainError` if the operation fails.
    func save<T: Encodable>(_ value: T, forKey key: String) async throws {
        do {
            let data = try JSONEncoder().encode(value)
            try await saveData(data, forKey: key)
        } catch {
            throw KeychainError.encodingFailed
        }
    }
    
    /// Retrieves a Codable object from the keychain.
    ///
    /// - Parameter key: The key associated with the object.
    /// - Returns: The decoded object, or `nil` if not found.
    /// - Throws: `KeychainError` if the operation fails.
    func get<T: Decodable>(forKey key: String) async throws -> T? {
        guard let data = try await getData(forKey: key) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw KeychainError.decodingFailed
        }
    }
    
    /// Checks if a value exists in the keychain.
    ///
    /// - Parameter key: The key to check.
    /// - Returns: `true` if the key exists.
    func exists(forKey key: String) async -> Bool {
        do {
            let data = try await getData(forKey: key)
            return data != nil
        } catch {
            return false
        }
    }
}
