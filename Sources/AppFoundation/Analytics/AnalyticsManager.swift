// AnalyticsManager.swift
// AppFoundation
//
// Actor-based analytics manager with multi-provider support.

import Foundation

// MARK: - Analytics Manager

/// Thread-safe analytics manager with support for multiple providers.
///
/// ```swift
/// // Register providers
/// await AnalyticsManager.shared.register(provider: FirebaseAnalyticsProvider())
/// await AnalyticsManager.shared.register(provider: ConsoleAnalyticsProvider())
///
/// // Track events
/// await AnalyticsManager.shared.trackEvent(name: "button_tapped", parameters: ["button_id": "purchase"])
/// await AnalyticsManager.shared.trackScreen(name: "HomeScreen")
///
/// // Enable/disable analytics
/// await AnalyticsManager.shared.setEnabled(false) // GDPR compliance
/// ```
public actor AnalyticsManager {
    
    // MARK: - Singleton
    
    /// Shared analytics manager instance.
    public static let shared = AnalyticsManager()
    
    // MARK: - Properties
    
    private var providers: [String: AnalyticsProvider] = [:]
    private var isEnabled: Bool = true
    private var eventQueue: [AnalyticsEvent] = []
    private var userId: String?
    private var userProperties: [String: String] = [:]
    
    /// Maximum number of events to queue.
    public var maxQueueSize: Int = 100
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Provider Management
    
    /// Registers an analytics provider.
    ///
    /// - Parameter provider: The provider to register.
    public func register(provider: AnalyticsProvider) {
        providers[provider.name] = provider
        
        // Set existing user ID and properties on new provider
        Task {
            if let userId = userId {
                await provider.setUserId(userId)
            }
            
            for (name, value) in userProperties {
                await provider.setUserProperty(name: name, value: value)
            }
        }
    }
    
    /// Unregisters an analytics provider.
    ///
    /// - Parameter providerName: The name of the provider to unregister.
    public func unregister(providerName: String) {
        providers.removeValue(forKey: providerName)
    }
    
    /// Returns all registered provider names.
    public var registeredProviders: [String] {
        Array(providers.keys)
    }
    
    // MARK: - Analytics Control
    
    /// Enables or disables analytics tracking.
    ///
    /// When disabled, events are not tracked and the queue is cleared.
    ///
    /// - Parameter enabled: Whether analytics should be enabled.
    public func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        
        if !enabled {
            // Clear queue when disabled for privacy
            eventQueue.removeAll()
        }
    }
    
    /// Returns whether analytics is currently enabled.
    public var analyticsEnabled: Bool {
        isEnabled
    }
    
    // MARK: - Event Tracking
    
    /// Tracks a custom event.
    ///
    /// - Parameters:
    ///   - name: The event name.
    ///   - parameters: Optional parameters.
    public func trackEvent(name: String, parameters: [String: String]? = nil) {
        let event = AnalyticsEvent(name: name, parameters: parameters)
        trackEvent(event)
    }
    
    /// Tracks an analytics event.
    ///
    /// - Parameter event: The event to track.
    public func trackEvent(_ event: AnalyticsEvent) {
        guard isEnabled else { return }
        
        // Forward to all providers
        for provider in providers.values {
            Task {
                await provider.trackEvent(event)
            }
        }
    }
    
    /// Tracks a screen view.
    ///
    /// - Parameters:
    ///   - name: The screen name.
    ///   - parameters: Optional parameters.
    public func trackScreen(name: String, parameters: [String: String]? = nil) {
        guard isEnabled else { return }
        
        for provider in providers.values {
            Task {
                var params: [String: Any] = [:]
                parameters?.forEach { params[$0.key] = $0.value }
                await provider.trackScreen(name: name, parameters: params)
            }
        }
    }
    
    // MARK: - User Management
    
    /// Sets the user identifier.
    ///
    /// - Parameter userId: The user ID, or nil to clear.
    public func setUserId(_ userId: String?) {
        self.userId = userId
        
        for provider in providers.values {
            Task {
                await provider.setUserId(userId)
            }
        }
    }
    
    /// Sets a user property.
    ///
    /// - Parameters:
    ///   - name: The property name.
    ///   - value: The property value.
    public func setUserProperty(name: String, value: String) {
        userProperties[name] = value
        
        for provider in providers.values {
            Task {
                await provider.setUserProperty(name: name, value: value)
            }
        }
    }
    
    /// Clears all user properties.
    public func clearUserProperties() {
        userProperties.removeAll()
    }
    
    // MARK: - Queue Management
    
    /// Adds an event to the queue.
    ///
    /// - Parameter event: The event to queue.
    private func queueEvent(_ event: AnalyticsEvent) {
        if eventQueue.count >= maxQueueSize {
            // Remove oldest event if queue is full
            eventQueue.removeFirst()
        }
        
        eventQueue.append(event)
    }
    
    /// Flushes all queued events to providers.
    public func flush() {
        guard isEnabled else { return }
        
        let events = eventQueue
        eventQueue.removeAll()
        
        for event in events {
            trackEvent(event)
        }
    }
    
    /// Returns the number of queued events.
    public var queuedEventCount: Int {
        eventQueue.count
    }
    
    /// Clears all queued events.
    public func clearQueue() {
        eventQueue.removeAll()
    }
}

// MARK: - Analytics Manager + Convenience

public extension AnalyticsManager {
    /// Tracks multiple events at once.
    ///
    /// - Parameter events: The events to track.
    func trackEvents(_ events: [AnalyticsEvent]) {
        for event in events {
            trackEvent(event)
        }
    }
}
