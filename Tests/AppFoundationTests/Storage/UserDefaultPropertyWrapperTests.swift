// UserDefaultPropertyWrapperTests.swift
// AppFoundationTests

import XCTest
@testable import AppFoundation

final class UserDefaultPropertyWrapperTests: XCTestCase {
    
    private let suiteName = "com.appfoundation.propertywrapper.tests"
    private var userDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
    }
    
    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        super.tearDown()
    }
    
    // MARK: - Basic Types Tests
    
    func testStringPropertyWrapper() {
        @UserDefault(key: "test_string", defaultValue: "default", userDefaults: userDefaults)
        var testString: String
        
        XCTAssertEqual(testString, "default")
        
        testString = "Hello"
        XCTAssertEqual(testString, "Hello")
        
        // Verify persistence
        let stored = userDefaults.string(forKey: "test_string")
        XCTAssertEqual(stored, "Hello")
    }
    
    func testIntPropertyWrapper() {
        @UserDefault(key: "test_int", defaultValue: 0, userDefaults: userDefaults)
        var testInt: Int
        
        XCTAssertEqual(testInt, 0)
        
        testInt = 42
        XCTAssertEqual(testInt, 42)
    }
    
    func testDoublePropertyWrapper() {
        @UserDefault(key: "test_double", defaultValue: 0.0, userDefaults: userDefaults)
        var testDouble: Double
        
        XCTAssertEqual(testDouble, 0.0)
        
        testDouble = 3.14
        XCTAssertEqual(testDouble, 3.14, accuracy: 0.001)
    }
    
    func testBoolPropertyWrapper() {
        @UserDefault(key: "test_bool", defaultValue: false, userDefaults: userDefaults)
        var testBool: Bool
        
        XCTAssertFalse(testBool)
        
        testBool = true
        XCTAssertTrue(testBool)
    }
    
    // MARK: - Codable Tests
    
    struct TestUser: Codable, Equatable {
        let name: String
        let age: Int
    }
    
    func testCodablePropertyWrapper() {
        let defaultUser = TestUser(name: "Guest", age: 0)
        
        @UserDefault(key: "test_user", defaultValue: defaultUser, userDefaults: userDefaults)
        var testUser: TestUser
        
        XCTAssertEqual(testUser, defaultUser)
        
        let newUser = TestUser(name: "John", age: 30)
        testUser = newUser
        XCTAssertEqual(testUser, newUser)
    }
    
    // MARK: - Optional Property Wrapper Tests
    
    func testOptionalStringPropertyWrapper() {
        @OptionalUserDefault(key: "optional_string", userDefaults: userDefaults)
        var optionalString: String?
        
        XCTAssertNil(optionalString)
        
        optionalString = "Hello"
        XCTAssertEqual(optionalString, "Hello")
        
        optionalString = nil
        XCTAssertNil(optionalString)
        XCTAssertNil(userDefaults.string(forKey: "optional_string"))
    }
    
    func testOptionalCodablePropertyWrapper() {
        @OptionalUserDefault(key: "optional_user", userDefaults: userDefaults)
        var optionalUser: TestUser?
        
        XCTAssertNil(optionalUser)
        
        let user = TestUser(name: "John", age: 30)
        optionalUser = user
        XCTAssertEqual(optionalUser, user)
        
        optionalUser = nil
        XCTAssertNil(optionalUser)
    }
    
    // MARK: - Reset Tests
    
    func testReset() {
        @UserDefault(key: "test_reset", defaultValue: "default", userDefaults: userDefaults)
        var testValue: String
        
        testValue = "Changed"
        XCTAssertEqual(testValue, "Changed")
        
        _testValue.reset()
        XCTAssertEqual(testValue, "default")
        XCTAssertFalse(_testValue.hasValue)
    }
    
    func testHasValue() {
        @UserDefault(key: "test_has_value", defaultValue: "default", userDefaults: userDefaults)
        var testValue: String
        
        XCTAssertFalse(_testValue.hasValue)
        
        testValue = "Value"
        XCTAssertTrue(_testValue.hasValue)
    }
    
    // MARK: - Persistence Tests
    
    func testPersistenceAcrossInstances() {
        do {
            @UserDefault(key: "persistence_test", defaultValue: 0, userDefaults: userDefaults)
            var counter: Int
            
            counter = 42
        }
        
        do {
            @UserDefault(key: "persistence_test", defaultValue: 0, userDefaults: userDefaults)
            var counter: Int
            
            XCTAssertEqual(counter, 42)
        }
    }
    
    // MARK: - Static Property Tests
    
    func testStaticProperties() {
        class Settings {
            @UserDefault(key: "static_test", defaultValue: false)
            static var testFlag: Bool
        }
        
        XCTAssertFalse(Settings.testFlag)
        
        Settings.testFlag = true
        XCTAssertTrue(Settings.testFlag)
    }
}
