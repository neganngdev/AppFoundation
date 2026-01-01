// RequestBuilder.swift
// AppFoundation
//
// Utilities for building HTTP requests.

import Foundation

// MARK: - Request Builder

/// Utilities for constructing HTTP requests.
public enum RequestBuilder {
    
    // MARK: - Query Parameter Encoding
    
    /// Encodes query parameters into a URL query string.
    ///
    /// - Parameter parameters: Dictionary of query parameters.
    /// - Returns: URL-encoded query string.
    public static func encodeQueryParameters(_ parameters: [String: String]) -> String {
        parameters
            .sorted { $0.key < $1.key }
            .map { key, value in
                let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
                return "\(encodedKey)=\(encodedValue)"
            }
            .joined(separator: "&")
    }
    
    // MARK: - JSON Encoding
    
    /// Encodes a Codable object to JSON data.
    ///
    /// - Parameters:
    ///   - value: The object to encode.
    ///   - encoder: Optional custom JSONEncoder.
    /// - Returns: JSON data.
    /// - Throws: `NetworkError.encodingError` if encoding fails.
    public static func encodeJSON<T: Encodable>(
        _ value: T,
        encoder: JSONEncoder = JSONEncoder()
    ) throws -> Data {
        do {
            encoder.dateEncodingStrategy = .iso8601
            return try encoder.encode(value)
        } catch {
            throw NetworkError.encodingError(error.localizedDescription)
        }
    }
    
    // MARK: - Multipart Form Data
    
    /// Builds a multipart/form-data request body.
    ///
    /// - Parameters:
    ///   - parts: Array of multipart form data parts.
    ///   - boundary: Optional custom boundary string.
    /// - Returns: The multipart body data and content type header value.
    public static func buildMultipartBody(
        parts: [MultipartFormDataPart],
        boundary: String = UUID().uuidString
    ) -> (data: Data, contentType: String) {
        var body = Data()
        
        for part in parts {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(part.name)\"".data(using: .utf8)!)
            
            if let filename = part.filename {
                body.append("; filename=\"\(filename)\"".data(using: .utf8)!)
            }
            
            body.append("\r\n".data(using: .utf8)!)
            
            if let mimeType = part.mimeType {
                body.append("Content-Type: \(mimeType)\r\n".data(using: .utf8)!)
            }
            
            body.append("\r\n".data(using: .utf8)!)
            body.append(part.data)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        let contentType = "multipart/form-data; boundary=\(boundary)"
        return (body, contentType)
    }
}

// MARK: - Multipart Form Data Part

/// Represents a part of a multipart/form-data request.
public struct MultipartFormDataPart {
    /// The form field name.
    public let name: String
    
    /// The data for this part.
    public let data: Data
    
    /// Optional filename (for file uploads).
    public let filename: String?
    
    /// Optional MIME type.
    public let mimeType: String?
    
    /// Creates a new multipart form data part.
    ///
    /// - Parameters:
    ///   - name: The form field name.
    ///   - data: The data for this part.
    ///   - filename: Optional filename for file uploads.
    ///   - mimeType: Optional MIME type.
    public init(
        name: String,
        data: Data,
        filename: String? = nil,
        mimeType: String? = nil
    ) {
        self.name = name
        self.data = data
        self.filename = filename
        self.mimeType = mimeType
    }
}

// MARK: - Multipart Form Data Part + Convenience

public extension MultipartFormDataPart {
    /// Creates a text field part.
    ///
    /// - Parameters:
    ///   - name: The form field name.
    ///   - value: The text value.
    static func text(name: String, value: String) -> MultipartFormDataPart {
        MultipartFormDataPart(
            name: name,
            data: value.data(using: .utf8) ?? Data()
        )
    }
    
    /// Creates a file part.
    ///
    /// - Parameters:
    ///   - name: The form field name.
    ///   - data: The file data.
    ///   - filename: The filename.
    ///   - mimeType: The MIME type (e.g., "image/jpeg").
    static func file(
        name: String,
        data: Data,
        filename: String,
        mimeType: String
    ) -> MultipartFormDataPart {
        MultipartFormDataPart(
            name: name,
            data: data,
            filename: filename,
            mimeType: mimeType
        )
    }
    
    /// Creates an image part.
    ///
    /// - Parameters:
    ///   - name: The form field name.
    ///   - imageData: The image data.
    ///   - filename: The filename.
    ///   - imageType: The image type (defaults to "jpeg").
    static func image(
        name: String,
        imageData: Data,
        filename: String,
        imageType: String = "jpeg"
    ) -> MultipartFormDataPart {
        MultipartFormDataPart(
            name: name,
            data: imageData,
            filename: filename,
            mimeType: "image/\(imageType)"
        )
    }
}
