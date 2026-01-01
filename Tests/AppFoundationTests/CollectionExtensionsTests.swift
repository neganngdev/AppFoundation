// CollectionExtensionsTests.swift
// AppFoundationTests

import XCTest
@testable import AppFoundation

final class CollectionExtensionsTests: XCTestCase {
    
    // MARK: - Safe Subscript Tests
    
    func testSafeSubscript_validIndex_returnsElement() {
        let array = [1, 2, 3, 4, 5]
        XCTAssertEqual(array[safe: 0], 1)
        XCTAssertEqual(array[safe: 2], 3)
        XCTAssertEqual(array[safe: 4], 5)
    }
    
    func testSafeSubscript_outOfBoundsPositive_returnsNil() {
        let array = [1, 2, 3]
        XCTAssertNil(array[safe: 3])
        XCTAssertNil(array[safe: 10])
    }
    
    func testSafeSubscript_emptyArray_returnsNil() {
        let array: [Int] = []
        XCTAssertNil(array[safe: 0])
    }
    
    func testSafeSubscript_string_validIndex() {
        let string = "Hello"
        let index = string.index(string.startIndex, offsetBy: 1)
        XCTAssertEqual(string[safe: index], "e")
    }
    
    // MARK: - isNotEmpty Tests
    
    func testIsNotEmpty_nonEmpty_returnsTrue() {
        XCTAssertTrue([1, 2, 3].isNotEmpty)
        XCTAssertTrue("Hello".isNotEmpty)
    }
    
    func testIsNotEmpty_empty_returnsFalse() {
        XCTAssertFalse([Int]().isNotEmpty)
        XCTAssertFalse("".isNotEmpty)
    }
    
    // MARK: - Chunked Tests
    
    func testChunked_evenDivision_correctChunks() {
        let array = [1, 2, 3, 4, 5, 6]
        let result = array.chunked(into: 2)
        
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0], [1, 2])
        XCTAssertEqual(result[1], [3, 4])
        XCTAssertEqual(result[2], [5, 6])
    }
    
    func testChunked_unevenDivision_lastChunkSmaller() {
        let array = [1, 2, 3, 4, 5]
        let result = array.chunked(into: 2)
        
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0], [1, 2])
        XCTAssertEqual(result[1], [3, 4])
        XCTAssertEqual(result[2], [5])
    }
    
    func testChunked_sizeGreaterThanArray_singleChunk() {
        let array = [1, 2, 3]
        let result = array.chunked(into: 10)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0], [1, 2, 3])
    }
    
    func testChunked_emptyArray_emptyResult() {
        let array: [Int] = []
        let result = array.chunked(into: 2)
        
        XCTAssertTrue(result.isEmpty)
    }
    
    func testChunked_sizeOfOne_individualElements() {
        let array = [1, 2, 3]
        let result = array.chunked(into: 1)
        
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0], [1])
        XCTAssertEqual(result[1], [2])
        XCTAssertEqual(result[2], [3])
    }
    
    func testChunked_zeroSize_emptyResult() {
        let array = [1, 2, 3]
        let result = array.chunked(into: 0)
        
        XCTAssertTrue(result.isEmpty)
    }
    
    // MARK: - RemoveDuplicates Tests (Hashable)
    
    func testRemovingDuplicates_withDuplicates_preservesOrder() {
        let array = [1, 2, 2, 3, 1, 4, 3, 5]
        let result = array.removingDuplicates()
        
        XCTAssertEqual(result, [1, 2, 3, 4, 5])
    }
    
    func testRemovingDuplicates_noDuplicates_unchanged() {
        let array = [1, 2, 3, 4, 5]
        let result = array.removingDuplicates()
        
        XCTAssertEqual(result, [1, 2, 3, 4, 5])
    }
    
    func testRemovingDuplicates_allSame_singleElement() {
        let array = [1, 1, 1, 1]
        let result = array.removingDuplicates()
        
        XCTAssertEqual(result, [1])
    }
    
    func testRemovingDuplicates_emptyArray_emptyResult() {
        let array: [Int] = []
        let result = array.removingDuplicates()
        
        XCTAssertTrue(result.isEmpty)
    }
    
    func testRemovingDuplicates_strings() {
        let array = ["a", "b", "a", "c", "b"]
        let result = array.removingDuplicates()
        
        XCTAssertEqual(result, ["a", "b", "c"])
    }
    
    func testRemoveDuplicates_mutatingVersion() {
        var array = [1, 2, 2, 3, 1]
        array.removeDuplicates()
        
        XCTAssertEqual(array, [1, 2, 3])
    }
    
    // MARK: - RemoveDuplicates Tests (Equatable)
    
    func testRemovingDuplicatesEquatable_customType() {
        struct Person: Equatable {
            let name: String
        }
        
        let people = [
            Person(name: "Alice"),
            Person(name: "Bob"),
            Person(name: "Alice"),
            Person(name: "Charlie")
        ]
        
        let result = people.removingDuplicatesEquatable()
        
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].name, "Alice")
        XCTAssertEqual(result[1].name, "Bob")
        XCTAssertEqual(result[2].name, "Charlie")
    }
    
    // MARK: - Dictionary Extension Tests
    
    func testDictionaryMerging_noConflicts_combined() {
        let dict1 = ["a": 1, "b": 2]
        let dict2 = ["c": 3, "d": 4]
        
        let result = dict1.merging(dict2)
        
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result["a"], 1)
        XCTAssertEqual(result["c"], 3)
    }
    
    func testDictionaryMerging_withConflicts_usesNewValue() {
        let dict1 = ["a": 1, "b": 2]
        let dict2 = ["b": 10, "c": 3]
        
        let result = dict1.merging(dict2)
        
        XCTAssertEqual(result["b"], 10)
    }
    
    func testDictionaryMerging_customCombiner() {
        let dict1 = ["a": 1, "b": 2]
        let dict2 = ["b": 10, "c": 3]
        
        let result = dict1.merging(dict2) { old, new in old + new }
        
        XCTAssertEqual(result["b"], 12)
    }
    
    func testGetOrSet_existingKey_returnsExisting() {
        var dict = ["a": 1]
        let value = dict.getOrSet("a", default: 100)
        
        XCTAssertEqual(value, 1)
        XCTAssertEqual(dict["a"], 1)
    }
    
    func testGetOrSet_newKey_setsAndReturnsDefault() {
        var dict = ["a": 1]
        let value = dict.getOrSet("b", default: 100)
        
        XCTAssertEqual(value, 100)
        XCTAssertEqual(dict["b"], 100)
    }
}

// MARK: - Async Extension Tests

@available(iOS 16.0, *)
final class CollectionAsyncExtensionsTests: XCTestCase {
    
    func testAsyncMap_transformsElements() async {
        let array = [1, 2, 3]
        let result = await array.asyncMap { $0 * 2 }
        
        XCTAssertEqual(result, [2, 4, 6])
    }
    
    func testAsyncCompactMap_filtersNil() async {
        let array = [1, 2, 3, 4, 5]
        let result = await array.asyncCompactMap { $0 % 2 == 0 ? $0 : nil }
        
        XCTAssertEqual(result, [2, 4])
    }
    
    func testAsyncFilter_filtersElements() async {
        let array = [1, 2, 3, 4, 5]
        let result = await array.asyncFilter { $0 > 3 }
        
        XCTAssertEqual(result, [4, 5])
    }
    
    func testAsyncForEach_iteratesAllElements() async {
        let array = [1, 2, 3]
        var sum = 0
        
        await array.asyncForEach { sum += $0 }
        
        XCTAssertEqual(sum, 6)
    }
}
