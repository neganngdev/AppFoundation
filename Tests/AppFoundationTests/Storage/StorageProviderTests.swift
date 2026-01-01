// StorageProviderTests.swift
// AppFoundationTests

import XCTest
@testable import AppFoundation

final class StorageProviderTests: XCTestCase {
    
    // MARK: - InMemoryStorage Tests
    
    func testInMemoryStorageSaveAndGet() throws {
        let storage = InMemoryStorage()
        
        try storage.save("test_value", forKey: "test_key")
        let value: String? = try storage.get(forKey: "test_key")
        
        XCTAssertEqual(value, "test_value")
    }
    
    func testInMemoryStorageDelete() throws {
        let storage = InMemoryStorage()
        
        try storage.save("test_value", forKey: "test_key")
        XCTAssertTrue(storage.exists(forKey: "test_key"))
        
        try storage.delete(forKey: "test_key")
        XCTAssertFalse(storage.exists(forKey: "test_key"))
    }
    
    func testInMemoryStorageDeleteAll() throws {
        let storage = InMemoryStorage()
        
        try storage.save("value1", forKey: "key1")
        try storage.save("value2", forKey: "key2")
        
        try storage.deleteAll()
        
        XCTAssertFalse(storage.exists(forKey: "key1"))
        XCTAssertFalse(storage.exists(forKey: "key2"))
    }
    
    func testInMemoryStorageCodable() throws {
        struct TestData: Codable, Equatable {
            let name: String
            let value: Int
        }
        
        let storage = InMemoryStorage()
        let testData = TestData(name: "Test", value: 42)
        
        try storage.save(testData, forKey: "test_data")
        let retrieved: TestData? = try storage.get(forKey: "test_data")
        
        XCTAssertEqual(retrieved, testData)
    }
    
    func testInMemoryStorageThreadSafety() throws {
        let storage = InMemoryStorage()
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
    
    // MARK: - Type-Safe Keys Tests
    
    enum TestKeys: String, StorageKey {
        case username
        case email
        case age
        
        var key: String { rawValue }
    }
    
    func testTypeSafeKeys() throws {
        let storage = InMemoryStorage()
        
        try storage.save("john_doe", forKey: TestKeys.username)
        try storage.save("john@example.com", forKey: TestKeys.email)
        try storage.save(30, forKey: TestKeys.age)
        
        let username: String? = try storage.get(forKey: TestKeys.username)
        let email: String? = try storage.get(forKey: TestKeys.email)
        let age: Int? = try storage.get(forKey: TestKeys.age)
        
        XCTAssertEqual(username, "john_doe")
        XCTAssertEqual(email, "john@example.com")
        XCTAssertEqual(age, 30)
    }
    
    func testTypeSafeKeysDelete() throws {
        let storage = InMemoryStorage()
        
        try storage.save("test", forKey: TestKeys.username)
        XCTAssertTrue(storage.exists(forKey: TestKeys.username))
        
        try storage.delete(forKey: TestKeys.username)
        XCTAssertFalse(storage.exists(forKey: TestKeys.username))
    }
    
    // MARK: - Protocol Conformance Tests
    
    func testStorageProviderConformance() {
        // Test that both implementations conform to StorageProvider
        let _: any StorageProvider = InMemoryStorage()
        let _: any StorageProvider = UserDefaultsStorage()
    }
    
    func testDependencyInjection() throws {
        // Demonstrate dependency injection pattern
        func saveUser(to storage: any StorageProvider) throws {
            try storage.save("John Doe", forKey: "user")
        }
        
        let memoryStorage = InMemoryStorage()
        try saveUser(to: memoryStorage)
        
        let value: String? = try memoryStorage.get(forKey: "user")
        XCTAssertEqual(value, "John Doe")
    }
}
