// KeychainStorageTests.swift
// AppFoundationTests

import XCTest
@testable import AppFoundation

final class KeychainStorageTests: XCTestCase {
    
    private var keychain: KeychainStorage!
    private let testService = "com.appfoundation.keychain.tests"
    
    override func setUp() async throws {
        try await super.setUp()
        let config = KeychainConfiguration(service: testService)
        keychain = KeychainStorage(configuration: config)
        try await keychain.deleteAllData()
    }
    
    override func tearDown() async throws {
        try await keychain.deleteAllData()
        keychain = nil
        try await super.tearDown()
    }
    
    // MARK: - String Tests
    
    func testSaveAndGetString() async throws {
        try await keychain.save("secret_token", forKey: "auth_token")
        let value = try await keychain.getString(forKey: "auth_token")
        
        XCTAssertEqual(value, "secret_token")
    }
    
    func testUpdateString() async throws {
        try await keychain.save("old_value", forKey: "test_key")
        try await keychain.save("new_value", forKey: "test_key")
        
        let value = try await keychain.getString(forKey: "test_key")
        XCTAssertEqual(value, "new_value")
    }
    
    // MARK: - Data Tests
    
    func testSaveAndGetData() async throws {
        let data = "Test Data".data(using: .utf8)!
        try await keychain.saveData(data, forKey: "test_data")
        let retrieved = try await keychain.getData(forKey: "test_data")
        
        XCTAssertEqual(retrieved, data)
    }
    
    // MARK: - Codable Tests
    
    struct TestUser: Codable, Equatable {
        let name: String
        let email: String
        let age: Int
    }
    
    func testSaveAndGetCodable() async throws {
        let user = TestUser(name: "John Doe", email: "john@example.com", age: 30)
        try await keychain.save(user, forKey: "current_user")
        let retrieved: TestUser? = try await keychain.get(forKey: "current_user")
        
        XCTAssertEqual(retrieved, user)
    }
    
    func testSaveAndGetCodableArray() async throws {
        let users = [
            TestUser(name: "John", email: "john@example.com", age: 30),
            TestUser(name: "Jane", email: "jane@example.com", age: 25)
        ]
        
        try await keychain.save(users, forKey: "users_list")
        let retrieved: [TestUser]? = try await keychain.get(forKey: "users_list")
        
        XCTAssertEqual(retrieved, users)
    }
    
    // MARK: - Delete Tests
    
    func testDelete() async throws {
        try await keychain.save("test_value", forKey: "test_key")
        let existsBefore = await keychain.exists(forKey: "test_key")
        XCTAssertTrue(existsBefore)
        
        try await keychain.deleteData(forKey: "test_key")
        let existsAfter = await keychain.exists(forKey: "test_key")
        XCTAssertFalse(existsAfter)
    }
    
    func testDeleteNonExistentKey() async throws {
        // Should not throw error
        try await keychain.deleteData(forKey: "nonexistent_key")
    }
    
    func testDeleteAll() async throws {
        try await keychain.save("value1", forKey: "key1")
        try await keychain.save("value2", forKey: "key2")
        try await keychain.save("value3", forKey: "key3")
        
        try await keychain.deleteAllData()
        
        let exists1 = await keychain.exists(forKey: "key1")
        let exists2 = await keychain.exists(forKey: "key2")
        let exists3 = await keychain.exists(forKey: "key3")
        
        XCTAssertFalse(exists1)
        XCTAssertFalse(exists2)
        XCTAssertFalse(exists3)
    }
    
    // MARK: - Exists Tests
    
    func testExists() async throws {
        let existsBefore = await keychain.exists(forKey: "nonexistent")
        XCTAssertFalse(existsBefore)
        
        try await keychain.save("test", forKey: "test_key")
        let existsAfter = await keychain.exists(forKey: "test_key")
        XCTAssertTrue(existsAfter)
    }
    
    // MARK: - Error Handling Tests
    
    func testGetNonExistentKey() async throws {
        let value = try await keychain.getString(forKey: "nonexistent")
        XCTAssertNil(value)
    }
    
    // MARK: - Batch Operations Tests
    
    func testSaveBatch() async throws {
        let items = [
            "key1": "value1".data(using: .utf8)!,
            "key2": "value2".data(using: .utf8)!,
            "key3": "value3".data(using: .utf8)!
        ]
        
        try await keychain.saveBatch(items)
        
        let value1 = try await keychain.getString(forKey: "key1")
        let value2 = try await keychain.getString(forKey: "key2")
        let value3 = try await keychain.getString(forKey: "key3")
        
        XCTAssertEqual(value1, "value1")
        XCTAssertEqual(value2, "value2")
        XCTAssertEqual(value3, "value3")
    }
    
    func testGetBatch() async throws {
        try await keychain.save("value1", forKey: "key1")
        try await keychain.save("value2", forKey: "key2")
        try await keychain.save("value3", forKey: "key3")
        
        let results = try await keychain.getBatch(forKeys: ["key1", "key2", "key3"])
        
        XCTAssertEqual(results.count, 3)
        XCTAssertNotNil(results["key1"])
        XCTAssertNotNil(results["key2"])
        XCTAssertNotNil(results["key3"])
    }
    
    func testDeleteBatch() async throws {
        try await keychain.save("value1", forKey: "key1")
        try await keychain.save("value2", forKey: "key2")
        try await keychain.save("value3", forKey: "key3")
        
        try await keychain.deleteBatch(forKeys: ["key1", "key2"])
        
        let exists1 = await keychain.exists(forKey: "key1")
        let exists2 = await keychain.exists(forKey: "key2")
        let exists3 = await keychain.exists(forKey: "key3")
        
        XCTAssertFalse(exists1)
        XCTAssertFalse(exists2)
        XCTAssertTrue(exists3)
    }
    
    // MARK: - Query Operations Tests
    
    func testAllKeys() async throws {
        try await keychain.save("value1", forKey: "key1")
        try await keychain.save("value2", forKey: "key2")
        try await keychain.save("value3", forKey: "key3")
        
        let keys = try await keychain.allKeys()
        
        XCTAssertEqual(keys.count, 3)
        XCTAssertTrue(keys.contains("key1"))
        XCTAssertTrue(keys.contains("key2"))
        XCTAssertTrue(keys.contains("key3"))
    }
    
    func testAllKeysEmpty() async throws {
        let keys = try await keychain.allKeys()
        XCTAssertTrue(keys.isEmpty)
    }
    
    // MARK: - Thread Safety Tests
    
    func testConcurrentAccess() async throws {
        await withTaskGroup(of: Void.self) { group in
            for index in 0..<50 {
                group.addTask {
                    do {
                        try await self.keychain.save("Value\(index)", forKey: "key\(index)")
                        let _: String? = try await self.keychain.getString(forKey: "key\(index)")
                    } catch {
                        XCTFail("Concurrent operation failed: \(error)")
                    }
                }
            }
        }
        
        let keys = try await keychain.allKeys()
        XCTAssertEqual(keys.count, 50)
    }
}
