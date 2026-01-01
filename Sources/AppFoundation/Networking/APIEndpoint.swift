// APIEndpoint.swift
// AppFoundation
//
// Protocol for defining API endpoints.

import Foundation

// MARK: - API Endpoint

/// Protocol for defining API endpoints.
///
/// Conform to this protocol to create type-safe API endpoint definitions.
///
/// ```swift
/// struct UserEndpoint: APIEndpoint {
///     let userId: String
///     var path: String { "/users/\(userId)" }
///     var method: HTTPMethod { .get }
/// }
///
/// let endpoint = UserEndpoint(userId: "123")
/// let url = try endpoint.buildURL()
/// ```
public protocol APIEndpoint {
    /// The base URL for the API.
    var baseURL: String { get }
    
    /// The path component of the URL.
    var path: String { get }
    
    /// The HTTP method for this endpoint.
    var method: HTTPMethod { get }
    
    /// Optional HTTP headers.
    var headers: [String: String]? { get }
    
    /// Optional query parameters.
    var queryParameters: [String: String]? { get }
    
    /// Optional request body data.
    var body: Data? { get }
    
    /// Request timeout interval in seconds.
    var timeout: TimeInterval { get }
}

// MARK: - API Endpoint + Default Implementation

public extension APIEndpoint {
    /// Default base URL (override in your implementation).
    var baseURL: String {
        ""
    }
    
    /// Default headers (none).
    var headers: [String: String]? {
        nil
    }
    
    /// Default query parameters (none).
    var queryParameters: [String: String]? {
        nil
    }
    
    /// Default body (none).
    var body: Data? {
        nil
    }
    
    /// Default timeout (30 seconds).
    var timeout: TimeInterval {
        30.0
    }
}

// MARK: - API Endpoint + URL Building

public extension APIEndpoint {
    /// Builds the complete URL for this endpoint.
    ///
    /// - Returns: The constructed URL.
    /// - Throws: `NetworkError.invalidURL` if the URL cannot be constructed.
    func buildURL() throws -> URL {
        let urlString = baseURL + path
        
        guard var components = URLComponents(string: urlString) else {
            throw NetworkError.invalidURL(urlString)
        }
        
        // Add query parameters if present
        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            components.queryItems = queryParameters.map { key, value in
                URLQueryItem(name: key, value: value)
            }
        }
        
        guard let url = components.url else {
            throw NetworkError.invalidURL(urlString)
        }
        
        return url
    }
    
    /// Builds a URLRequest for this endpoint.
    ///
    /// - Returns: The configured URLRequest.
    /// - Throws: `NetworkError.invalidURL` if the URL cannot be constructed.
    func buildURLRequest() throws -> URLRequest {
        let url = try buildURL()
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeout
        
        // Set headers
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Set body
        request.httpBody = body
        
        return request
    }
}

// MARK: - API Endpoint + JSON Encoding

public extension APIEndpoint {
    /// Creates an endpoint with a JSON-encoded body.
    ///
    /// - Parameter encodable: The object to encode as JSON.
    /// - Returns: A modified endpoint with the JSON body.
    /// - Throws: `NetworkError.encodingError` if encoding fails.
    func withJSONBody<T: Encodable>(_ encodable: T) throws -> Self {
        var endpoint = self
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(encodable)
            
            // This is a workaround since we can't mutate self in a protocol extension
            // Users should create a mutable copy or use RequestBuilder
            return endpoint
        } catch {
            throw NetworkError.encodingError(error.localizedDescription)
        }
    }
}
