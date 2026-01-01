// NetworkErrorTests.swift
// AppFoundationTests

import XCTest
@testable import AppFoundation

final class NetworkErrorTests: XCTestCase {
    
    func testErrorDescriptions() {
        XCTAssertEqual(NetworkError.noInternet.errorDescription, "No internet connection")
        XCTAssertEqual(NetworkError.timeout.errorDescription, "Request timed out")
        XCTAssertEqual(NetworkError.invalidURL("test").errorDescription, "Invalid URL: test")
        XCTAssertEqual(NetworkError.invalidResponse.errorDescription, "Invalid server response")
        XCTAssertEqual(NetworkError.cancelled.errorDescription, "Request was cancelled")
    }
    
    func testStatusCodeError() {
        let error = NetworkError.statusCode(404, nil)
        XCTAssertEqual(error.errorDescription, "HTTP error 404: Not Found")
        XCTAssertEqual(error.statusCode, 404)
        XCTAssertNil(error.responseData)
    }
    
    func testStatusCodeWithData() {
        let data = "Error data".data(using: .utf8)
        let error = NetworkError.statusCode(500, data)
        XCTAssertEqual(error.statusCode, 500)
        XCTAssertEqual(error.responseData, data)
    }
    
    func testDecodingError() {
        let error = NetworkError.decodingError("Invalid JSON")
        XCTAssertEqual(error.errorDescription, "Failed to decode response: Invalid JSON")
    }
    
    func testEncodingError() {
        let error = NetworkError.encodingError("Invalid data")
        XCTAssertEqual(error.errorDescription, "Failed to encode request: Invalid data")
    }
    
    func testFromURLError() {
        let urlError = URLError(.notConnectedToInternet)
        let networkError = NetworkError.from(urlError)
        XCTAssertEqual(networkError, .noInternet)
    }
    
    func testFromURLErrorTimeout() {
        let urlError = URLError(.timedOut)
        let networkError = NetworkError.from(urlError)
        XCTAssertEqual(networkError, .timeout)
    }
    
    func testFromURLErrorCancelled() {
        let urlError = URLError(.cancelled)
        let networkError = NetworkError.from(urlError)
        XCTAssertEqual(networkError, .cancelled)
    }
    
    func testIsClientError() {
        XCTAssertTrue(NetworkError.statusCode(400, nil).isClientError)
        XCTAssertTrue(NetworkError.statusCode(404, nil).isClientError)
        XCTAssertTrue(NetworkError.statusCode(499, nil).isClientError)
        
        XCTAssertFalse(NetworkError.statusCode(500, nil).isClientError)
        XCTAssertFalse(NetworkError.noInternet.isClientError)
    }
    
    func testIsServerError() {
        XCTAssertTrue(NetworkError.statusCode(500, nil).isServerError)
        XCTAssertTrue(NetworkError.statusCode(502, nil).isServerError)
        XCTAssertTrue(NetworkError.statusCode(599, nil).isServerError)
        
        XCTAssertFalse(NetworkError.statusCode(400, nil).isServerError)
        XCTAssertFalse(NetworkError.timeout.isServerError)
    }
    
    func testEquality() {
        XCTAssertEqual(NetworkError.noInternet, NetworkError.noInternet)
        XCTAssertEqual(NetworkError.timeout, NetworkError.timeout)
        XCTAssertEqual(NetworkError.invalidURL("test"), NetworkError.invalidURL("test"))
        XCTAssertEqual(NetworkError.statusCode(404, nil), NetworkError.statusCode(404, nil))
        
        XCTAssertNotEqual(NetworkError.noInternet, NetworkError.timeout)
        XCTAssertNotEqual(NetworkError.statusCode(404, nil), NetworkError.statusCode(500, nil))
    }
}
