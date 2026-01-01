// Collection+Extensions.swift
// AppFoundation
//
// Extensions providing safe access, chunking, and deduplication for collections.

import Foundation

// MARK: - Collection Extensions

public extension Collection {
    
    /// Returns the element at the specified index if it exists, otherwise `nil`.
    ///
    /// This provides a safe way to access collection elements without risking
    /// an index out of bounds crash.
    ///
    /// ```swift
    /// let array = [1, 2, 3]
    /// array[safe: 0]  // Optional(1)
    /// array[safe: 5]  // nil
    /// array[safe: -1] // nil (for Array)
    /// ```
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
    
    /// Returns `true` if the collection is not empty.
    ///
    /// A convenience property that is more readable than `!isEmpty`.
    ///
    /// ```swift
    /// [1, 2, 3].isNotEmpty  // true
    /// [].isNotEmpty         // false
    /// ```
    var isNotEmpty: Bool {
        !isEmpty
    }
}

// MARK: - Array Extensions

public extension Array {
    
    /// Splits the array into chunks of the specified size.
    ///
    /// The last chunk may contain fewer elements than the specified size
    /// if the array's count is not evenly divisible.
    ///
    /// - Parameter size: The maximum size of each chunk. Must be greater than 0.
    /// - Returns: An array of arrays, where each inner array has at most `size` elements.
    ///
    /// ```swift
    /// [1, 2, 3, 4, 5].chunked(into: 2)  // [[1, 2], [3, 4], [5]]
    /// [1, 2, 3].chunked(into: 5)         // [[1, 2, 3]]
    /// [].chunked(into: 2)                // []
    /// ```
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

public extension Array where Element: Hashable {
    
    /// Returns a new array with duplicate elements removed, preserving order.
    ///
    /// The first occurrence of each element is kept, subsequent duplicates are removed.
    ///
    /// ```swift
    /// [1, 2, 2, 3, 1, 4].removingDuplicates()  // [1, 2, 3, 4]
    /// ["a", "b", "a", "c"].removingDuplicates() // ["a", "b", "c"]
    /// ```
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
    
    /// Removes duplicate elements from the array in place, preserving order.
    ///
    /// ```swift
    /// var numbers = [1, 2, 2, 3, 1, 4]
    /// numbers.removeDuplicates()
    /// // numbers is now [1, 2, 3, 4]
    /// ```
    mutating func removeDuplicates() {
        self = removingDuplicates()
    }
}

public extension Array where Element: Equatable {
    
    /// Returns a new array with duplicate elements removed, preserving order.
    ///
    /// This version works with Equatable elements but is O(n²) complexity.
    /// Prefer the Hashable version when possible.
    ///
    /// ```swift
    /// struct Person: Equatable { let name: String }
    /// let people = [Person(name: "Alice"), Person(name: "Bob"), Person(name: "Alice")]
    /// people.removingDuplicatesEquatable()  // [Person(name: "Alice"), Person(name: "Bob")]
    /// ```
    func removingDuplicatesEquatable() -> [Element] {
        var result: [Element] = []
        for element in self {
            if !result.contains(element) {
                result.append(element)
            }
        }
        return result
    }
}

// MARK: - Sequence Extensions

public extension Sequence {
    
    /// Returns an array containing the non-nil results of calling the given
    /// transformation with each element of this sequence, asynchronously.
    ///
    /// - Parameter transform: An async closure that accepts an element and returns an optional value.
    /// - Returns: An array of the non-nil results.
    func asyncCompactMap<T>(
        _ transform: (Element) async throws -> T?
    ) async rethrows -> [T] {
        var results: [T] = []
        for element in self {
            if let result = try await transform(element) {
                results.append(result)
            }
        }
        return results
    }
    
    /// Returns an array containing the results of calling the given
    /// transformation with each element of this sequence, asynchronously.
    ///
    /// - Parameter transform: An async closure that accepts an element and returns a value.
    /// - Returns: An array of the transformed results.
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var results: [T] = []
        for element in self {
            results.append(try await transform(element))
        }
        return results
    }
    
    /// Calls the given closure on each element in the sequence asynchronously.
    ///
    /// - Parameter body: An async closure that takes an element of the sequence.
    func asyncForEach(
        _ body: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await body(element)
        }
    }
    
    /// Returns an array containing the elements of this sequence that satisfy
    /// the given predicate, asynchronously.
    ///
    /// - Parameter isIncluded: An async closure that takes an element and returns a Boolean.
    /// - Returns: An array of the elements that satisfy the predicate.
    func asyncFilter(
        _ isIncluded: (Element) async throws -> Bool
    ) async rethrows -> [Element] {
        var results: [Element] = []
        for element in self {
            if try await isIncluded(element) {
                results.append(element)
            }
        }
        return results
    }
}

// MARK: - Dictionary Extensions

public extension Dictionary {
    
    /// Merges the given dictionary into this dictionary, using a combining closure
    /// to determine the value for duplicate keys.
    ///
    /// - Parameters:
    ///   - other: The dictionary to merge.
    ///   - combine: A closure that takes the current and new values for duplicate keys.
    /// - Returns: A new dictionary with the merged values.
    func merging(
        _ other: [Key: Value],
        uniquingKeysWith combine: (Value, Value) -> Value = { _, new in new }
    ) -> [Key: Value] {
        var result = self
        for (key, value) in other {
            if let existing = result[key] {
                result[key] = combine(existing, value)
            } else {
                result[key] = value
            }
        }
        return result
    }
    
    /// Returns the value for the given key, or sets and returns a default value if the key doesn't exist.
    ///
    /// - Parameters:
    ///   - key: The key to look up.
    ///   - defaultValue: An autoclosure that produces the default value.
    /// - Returns: The existing value or the newly set default value.
    mutating func getOrSet(
        _ key: Key,
        default defaultValue: @autoclosure () -> Value
    ) -> Value {
        if let value = self[key] {
            return value
        }
        let value = defaultValue()
        self[key] = value
        return value
    }
}
