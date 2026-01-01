// NetworkError.swift
// AppFoundation
//
// Comprehensive error types for network operations.

import Foundation

// MARK: - Network Error

/// Errors that can occur during network operations.
public enum NetworkError: LocalizedError, Equatable {
    /// No internet connection available.
    case noInternet
    
    /// The request timed out.
    case timeout
    
    /// The URL is invalid or malformed.
    case invalidURL(String)
    
    /// The response is not a valid HTTP response.
    case invalidResponse
    
    /// HTTP error with status code and optional response data.
    case statusCode(Int, Data?)
    
    /// Failed to decode the response.
    case decodingError(String)
    
    /// Failed to encode the request.
    case encodingError(String)
    
    /// The request was cancelled.
    case cancelled
    
    /// An unknown error occurred.
    case unknown(String)
    
    // MARK: - LocalizedError Conformance
    
    public var errorDescription: String? {
        switch self {
        case .noInternet:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .invalidResponse:
            return "Invalid server response"
        case .statusCode(let code, _):
            return "HTTP error \(code): \(httpStatusMessage(for: code))"
        case .decodingError(let message):
            return "Failed to decode response: \(message)"
        case .encodingError(let message):
            return "Failed to encode request: \(message)"
        case .cancelled:
            return "Request was cancelled"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .noInternet:
            return "The device is not connected to the internet"
        case .timeout:
            return "The server took too long to respond"
        case .invalidURL:
            return "The URL format is incorrect"
        case .invalidResponse:
            return "The server returned an unexpected response format"
        case .statusCode(let code, _):
            return "The server returned status code \(code)"
        case .decodingError:
            return "The response data could not be parsed"
        case .encodingError:
            return "The request data could not be formatted"
        case .cancelled:
            return "The operation was cancelled by the user or system"
        case .unknown:
            return "An unexpected error occurred"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .noInternet:
            return "Check your internet connection and try again"
        case .timeout:
            return "Try again later or check your connection speed"
        case .invalidURL:
            return "Contact support if this problem persists"
        case .invalidResponse:
            return "Try again or contact support"
        case .statusCode(let code, _):
            return httpRecoverySuggestion(for: code)
        case .decodingError:
            return "The API response format may have changed"
        case .encodingError:
            return "Check the request data format"
        case .cancelled:
            return "Try the operation again"
        case .unknown:
            return "Try again or contact support"
        }
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.noInternet, .noInternet),
             (.timeout, .timeout),
             (.invalidResponse, .invalidResponse),
             (.cancelled, .cancelled):
            return true
        case (.invalidURL(let lhsURL), .invalidURL(let rhsURL)):
            return lhsURL == rhsURL
        case (.statusCode(let lhsCode, _), .statusCode(let rhsCode, _)):
            return lhsCode == rhsCode
        case (.decodingError(let lhsMsg), .decodingError(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.encodingError(let lhsMsg), .encodingError(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.unknown(let lhsMsg), .unknown(let rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }
    
    // MARK: - Helper Methods
    
    /// Returns a human-readable message for an HTTP status code.
    private func httpStatusMessage(for code: Int) -> String {
        switch code {
        case 400: return "Bad Request"
        case 401: return "Unauthorized"
        case 403: return "Forbidden"
        case 404: return "Not Found"
        case 405: return "Method Not Allowed"
        case 408: return "Request Timeout"
        case 409: return "Conflict"
        case 410: return "Gone"
        case 422: return "Unprocessable Entity"
        case 429: return "Too Many Requests"
        case 500: return "Internal Server Error"
        case 501: return "Not Implemented"
        case 502: return "Bad Gateway"
        case 503: return "Service Unavailable"
        case 504: return "Gateway Timeout"
        default:
            if (400..<500).contains(code) {
                return "Client Error"
            } else if (500..<600).contains(code) {
                return "Server Error"
            }
            return "Unknown Status"
        }
    }
    
    /// Returns a recovery suggestion for an HTTP status code.
    private func httpRecoverySuggestion(for code: Int) -> String {
        switch code {
        case 400:
            return "Check the request parameters and try again"
        case 401:
            return "Please log in again"
        case 403:
            return "You don't have permission to access this resource"
        case 404:
            return "The requested resource was not found"
        case 408, 504:
            return "The request timed out. Try again"
        case 429:
            return "Too many requests. Please wait and try again"
        case 500, 502, 503:
            return "Server error. Try again later"
        default:
            return "Try again or contact support"
        }
    }
}

// MARK: - Network Error + Convenience

public extension NetworkError {
    /// Creates a NetworkError from a URLError.
    static func from(_ urlError: URLError) -> NetworkError {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noInternet
        case .timedOut:
            return .timeout
        case .badURL, .unsupportedURL:
            return .invalidURL(urlError.failureURLString ?? "unknown")
        case .cancelled:
            return .cancelled
        default:
            return .unknown(urlError.localizedDescription)
        }
    }
    
    /// Whether this is a client error (4xx status code).
    var isClientError: Bool {
        if case .statusCode(let code, _) = self, (400..<500).contains(code) {
            return true
        }
        return false
    }
    
    /// Whether this is a server error (5xx status code).
    var isServerError: Bool {
        if case .statusCode(let code, _) = self, (500..<600).contains(code) {
            return true
        }
        return false
    }
    
    /// The HTTP status code if this is a status code error.
    var statusCode: Int? {
        if case .statusCode(let code, _) = self {
            return code
        }
        return nil
    }
    
    /// The response data if available.
    var responseData: Data? {
        if case .statusCode(_, let data) = self {
            return data
        }
        return nil
    }
}
