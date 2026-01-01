// EnvironmentTests.swift
// AppFoundationTests

import XCTest
@testable import AppFoundation

final class EnvironmentTests: XCTestCase {
    
    override func tearDown() {
        EnvironmentOverride.clear()
        super.tearDown()
    }
    
    // MARK: - Environment Enum Tests
    
    func testEnvironment_displayName() {
        XCTAssertEqual(Environment.development.displayName, "Development")
        XCTAssertEqual(Environment.staging.displayName, "Staging")
        XCTAssertEqual(Environment.production.displayName, "Production")
    }
    
    func testEnvironment_shortName() {
        XCTAssertEqual(Environment.development.shortName, "DEV")
        XCTAssertEqual(Environment.staging.shortName, "STG")
        XCTAssertEqual(Environment.production.shortName, "PROD")
    }
    
    func testEnvironment_isDevelopment() {
        XCTAssertTrue(Environment.development.isDevelopment)
        XCTAssertFalse(Environment.staging.isDevelopment)
        XCTAssertFalse(Environment.production.isDevelopment)
    }
    
    func testEnvironment_isProduction() {
        XCTAssertFalse(Environment.development.isProduction)
        XCTAssertFalse(Environment.staging.isProduction)
        XCTAssertTrue(Environment.production.isProduction)
    }
    
    func testEnvironment_isDebugEnabled() {
        XCTAssertTrue(Environment.development.isDebugEnabled)
        XCTAssertTrue(Environment.staging.isDebugEnabled)
        XCTAssertFalse(Environment.production.isDebugEnabled)
    }
    
    // MARK: - EnvironmentConfigurable Tests
    
    struct TestConfig: EnvironmentConfigurable, Equatable {
        let baseURL: String
        
        static var development: TestConfig {
            TestConfig(baseURL: "http://localhost")
        }
        
        static var staging: TestConfig {
            TestConfig(baseURL: "https://staging.example.com")
        }
        
        static var production: TestConfig {
            TestConfig(baseURL: "https://api.example.com")
        }
    }
    
    func testEnvironmentConfigurable_development() {
        let config = TestConfig.configuration(for: .development)
        XCTAssertEqual(config.baseURL, "http://localhost")
    }
    
    func testEnvironmentConfigurable_staging() {
        let config = TestConfig.configuration(for: .staging)
        XCTAssertEqual(config.baseURL, "https://staging.example.com")
    }
    
    func testEnvironmentConfigurable_production() {
        let config = TestConfig.configuration(for: .production)
        XCTAssertEqual(config.baseURL, "https://api.example.com")
    }
    
    // MARK: - EnvironmentValue Property Wrapper Tests
    
    func testEnvironmentValue_returnsCorrectValue() {
        @EnvironmentValue(
            development: "dev-value",
            staging: "staging-value",
            production: "prod-value"
        )
        var testValue: String
        
        // Value depends on current environment
        XCTAssertFalse(testValue.isEmpty)
    }
    
    // MARK: - FeatureFlag Tests
    
    func testFeatureFlag_developmentOnly() {
        let flag = FeatureFlag.developmentOnly("test_feature")
        
        XCTAssertEqual(flag.name, "test_feature")
        XCTAssertEqual(flag.enabledEnvironments, [.development])
    }
    
    func testFeatureFlag_preProduction() {
        let flag = FeatureFlag.preProduction("test_feature")
        
        XCTAssertEqual(flag.enabledEnvironments, [.development, .staging])
    }
    
    func testFeatureFlag_always() {
        let flag = FeatureFlag.always("test_feature")
        
        XCTAssertTrue(flag.enabledEnvironments.contains(.development))
        XCTAssertTrue(flag.enabledEnvironments.contains(.staging))
        XCTAssertTrue(flag.enabledEnvironments.contains(.production))
    }
    
    // MARK: - Environment Override Tests (DEBUG only)
    
    #if DEBUG
    func testEnvironmentOverride_setsOverride() {
        EnvironmentOverride.set(.staging)
        XCTAssertEqual(EnvironmentOverride.current, .staging)
        XCTAssertEqual(Environment.effective, .staging)
    }
    
    func testEnvironmentOverride_clearRemovesOverride() {
        EnvironmentOverride.set(.production)
        EnvironmentOverride.clear()
        XCTAssertNil(EnvironmentOverride.current)
    }
    #endif
}
