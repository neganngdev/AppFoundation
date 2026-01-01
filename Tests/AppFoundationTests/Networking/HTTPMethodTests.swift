// HTTPMethodTests.swift
// AppFoundationTests

import XCTest
@testable import AppFoundation

final class HTTPMethodTests: XCTestCase {
    
    func testRawValues() {
        XCTAssertEqual(HTTPMethod.get.rawValue, "GET")
        XCTAssertEqual(HTTPMethod.post.rawValue, "POST")
        XCTAssertEqual(HTTPMethod.put.rawValue, "PUT")
        XCTAssertEqual(HTTPMethod.delete.rawValue, "DELETE")
        XCTAssertEqual(HTTPMethod.patch.rawValue, "PATCH")
        XCTAssertEqual(HTTPMethod.head.rawValue, "HEAD")
        XCTAssertEqual(HTTPMethod.options.rawValue, "OPTIONS")
    }
    
    func testSupportsBody() {
        XCTAssertTrue(HTTPMethod.post.supportsBody)
        XCTAssertTrue(HTTPMethod.put.supportsBody)
        XCTAssertTrue(HTTPMethod.patch.supportsBody)
        
        XCTAssertFalse(HTTPMethod.get.supportsBody)
        XCTAssertFalse(HTTPMethod.delete.supportsBody)
        XCTAssertFalse(HTTPMethod.head.supportsBody)
        XCTAssertFalse(HTTPMethod.options.supportsBody)
    }
    
    func testIsIdempotent() {
        XCTAssertTrue(HTTPMethod.get.isIdempotent)
        XCTAssertTrue(HTTPMethod.put.isIdempotent)
        XCTAssertTrue(HTTPMethod.delete.isIdempotent)
        XCTAssertTrue(HTTPMethod.head.isIdempotent)
        XCTAssertTrue(HTTPMethod.options.isIdempotent)
        
        XCTAssertFalse(HTTPMethod.post.isIdempotent)
        XCTAssertFalse(HTTPMethod.patch.isIdempotent)
    }
    
    func testAllCases() {
        let allCases = HTTPMethod.allCases
        XCTAssertEqual(allCases.count, 7)
        XCTAssertTrue(allCases.contains(.get))
        XCTAssertTrue(allCases.contains(.post))
        XCTAssertTrue(allCases.contains(.put))
        XCTAssertTrue(allCases.contains(.delete))
        XCTAssertTrue(allCases.contains(.patch))
        XCTAssertTrue(allCases.contains(.head))
        XCTAssertTrue(allCases.contains(.options))
    }
}
