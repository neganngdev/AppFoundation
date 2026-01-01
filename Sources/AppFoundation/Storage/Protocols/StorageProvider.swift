// StorageProvider.swift
// AppFoundation
//
// Generic storage protocol for abstraction and dependency injection.

import Foundation

// MARK: - Storage Provider Protocol

/// A protocol defining a generic interface for storage operations.
///
/// Implement this protocol to create custom storage providers that can be
/// easily swapped or mocked in tests.
///
/// ```swift
/// class MyStorage: StorageProvider {
///     func save<T>(_ value: T, forKey key: String) throws where T: Encodable {
///         // Implementation
///     }
///     // ... other methods
/// }
/// ```
public protocol StorageProvider {
    /// Saves a value for the specified key.
    ///
    /// - Parameters:
    ///   - value: The value to save. Must be Encodable.
    ///   - key: The key to associate with the value.
    /// - Throws: An error if the save operation fails.
    func save<T: Encodable>(_ value: T, forKey key: String) throws
    
    /// Retrieves a value for the specified key.
    ///
    /// - Parameter key: The key associated with the value.
    /// - Returns: The decoded value, or `nil` if not found.
    /// - Throws: An error if the retrieval or decoding fails.
    func get<T: Decodable>(forKey key: String) throws -> T?
    
    /// Deletes the value associated with the specified key.
    ///
    /// - Parameter key: The key to delete.
    /// - Throws: An error if the deletion fails.
    func delete(forKey key: String) throws
    
    /// Deletes all stored values.
    ///
    /// - Throws: An error if the operation fails.
    func deleteAll() throws
    
    /// Checks if a value exists for the specified key.
    ///
    /// - Parameter key: The key to check.
    /// - Returns: `true` if a value exists for the key.
    func exists(forKey key: String) -> Bool
}

// MARK: - Async Storage Provider

/// An async version of StorageProvider for async/await support.
///
/// Use this protocol when your storage operations are asynchronous,
/// such as with Keychain or network-based storage.
public protocol AsyncStorageProvider {
    /// Saves a value for the specified key asynchronously.
    func save<T: Encodable>(_ value: T, forKey key: String) async throws
    
    /// Retrieves a value for the specified key asynchronously.
    func get<T: Decodable>(forKey key: String) async throws -> T?
    
    /// Deletes the value associated with the specified key asynchronously.
    func delete(forKey key: String) async throws
    
    /// Deletes all stored values asynchronously.
    func deleteAll() async throws
    
    /// Checks if a value exists for the specified key asynchronously.
    func exists(forKey key: String) async -> Bool
}

// MARK: - In-Memory Storage (for testing)

/// A simple in-memory storage implementation for testing purposes.
///
/// This implementation is thread-safe and useful for unit tests.
///
/// ```swift
/// let storage = InMemoryStorage()
/// try storage.save("test", forKey: "key")
/// let value: String? = try storage.get(forKey: "key")
/// ```
public final class InMemoryStorage: StorageProvider, @unchecked Sendable {
    private var storage: [String: Data] = [:]
    private let lock = NSLock()
    
    public init() {}
    
    public func save<T: Encodable>(_ value: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(value)
        lock.lock()
        defer { lock.unlock() }
        storage[key] = data
    }
    
    public func get<T: Decodable>(forKey key: String) throws -> T? {
        lock.lock()
        defer { lock.unlock() }
        
        guard let data = storage[key] else {
            return nil
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    public func delete(forKey key: String) throws {
        lock.lock()
        defer { lock.unlock() }
        storage.removeValue(forKey: key)
    }
    
    public func deleteAll() throws {
        lock.lock()
        defer { lock.unlock() }
        storage.removeAll()
    }
    
    public func exists(forKey key: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return storage[key] != nil
    }
}

// MARK: - Storage Key Protocol

/// A protocol for type-safe storage keys.
///
/// Use this to create compile-time safe storage keys.
///
/// ```swift
/// enum StorageKeys: String, StorageKey {
///     case username
///     case hasSeenOnboarding
///     
///     var key: String { rawValue }
/// }
///
/// try storage.save("John", forKey: StorageKeys.username.key)
/// ```
public protocol StorageKey {
    /// The string key used for storage.
    var key: String { get }
}

extension String: StorageKey {
    public var key: String { self }
}

// MARK: - Storage Provider Extensions

public extension StorageProvider {
    /// Saves a value using a type-safe key.
    func save<T: Encodable, K: StorageKey>(_ value: T, forKey key: K) throws {
        try save(value, forKey: key.key)
    }
    
    /// Retrieves a value using a type-safe key.
    func get<T: Decodable, K: StorageKey>(forKey key: K) throws -> T? {
        try get(forKey: key.key)
    }
    
    /// Deletes a value using a type-safe key.
    func delete<K: StorageKey>(forKey key: K) throws {
        try delete(forKey: key.key)
    }
    
    /// Checks existence using a type-safe key.
    func exists<K: StorageKey>(forKey key: K) -> Bool {
        exists(forKey: key.key)
    }
}
