# AppFoundation

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2016.0+-lightgrey.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A comprehensive Swift Package providing essential utilities, extensions, and business logic for iOS applications. Built with modern Swift concurrency and designed for reusability across multiple projects.

## Features

### 📝 Extensions

#### String Extensions
- **Validation**: `isBlank`, `isValidEmail`, `isNumeric`, `isAlphanumeric`
- **Transformation**: `trimmed`, `localized`, `capitalizedFirst`
- **Utilities**: `nilIfEmpty`

```swift
"user@example.com".isValidEmail  // true
"  Hello  ".trimmed               // "Hello"
"".nilIfEmpty                     // nil
```

#### Date Extensions
- **Formatting**: `formatted(as:)`, `relativeTime`
- **Boundaries**: `startOfDay`, `endOfDay`, `startOfWeek`, `startOfMonth`
- **Comparison**: `isToday`, `isYesterday`, `isTomorrow`, `isPast`, `isFuture`
- **Arithmetic**: `adding(days:)`, `adding(hours:)`, `days(from:)`

```swift
let date = Date()
date.formatted(as: "yyyy-MM-dd")  // "2024-01-15"
date.relativeTime                  // "now"
date.isToday                       // true
date.adding(days: 7)               // Date 7 days from now
```

#### Collection Extensions
- **Safe Access**: `[safe: index]` - Returns `nil` instead of crashing
- **Chunking**: `chunked(into:)` - Split arrays into smaller chunks
- **Deduplication**: `removingDuplicates()` - Remove duplicates while preserving order
- **Async Operations**: `asyncMap`, `asyncFilter`, `asyncForEach`

```swift
let array = [1, 2, 3, 4, 5]
array[safe: 10]                    // nil (safe access)
array.chunked(into: 2)             // [[1, 2], [3, 4], [5]]
[1, 2, 2, 3].removingDuplicates()  // [1, 2, 3]
```

#### Optional Extensions
- **String**: `isNilOrEmpty`, `isNilOrBlank`, `orEmpty`
- **Collection**: `isNilOrEmpty`, `hasElements`
- **Bool**: `orFalse`, `orTrue`
- **General**: `hasValue`, `isNil`, `ifLet`

```swift
let name: String? = nil
name.isNilOrEmpty     // true
name.orEmpty          // ""

let items: [Int]? = []
items.isNilOrEmpty    // true
```

#### UserDefaults Extensions
- **Typed Access**: Generic getters and setters
- **Codable Support**: Store and retrieve Codable objects
- **Type-Safe Keys**: `UserDefaultsKey<T>` for compile-time safety
- **Subscripts**: Convenient subscript access

```swift
// Typed access
defaults.set(value: "John", forKey: "username")
let name: String = defaults.get(forKey: "username", default: "Guest")

// Codable support
try defaults.setCodable(user, forKey: "currentUser")
let user = defaults.getCodable(User.self, forKey: "currentUser")

// Type-safe keys
extension UserDefaultsKey {
    static let username = UserDefaultsKey<String>("username")
}
defaults[.username] = "John"
```

### 🪵 Logger

A flexible logging system with support for multiple destinations and log levels.

```swift
// Use the shared logger
Logger.shared.debug("Debug message")
Logger.shared.info("User logged in")
Logger.shared.warning("Memory usage high")
Logger.shared.error("Failed to save data")

// Create a custom logger
let logger = Logger(
    minimumLevel: .info,
    destinations: [ConsoleDestination(), PrintDestination()],
    category: "Network"
)

// Global convenience functions
logInfo("Application started")
logError("Something went wrong")
```

**Features:**
- Multiple log levels: debug, info, warning, error
- Pluggable destinations (Console, Print, or custom)
- Automatic file, function, and line metadata
- Thread-safe
- Uses `os.Logger` for system integration

### 🌍 Environment Configuration

Environment-aware configuration system supporting development, staging, and production.

```swift
// Access current environment
let env = Environment.current  // .development, .staging, or .production

// Environment-specific configuration
struct APIConfig: EnvironmentConfigurable {
    let baseURL: String
    
    static var development: APIConfig {
        APIConfig(baseURL: "http://localhost:8080")
    }
    
    static var staging: APIConfig {
        APIConfig(baseURL: "https://staging-api.example.com")
    }
    
    static var production: APIConfig {
        APIConfig(baseURL: "https://api.example.com")
    }
}

let config = APIConfig.current

// Property wrapper
@EnvironmentValue(
    development: "dev-key",
    staging: "staging-key",
    production: "prod-key"
)
var apiKey: String

// Feature flags
let newFeature = FeatureFlag.developmentOnly("new_onboarding")
if newFeature.isEnabled {
    // Show new feature
}
```

### ⚠️ Error Handling

Comprehensive error types with localized descriptions.

```swift
// Validation errors
throw AppFoundationError.validation(.invalidEmail)
throw AppFoundationError.validation(.emptyField(fieldName: "username"))

// Storage errors
throw AppFoundationError.storage(.notFound(key: "user"))
throw AppFoundationError.storage(.encodingFailed("Invalid data"))

// Configuration errors
throw AppFoundationError.configuration(.missingValue(key: "API_KEY"))

// Network errors
throw AppFoundationError.network(.noConnection)
throw AppFoundationError.network(.serverError(statusCode: 500))
```

