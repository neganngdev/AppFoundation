// Optional+Extensions.swift
// AppFoundation
//
// Extensions providing convenient nil and empty checking for optional types.

import Foundation

// MARK: - Optional String Extensions

public extension Optional where Wrapped == String {
    
    /// Returns `true` if the optional is `nil` or the wrapped string is empty.
    ///
    /// ```swift
    /// let nilString: String? = nil
    /// let emptyString: String? = ""
    /// let blankString: String? = "   "
    /// let validString: String? = "Hello"
    ///
    /// nilString.isNilOrEmpty    // true
    /// emptyString.isNilOrEmpty  // true
    /// blankString.isNilOrEmpty  // false (contains whitespace characters)
    /// validString.isNilOrEmpty  // false
    /// ```
    var isNilOrEmpty: Bool {
        switch self {
        case .none:
            return true
        case .some(let wrapped):
            return wrapped.isEmpty
        }
    }
    
    /// Returns `true` if the optional is `nil` or the wrapped string is empty or contains only whitespace.
    ///
    /// ```swift
    /// let nilString: String? = nil
    /// let emptyString: String? = ""
    /// let blankString: String? = "   "
    /// let validString: String? = "Hello"
    ///
    /// nilString.isNilOrBlank    // true
    /// emptyString.isNilOrBlank  // true
    /// blankString.isNilOrBlank  // true
    /// validString.isNilOrBlank  // false
    /// ```
    var isNilOrBlank: Bool {
        switch self {
        case .none:
            return true
        case .some(let wrapped):
            return wrapped.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    /// Returns the wrapped value or an empty string if `nil`.
    ///
    /// ```swift
    /// let nilString: String? = nil
    /// let validString: String? = "Hello"
    ///
    /// nilString.orEmpty    // ""
    /// validString.orEmpty  // "Hello"
    /// ```
    var orEmpty: String {
        self ?? ""
    }
}

// MARK: - Optional Collection Extensions

public extension Optional where Wrapped: Collection {
    
    /// Returns `true` if the optional is `nil` or the wrapped collection is empty.
    ///
    /// ```swift
    /// let nilArray: [Int]? = nil
    /// let emptyArray: [Int]? = []
    /// let validArray: [Int]? = [1, 2, 3]
    ///
    /// nilArray.isNilOrEmpty    // true
    /// emptyArray.isNilOrEmpty  // true
    /// validArray.isNilOrEmpty  // false
    /// ```
    var isNilOrEmpty: Bool {
        switch self {
        case .none:
            return true
        case .some(let wrapped):
            return wrapped.isEmpty
        }
    }
    
    /// Returns `true` if the optional contains a non-empty collection.
    ///
    /// ```swift
    /// let nilArray: [Int]? = nil
    /// let emptyArray: [Int]? = []
    /// let validArray: [Int]? = [1, 2, 3]
    ///
    /// nilArray.hasElements    // false
    /// emptyArray.hasElements  // false
    /// validArray.hasElements  // true
    /// ```
    var hasElements: Bool {
        !isNilOrEmpty
    }
}

// MARK: - Optional Bool Extensions

public extension Optional where Wrapped == Bool {
    
    /// Returns the wrapped value or `false` if `nil`.
    ///
    /// ```swift
    /// let nilBool: Bool? = nil
    /// let trueBool: Bool? = true
    /// let falseBool: Bool? = false
    ///
    /// nilBool.orFalse    // false
    /// trueBool.orFalse   // true
    /// falseBool.orFalse  // false
    /// ```
    var orFalse: Bool {
        self ?? false
    }
    
    /// Returns the wrapped value or `true` if `nil`.
    ///
    /// ```swift
    /// let nilBool: Bool? = nil
    /// let trueBool: Bool? = true
    /// let falseBool: Bool? = false
    ///
    /// nilBool.orTrue    // true
    /// trueBool.orTrue   // true
    /// falseBool.orTrue  // false
    /// ```
    var orTrue: Bool {
        self ?? true
    }
}

// MARK: - General Optional Extensions

public extension Optional {
    
    /// Returns `true` if the optional has a value (is not `nil`).
    ///
    /// ```swift
    /// let nilValue: Int? = nil
    /// let value: Int? = 42
    ///
    /// nilValue.hasValue  // false
    /// value.hasValue     // true
    /// ```
    var hasValue: Bool {
        self != nil
    }
    
    /// Returns `true` if the optional is `nil`.
    ///
    /// ```swift
    /// let nilValue: Int? = nil
    /// let value: Int? = 42
    ///
    /// nilValue.isNil  // true
    /// value.isNil     // false
    /// ```
    var isNil: Bool {
        self == nil
    }
    
    /// Executes a closure if the optional has a value.
    ///
    /// - Parameter action: The closure to execute with the unwrapped value.
    ///
    /// ```swift
    /// let name: String? = "John"
    /// name.ifLet { print("Hello, \($0)!") }
    /// // Prints: "Hello, John!"
    /// ```
    func ifLet(_ action: (Wrapped) -> Void) {
        if let value = self {
            action(value)
        }
    }
    
    /// Executes one closure if the optional has a value, or another if it's `nil`.
    ///
    /// - Parameters:
    ///   - ifSome: The closure to execute if the optional has a value.
    ///   - ifNone: The closure to execute if the optional is `nil`.
    ///
    /// ```swift
    /// let name: String? = nil
    /// name.ifLet(
    ///     then: { print("Hello, \($0)!") },
    ///     else: { print("No name provided") }
    /// )
    /// // Prints: "No name provided"
    /// ```
    func ifLet(
        then ifSome: (Wrapped) -> Void,
        else ifNone: () -> Void
    ) {
        if let value = self {
            ifSome(value)
        } else {
            ifNone()
        }
    }
    
    /// Transforms the optional value using an async closure.
    ///
    /// - Parameter transform: An async closure that transforms the wrapped value.
    /// - Returns: The transformed value or `nil` if the original is `nil`.
    func asyncMap<T>(_ transform: (Wrapped) async throws -> T) async rethrows -> T? {
        guard let value = self else { return nil }
        return try await transform(value)
    }
}
