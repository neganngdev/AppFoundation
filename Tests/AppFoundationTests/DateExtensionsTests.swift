// DateExtensionsTests.swift
// AppFoundationTests

import XCTest
@testable import AppFoundation

final class DateExtensionsTests: XCTestCase {
    
    // MARK: - Test Setup
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private func createDate(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        return calendar.date(from: components)!
    }
    
    // MARK: - formatted(as:) Tests
    
    func testFormatted_yearMonthDay_correctFormat() {
        let date = createDate(year: 2024, month: 1, day: 15)
        XCTAssertEqual(date.formatted(as: "yyyy-MM-dd"), "2024-01-15")
    }
    
    func testFormatted_monthDayYear_correctFormat() {
        let date = createDate(year: 2024, month: 12, day: 25)
        XCTAssertEqual(date.formatted(as: "MM/dd/yyyy"), "12/25/2024")
    }
    
    func testFormatted_withTime_correctFormat() {
        let date = createDate(year: 2024, month: 1, day: 15, hour: 14, minute: 30, second: 45)
        XCTAssertEqual(date.formatted(as: "HH:mm:ss"), "14:30:45")
    }
    
    // MARK: - DateFormat Enum Tests
    
    func testFormattedUsingEnum_shortDate_correctFormat() {
        let date = createDate(year: 2024, month: 1, day: 15)
        XCTAssertEqual(date.formatted(using: .shortDate), "01/15/24")
    }
    
    func testFormattedUsingEnum_time24Hour_correctFormat() {
        let date = createDate(year: 2024, month: 1, day: 15, hour: 14, minute: 30)
        XCTAssertEqual(date.formatted(using: .time24Hour), "14:30")
    }
    
    // MARK: - startOfDay Tests
    
    func testStartOfDay_returnsCorrectTime() {
        let date = createDate(year: 2024, month: 1, day: 15, hour: 14, minute: 30, second: 45)
        let start = date.startOfDay
        
        let components = calendar.dateComponents([.hour, .minute, .second], from: start)
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }
    
    func testStartOfDay_sameDay() {
        let date = createDate(year: 2024, month: 1, day: 15, hour: 14, minute: 30)
        let start = date.startOfDay
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let startComponents = calendar.dateComponents([.year, .month, .day], from: start)
        
        XCTAssertEqual(dateComponents.year, startComponents.year)
        XCTAssertEqual(dateComponents.month, startComponents.month)
        XCTAssertEqual(dateComponents.day, startComponents.day)
    }
    
    // MARK: - endOfDay Tests
    
    func testEndOfDay_returnsEndOfSameDay() {
        let date = createDate(year: 2024, month: 1, day: 15, hour: 10)
        let end = date.endOfDay
        
        let components = calendar.dateComponents([.hour, .minute, .second], from: end)
        XCTAssertEqual(components.hour, 23)
        XCTAssertEqual(components.minute, 59)
        XCTAssertEqual(components.second, 59)
    }
    
    func testEndOfDay_sameDay() {
        let date = createDate(year: 2024, month: 1, day: 15, hour: 10)
        let end = date.endOfDay
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let endComponents = calendar.dateComponents([.year, .month, .day], from: end)
        
        XCTAssertEqual(dateComponents.year, endComponents.year)
        XCTAssertEqual(dateComponents.month, endComponents.month)
        XCTAssertEqual(dateComponents.day, endComponents.day)
    }
    
    // MARK: - Date Comparison Tests
    
    func testIsToday_currentDate_returnsTrue() {
        let now = Date()
        XCTAssertTrue(now.isToday)
    }
    
    func testIsToday_yesterday_returnsFalse() {
        let yesterday = Date().adding(days: -1)
        XCTAssertFalse(yesterday.isToday)
    }
    
    func testIsYesterday_yesterday_returnsTrue() {
        let yesterday = Date().adding(days: -1)
        XCTAssertTrue(yesterday.isYesterday)
    }
    
    func testIsTomorrow_tomorrow_returnsTrue() {
        let tomorrow = Date().adding(days: 1)
        XCTAssertTrue(tomorrow.isTomorrow)
    }
    
    func testIsPast_pastDate_returnsTrue() {
        let past = Date().addingTimeInterval(-3600) // 1 hour ago
        XCTAssertTrue(past.isPast)
    }
    
    func testIsFuture_futureDate_returnsTrue() {
        let future = Date().addingTimeInterval(3600) // 1 hour from now
        XCTAssertTrue(future.isFuture)
    }
    
    func testIsSameDay_sameDayDifferentTimes_returnsTrue() {
        let date1 = createDate(year: 2024, month: 1, day: 15, hour: 10)
        let date2 = createDate(year: 2024, month: 1, day: 15, hour: 20)
        XCTAssertTrue(date1.isSameDay(as: date2))
    }
    
    func testIsSameDay_differentDays_returnsFalse() {
        let date1 = createDate(year: 2024, month: 1, day: 15)
        let date2 = createDate(year: 2024, month: 1, day: 16)
        XCTAssertFalse(date1.isSameDay(as: date2))
    }
    
    // MARK: - Date Arithmetic Tests
    
    func testAddingDays_positive_movesForward() {
        let date = createDate(year: 2024, month: 1, day: 15)
        let result = date.adding(days: 5)
        
        let components = calendar.dateComponents([.year, .month, .day], from: result)
        XCTAssertEqual(components.day, 20)
    }
    
    func testAddingDays_negative_movesBackward() {
        let date = createDate(year: 2024, month: 1, day: 15)
        let result = date.adding(days: -5)
        
        let components = calendar.dateComponents([.year, .month, .day], from: result)
        XCTAssertEqual(components.day, 10)
    }
    
    func testAddingHours_correctResult() {
        let date = createDate(year: 2024, month: 1, day: 15, hour: 10)
        let result = date.adding(hours: 5)
        
        let components = calendar.dateComponents([.hour], from: result)
        XCTAssertEqual(components.hour, 15)
    }
    
    func testAddingMinutes_correctResult() {
        let date = createDate(year: 2024, month: 1, day: 15, hour: 10, minute: 30)
        let result = date.adding(minutes: 15)
        
        let components = calendar.dateComponents([.minute], from: result)
        XCTAssertEqual(components.minute, 45)
    }
    
    func testDaysFrom_correctDifference() {
        let date1 = createDate(year: 2024, month: 1, day: 15)
        let date2 = createDate(year: 2024, month: 1, day: 10)
        
        XCTAssertEqual(date1.days(from: date2), 5)
        XCTAssertEqual(date2.days(from: date1), -5)
    }
    
    // MARK: - relativeTime Tests
    
    func testRelativeTime_recentPast_containsAgo() {
        let past = Date().addingTimeInterval(-3600) // 1 hour ago
        let relative = past.relativeTime
        XCTAssertTrue(relative.contains("ago") || relative.contains("hour"))
    }
    
    func testRelativeTime_nearFuture_containsIn() {
        let future = Date().addingTimeInterval(3600) // 1 hour from now
        let relative = future.relativeTime
        XCTAssertTrue(relative.contains("in") || relative.contains("hour"))
    }
}
