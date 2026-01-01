// OptionalExtensionsTests.swift
// AppFoundationTests

import XCTest
@testable import AppFoundation

final class OptionalExtensionsTests: XCTestCase {
    
    // MARK: - String isNilOrEmpty Tests
    
    func testStringIsNilOrEmpty_nil_returnsTrue() {
        let value: String? = nil
        XCTAssertTrue(value.isNilOrEmpty)
    }
    
    func testStringIsNilOrEmpty_empty_returnsTrue() {
        let value: String? = ""
        XCTAssertTrue(value.isNilOrEmpty)
    }
    
    func testStringIsNilOrEmpty_whitespace_returnsFalse() {
        let value: String? = "   "
        XCTAssertFalse(value.isNilOrEmpty) // Whitespace is not empty
    }
    
    func testStringIsNilOrEmpty_nonEmpty_returnsFalse() {
        let value: String? = "Hello"
        XCTAssertFalse(value.isNilOrEmpty)
    }
    
    // MARK: - String isNilOrBlank Tests
    
    func testStringIsNilOrBlank_nil_returnsTrue() {
        let value: String? = nil
        XCTAssertTrue(value.isNilOrBlank)
    }
    
    func testStringIsNilOrBlank_empty_returnsTrue() {
        let value: String? = ""
        XCTAssertTrue(value.isNilOrBlank)
    }
    
    func testStringIsNilOrBlank_whitespace_returnsTrue() {
        let value: String? = "   "
        XCTAssertTrue(value.isNilOrBlank)
    }
    
    func testStringIsNilOrBlank_nonEmpty_returnsFalse() {
        let value: String? = "Hello"
        XCTAssertFalse(value.isNilOrBlank)
    }
    
    // MARK: - String orEmpty Tests
    
    func testStringOrEmpty_nil_returnsEmptyString() {
        let value: String? = nil
        XCTAssertEqual(value.orEmpty, "")
    }
    
    func testStringOrEmpty_nonNil_returnsValue() {
        let value: String? = "Hello"
        XCTAssertEqual(value.orEmpty, "Hello")
    }
    
    // MARK: - Collection isNilOrEmpty Tests
    
    func testArrayIsNilOrEmpty_nil_returnsTrue() {
        let value: [Int]? = nil
        XCTAssertTrue(value.isNilOrEmpty)
    }
    
    func testArrayIsNilOrEmpty_empty_returnsTrue() {
        let value: [Int]? = []
        XCTAssertTrue(value.isNilOrEmpty)
    }
    
    func testArrayIsNilOrEmpty_nonEmpty_returnsFalse() {
        let value: [Int]? = [1, 2, 3]
        XCTAssertFalse(value.isNilOrEmpty)
    }
    
    // MARK: - Collection hasElements Tests
    
    func testArrayHasElements_nil_returnsFalse() {
        let value: [Int]? = nil
        XCTAssertFalse(value.hasElements)
    }
    
    func testArrayHasElements_empty_returnsFalse() {
        let value: [Int]? = []
        XCTAssertFalse(value.hasElements)
    }
    
    func testArrayHasElements_nonEmpty_returnsTrue() {
        let value: [Int]? = [1, 2, 3]
        XCTAssertTrue(value.hasElements)
    }
    
    // MARK: - Dictionary isNilOrEmpty Tests
    
    func testDictionaryIsNilOrEmpty_nil_returnsTrue() {
        let value: [String: Int]? = nil
        XCTAssertTrue(value.isNilOrEmpty)
    }
    
    func testDictionaryIsNilOrEmpty_empty_returnsTrue() {
        let value: [String: Int]? = [:]
        XCTAssertTrue(value.isNilOrEmpty)
    }
    
    func testDictionaryIsNilOrEmpty_nonEmpty_returnsFalse() {
        let value: [String: Int]? = ["a": 1]
        XCTAssertFalse(value.isNilOrEmpty)
    }
    
    // MARK: - Bool orFalse/orTrue Tests
    
    func testBoolOrFalse_nil_returnsFalse() {
        let value: Bool? = nil
        XCTAssertFalse(value.orFalse)
    }
    
    func testBoolOrFalse_true_returnsTrue() {
        let value: Bool? = true
        XCTAssertTrue(value.orFalse)
    }
    
    func testBoolOrFalse_false_returnsFalse() {
        let value: Bool? = false
        XCTAssertFalse(value.orFalse)
    }
    
    func testBoolOrTrue_nil_returnsTrue() {
        let value: Bool? = nil
        XCTAssertTrue(value.orTrue)
    }
    
    func testBoolOrTrue_false_returnsFalse() {
        let value: Bool? = false
        XCTAssertFalse(value.orTrue)
    }
    
    // MARK: - General Optional Tests
    
    func testHasValue_nil_returnsFalse() {
        let value: Int? = nil
        XCTAssertFalse(value.hasValue)
    }
    
    func testHasValue_nonNil_returnsTrue() {
        let value: Int? = 42
        XCTAssertTrue(value.hasValue)
    }
    
    func testIsNil_nil_returnsTrue() {
        let value: Int? = nil
        XCTAssertTrue(value.isNil)
    }
    
    func testIsNil_nonNil_returnsFalse() {
        let value: Int? = 42
        XCTAssertFalse(value.isNil)
    }
    
    // MARK: - ifLet Tests
    
    func testIfLet_nonNil_executesAction() {
        let value: Int? = 42
        var result = 0
        
        value.ifLet { result = $0 }
        
        XCTAssertEqual(result, 42)
    }
    
    func testIfLet_nil_doesNotExecuteAction() {
        let value: Int? = nil
        var result = 0
        
        value.ifLet { result = $0 }
        
        XCTAssertEqual(result, 0)
    }
    
    func testIfLetThenElse_nonNil_executesThen() {
        let value: Int? = 42
        var result = ""
        
        value.ifLet(
            then: { _ in result = "then" },
            else: { result = "else" }
        )
        
        XCTAssertEqual(result, "then")
    }
    
    func testIfLetThenElse_nil_executesElse() {
        let value: Int? = nil
        var result = ""
        
        value.ifLet(
            then: { _ in result = "then" },
            else: { result = "else" }
        )
        
        XCTAssertEqual(result, "else")
    }
}

// MARK: - Async Extension Tests

@available(iOS 16.0, *)
final class OptionalAsyncExtensionsTests: XCTestCase {
    
    func testAsyncMap_nonNil_transforms() async {
        let value: Int? = 5
        let result = await value.asyncMap { $0 * 2 }
        
        XCTAssertEqual(result, 10)
    }
    
    func testAsyncMap_nil_returnsNil() async {
        let value: Int? = nil
        let result = await value.asyncMap { $0 * 2 }
        
        XCTAssertNil(result)
    }
}
