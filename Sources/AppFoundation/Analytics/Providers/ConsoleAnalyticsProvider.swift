// ConsoleAnalyticsProvider.swift
// AppFoundation
//
// Console logger provider for debugging.

import Foundation

// MARK: - Console Analytics Provider

/// Analytics provider that logs events to the console.
///
/// Useful for debugging and development.
///
/// ```swift
/// let provider = ConsoleAnalyticsProvider()
/// await AnalyticsManager.shared.register(provider: provider)
/// ```
public actor ConsoleAnalyticsProvider: AnalyticsProvider {
    
    // MARK: - Properties
    
    nonisolated public var name: String { "Console" }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Analytics Provider
    
    public func trackEvent(_ event: AnalyticsEvent) async {
        let timestamp = dateFormatter.string(from: event.timestamp)
        print("📊 [\(timestamp)] Event: \(event.name)")
        
        if let parameters = event.parameters, !parameters.isEmpty {
            print("   Parameters:")
            for (key, value) in parameters.sorted(by: { $0.key < $1.key }) {
                print("   - \(key): \(value)")
            }
        }
    }
    
    public func trackScreen(name: String, parameters: [String: Any]?) async {
        let timestamp = dateFormatter.string(from: Date())
        print("📱 [\(timestamp)] Screen: \(name)")
        
        if let parameters = parameters, !parameters.isEmpty {
            print("   Parameters:")
            for (key, value) in parameters.sorted(by: { $0.key < $1.key }) {
                print("   - \(key): \(value)")
            }
        }
    }
    
    public func setUserProperty(name: String, value: String) async {
        print("👤 User Property: \(name) = \(value)")
    }
    
    public func setUserId(_ userId: String?) async {
        if let userId = userId {
            print("🆔 User ID: \(userId)")
        } else {
            print("🆔 User ID: cleared")
        }
    }
}
