// UserDefaultsStorage.swift
// AppFoundation
//
// Thread-safe UserDefaults storage implementation.

import Foundation

// MARK: - UserDefaults Storage

/// A thread-safe wrapper around UserDefaults conforming to StorageProvider.
///
/// This class provides a consistent interface for UserDefaults operations
/// with proper synchronization and error handling.
///
/// ```swift
/// let storage = UserDefaultsStorage()
///
/// // Save
/// try storage.save("John", forKey: "username")
/// try storage.save(user, forKey: "current_user")
///
/// // Retrieve
/// let name: String? = try storage.get(forKey: "username")
/// let user: User? = try storage.get(forKey: "current_user")
///
/// // Delete
/// try storage.delete(forKey: "username")
/// ```
public final class UserDefaultsStorage: StorageProvider, @unchecked Sendable {
    
    // MARK: - Properties
    
    private let userDefaults: UserDefaults
    private let lock = NSLock()
    
    // MARK: - Initialization
    
    /// Creates a new UserDefaults storage instance.
    ///
    /// - Parameter userDefaults: The UserDefaults instance to use. Defaults to `.standard`.
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    /// Creates a new UserDefaults storage with a custom suite name.
    ///
    /// - Parameter suiteName: The suite name for the UserDefaults.
    public convenience init?(suiteName: String) {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            return nil
        }
        self.init(userDefaults: userDefaults)
    }
    
    // MARK: - StorageProvider Implementation
    
    public func save<T: Encodable>(_ value: T, forKey key: String) throws {
        lock.lock()
        defer { lock.unlock() }
        
        // Handle primitive types directly
        if let stringValue = value as? String {
            userDefaults.set(stringValue, forKey: key)
        } else if let intValue = value as? Int {
            userDefaults.set(intValue, forKey: key)
        } else if let doubleValue = value as? Double {
            userDefaults.set(doubleValue, forKey: key)
        } else if let boolValue = value as? Bool {
            userDefaults.set(boolValue, forKey: key)
        } else if let dataValue = value as? Data {
            userDefaults.set(dataValue, forKey: key)
        } else {
            // Use Codable for complex types
            do {
                try userDefaults.setCodable(value, forKey: key)
            } catch {
                throw AppFoundationError.storage(.encodingFailed(error.localizedDescription))
            }
        }
    }
    
    public func get<T: Decodable>(forKey key: String) throws -> T? {
        lock.lock()
        defer { lock.unlock() }
        
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
    
    public func delete(forKey key: String) throws {
        lock.lock()
        defer { lock.unlock() }
        userDefaults.removeObject(forKey: key)
    }
    
    public func deleteAll() throws {
        lock.lock()
        defer { lock.unlock() }
        
        guard let domain = Bundle.main.bundleIdentifier else {
            throw AppFoundationError.configuration(.missingValue(key: "bundleIdentifier"))
        }
        
        userDefaults.removePersistentDomain(forName: domain)
    }
    
    public func exists(forKey key: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return userDefaults.object(forKey: key) != nil
    }
    
    // MARK: - Batch Operations
    
    /// Saves multiple key-value pairs.
    ///
    /// - Parameter items: A dictionary of keys and values to save.
    /// - Throws: An error if any save operation fails.
    public func saveBatch<T: Encodable>(_ items: [String: T]) throws {
        for (key, value) in items {
            try save(value, forKey: key)
        }
    }
    
    /// Deletes multiple keys.
    ///
    /// - Parameter keys: The keys to delete.
    public func deleteBatch(forKeys keys: [String]) {
        lock.lock()
        defer { lock.unlock() }
        
        for key in keys {
            userDefaults.removeObject(forKey: key)
        }
    }
    
    // MARK: - Synchronization
    
    /// Forces UserDefaults to save to disk immediately.
    ///
    /// - Returns: `true` if synchronization was successful.
    @discardableResult
    public func synchronize() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return userDefaults.synchronize()
    }
}

// MARK: - UserDefaults Storage + Convenience

public extension UserDefaultsStorage {
    /// Saves a value with a type-safe key.
    func save<T: Encodable, K: StorageKey>(_ value: T, forKey key: K) throws {
        try save(value, forKey: key.key)
    }
    
    /// Retrieves a value with a type-safe key.
    func get<T: Decodable, K: StorageKey>(forKey key: K) throws -> T? {
        try get(forKey: key.key)
    }
    
    /// Deletes a value with a type-safe key.
    func delete<K: StorageKey>(forKey key: K) throws {
        try delete(forKey: key.key)
    }
    
    /// Checks existence with a type-safe key.
    func exists<K: StorageKey>(forKey key: K) -> Bool {
        exists(forKey: key.key)
    }
}