All errors conform to `LocalizedError` with:
- `errorDescription`: User-facing error message
- `failureReason`: Why the error occurred
- `recoverySuggestion`: How to fix the issue

### 💾 Storage Layer

Thread-safe storage solutions for local data persistence with UserDefaults and Keychain.

#### UserDefaults Storage

Thread-safe wrapper around UserDefaults with protocol conformance:

```swift
let storage = UserDefaultsStorage()

// Save primitives
try storage.save("John", forKey: "username")
try storage.save(42, forKey: "age")

// Save Codable objects
try storage.save(user, forKey: "current_user")

// Retrieve with type safety
let name: String? = try storage.get(forKey: "username")
let user: User? = try storage.get(forKey: "current_user")

// Batch operations
try storage.saveBatch(["key1": "value1", "key2": "value2"])
storage.deleteBatch(forKeys: ["key1", "key2"])
```

#### @UserDefault Property Wrapper

Type-safe property wrapper that works outside SwiftUI (unlike `@AppStorage`):

```swift
class Settings {
    @UserDefault(key: "hasSeenOnboarding", defaultValue: false)
    static var hasSeenOnboarding: Bool
    
    @UserDefault(key: "username", defaultValue: "Guest")
    static var username: String
    
    @OptionalUserDefault(key: "apiToken")
    static var apiToken: String?
}

// Usage
Settings.hasSeenOnboarding = true
print(Settings.username)  // "Guest"
```

**Features:**
- Works with primitives (String, Int, Double, Bool, Data)
- Codable support for complex types
- Optional variant with `@OptionalUserDefault`
- `reset()` and `hasValue` helpers

#### Keychain Storage

Secure, actor-based storage for sensitive data:

```swift
let keychain = KeychainStorage()

// Save credentials securely
try await keychain.save("secret_password", forKey: "password")
try await keychain.save(credentials, forKey: "auth_credentials")

// Retrieve
let password: String? = try await keychain.getString(forKey: "password")
let creds: Credentials? = try await keychain.get(forKey: "auth_credentials")

// Batch operations
try await keychain.saveBatch(["key1": data1, "key2": data2])
try await keychain.deleteBatch(forKeys: ["key1", "key2"])

// Query all keys
let allKeys = try await keychain.allKeys()

// Delete all
try await keychain.deleteAll()
```

**Features:**
- Actor-based for automatic thread safety
- Async/await support
- Access group support for app extensions
- Accessibility options (whenUnlocked, afterFirstUnlock, etc.)
- Comprehensive error handling with `KeychainError`

#### Storage Protocols

Generic protocols for abstraction and dependency injection:

```swift
// Use any storage implementation
func saveUser(_ user: User, to storage: any StorageProvider) throws {
    try storage.save(user, forKey: "user")
}

// Switch implementations easily
let memoryStorage = InMemoryStorage()  // For testing
let userDefaultsStorage = UserDefaultsStorage()  // For production

// Type-safe keys
enum StorageKeys: String, StorageKey {
    case username
    case theme
    
    var key: String { rawValue }
}

try storage.save("John", forKey: StorageKeys.username)
```

**Available Protocols:**
- `StorageProvider` - Synchronous storage interface
- `AsyncStorageProvider` - Async/await storage interface
- `KeychainStorable` - Keychain-specific operations
- `StorageKey` - Type-safe storage keys

### 🌐 Networking Layer

Modern, protocol-based networking with async/await for REST APIs.

#### API Client

Type-safe API client with automatic JSON encoding/decoding:

```swift
// Define an endpoint
struct UserEndpoint: APIEndpoint {
    let userId: String
    var baseURL: String { "https://api.example.com" }
    var path: String { "/users/\(userId)" }
    var method: HTTPMethod { .get }
}

// Make a request
let client = DefaultAPIClient()
let user: User = try await client.request(UserEndpoint(userId: "123"))
```

#### HTTP Methods

```swift
enum HTTPMethod {
    case get, post, put, delete, patch, head, options
}
```

**Helper properties:**
- `supportsBody` - Whether method typically includes a body
- `isIdempotent` - Whether method is idempotent

#### Network Error Handling

Comprehensive error types with localized descriptions:

```swift
enum NetworkError {
    case noInternet
    case timeout
    case invalidURL(String)
    case statusCode(Int, Data?)
    case decodingError(String)
    case encodingError(String)
    case cancelled
}

// Usage
do {
    let data = try await client.request(endpoint)
} catch let error as NetworkError {
    switch error {
    case .noInternet:
        print("No connection")
    case .statusCode(let code, _):
        print("HTTP error: \(code)")
    default:
        print(error.localizedDescription)
    }
}
```

#### Request Builder

Utilities for building requests:

