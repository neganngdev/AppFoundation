// MockAnalyticsProvider.swift
// AppFoundation
//
// Mock provider for testing.

import Foundation

// MARK: - Mock Analytics Provider

/// Mock analytics provider for testing.
///
/// Records all events and allows verification in tests.
///
/// ```swift
/// let mock = MockAnalyticsProvider()
/// await AnalyticsManager.shared.register(provider: mock)
///
/// // ... perform actions ...
///
/// let events = await mock.trackedEvents
/// XCTAssertEqual(events.count, 1)
/// ```
public actor MockAnalyticsProvider: AnalyticsProvider {
    
    // MARK: - Properties
    
    nonisolated public var name: String { "Mock" }
    
    private(set) public var trackedEvents: [AnalyticsEvent] = []
    private(set) public var trackedScreens: [(name: String, parameters: [String: Any]?)] = []
    private(set) public var userProperties: [String: String] = [:]
    private(set) public var userId: String?
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Analytics Provider
    
    public func trackEvent(_ event: AnalyticsEvent) async {
        trackedEvents.append(event)
    }
    
    public func trackScreen(name: String, parameters: [String: Any]?) async {
        trackedScreens.append((name: name, parameters: parameters))
    }
    
    public func setUserProperty(name: String, value: String) async {
        userProperties[name] = value
    }
    
    public func setUserId(_ userId: String?) async {
        self.userId = userId
    }
    
    // MARK: - Testing Helpers
    
    /// Resets all tracked data.
    public func reset() {
        trackedEvents.removeAll()
        trackedScreens.removeAll()
        userProperties.removeAll()
        userId = nil
    }
    
    /// Returns whether an event with the given name was tracked.
    ///
    /// - Parameter name: The event name.
    /// - Returns: True if the event was tracked.
    public func didTrackEvent(named name: String) -> Bool {
        trackedEvents.contains { $0.name == name }
    }
    
    /// Returns the number of times an event was tracked.
    ///
    /// - Parameter name: The event name.
    /// - Returns: The count.
    public func eventCount(named name: String) -> Int {
        trackedEvents.filter { $0.name == name }.count
    }
    
    /// Returns whether a screen was tracked.
    ///
    /// - Parameter name: The screen name.
    /// - Returns: True if the screen was tracked.
    public func didTrackScreen(named name: String) -> Bool {
        trackedScreens.contains { $0.name == name }
    }
}
