# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-01

### Added
- Initial release of AppFoundation
- String extensions: validation, transformation, and utilities
- Date extensions: formatting, relative time, boundaries, comparison, arithmetic
- Collection extensions: safe subscript, chunking, deduplication, async operations
- Optional extensions: nil/empty checking for String, Collection, Bool
- UserDefaults extensions: typed access, Codable support, type-safe keys
- Logger system with protocol-based architecture and multiple destinations
- Environment configuration with development/staging/production support
- Feature flags system
- Custom error types with LocalizedError conformance
- Comprehensive unit test suite (147 tests)

### Features
- iOS 16.0+ support
- Swift 5.9+ with modern concurrency (async/await)
- No external dependencies
- Comprehensive inline documentation
- Thread-safe implementations

[1.0.0]: https://github.com/neganngdev/AppFoundation/releases/tag/1.0.0
