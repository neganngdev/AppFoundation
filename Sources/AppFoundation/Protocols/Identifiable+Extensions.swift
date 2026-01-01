// Identifiable+Extensions.swift
// AppFoundation
//
// Protocol extensions for common patterns.

import Foundation

// MARK: - StringIdentifiable

/// A protocol for types that can be identified by a string.
///
/// Useful for models that use string IDs (e.g., from APIs).
public protocol StringIdentifiable: Identifiable where ID == String {}

// MARK: - Describable

/// A protocol for types that provide a user-friendly description.
public protocol Describable {
    /// A human-readable description of the instance.
    var displayDescription: String { get }
}

// MARK: - Copyable

/// A protocol for types that can create deep copies of themselves.
public protocol Copyable {
    /// Creates a deep copy of the instance.
    func copy() -> Self
}

// MARK: - Emptyable

/// A protocol for types that can be empty and provide an empty instance.
public protocol Emptyable {
    /// Whether this instance is empty.
    var isEmpty: Bool { get }
    
    /// Creates an empty instance.
    static var empty: Self { get }
}

// MARK: - Default Implementations

public extension Emptyable where Self: Collection {
    var isEmpty: Bool {
        count == 0
    }
}

// MARK: - Configurable

/// A protocol for types that can be configured using a closure.
///
/// ```swift
/// class MyView: Configurable {
///     var title: String = ""
/// }
///
/// let view = MyView().configured {
///     $0.title = "Hello"
/// }
/// ```
public protocol Configurable {}

public extension Configurable {
    /// Configures the instance using a closure and returns it.
    ///
    /// - Parameter configure: A closure that configures the instance.
    /// - Returns: The configured instance.
    @discardableResult
    func configured(_ configure: (Self) throws -> Void) rethrows -> Self {
        try configure(self)
        return self
    }
}

// MARK: - Then Protocol (Alternative to Configurable)

/// A protocol that allows inline configuration of instances.
///
/// Similar to Configurable but returns a modified copy for value types.
public protocol Then {}

public extension Then where Self: AnyObject {
    /// Configures the instance using a closure and returns it.
    @discardableResult
    func then(_ configure: (Self) throws -> Void) rethrows -> Self {
        try configure(self)
        return self
    }
}

public extension Then where Self: Any {
    /// Creates a copy, configures it, and returns the modified copy.
    func with(_ configure: (inout Self) throws -> Void) rethrows -> Self {
        var copy = self
        try configure(&copy)
        return copy
    }
}

// MARK: - NSObject Conformance

extension NSObject: Then {}
extension NSObject: Configurable {}
