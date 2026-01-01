// AnalyticsEvent.swift
// AppFoundation
//
// Event model for analytics tracking.

import Foundation

// MARK: - Analytics Event

/// Represents an analytics event.
///
/// ```swift
/// let event = AnalyticsEvent(name: "button_tapped", parameters: ["button_id": "purchase"])
/// await AnalyticsManager.shared.trackEvent(event)
/// ```
public struct AnalyticsEvent: Sendable, Equatable {
    /// The event name.
    public let name: String
    
    /// Optional event parameters.
    public let parameters: [String: String]?
    
    /// The timestamp when the event was created.
    public let timestamp: Date
    
    /// Creates a new analytics event.
    ///
    /// - Parameters:
    ///   - name: The event name.
    ///   - parameters: Optional parameters.
    ///   - timestamp: The event timestamp (defaults to now).
    public init(
        name: String,
        parameters: [String: String]? = nil,
        timestamp: Date = Date()
    ) {
        self.name = name
        self.parameters = parameters
        self.timestamp = timestamp
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: AnalyticsEvent, rhs: AnalyticsEvent) -> Bool {
        lhs.name == rhs.name &&
        lhs.parameters == rhs.parameters
    }
}

// MARK: - Analytics Event + Predefined Events

public extension AnalyticsEvent {
    /// Creates a custom event.
    ///
    /// - Parameters:
    ///   - name: The event name.
    ///   - parameters: Optional parameters.
    /// - Returns: An analytics event.
    static func custom(name: String, parameters: [String: String]? = nil) -> AnalyticsEvent {
        AnalyticsEvent(name: name, parameters: parameters)
    }
    
    /// App opened event.
    static var appOpened: AnalyticsEvent {
        AnalyticsEvent(name: "app_opened")
    }
    
    /// App backgrounded event.
    static var appBackgrounded: AnalyticsEvent {
        AnalyticsEvent(name: "app_backgrounded")
    }
    
    /// Screen viewed event.
    ///
    /// - Parameter name: The screen name.
    /// - Returns: An analytics event.
    static func screenViewed(name: String) -> AnalyticsEvent {
        AnalyticsEvent(name: "screen_view", parameters: ["screen_name": name])
    }
    
    /// Button tapped event.
    ///
    /// - Parameter id: The button identifier.
    /// - Returns: An analytics event.
    static func buttonTapped(id: String) -> AnalyticsEvent {
        AnalyticsEvent(name: "button_tap", parameters: ["button_id": id])
    }
    
    /// Feature used event.
    ///
    /// - Parameter name: The feature name.
    /// - Returns: An analytics event.
    static func featureUsed(name: String) -> AnalyticsEvent {
        AnalyticsEvent(name: "feature_used", parameters: ["feature_name": name])
    }
    
    /// Error occurred event.
    ///
    /// - Parameters:
    ///   - error: The error description.
    ///   - code: Optional error code.
    /// - Returns: An analytics event.
    static func errorOccurred(error: String, code: String? = nil) -> AnalyticsEvent {
        var params: [String: String] = ["error": error]
        if let code = code {
            params["error_code"] = code
        }
        return AnalyticsEvent(name: "error_occurred", parameters: params)
    }
    
    /// Purchase completed event.
    ///
    /// - Parameters:
    ///   - productId: The product identifier.
    ///   - amount: The purchase amount.
    ///   - currency: The currency code (defaults to "USD").
    /// - Returns: An analytics event.
    static func purchaseCompleted(
        productId: String,
        amount: String,
        currency: String = "USD"
    ) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "purchase_completed",
            parameters: [
                "product_id": productId,
                "amount": amount,
                "currency": currency
            ]
        )
    }
    
    /// Search performed event.
    ///
    /// - Parameter query: The search query.
    /// - Returns: An analytics event.
    static func searchPerformed(query: String) -> AnalyticsEvent {
        AnalyticsEvent(name: "search", parameters: ["query": query])
    }
    
    /// Share event.
    ///
    /// - Parameters:
    ///   - contentType: The type of content shared.
    ///   - method: The sharing method.
    /// - Returns: An analytics event.
    static func shared(contentType: String, method: String) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "share",
            parameters: [
                "content_type": contentType,
                "method": method
            ]
        )
    }
}
