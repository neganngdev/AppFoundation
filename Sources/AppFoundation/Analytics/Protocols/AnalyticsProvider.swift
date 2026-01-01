// AnalyticsProvider.swift
// AppFoundation
//
// Protocol for analytics providers.

import Foundation

// MARK: - Analytics Provider

/// Protocol for analytics providers.
///
/// Conform to this protocol to create custom analytics providers
/// (Firebase, Mixpanel, TelemetryDeck, etc.).
///
/// ```swift
/// actor FirebaseAnalyticsProvider: AnalyticsProvider {
///     var name: String { "Firebase" }
///     
///     func trackEvent(_ event: AnalyticsEvent) async {
///         Analytics.logEvent(event.name, parameters: event.parameters)
///     }
/// }
/// ```
public protocol AnalyticsProvider: Sendable {
    /// The name of this analytics provider.
    var name: String { get }
    
    /// Tracks a custom event.
    ///
    /// - Parameter event: The event to track.
    func trackEvent(_ event: AnalyticsEvent) async
    
    /// Tracks a screen view.
    ///
    /// - Parameters:
    ///   - name: The screen name.
    ///   - parameters: Optional parameters.
    func trackScreen(name: String, parameters: [String: Any]?) async
    
    /// Sets a user property.
    ///
    /// - Parameters:
    ///   - name: The property name.
    ///   - value: The property value.
    func setUserProperty(name: String, value: String) async
    
    /// Sets the user identifier.
    ///
    /// - Parameter userId: The user ID, or nil to clear.
    func setUserId(_ userId: String?) async
}

// MARK: - Analytics Provider + Default Implementation

public extension AnalyticsProvider {
    /// Default implementation for screen tracking.
    func trackScreen(name: String, parameters: [String: Any]?) async {
        var params: [String: String] = [:]
        
        // Convert Any to String
        parameters?.forEach { key, value in
            params[key] = "\(value)"
        }
        params["screen_name"] = name
        
        let event = AnalyticsEvent(
            name: "screen_view",
            parameters: params
        )
        
        await trackEvent(event)
    }
}
