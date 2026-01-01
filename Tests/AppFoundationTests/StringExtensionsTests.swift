// StringExtensionsTests.swift
// AppFoundationTests

import XCTest
@testable import AppFoundation

final class StringExtensionsTests: XCTestCase {
    
    // MARK: - isBlank Tests
    
    func testIsBlank_emptyString_returnsTrue() {
        XCTAssertTrue("".isBlank)
    }
    
    func testIsBlank_whitespaceOnly_returnsTrue() {
        XCTAssertTrue("   ".isBlank)
        XCTAssertTrue("\t\t".isBlank)
        XCTAssertTrue("\n\n".isBlank)
        XCTAssertTrue("  \n\t  ".isBlank)
    }
    
    func testIsBlank_nonEmptyString_returnsFalse() {
        XCTAssertFalse("Hello".isBlank)
        XCTAssertFalse(" Hello ".isBlank)
        XCTAssertFalse("a".isBlank)
    }
    
    // MARK: - isValidEmail Tests
    
    func testIsValidEmail_validEmails_returnsTrue() {
        XCTAssertTrue("user@example.com".isValidEmail)
        XCTAssertTrue("user.name@example.com".isValidEmail)
        XCTAssertTrue("user+tag@example.co.uk".isValidEmail)
        XCTAssertTrue("user123@domain123.org".isValidEmail)
        XCTAssertTrue("User@Example.COM".isValidEmail)
    }
    
    func testIsValidEmail_invalidEmails_returnsFalse() {
        XCTAssertFalse("".isValidEmail)
        XCTAssertFalse("invalid".isValidEmail)
        XCTAssertFalse("@example.com".isValidEmail)
        XCTAssertFalse("user@".isValidEmail)
        XCTAssertFalse("user@.com".isValidEmail)
        XCTAssertFalse("user @example.com".isValidEmail)
        XCTAssertFalse("user@example".isValidEmail)
    }
    
    // MARK: - trimmed Tests
    
    func testTrimmed_whitespace_removed() {
        XCTAssertEqual("  Hello  ".trimmed, "Hello")
        XCTAssertEqual("\n\tHello\n\t".trimmed, "Hello")
        XCTAssertEqual("Hello".trimmed, "Hello")
    }
    
    func testTrimmed_emptyString_remainsEmpty() {
        XCTAssertEqual("".trimmed, "")
        XCTAssertEqual("   ".trimmed, "")
    }
    
    // MARK: - localized Tests
    
    func testLocalized_unknownKey_returnsKey() {
        // When the key doesn't exist, NSLocalizedString returns the key itself
        let key = "nonexistent_key_12345"
        XCTAssertEqual(key.localized, key)
    }
    
    // MARK: - nilIfEmpty Tests
    
    func testNilIfEmpty_nonEmpty_returnsValue() {
        XCTAssertEqual("Hello".nilIfEmpty, "Hello")
    }
    
    func testNilIfEmpty_empty_returnsNil() {
        XCTAssertNil("".nilIfEmpty)
    }
    
    func testNilIfEmpty_blank_returnsNil() {
        XCTAssertNil("   ".nilIfEmpty)
    }
    
    // MARK: - capitalizedFirst Tests
    
    func testCapitalizedFirst_lowercaseStart_capitalizes() {
        XCTAssertEqual("hello".capitalizedFirst, "Hello")
        XCTAssertEqual("hello world".capitalizedFirst, "Hello world")
    }
    
    func testCapitalizedFirst_uppercasePreserved() {
        XCTAssertEqual("hello WORLD".capitalizedFirst, "Hello WORLD")
    }
    
    func testCapitalizedFirst_empty_remainsEmpty() {
        XCTAssertEqual("".capitalizedFirst, "")
    }
    
    // MARK: - isNumeric Tests
    
    func testIsNumeric_numbersOnly_returnsTrue() {
        XCTAssertTrue("12345".isNumeric)
        XCTAssertTrue("0".isNumeric)
    }
    
    func testIsNumeric_withOtherCharacters_returnsFalse() {
        XCTAssertFalse("12.34".isNumeric)
        XCTAssertFalse("12a34".isNumeric)
        XCTAssertFalse("".isNumeric)
        XCTAssertFalse("-123".isNumeric)
    }
    
    // MARK: - isAlphanumeric Tests
    
    func testIsAlphanumeric_lettersAndNumbers_returnsTrue() {
        XCTAssertTrue("Hello123".isAlphanumeric)
        XCTAssertTrue("ABC".isAlphanumeric)
        XCTAssertTrue("123".isAlphanumeric)
    }
    
    func testIsAlphanumeric_withOtherCharacters_returnsFalse() {
        XCTAssertFalse("Hello 123".isAlphanumeric)
        XCTAssertFalse("Hello!".isAlphanumeric)
        XCTAssertFalse("".isAlphanumeric)
    }
}
