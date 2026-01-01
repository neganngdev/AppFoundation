// UserDefaultsStorageTests.swift
// AppFoundationTests

import XCTest
@testable import AppFoundation

final class UserDefaultsStorageTests: XCTestCase {
    
    private var storage: UserDefaultsStorage!
    private let suiteName = "com.appfoundation.storage.tests"
    
    override func setUp() {
        super.setUp()
        storage = UserDefaultsStorage(suiteName: suiteName)
        try? storage.deleteAll()
    }
    
    override func tearDown() {
        try? storage.deleteAll()
        storage = nil
        super.tearDown()
    }
    
    // MARK: - Primitive Types Tests
    
    func testSaveAndGetString() throws {
        try storage.save("Hello", forKey: "test_string")
        let value: String? = try storage.get(forKey: "test_string")
        
        XCTAssertEqual(value, "Hello")
    }
    
    func testSaveAndGetInt() throws {
        try storage.save(42, forKey: "test_int")
        let value: Int? = try storage.get(forKey: "test_int")
        
        XCTAssertEqual(value, 42)
    }
    
    func testSaveAndGetDouble() throws {
        try storage.save(3.14, forKey: "test_double")
        let value: Double? = try storage.get(forKey: "test_double")
        
        XCTAssertNotNil(value)
        XCTAssertEqual(value!, 3.14, accuracy: 0.001)
    }
    
    func testSaveAndGetBool() throws {
        try storage.save(true, forKey: "test_bool")
        let value: Bool? = try storage.get(forKey: "test_bool")
        
        XCTAssertEqual(value, true)
    }
    
    func testSaveAndGetData() throws {
        let data = "Test".data(using: .utf8)!
        try storage.save(data, forKey: "test_data")
        let value: Data? = try storage.get(forKey: "test_data")
        
        XCTAssertEqual(value, data)
    }
    
    // MARK: - Codable Tests
    
    struct TestUser: Codable, Equatable {
        let name: String
        let age: Int
    }
    
    func testSaveAndGetCodable() throws {
        let user = TestUser(name: "John", age: 30)
        try storage.save(user, forKey: "test_user")
        let value: TestUser? = try storage.get(forKey: "test_user")
        
        XCTAssertEqual(value, user)
    }
    
    func testSaveAndGetCodableArray() throws {
        let users = [
            TestUser(name: "John", age: 30),
            TestUser(name: "Jane", age: 25)
        ]
        try storage.save(users, forKey: "test_users")
        let value: [TestUser]? = try storage.get(forKey: "test_users")
        
        XCTAssertEqual(value, users)
    }
    
    // MARK: - Delete Tests
    
    func testDelete() throws {
        try storage.save("Test", forKey: "test_key")
        XCTAssertTrue(storage.exists(forKey: "test_key"))
        
        try storage.delete(forKey: "test_key")
        XCTAssertFalse(storage.exists(forKey: "test_key"))
    }
    
    func testDeleteAll() throws {
        try storage.save("Value1", forKey: "key1")
        try storage.save("Value2", forKey: "key2")
        try storage.save("Value3", forKey: "key3")
        
        try storage.deleteAll()
        
        XCTAssertFalse(storage.exists(forKey: "key1"))
        XCTAssertFalse(storage.exists(forKey: "key2"))
        XCTAssertFalse(storage.exists(forKey: "key3"))
    }
    
    // MARK: - Exists Tests
    
    func testExists() throws {
        XCTAssertFalse(storage.exists(forKey: "nonexistent"))
        
        try storage.save("Test", forKey: "test_key")
        XCTAssertTrue(storage.exists(forKey: "test_key"))
    }
    
    // MARK: - Batch Operations Tests
    
    func testSaveBatch() throws {
        let items = [
            "key1": "value1",
            "key2": "value2",
            "key3": "value3"
        ]
        
        try storage.saveBatch(items)
        
        let value1: String? = try storage.get(forKey: "key1")
        let value2: String? = try storage.get(forKey: "key2")
        let value3: String? = try storage.get(forKey: "key3")
        
        XCTAssertEqual(value1, "value1")
        XCTAssertEqual(value2, "value2")
        XCTAssertEqual(value3, "value3")
    }
    
    func testDeleteBatch() throws {
        try storage.save("value1", forKey: "key1")
        try storage.save("value2", forKey: "key2")
        try storage.save("value3", forKey: "key3")
        
        storage.deleteBatch(forKeys: ["key1", "key2"])
        
        XCTAssertFalse(storage.exists(forKey: "key1"))
        XCTAssertFalse(storage.exists(forKey: "key2"))
        XCTAssertTrue(storage.exists(forKey: "key3"))
    }
    
    // MARK: - Thread Safety Tests
    
    func testConcurrentAccess() throws {
        let expectation = self.expectation(description: "Concurrent operations")
        expectation.expectedFulfillmentCount = 100
        
        DispatchQueue.concurrentPerform(iterations: 100) { index in
            do {
                try storage.save("Value\(index)", forKey: "key\(index)")
                let _: String? = try storage.get(forKey: "key\(index)")
                expectation.fulfill()
            } catch {
                XCTFail("Concurrent operation failed: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Get Non-Existent Key
    
    func testGetNonExistentKey() throws {
        let value: String? = try storage.get(forKey: "nonexistent")
        XCTAssertNil(value)
    }
}
