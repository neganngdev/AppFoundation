// KeychainStorage.swift
// AppFoundation
//
// Actor-based thread-safe Keychain manager with CRUD operations.

import Foundation
import Security

// MARK: - Keychain Storage

/// A thread-safe Keychain storage manager using Swift actors.
///
/// This actor provides secure storage for sensitive data like passwords,
/// tokens, and other credentials using the iOS Keychain.
///
/// ```swift
/// let keychain = KeychainStorage()
///
/// // Save
/// try await keychain.save("secret_token", forKey: "auth_token")
/// try await keychain.save(user, forKey: "current_user")
///
/// // Retrieve
/// let token: String? = try await keychain.getString(forKey: "auth_token")
/// let user: User? = try await keychain.get(forKey: "current_user")
///
/// // Delete
/// try await keychain.delete(forKey: "auth_token")
/// try await keychain.deleteAll()
/// ```
public actor KeychainStorage: KeychainStorable {
    
    // MARK: - Properties
    
    public let configuration: KeychainConfiguration
    
    // MARK: - Initialization
    
    /// Creates a new keychain storage instance.
    ///
    /// - Parameter configuration: The configuration for keychain operations.
    public init(configuration: KeychainConfiguration = KeychainConfiguration()) {
        self.configuration = configuration
    }
    
    // MARK: - KeychainStorable Implementation
    
    public func saveData(_ data: Data, forKey key: String) async throws {
        var query = buildBaseQuery(forKey: key)
        query[kSecValueData] = data
        query[kSecAttrAccessible] = configuration.accessible.rawValue
        
        // Try to add the item
        var status = SecItemAdd(query as CFDictionary, nil)
        
        // If item already exists, update it instead
        if status == errSecDuplicateItem {
            let updateQuery = buildBaseQuery(forKey: key)
            let attributesToUpdate: [CFString: Any] = [
                kSecValueData: data,
                kSecAttrAccessible: configuration.accessible.rawValue
            ]
            
            status = SecItemUpdate(
                updateQuery as CFDictionary,
                attributesToUpdate as CFDictionary
            )
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.from(status: status)
        }
    }
    
    public func getData(forKey key: String) async throws -> Data? {
        var query = buildBaseQuery(forKey: key)
        query[kSecReturnData] = true
        query[kSecMatchLimit] = kSecMatchLimitOne
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecItemNotFound {
            return nil
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.from(status: status)
        }
        
        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }
        
        return data
    }
    
    public func deleteData(forKey key: String) async throws {
        let query = buildBaseQuery(forKey: key)
        let status = SecItemDelete(query as CFDictionary)
        
        // Success or item not found are both acceptable
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.from(status: status)
        }
    }
    
    public func deleteAllData() async throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: configuration.service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        // Success or item not found are both acceptable
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.from(status: status)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Builds the base query dictionary for keychain operations.
    private func buildBaseQuery(forKey key: String) -> [CFString: Any] {
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: configuration.service,
            kSecAttrAccount: key
        ]
        
        if let accessGroup = configuration.accessGroup {
            query[kSecAttrAccessGroup] = accessGroup
        }
        
        if configuration.synchronizable {
            query[kSecAttrSynchronizable] = true
        }
        
        return query
    }
    
    // MARK: - Batch Operations
    
    /// Saves multiple key-value pairs to the keychain.
    ///
    /// - Parameter items: A dictionary of keys and data to save.
    /// - Throws: `KeychainError` if any operation fails.
    public func saveBatch(_ items: [String: Data]) async throws {
        for (key, data) in items {
            try await saveData(data, forKey: key)
        }
    }
    
    /// Retrieves multiple values from the keychain.
    ///
    /// - Parameter keys: The keys to retrieve.
    /// - Returns: A dictionary of keys and their associated data.
    /// - Throws: `KeychainError` if any operation fails.
    public func getBatch(forKeys keys: [String]) async throws -> [String: Data] {
        var results: [String: Data] = [:]
        
        for key in keys {
            if let data = try await getData(forKey: key) {
                results[key] = data
            }
        }
        
        return results
    }
    
    /// Deletes multiple keys from the keychain.
    ///
    /// - Parameter keys: The keys to delete.
    /// - Throws: `KeychainError` if any operation fails.
    public func deleteBatch(forKeys keys: [String]) async throws {
        for key in keys {
            try await deleteData(forKey: key)
        }
    }
    
    // MARK: - Query Operations
    
    /// Retrieves all keys stored in the keychain for this service.
    ///
    /// - Returns: An array of all stored keys.
    /// - Throws: `KeychainError` if the operation fails.
    public func allKeys() async throws -> [String] {
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: configuration.service,
            kSecReturnAttributes: true,
            kSecMatchLimit: kSecMatchLimitAll
        ]
        
        if let accessGroup = configuration.accessGroup {
            query[kSecAttrAccessGroup] = accessGroup
        }
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecItemNotFound {
            return []
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.from(status: status)
        }
        
        guard let items = result as? [[CFString: Any]] else {
            return []
        }
        
        return items.compactMap { $0[kSecAttrAccount] as? String }
    }
}

// MARK: - Keychain Storage + AsyncStorageProvider

extension KeychainStorage: AsyncStorageProvider {
    public func save<T: Encodable>(_ value: T, forKey key: String) async throws {
        // Calls KeychainStorable's save method
        try await (self as KeychainStorable).save(value, forKey: key)
    }
    
    public func get<T: Decodable>(forKey key: String) async throws -> T? {
        // Calls KeychainStorable's get method
        try await (self as KeychainStorable).get(forKey: key)
    }
    
    public func delete(forKey key: String) async throws {
        try await deleteData(forKey: key)
    }
    
    public func deleteAll() async throws {
        try await deleteAllData()
    }
    
    public func exists(forKey key: String) async -> Bool {
        // Calls KeychainStorable's exists method
        await (self as KeychainStorable).exists(forKey: key)
    }
}
