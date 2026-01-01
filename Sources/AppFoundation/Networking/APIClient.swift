// APIClient.swift
// AppFoundation
//
// Protocol and implementation for making API requests.

import Foundation

// MARK: - API Client Protocol

/// Protocol for making API requests.
///
/// Conform to this protocol to create custom API clients or use `DefaultAPIClient`.
///
/// ```swift
/// let client = DefaultAPIClient()
/// let user: User = try await client.request(UserEndpoint(userId: "123"))
/// ```
public protocol APIClient: Sendable {
    /// Makes a request and decodes the response.
    ///
    /// - Parameter endpoint: The API endpoint to request.
    /// - Returns: The decoded response.
    /// - Throws: `NetworkError` if the request fails.
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    
    /// Makes a request and returns raw data.
    ///
    /// - Parameter endpoint: The API endpoint to request.
    /// - Returns: The response data.
    /// - Throws: `NetworkError` if the request fails.
    func request(_ endpoint: APIEndpoint) async throws -> Data
}

// MARK: - Default API Client

/// Default implementation of APIClient using URLSession.
public actor DefaultAPIClient: APIClient {
    
    // MARK: - Properties
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private var defaultHeaders: [String: String]
    
    // MARK: - Initialization
    
    /// Creates a new API client.
    ///
    /// - Parameters:
    ///   - session: The URLSession to use (defaults to `.shared`).
    ///   - decoder: The JSONDecoder to use for responses.
    ///   - defaultHeaders: Default headers to include in all requests.
    public init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        defaultHeaders: [String: String] = [:]
    ) {
        self.session = session
        self.decoder = decoder
        self.decoder.dateDecodingStrategy = .iso8601
        self.defaultHeaders = defaultHeaders
        
        // Set default headers
        if self.defaultHeaders["User-Agent"] == nil {
            self.defaultHeaders["User-Agent"] = "AppFoundation/1.0"
        }
        if self.defaultHeaders["Accept"] == nil {
            self.defaultHeaders["Accept"] = "application/json"
        }
    }
    
    // MARK: - Header Management
    
    /// Sets a default header value.
    ///
    /// - Parameters:
    ///   - value: The header value.
    ///   - key: The header key.
    public func setDefaultHeader(_ value: String, forKey key: String) {
        defaultHeaders[key] = value
    }
    
    /// Removes a default header.
    ///
    /// - Parameter key: The header key to remove.
    public func removeDefaultHeader(forKey key: String) {
        defaultHeaders.removeValue(forKey: key)
    }
    
    /// Sets the authorization header with a bearer token.
    ///
    /// - Parameter token: The bearer token.
    public func setBearerToken(_ token: String) {
        defaultHeaders["Authorization"] = "Bearer \(token)"
    }
    
    /// Removes the authorization header.
    public func clearAuthorization() {
        defaultHeaders.removeValue(forKey: "Authorization")
    }
    
    // MARK: - Request Methods
    
    public func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let data = try await request(endpoint)
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }
    
    public func request(_ endpoint: APIEndpoint) async throws -> Data {
        var urlRequest = try endpoint.buildURLRequest()
        
        // Merge default headers with endpoint headers
        for (key, value) in defaultHeaders {
            if urlRequest.value(forHTTPHeaderField: key) == nil {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Set Content-Type for requests with body
        if endpoint.method.supportsBody, urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return try await performRequest(urlRequest)
    }
    
    // MARK: - Private Methods
    
    private func performRequest(_ request: URLRequest) async throws -> Data {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            // Check status code
            try validateStatusCode(httpResponse.statusCode, data: data)
            
            return data
        } catch let error as NetworkError {
            throw error
        } catch let urlError as URLError {
            throw NetworkError.from(urlError)
        } catch {
            throw NetworkError.unknown(error.localizedDescription)
        }
    }
    
    private func validateStatusCode(_ statusCode: Int, data: Data) throws {
        guard (200..<300).contains(statusCode) else {
            throw NetworkError.statusCode(statusCode, data)
        }
    }
}

// MARK: - Default API Client + Upload

public extension DefaultAPIClient {
    /// Uploads data with progress tracking.
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint.
    ///   - data: The data to upload.
    ///   - progress: Optional progress callback.
    /// - Returns: The decoded response.
    /// - Throws: `NetworkError` if the request fails.
    func upload<T: Decodable>(
        _ endpoint: APIEndpoint,
        data: Data,
        progress: ((Double) -> Void)? = nil
    ) async throws -> T {
        let responseData = try await upload(endpoint, data: data, progress: progress)
        
        do {
            return try decoder.decode(T.self, from: responseData)
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }
    
    /// Uploads data with progress tracking and returns raw data.
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint.
    ///   - data: The data to upload.
    ///   - progress: Optional progress callback.
    /// - Returns: The response data.
    /// - Throws: `NetworkError` if the request fails.
    func upload(
        _ endpoint: APIEndpoint,
        data: Data,
        progress: ((Double) -> Void)? = nil
    ) async throws -> Data {
        var urlRequest = try endpoint.buildURLRequest()
        urlRequest.httpBody = data
        
        // Merge headers
        for (key, value) in defaultHeaders {
            if urlRequest.value(forHTTPHeaderField: key) == nil {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        return try await performRequest(urlRequest)
    }
}

// MARK: - Default API Client + Multipart

public extension DefaultAPIClient {
    /// Uploads multipart form data.
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint.
    ///   - parts: The multipart form data parts.
    /// - Returns: The decoded response.
    /// - Throws: `NetworkError` if the request fails.
    func uploadMultipart<T: Decodable>(
        _ endpoint: APIEndpoint,
        parts: [MultipartFormDataPart]
    ) async throws -> T {
        let (body, contentType) = RequestBuilder.buildMultipartBody(parts: parts)
        
        var urlRequest = try endpoint.buildURLRequest()
        urlRequest.httpBody = body
        urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // Merge headers
        for (key, value) in defaultHeaders {
            if urlRequest.value(forHTTPHeaderField: key) == nil, key != "Content-Type" {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let data = try await performRequest(urlRequest)
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }
}
