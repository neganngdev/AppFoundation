// UserDefaults+Extensions.swift
// AppFoundation
//
// Extensions providing type-safe access to UserDefaults with Codable support.

import Foundation

// MARK: - UserDefaults Extensions

public extension UserDefaults {
    
    // MARK: - Generic Typed Getters/Setters
    
    /// Sets a value for the specified key.
    ///
    /// - Parameters:
    ///   - value: The value to store.
    ///   - key: The key with which to associate the value.
    ///
    /// ```swift
    /// UserDefaults.standard.set(value: "John", forKey: "username")
    /// UserDefaults.standard.set(value: 42, forKey: "score")
    /// ```
    func set<T>(value: T?, forKey key: String) {
        set(value, forKey: key)
    }
    
    /// Returns the value associated with the specified key, or a default value.
    ///
    /// - Parameters:
    ///   - key: The key associated with the value.
    ///   - defaultValue: The default value to return if the key doesn't exist.
    /// - Returns: The stored value or the default value.
    ///
    /// ```swift
    /// let username: String = UserDefaults.standard.get(forKey: "username", default: "Guest")
    /// let score: Int = UserDefaults.standard.get(forKey: "score", default: 0)
    /// ```
    func get<T>(forKey key: String, default defaultValue: T) -> T {
        object(forKey: key) as? T ?? defaultValue
    }
    
    /// Returns the optional value associated with the specified key.
    ///
    /// - Parameter key: The key associated with the value.
    /// - Returns: The stored value or `nil` if not found.
    ///
    /// ```swift
    /// let username: String? = UserDefaults.standard.get(forKey: "username")
    /// ```
    func get<T>(forKey key: String) -> T? {
        object(forKey: key) as? T
    }
    
    // MARK: - Codable Support
    
    /// Stores a Codable object for the specified key.
    ///
    /// The object is encoded to JSON data before storage.
    ///
    /// - Parameters:
    ///   - object: The Codable object to store.
    ///   - key: The key with which to associate the object.
    /// - Throws: An error if encoding fails.
    ///
    /// ```swift
    /// struct User: Codable {
    ///     let name: String
    ///     let email: String
    /// }
    ///
    /// let user = User(name: "John", email: "john@example.com")
    /// try UserDefaults.standard.setCodable(user, forKey: "currentUser")
    /// ```
    func setCodable<T: Encodable>(_ object: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(object)
        set(data, forKey: key)
    }
    
    /// Retrieves a Codable object for the specified key.
    ///
    /// - Parameters:
    ///   - type: The type of object to decode.
    ///   - key: The key associated with the object.
    /// - Returns: The decoded object or `nil` if not found or decoding fails.
    ///
    /// ```swift
    /// let user: User? = UserDefaults.standard.getCodable(User.self, forKey: "currentUser")
    /// ```
    func getCodable<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
    
    /// Retrieves a Codable object for the specified key, or returns a default value.
    ///
    /// - Parameters:
    ///   - type: The type of object to decode.
    ///   - key: The key associated with the object.
    ///   - defaultValue: The default value to return if decoding fails.
    /// - Returns: The decoded object or the default value.
    func getCodable<T: Decodable>(
        _ type: T.Type,
        forKey key: String,
        default defaultValue: T
    ) -> T {
        getCodable(type, forKey: key) ?? defaultValue
    }
    
    /// Safely sets a Codable object, returning a boolean indicating success.
    ///
    /// - Parameters:
    ///   - object: The Codable object to store.
    ///   - key: The key with which to associate the object.
    /// - Returns: `true` if the object was successfully stored.
    @discardableResult
    func setCodableSafe<T: Encodable>(_ object: T, forKey key: String) -> Bool {
        do {
            try setCodable(object, forKey: key)
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - Convenience Subscripts
    
    /// Subscript access to string values.
    subscript(string key: String) -> String? {
        get { string(forKey: key) }
        set { set(newValue, forKey: key) }
    }
    
    /// Subscript access to integer values.
    subscript(int key: String) -> Int {
        get { integer(forKey: key) }
        set { set(newValue, forKey: key) }
    }
    
    /// Subscript access to double values.
    subscript(double key: String) -> Double {
        get { double(forKey: key) }
        set { set(newValue, forKey: key) }
    }
    
    /// Subscript access to boolean values.
    subscript(bool key: String) -> Bool {
        get { bool(forKey: key) }
        set { set(newValue, forKey: key) }
    }
    
    /// Subscript access to date values.
    subscript(date key: String) -> Date? {
        get { object(forKey: key) as? Date }
        set { set(newValue, forKey: key) }
    }
    
    /// Subscript access to URL values.
    subscript(url key: String) -> URL? {
        get { url(forKey: key) }
        set { set(newValue, forKey: key) }
    }
    
    /// Subscript access to Data values.
    subscript(data key: String) -> Data? {
        get { data(forKey: key) }
        set { set(newValue, forKey: key) }
    }
    
    // MARK: - Existence Check
    
    /// Returns `true` if a value exists for the specified key.
    ///
    /// - Parameter key: The key to check.
    /// - Returns: `true` if the key exists.
    func hasValue(forKey key: String) -> Bool {
        object(forKey: key) != nil
    }
    
    // MARK: - Batch Operations
    
    /// Removes values for multiple keys.
    ///
    /// - Parameter keys: The keys whose values should be removed.
    func removeValues(forKeys keys: [String]) {
        keys.forEach { removeObject(forKey: $0) }
    }
    
    /// Sets multiple key-value pairs at once.
    ///
    /// - Parameter dictionary: A dictionary of keys and values to set.
    func setValues(_ dictionary: [String: Any]) {
        dictionary.forEach { set($0.value, forKey: $0.key) }
    }
}

// MARK: - UserDefaults Keys

/// A type-safe key for UserDefaults.
///
/// Use this to define your UserDefaults keys with their associated types.
///
/// ```swift
/// extension UserDefaultsKey {
///     static let username = UserDefaultsKey<String>("username")
///     static let onboardingComplete = UserDefaultsKey<Bool>("onboardingComplete")
/// }
///
/// UserDefaults.standard[.username] = "John"
/// let name = UserDefaults.standard[.username]
/// ```
public struct UserDefaultsKey<T> {
    public let key: String
    
    public init(_ key: String) {
        self.key = key
    }
}

public extension UserDefaults {
    
    /// Subscript access using type-safe keys.
    subscript<T>(key: UserDefaultsKey<T>) -> T? {
        get { object(forKey: key.key) as? T }
        set { set(newValue, forKey: key.key) }
    }
    
    /// Subscript access using type-safe keys with a default value.
    subscript<T>(key: UserDefaultsKey<T>, default defaultValue: T) -> T {
        get { object(forKey: key.key) as? T ?? defaultValue }
        set { set(newValue, forKey: key.key) }
    }
}
