// HTTPMethod.swift
// AppFoundation
//
// HTTP method enumeration for network requests.

import Foundation

// MARK: - HTTP Method

/// HTTP request methods.
///
/// Represents the standard HTTP methods used in REST APIs.
///
/// ```swift
/// let method: HTTPMethod = .get
/// let request = URLRequest(url: url)
/// request.httpMethod = method.rawValue
/// ```
public enum HTTPMethod: String, Sendable, CaseIterable {
    /// GET method - Retrieve data
    case get = "GET"
    
    /// POST method - Create new resource
    case post = "POST"
    
    /// PUT method - Update/replace resource
    case put = "PUT"
    
    /// DELETE method - Delete resource
    case delete = "DELETE"
    
    /// PATCH method - Partial update
    case patch = "PATCH"
    
    /// HEAD method - Retrieve headers only
    case head = "HEAD"
    
    /// OPTIONS method - Get supported methods
    case options = "OPTIONS"
}

// MARK: - HTTP Method + Helpers

public extension HTTPMethod {
    /// Whether this method typically includes a request body.
    var supportsBody: Bool {
        switch self {
        case .post, .put, .patch:
            return true
        case .get, .delete, .head, .options:
            return false
        }
    }
    
    /// Whether this method is considered idempotent.
    var isIdempotent: Bool {
        switch self {
        case .get, .put, .delete, .head, .options:
            return true
        case .post, .patch:
            return false
        }
    }
}
