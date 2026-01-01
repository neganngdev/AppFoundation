// AnalyticsProviderTests.swift
// AppFoundationTests

import XCTest
@testable import AppFoundation

final class AnalyticsProviderTests: XCTestCase {
    
    func testMockProviderTracksEvents() async {
        let provider = MockAnalyticsProvider()
        let event = AnalyticsEvent(name: "test", parameters: ["key": "value"])
        
        await provider.trackEvent(event)
        
        let events = await provider.trackedEvents
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.name, "test")
    }
    
    func testMockProviderTracksScreens() async {
        let provider = MockAnalyticsProvider()
        
        await provider.trackScreen(name: "HomeScreen", parameters: ["source": "tab"])
        
        let screens = await provider.trackedScreens
        XCTAssertEqual(screens.count, 1)
        XCTAssertEqual(screens.first?.name, "HomeScreen")
    }
    
    func testMockProviderSetsUserId() async {
        let provider = MockAnalyticsProvider()
        
        await provider.setUserId("user123")
        
        let userId = await provider.userId
        XCTAssertEqual(userId, "user123")
    }
    
    func testMockProviderSetsUserProperties() async {
        let provider = MockAnalyticsProvider()
        
        await provider.setUserProperty(name: "plan", value: "premium")
        await provider.setUserProperty(name: "country", value: "US")
        
        let properties = await provider.userProperties
        XCTAssertEqual(properties["plan"], "premium")
        XCTAssertEqual(properties["country"], "US")
    }
    
    func testMockProviderReset() async {
        let provider = MockAnalyticsProvider()
        
        await provider.trackEvent(AnalyticsEvent.appOpened)
        await provider.setUserId("user123")
        await provider.setUserProperty(name: "plan", value: "premium")
        
        await provider.reset()
        
        let events = await provider.trackedEvents
        let userId = await provider.userId
        let properties = await provider.userProperties
        
        XCTAssertEqual(events.count, 0)
        XCTAssertNil(userId)
        XCTAssertEqual(properties.count, 0)
    }
    
    func testMockProviderDidTrackEvent() async {
        let provider = MockAnalyticsProvider()
        
        await provider.trackEvent(AnalyticsEvent.appOpened)
        
        let didTrack = await provider.didTrackEvent(named: "app_opened")
        let didNotTrack = await provider.didTrackEvent(named: "other_event")
        
        XCTAssertTrue(didTrack)
        XCTAssertFalse(didNotTrack)
    }
    
    func testMockProviderEventCount() async {
        let provider = MockAnalyticsProvider()
        
        await provider.trackEvent(AnalyticsEvent.appOpened)
        await provider.trackEvent(AnalyticsEvent.appOpened)
        await provider.trackEvent(AnalyticsEvent.buttonTapped(id: "test"))
        
        let openCount = await provider.eventCount(named: "app_opened")
        let tapCount = await provider.eventCount(named: "button_tap")
        
        XCTAssertEqual(openCount, 2)
        XCTAssertEqual(tapCount, 1)
    }
    
    func testMockProviderDidTrackScreen() async {
        let provider = MockAnalyticsProvider()
        
        await provider.trackScreen(name: "HomeScreen", parameters: nil)
        
        let didTrack = await provider.didTrackScreen(named: "HomeScreen")
        let didNotTrack = await provider.didTrackScreen(named: "ProfileScreen")
        
        XCTAssertTrue(didTrack)
        XCTAssertFalse(didNotTrack)
    }
    
    func testConsoleProviderName() async {
        let provider = ConsoleAnalyticsProvider()
        let name = await provider.name
        XCTAssertEqual(name, "Console")
    }
}
