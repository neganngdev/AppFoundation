// LoggerTests.swift
// AppFoundationTests

import XCTest
@testable import AppFoundation

final class LoggerTests: XCTestCase {
    
    final class MockDestination: LogDestination, @unchecked Sendable {
        var minimumLevel: LogLevel
        private(set) var messages: [LogMessage] = []
        private let lock = NSLock()
        
        init(minimumLevel: LogLevel = .debug) {
            self.minimumLevel = minimumLevel
        }
        
        func write(_ message: LogMessage) {
            lock.lock()
            defer { lock.unlock() }
            messages.append(message)
        }
    }
    
    func testLogLevel_comparison() {
        XCTAssertTrue(LogLevel.debug < LogLevel.info)
        XCTAssertTrue(LogLevel.warning < LogLevel.error)
    }
    
    func testLogger_allLevels_received() {
        let destination = MockDestination()
        let logger = Logger(destinations: [destination])
        
        logger.debug("Debug")
        logger.info("Info")
        logger.warning("Warning")
        logger.error("Error")
        
        XCTAssertEqual(destination.messages.count, 4)
    }
    
    func testLogger_minimumLevel_filters() {
        let destination = MockDestination()
        let logger = Logger(minimumLevel: .warning, destinations: [destination])
        
        logger.debug("Debug")
        logger.info("Info")
        logger.warning("Warning")
        logger.error("Error")
        
        XCTAssertEqual(destination.messages.count, 2)
    }
    
    func testLogger_multipleDestinations() {
        let dest1 = MockDestination()
        let dest2 = MockDestination()
        let logger = Logger(destinations: [dest1, dest2])
        
        logger.info("Test")
        
        XCTAssertEqual(dest1.messages.count, 1)
        XCTAssertEqual(dest2.messages.count, 1)
    }
    
    func testLogMessage_metadata() {
        let destination = MockDestination()
        let logger = Logger(destinations: [destination])
        
        logger.info("Test")
        
        let msg = destination.messages.first!
        XCTAssertEqual(msg.message, "Test")
        XCTAssertTrue(msg.fileName.hasSuffix(".swift"))
        XCTAssertGreaterThan(msg.line, 0)
    }
}
