// Date+Extensions.swift
// AppFoundation
//
// Extensions providing common date utilities for formatting, comparison, and manipulation.

import Foundation

// MARK: - Date Extensions

public extension Date {
    
    // MARK: - Formatting
    
    /// Formats the date using the specified format string.
    ///
    /// - Parameter format: The date format string (e.g., "yyyy-MM-dd", "HH:mm:ss").
    /// - Parameter locale: The locale to use. Defaults to current locale.
    /// - Parameter timeZone: The time zone to use. Defaults to current time zone.
    /// - Returns: A formatted string representation of the date.
    ///
    /// ```swift
    /// let date = Date()
    /// date.formatted(as: "yyyy-MM-dd")      // "2024-01-15"
    /// date.formatted(as: "MMMM d, yyyy")    // "January 15, 2024"
    /// date.formatted(as: "HH:mm:ss")        // "14:30:00"
    /// ```
    func formatted(
        as format: String,
        locale: Locale = .current,
        timeZone: TimeZone = .current
    ) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        formatter.timeZone = timeZone
        return formatter.string(from: self)
    }
    
    /// Returns a human-readable relative time string (e.g., "2 hours ago", "in 3 days").
    ///
    /// Uses `RelativeDateTimeFormatter` for localized relative time formatting.
    ///
    /// ```swift
    /// Date().addingTimeInterval(-3600).relativeTime  // "1 hour ago"
    /// Date().addingTimeInterval(86400).relativeTime  // "in 1 day"
    /// Date().relativeTime                             // "now"
    /// ```
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    /// Returns a relative time string with customizable style.
    ///
    /// - Parameter unitsStyle: The style for formatting units (.full, .short, .abbreviated, .spellOut).
    /// - Returns: A formatted relative time string.
    func relativeTime(unitsStyle: RelativeDateTimeFormatter.UnitsStyle) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = unitsStyle
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    // MARK: - Day Boundaries
    
    /// Returns the start of the day (00:00:00) for this date.
    ///
    /// ```swift
    /// let date = Date() // 2024-01-15 14:30:00
    /// date.startOfDay   // 2024-01-15 00:00:00
    /// ```
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// Returns the end of the day (23:59:59.999) for this date.
    ///
    /// ```swift
    /// let date = Date() // 2024-01-15 14:30:00
    /// date.endOfDay     // 2024-01-15 23:59:59
    /// ```
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    // MARK: - Date Components
    
    /// Returns the start of the week for this date.
    ///
    /// Uses the current calendar's definition of week start day.
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    /// Returns the start of the month for this date.
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    /// Returns the end of the month for this date.
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth) ?? self
    }
    
    // MARK: - Comparison
    
    /// Checks if the date is today.
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Checks if the date is yesterday.
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    /// Checks if the date is tomorrow.
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }
    
    /// Checks if the date is in the past.
    var isPast: Bool {
        self < Date()
    }
    
    /// Checks if the date is in the future.
    var isFuture: Bool {
        self > Date()
    }
    
    /// Checks if the date is in the same day as another date.
    ///
    /// - Parameter date: The date to compare with.
    /// - Returns: `true` if both dates are on the same calendar day.
    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    // MARK: - Date Arithmetic
    
    /// Adds the specified number of days to the date.
    ///
    /// - Parameter days: The number of days to add (can be negative).
    /// - Returns: A new date with the days added.
    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    /// Adds the specified number of hours to the date.
    ///
    /// - Parameter hours: The number of hours to add (can be negative).
    /// - Returns: A new date with the hours added.
    func adding(hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: self) ?? self
    }
    
    /// Adds the specified number of minutes to the date.
    ///
    /// - Parameter minutes: The number of minutes to add (can be negative).
    /// - Returns: A new date with the minutes added.
    func adding(minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: minutes, to: self) ?? self
    }
    
    /// Returns the number of days between this date and another date.
    ///
    /// - Parameter date: The date to compare with.
    /// - Returns: The number of calendar days between the dates.
    func days(from date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
}

// MARK: - Common Date Formats

public enum DateFormat: String {
    /// ISO 8601 format: "2024-01-15T14:30:00Z"
    case iso8601 = "yyyy-MM-dd'T'HH:mm:ssZ"
    
    /// Short date: "01/15/24"
    case shortDate = "MM/dd/yy"
    
    /// Medium date: "Jan 15, 2024"
    case mediumDate = "MMM d, yyyy"
    
    /// Long date: "January 15, 2024"
    case longDate = "MMMM d, yyyy"
    
    /// Time only: "2:30 PM"
    case time = "h:mm a"
    
    /// Time with seconds: "2:30:00 PM"
    case timeWithSeconds = "h:mm:ss a"
    
    /// 24-hour time: "14:30"
    case time24Hour = "HH:mm"
    
    /// Date and time: "Jan 15, 2024 at 2:30 PM"
    case dateTime = "MMM d, yyyy 'at' h:mm a"
    
    /// Year and month: "January 2024"
    case yearMonth = "MMMM yyyy"
}

public extension Date {
    /// Formats the date using a predefined format.
    ///
    /// - Parameter format: The predefined date format to use.
    /// - Returns: A formatted string representation of the date.
    func formatted(using format: DateFormat) -> String {
        formatted(as: format.rawValue)
    }
}
