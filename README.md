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

The package includes comprehensive unit tests (147 tests, all passing).

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
