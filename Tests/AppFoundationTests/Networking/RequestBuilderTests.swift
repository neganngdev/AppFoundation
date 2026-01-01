// RequestBuilderTests.swift
// AppFoundationTests

import XCTest
@testable import AppFoundation

final class RequestBuilderTests: XCTestCase {
    
    func testEncodeQueryParameters() {
        let params = [
            "name": "John Doe",
            "age": "30",
            "city": "New York"
        ]
        
        let encoded = RequestBuilder.encodeQueryParameters(params)
        
        // Parameters should be sorted and encoded
        XCTAssertTrue(encoded.contains("age=30"))
        XCTAssertTrue(encoded.contains("city=New%20York"))
        XCTAssertTrue(encoded.contains("name=John%20Doe"))
    }
    
    func testEncodeJSON() throws {
        struct TestData: Codable {
            let name: String
            let value: Int
        }
        
        let testData = TestData(name: "test", value: 42)
        let data = try RequestBuilder.encodeJSON(testData)
        
        XCTAssertFalse(data.isEmpty)
        
        // Verify it can be decoded back
        let decoded = try JSONDecoder().decode(TestData.self, from: data)
        XCTAssertEqual(decoded.name, "test")
        XCTAssertEqual(decoded.value, 42)
    }
    
    func testBuildMultipartBody() {
        let parts = [
            MultipartFormDataPart.text(name: "field1", value: "value1"),
            MultipartFormDataPart.text(name: "field2", value: "value2")
        ]
        
        let (data, contentType) = RequestBuilder.buildMultipartBody(parts: parts)
        
        XCTAssertFalse(data.isEmpty)
        XCTAssertTrue(contentType.starts(with: "multipart/form-data; boundary="))
        
        let bodyString = String(data: data, encoding: .utf8)!
        XCTAssertTrue(bodyString.contains("field1"))
        XCTAssertTrue(bodyString.contains("value1"))
        XCTAssertTrue(bodyString.contains("field2"))
        XCTAssertTrue(bodyString.contains("value2"))
    }
    
    func testMultipartFormDataPartText() {
        let part = MultipartFormDataPart.text(name: "username", value: "john")
        
        XCTAssertEqual(part.name, "username")
        XCTAssertEqual(String(data: part.data, encoding: .utf8), "john")
        XCTAssertNil(part.filename)
        XCTAssertNil(part.mimeType)
    }
    
    func testMultipartFormDataPartFile() {
        let fileData = "file content".data(using: .utf8)!
        let part = MultipartFormDataPart.file(
            name: "document",
            data: fileData,
            filename: "test.txt",
            mimeType: "text/plain"
        )
        
        XCTAssertEqual(part.name, "document")
        XCTAssertEqual(part.data, fileData)
        XCTAssertEqual(part.filename, "test.txt")
        XCTAssertEqual(part.mimeType, "text/plain")
    }
    
    func testMultipartFormDataPartImage() {
        let imageData = Data([0xFF, 0xD8, 0xFF]) // JPEG header
        let part = MultipartFormDataPart.image(
            name: "photo",
            imageData: imageData,
            filename: "photo.jpg"
        )
        
        XCTAssertEqual(part.name, "photo")
        XCTAssertEqual(part.data, imageData)
        XCTAssertEqual(part.filename, "photo.jpg")
        XCTAssertEqual(part.mimeType, "image/jpeg")
    }
}