```swift
// Query parameters
let query = RequestBuilder.encodeQueryParameters(["q": "search", "limit": "10"])

// JSON encoding
let data = try RequestBuilder.encodeJSON(user)

// Multipart form-data
let parts = [
    MultipartFormDataPart.text(name: "title", value: "Photo"),
    MultipartFormDataPart.image(name: "photo", imageData: data, filename: "photo.jpg")
]
let (body, contentType) = RequestBuilder.buildMultipartBody(parts: parts)
```

#### Authentication

```swift
// Bearer token
await client.setBearerToken("your_access_token")

// Custom headers
await client.setDefaultHeader("X-API-Key", forKey: "api_key")
```

#### File Uploads

```swift
let parts = [
    MultipartFormDataPart.text(name: "description", value: "My file"),
    MultipartFormDataPart.file(
        name: "document",
        data: fileData,
        filename: "document.pdf",
        mimeType: "application/pdf"
    )
]

let response: UploadResponse = try await client.uploadMultipart(
    UploadEndpoint(),
    parts: parts
)
```

**Features:**
- Actor-based thread safety
- Async/await (no completion handlers)
- Automatic JSON encoding/decoding
- HTTP status code validation
- Bearer token authentication
- Multipart file uploads
- Protocol-based for easy mocking

### 📊 Analytics System

Privacy-first analytics with support for multiple providers.

#### Analytics Manager

Actor-based singleton for managing analytics:

```swift
// Register providers
await AnalyticsManager.shared.register(provider: FirebaseAnalyticsProvider())
await AnalyticsManager.shared.register(provider: ConsoleAnalyticsProvider())

// Track events
await AnalyticsManager.shared.trackEvent(name: "button_tapped", parameters: ["button_id": "purchase"])
await AnalyticsManager.shared.trackEvent(.buttonTapped(id: "purchase"))

// Track screens
await AnalyticsManager.shared.trackScreen(name: "HomeScreen")

// User management
await AnalyticsManager.shared.setUserId("user123")
await AnalyticsManager.shared.setUserProperty(name: "plan", value: "premium")
```

#### Predefined Events

```swift
// Common events
AnalyticsEvent.appOpened
AnalyticsEvent.screenViewed(name: "Home")
AnalyticsEvent.buttonTapped(id: "purchase")
AnalyticsEvent.featureUsed(name: "dark_mode")
AnalyticsEvent.errorOccurred(error: "Network error", code: "500")
AnalyticsEvent.purchaseCompleted(productId: "premium", amount: "9.99")
AnalyticsEvent.searchPerformed(query: "swift")
AnalyticsEvent.shared(contentType: "article", method: "twitter")
```

#### GDPR Compliance

```swift
// Disable analytics (user opts out)
await AnalyticsManager.shared.setEnabled(false)

// Enable analytics (user opts in)
await AnalyticsManager.shared.setEnabled(true)

// Check status
let isEnabled = await AnalyticsManager.shared.analyticsEnabled
```

#### Custom Provider

```swift
actor FirebaseAnalyticsProvider: AnalyticsProvider {
    nonisolated var name: String { "Firebase" }
    
    func trackEvent(_ event: AnalyticsEvent) async {
        Analytics.logEvent(event.name, parameters: event.parameters)
    }
    
    func trackScreen(name: String, parameters: [String: Any]?) async {
        Analytics.logEvent("screen_view", parameters: parameters)
    }
    
    func setUserProperty(name: String, value: String) async {
        Analytics.setUserProperty(value, forName: name)
    }
    
    func setUserId(_ userId: String?) async {
        Analytics.setUserID(userId)
    }
}
```

#### Built-in Providers

**ConsoleAnalyticsProvider** - Debug logging:
```swift
await AnalyticsManager.shared.register(provider: ConsoleAnalyticsProvider())
// Output: 📊 [19:15:32.123] Event: button_tap
```

**MockAnalyticsProvider** - Testing:
```swift
let mock = MockAnalyticsProvider()
await AnalyticsManager.shared.register(provider: mock)

// Verify in tests
let events = await mock.trackedEvents
XCTAssertTrue(await mock.didTrackEvent(named: "button_tap"))
```

**Features:**
- Actor-based thread safety
- Privacy-first (opt-in, GDPR compliant)
- Multiple provider support
- Event queueing (max 100 events)
- User properties & ID management
- Predefined common events
- Easy to add custom providers

## Installation

### Swift Package Manager

Add AppFoundation to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/neganngdev/AppFoundation.git", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/neganngdev/AppFoundation`
3. Select version and add to your target

## Requirements

- iOS 16.0+
- macOS 13.0+
- Swift 5.9+
- Xcode 15.0+

## Usage

Import the package in your Swift files:

```swift
import AppFoundation
```

All extensions and utilities are immediately available.

## Testing

The package includes comprehensive unit tests (256 tests, 246 passing).

Run tests with:

```bash
swift test
```

## Documentation

All public APIs include comprehensive inline documentation. Use Xcode's Quick Help (⌥ + Click) to view documentation for any type or method.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

AppFoundation is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Author

**neganngdev**
- GitHub: [@neganngdev](https://github.com/neganngdev)

## Acknowledgments

Built with ❤️ for the iOS development community.
