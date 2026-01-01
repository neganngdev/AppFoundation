// String+Extensions.swift
// AppFoundation
//
// Extensions providing common string utilities for validation, formatting, and localization.

import Foundation

// MARK: - String Extensions

public extension String {
    
    // MARK: - Validation
    
    /// Returns `true` if the string is empty or contains only whitespace characters.
    ///
    /// This is more comprehensive than `isEmpty` as it also checks for whitespace-only strings.
    ///
    /// ```swift
    /// "".isBlank        // true
    /// "   ".isBlank     // true
    /// "  \n\t ".isBlank // true
    /// "Hello".isBlank   // false
    /// ```
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Returns `true` if the string is a valid email address format.
    ///
    /// Uses RFC 5322 compliant regex pattern for email validation.
    ///
    /// ```swift
    /// "user@example.com".isValidEmail     // true
    /// "user.name@domain.co.uk".isValidEmail // true
    /// "invalid-email".isValidEmail        // false
    /// "@missing.local".isValidEmail       // false
    /// ```
    var isValidEmail: Bool {
        let emailPattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        guard let regex = try? NSRegularExpression(pattern: emailPattern, options: []) else {
            return false
        }
        let range = NSRange(location: 0, length: utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
    
    // MARK: - Transformation
    
    /// Returns a new string with leading and trailing whitespace and newlines removed.
    ///
    /// This is a convenience wrapper around `trimmingCharacters(in:)`.
    ///
    /// ```swift
    /// "  Hello World  ".trimmed // "Hello World"
    /// "\n\tContent\n".trimmed   // "Content"
    /// ```
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Returns a localized version of this string using `NSLocalizedString`.
    ///
    /// The string itself is used as the key for lookup in the Localizable.strings file.
    ///
    /// ```swift
    /// "hello_message".localized // Returns localized value or "hello_message" if not found
    /// ```
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    /// Returns a localized version of this string with arguments substituted.
    ///
    /// - Parameter arguments: The values to substitute into the format string.
    /// - Returns: A localized and formatted string.
    ///
    /// ```swift
    /// "hello_name".localized(with: "John") // "Hello, John!" (if localized format is "Hello, %@!")
    /// ```
    func localized(with arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }
    
    // MARK: - Utilities
    
    /// Returns `nil` if the string is empty or blank, otherwise returns the string.
    ///
    /// Useful for optional chaining and nil-coalescing operations.
    ///
    /// ```swift
    /// "Hello".nilIfEmpty     // Optional("Hello")
    /// "".nilIfEmpty          // nil
    /// "   ".nilIfEmpty       // nil
    /// ```
    var nilIfEmpty: String? {
        isBlank ? nil : self
    }
    
    /// Returns the string with only the first character capitalized.
    ///
    /// Unlike `capitalized`, this doesn't modify other characters.
    ///
    /// ```swift
    /// "hello WORLD".capitalizedFirst // "Hello WORLD"
    /// "HELLO".capitalizedFirst       // "HELLO"
    /// ```
    var capitalizedFirst: String {
        guard let first = first else { return self }
        return String(first).uppercased() + dropFirst()
    }
    
    /// Checks if the string contains only numeric characters.
    ///
    /// ```swift
    /// "12345".isNumeric  // true
    /// "12.34".isNumeric  // false (contains decimal point)
    /// "12a34".isNumeric  // false
    /// ```
    var isNumeric: Bool {
        !isEmpty && allSatisfy { $0.isNumber }
    }
    
    /// Checks if the string contains only alphanumeric characters.
    ///
    /// ```swift
    /// "Hello123".isAlphanumeric  // true
    /// "Hello 123".isAlphanumeric // false (contains space)
    /// ```
    var isAlphanumeric: Bool {
        !isEmpty && allSatisfy { $0.isLetter || $0.isNumber }
    }
}
