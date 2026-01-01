// AnalyticsManagerTests.swift
// AppFoundationTests

import XCTest
@testable import AppFoundation

final class AnalyticsManagerTests: XCTestCase {
    
    var manager: AnalyticsManager!
    var mockProvider: MockAnalyticsProvider!
    
    override func setUp() async throws {
        manager = AnalyticsManager.shared
        mockProvider = MockAnalyticsProvider()
        await manager.register(provider: mockProvider)
    }
    
    override func tearDown() async throws {
        await manager.unregister(providerName: "Mock")
        await manager.setEnabled(true)
        await manager.clearQueue()
        await mockProvider.reset()
    }
    
    func testProviderRegistration() async {
        let providers = await manager.registeredProviders
        XCTAssertTrue(providers.contains("Mock"))
    }
    
    func testProviderUnregistration() async {
        await manager.unregister(providerName: "Mock")
        let providers = await manager.registeredProviders
        XCTAssertFalse(providers.contains("Mock"))
    }
    
    func testTrackEvent() async {
        await manager.trackEvent(name: "test_event", parameters: ["key": "value"])
        
        // Give async tasks time to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        let events = await mockProvider.trackedEvents
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.name, "test_event")
        XCTAssertEqual(events.first?.parameters?["key"], "value")
    }
    
    func testTrackEventObject() async {
        let event = AnalyticsEvent.buttonTapped(id: "purchase")
        await manager.trackEvent(event)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        let events = await mockProvider.trackedEvents
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.name, "button_tap")
    }
    
    func testTrackScreen() async {
        await manager.trackScreen(name: "HomeScreen", parameters: ["source": "tab"])
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        let screens = await mockProvider.trackedScreens
        XCTAssertEqual(screens.count, 1)
        XCTAssertEqual(screens.first?.name, "HomeScreen")
    }
    
    func testSetUserId() async {
        await manager.setUserId("user123")
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        let userId = await mockProvider.userId
        XCTAssertEqual(userId, "user123")
    }
    
    func testSetUserProperty() async {
        await manager.setUserProperty(name: "plan", value: "premium")
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        let properties = await mockProvider.userProperties
        XCTAssertEqual(properties["plan"], "premium")
    }
    
    func testDisableAnalytics() async {
        await manager.setEnabled(false)
        await manager.trackEvent(name: "test_event")
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        let events = await mockProvider.trackedEvents
        XCTAssertEqual(events.count, 0)
    }
    
    func testEnableAnalytics() async {
        await manager.setEnabled(false)
        await manager.setEnabled(true)
        await manager.trackEvent(name: "test_event")
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        let events = await mockProvider.trackedEvents
        XCTAssertEqual(events.count, 1)
    }
    
    func testAnalyticsEnabledStatus() async {
        let initialStatus = await manager.analyticsEnabled
        XCTAssertTrue(initialStatus)
        
        await manager.setEnabled(false)
        let disabledStatus = await manager.analyticsEnabled
        XCTAssertFalse(disabledStatus)
    }
    
    func testMultipleProviders() async {
        let secondMock = MockAnalyticsProvider()
        await manager.register(provider: secondMock)
        
        await manager.trackEvent(name: "test_event")
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        let events1 = await mockProvider.trackedEvents
        let events2 = await secondMock.trackedEvents
        
        XCTAssertEqual(events1.count, 1)
        XCTAssertEqual(events2.count, 1)
        
        await manager.unregister(providerName: secondMock.name)
    }
    
    func testTrackMultipleEvents() async {
        let events = [
            AnalyticsEvent.appOpened,
            AnalyticsEvent.screenViewed(name: "Home"),
            AnalyticsEvent.buttonTapped(id: "login")
        ]
        
        await manager.trackEvents(events)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        let trackedEvents = await mockProvider.trackedEvents
        XCTAssertEqual(trackedEvents.count, 3)
    }
}
