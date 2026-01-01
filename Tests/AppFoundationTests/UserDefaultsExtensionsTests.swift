// UserDefaultsExtensionsTests.swift
// AppFoundationTests

import XCTest
@testable import AppFoundation

final class UserDefaultsExtensionsTests: XCTestCase {
    
    // MARK: - Test Properties
    
    private var defaults: UserDefaults!
    private let suiteName = "com.appfoundation.tests"
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }
    
    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        super.tearDown()
    }
    
    // MARK: - Typed Getter/Setter Tests
    
    func testSetAndGet_string() {
        defaults.set(value: "Hello", forKey: "testString")
        let result: String? = defaults.get(forKey: "testString")
        
        XCTAssertEqual(result, "Hello")
    }
    
    func testSetAndGet_integer() {
        defaults.set(value: 42, forKey: "testInt")
        let result: Int = defaults.get(forKey: "testInt", default: 0)
        
        XCTAssertEqual(result, 42)
    }
    
    func testSetAndGet_double() {
        defaults.set(value: 3.14, forKey: "testDouble")
        let result: Double = defaults.get(forKey: "testDouble", default: 0.0)
        
        XCTAssertEqual(result, 3.14, accuracy: 0.001)
    }
    
    func testSetAndGet_bool() {
        defaults.set(value: true, forKey: "testBool")
        let result: Bool = defaults.get(forKey: "testBool", default: false)
        
        XCTAssertTrue(result)
    }
    
    func testGet_nonExistent_returnsDefault() {
        let result: String = defaults.get(forKey: "nonexistent", default: "default")
        
        XCTAssertEqual(result, "default")
    }
    
    func testGet_nonExistent_returnsNil() {
        let result: String? = defaults.get(forKey: "nonexistent")
        
        XCTAssertNil(result)
    }
    
    // MARK: - Codable Tests
    
    struct TestUser: Codable, Equatable {
        let name: String
        let age: Int
    }
    
    func testSetCodable_andGet_success() throws {
        let user = TestUser(name: "John", age: 30)
        
        try defaults.setCodable(user, forKey: "testUser")
        let result = defaults.getCodable(TestUser.self, forKey: "testUser")
        
        XCTAssertEqual(result, user)
    }
    
    func testGetCodable_nonExistent_returnsNil() {
        let result = defaults.getCodable(TestUser.self, forKey: "nonexistent")
        
        XCTAssertNil(result)
    }
    
    func testGetCodable_withDefault_returnsDefault() {
        let defaultUser = TestUser(name: "Default", age: 0)
        let result = defaults.getCodable(
            TestUser.self,
            forKey: "nonexistent",
            default: defaultUser
        )
        
        XCTAssertEqual(result, defaultUser)
    }
    
    func testSetCodableSafe_success_returnsTrue() {
        let user = TestUser(name: "John", age: 30)
        
        let success = defaults.setCodableSafe(user, forKey: "testUser")
        
        XCTAssertTrue(success)
    }
    
    func testCodable_array() throws {
        let users = [
            TestUser(name: "John", age: 30),
            TestUser(name: "Jane", age: 25)
        ]
        
        try defaults.setCodable(users, forKey: "testUsers")
        let result = defaults.getCodable([TestUser].self, forKey: "testUsers")
        
        XCTAssertEqual(result, users)
    }
    
    // MARK: - Subscript Tests
    
    func testSubscript_string() {
        defaults[string: "testKey"] = "Hello"
        
        XCTAssertEqual(defaults[string: "testKey"], "Hello")
    }
    
    func testSubscript_int() {
        defaults[int: "testKey"] = 42
        
        XCTAssertEqual(defaults[int: "testKey"], 42)
    }
    
    func testSubscript_double() {
        defaults[double: "testKey"] = 3.14
        
        XCTAssertEqual(defaults[double: "testKey"], 3.14, accuracy: 0.001)
    }
    
    func testSubscript_bool() {
        defaults[bool: "testKey"] = true
        
        XCTAssertTrue(defaults[bool: "testKey"])
    }
    
    func testSubscript_date() {
        let date = Date()
        defaults[date: "testKey"] = date
        
        if let storedDate = defaults[date: "testKey"] {
            XCTAssertEqual(storedDate.timeIntervalSince1970,
                          date.timeIntervalSince1970,
                          accuracy: 0.001)
        } else {
            XCTFail("Date should not be nil")
        }
    }
    
    func testSubscript_url() {
        let url = URL(string: "https://example.com")!
        defaults[url: "testKey"] = url
        
        XCTAssertEqual(defaults[url: "testKey"], url)
    }
    
    func testSubscript_data() {
        let data = "Hello".data(using: .utf8)!
        defaults[data: "testKey"] = data
        
        XCTAssertEqual(defaults[data: "testKey"], data)
    }
    
    // MARK: - HasValue Tests
    
    func testHasValue_exists_returnsTrue() {
        defaults.set(value: "test", forKey: "testKey")
        
        XCTAssertTrue(defaults.hasValue(forKey: "testKey"))
    }
    
    func testHasValue_notExists_returnsFalse() {
        XCTAssertFalse(defaults.hasValue(forKey: "nonexistent"))
    }
    
    // MARK: - Batch Operations Tests
    
    func testRemoveValues_removesMultiple() {
        defaults.set(value: "a", forKey: "key1")
        defaults.set(value: "b", forKey: "key2")
        defaults.set(value: "c", forKey: "key3")
        
        defaults.removeValues(forKeys: ["key1", "key2"])
        
        XCTAssertFalse(defaults.hasValue(forKey: "key1"))
        XCTAssertFalse(defaults.hasValue(forKey: "key2"))
        XCTAssertTrue(defaults.hasValue(forKey: "key3"))
    }
    
    func testSetValues_setsMultiple() {
        defaults.setValues([
            "key1": "value1",
            "key2": 42,
            "key3": true
        ])
        
        XCTAssertEqual(defaults[string: "key1"], "value1")
        XCTAssertEqual(defaults[int: "key2"], 42)
        XCTAssertTrue(defaults[bool: "key3"])
    }
    
    // MARK: - Type-Safe Key Tests
    
    func testTypeSafeKey_setAndGet() {
        let key = UserDefaultsKey<String>("typeSafeKey")
        
        defaults[key] = "Hello"
        
        XCTAssertEqual(defaults[key], "Hello")
    }
    
    func testTypeSafeKey_withDefault() {
        let key = UserDefaultsKey<String>("nonexistentKey")
        
        let result = defaults[key, default: "default"]
        
        XCTAssertEqual(result, "default")
    }
}
