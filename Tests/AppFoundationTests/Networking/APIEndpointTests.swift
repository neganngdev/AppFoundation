// APIEndpointTests.swift
// AppFoundationTests

import XCTest
@testable import AppFoundation

final class APIEndpointTests: XCTestCase {
    
    struct TestEndpoint: APIEndpoint {
        var baseURL: String { "https://api.example.com" }
        var path: String { "/users/123" }
        var method: HTTPMethod { .get }
    }
    
    struct TestEndpointWithQuery: APIEndpoint {
        var baseURL: String { "https://api.example.com" }
        var path: String { "/search" }
        var method: HTTPMethod { .get }
        var queryParameters: [String: String]? {
            ["q": "test", "limit": "10"]
        }
    }
    
    struct TestEndpointWithHeaders: APIEndpoint {
        var baseURL: String { "https://api.example.com" }
        var path: String { "/data" }
        var method: HTTPMethod { .post }
        var headers: [String: String]? {
            ["X-Custom-Header": "value"]
        }
        var body: Data? {
            "test body".data(using: .utf8)
        }
    }
    
    func testBuildURL() throws {
        let endpoint = TestEndpoint()
        let url = try endpoint.buildURL()
        
        XCTAssertEqual(url.absoluteString, "https://api.example.com/users/123")
    }
    
    func testBuildURLWithQueryParameters() throws {
        let endpoint = TestEndpointWithQuery()
        let url = try endpoint.buildURL()
        
        XCTAssertTrue(url.absoluteString.contains("q=test"))
        XCTAssertTrue(url.absoluteString.contains("limit=10"))
    }
    
    func testBuildURLRequest() throws {
        let endpoint = TestEndpoint()
        let request = try endpoint.buildURLRequest()
        
        XCTAssertEqual(request.url?.absoluteString, "https://api.example.com/users/123")
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.timeoutInterval, 30.0)
    }
    
    func testBuildURLRequestWithHeaders() throws {
        let endpoint = TestEndpointWithHeaders()
        let request = try endpoint.buildURLRequest()
        
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Custom-Header"), "value")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertNotNil(request.httpBody)
    }
    
    func testDefaultValues() {
        struct MinimalEndpoint: APIEndpoint {
            var path: String { "/test" }
            var method: HTTPMethod { .get }
        }
        
        let endpoint = MinimalEndpoint()
        
        XCTAssertEqual(endpoint.baseURL, "")
        XCTAssertNil(endpoint.headers)
        XCTAssertNil(endpoint.queryParameters)
        XCTAssertNil(endpoint.body)
        XCTAssertEqual(endpoint.timeout, 30.0)
    }
}
