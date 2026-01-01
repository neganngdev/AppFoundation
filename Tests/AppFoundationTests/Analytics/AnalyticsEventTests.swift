// AnalyticsEventTests.swift
// AppFoundationTests

import XCTest
@testable import AppFoundation

final class AnalyticsEventTests: XCTestCase {
    
    func testEventCreation() {
        let event = AnalyticsEvent(name: "test_event", parameters: ["key": "value"])
        
        XCTAssertEqual(event.name, "test_event")
        XCTAssertEqual(event.parameters?["key"], "value")
        XCTAssertNotNil(event.timestamp)
    }
    
    func testEventWithoutParameters() {
        let event = AnalyticsEvent(name: "simple_event")
        
        XCTAssertEqual(event.name, "simple_event")
        XCTAssertNil(event.parameters)
    }
    
    func testCustomEvent() {
        let event = AnalyticsEvent.custom(name: "custom", parameters: ["foo": "bar"])
        
        XCTAssertEqual(event.name, "custom")
        XCTAssertEqual(event.parameters?["foo"], "bar")
    }
    
    func testAppOpenedEvent() {
        let event = AnalyticsEvent.appOpened
        
        XCTAssertEqual(event.name, "app_opened")
        XCTAssertNil(event.parameters)
    }
    
    func testScreenViewedEvent() {
        let event = AnalyticsEvent.screenViewed(name: "HomeScreen")
        
        XCTAssertEqual(event.name, "screen_view")
        XCTAssertEqual(event.parameters?["screen_name"], "HomeScreen")
    }
    
    func testButtonTappedEvent() {
        let event = AnalyticsEvent.buttonTapped(id: "purchase_button")
        
        XCTAssertEqual(event.name, "button_tap")
        XCTAssertEqual(event.parameters?["button_id"], "purchase_button")
    }
    
    func testFeatureUsedEvent() {
        let event = AnalyticsEvent.featureUsed(name: "dark_mode")
        
        XCTAssertEqual(event.name, "feature_used")
        XCTAssertEqual(event.parameters?["feature_name"], "dark_mode")
    }
    
    func testErrorOccurredEvent() {
        let event = AnalyticsEvent.errorOccurred(error: "Network error", code: "500")
        
        XCTAssertEqual(event.name, "error_occurred")
        XCTAssertEqual(event.parameters?["error"], "Network error")
        XCTAssertEqual(event.parameters?["error_code"], "500")
    }
    
    func testPurchaseCompletedEvent() {
        let event = AnalyticsEvent.purchaseCompleted(
            productId: "premium_monthly",
            amount: "9.99",
            currency: "USD"
        )
        
        XCTAssertEqual(event.name, "purchase_completed")
        XCTAssertEqual(event.parameters?["product_id"], "premium_monthly")
        XCTAssertEqual(event.parameters?["amount"], "9.99")
        XCTAssertEqual(event.parameters?["currency"], "USD")
    }
    
    func testSearchPerformedEvent() {
        let event = AnalyticsEvent.searchPerformed(query: "swift tutorial")
        
        XCTAssertEqual(event.name, "search")
        XCTAssertEqual(event.parameters?["query"], "swift tutorial")
    }
    
    func testSharedEvent() {
        let event = AnalyticsEvent.shared(contentType: "article", method: "twitter")
        
        XCTAssertEqual(event.name, "share")
        XCTAssertEqual(event.parameters?["content_type"], "article")
        XCTAssertEqual(event.parameters?["method"], "twitter")
    }
    
    func testEventEquality() {
        let event1 = AnalyticsEvent(name: "test", parameters: ["key": "value"])
        let event2 = AnalyticsEvent(name: "test", parameters: ["key": "value"])
        let event3 = AnalyticsEvent(name: "different", parameters: ["key": "value"])
        
        XCTAssertEqual(event1, event2)
        XCTAssertNotEqual(event1, event3)
    }
}
