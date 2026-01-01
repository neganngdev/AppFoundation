// Logger.swift
// AppFoundation
//
// A flexible logging system with support for multiple destinations and log levels.

import Foundation
import os

// MARK: - Log Level

/// Represents the severity level of a log message.
public enum LogLevel: Int, Comparable, Sendable {
    /// Debug information for development purposes.
    case debug = 0
    /// General informational messages.
    case info = 1
    /// Warning messages indicating potential issues.
    case warning = 2
    /// Error messages indicating failures.
    case error = 3
    
    /// A human-readable emoji representation of the log level.
    public var emoji: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
    
    /// A human-readable name for the log level.
    public var name: String {
        switch self {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warning: return "WARNING"
        case .error: return "ERROR"
        }
    }
    
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Log Message

/// A structured log message containing all relevant metadata.
public struct LogMessage: Sendable {
    /// The severity level of the log message.
    public let level: LogLevel
    /// The main content of the log message.
    public let message: String
    /// The file where the log was called.
    public let file: String
    /// The function where the log was called.
    public let function: String
    /// The line number where the log was called.
    public let line: Int
    /// The timestamp when the log was created.
    public let timestamp: Date
    /// Optional category for organizing logs.
    public let category: String?
    
    /// The filename without the full path.
    public var fileName: String {
        (file as NSString).lastPathComponent
    }
    
    /// A formatted string representation of the log message.
    public var formatted: String {
        let categoryPrefix = category.map { "[\($0)] " } ?? ""
        return "\(level.emoji) \(categoryPrefix)\(message) [\(fileName):\(line) \(function)]"
    }
    
    public init(
        level: LogLevel,
        message: String,
        file: String,
        function: String,
        line: Int,
        timestamp: Date = Date(),
        category: String? = nil
    ) {
        self.level = level
        self.message = message
        self.file = file
        self.function = function
        self.line = line
        self.timestamp = timestamp
        self.category = category
    }
}

// MARK: - Log Destination Protocol

/// A protocol that defines a destination for log messages.
///
/// Implement this protocol to create custom log destinations such as
/// file loggers, remote logging services, or analytics systems.
public protocol LogDestination: Sendable {
    /// The minimum log level this destination should receive.
    var minimumLevel: LogLevel { get }
    
    /// Writes a log message to the destination.
    ///
    /// - Parameter message: The log message to write.
    func write(_ message: LogMessage)
}

// MARK: - Logger Protocol

/// A protocol defining the interface for a logging system.
public protocol Logging: Sendable {
    /// The minimum log level to process.
    var minimumLevel: LogLevel { get set }
    
    /// Logs a debug message.
    func debug(
        _ message: @autoclosure () -> String,
        file: String,
        function: String,
        line: Int
    )
    
    /// Logs an informational message.
    func info(
        _ message: @autoclosure () -> String,
        file: String,
        function: String,
        line: Int
    )
    
    /// Logs a warning message.
    func warning(
        _ message: @autoclosure () -> String,
        file: String,
        function: String,
        line: Int
    )
    
    /// Logs an error message.
    func error(
        _ message: @autoclosure () -> String,
        file: String,
        function: String,
        line: Int
    )
}

// MARK: - Console Destination

/// A log destination that writes to the console using os.Logger.
public final class ConsoleDestination: LogDestination, @unchecked Sendable {
    public let minimumLevel: LogLevel
    private let osLogger: os.Logger
    
    /// Creates a new console destination.
    ///
    /// - Parameters:
    ///   - minimumLevel: The minimum log level to output.
    ///   - subsystem: The subsystem identifier (typically your bundle ID).
    ///   - category: The category for the logger.
    public init(
        minimumLevel: LogLevel = .debug,
        subsystem: String = Bundle.main.bundleIdentifier ?? "AppFoundation",
        category: String = "Default"
    ) {
        self.minimumLevel = minimumLevel
        self.osLogger = os.Logger(subsystem: subsystem, category: category)
    }
    
    public func write(_ message: LogMessage) {
        guard message.level >= minimumLevel else { return }
        
        let formattedMessage = message.formatted
        
        switch message.level {
        case .debug:
            osLogger.debug("\(formattedMessage, privacy: .public)")
        case .info:
            osLogger.info("\(formattedMessage, privacy: .public)")
        case .warning:
            osLogger.warning("\(formattedMessage, privacy: .public)")
        case .error:
            osLogger.error("\(formattedMessage, privacy: .public)")
        }
    }
}

// MARK: - Print Destination

/// A simple log destination that prints to standard output.
///
/// Useful for debugging and testing purposes.
public final class PrintDestination: LogDestination, @unchecked Sendable {
    public let minimumLevel: LogLevel
    private let lock = NSLock()
    
    public init(minimumLevel: LogLevel = .debug) {
        self.minimumLevel = minimumLevel
    }
    
    public func write(_ message: LogMessage) {
        guard message.level >= minimumLevel else { return }
        
        lock.lock()
        defer { lock.unlock() }
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let timestamp = dateFormatter.string(from: message.timestamp)
        
        print("[\(timestamp)] \(message.formatted)")
    }
}

// MARK: - Logger Implementation

/// A thread-safe logger that supports multiple destinations.
///
/// ```swift
/// // Create a logger with default console destination
/// let logger = Logger()
///
/// // Add additional destinations
/// logger.addDestination(PrintDestination(minimumLevel: .warning))
///
/// // Log messages
/// logger.debug("Starting operation")
/// logger.info("User logged in")
/// logger.warning("Memory usage is high")
/// logger.error("Failed to save data")
/// ```
public final class Logger: Logging, @unchecked Sendable {
    /// The shared default logger instance.
    public static let shared = Logger()
    
    /// The minimum log level to process.
    public var minimumLevel: LogLevel {
        get { _minimumLevel }
        set { _minimumLevel = newValue }
    }
    
    private var _minimumLevel: LogLevel
    private var destinations: [LogDestination]
    private let lock = NSLock()
    private let category: String?
    
    /// Creates a new logger.
    ///
    /// - Parameters:
    ///   - minimumLevel: The minimum log level to process.
    ///   - destinations: The initial log destinations.
    ///   - category: An optional category for all log messages.
    public init(
        minimumLevel: LogLevel = .debug,
        destinations: [LogDestination] = [ConsoleDestination()],
        category: String? = nil
    ) {
        self._minimumLevel = minimumLevel
        self.destinations = destinations
        self.category = category
    }
    
    // MARK: - Destination Management
    
    /// Adds a new destination to the logger.
    ///
    /// - Parameter destination: The destination to add.
    public func addDestination(_ destination: LogDestination) {
        lock.lock()
        defer { lock.unlock() }
        destinations.append(destination)
    }
    
    /// Removes all destinations from the logger.
    public func removeAllDestinations() {
        lock.lock()
        defer { lock.unlock() }
        destinations.removeAll()
    }
    
    /// Returns the current number of destinations.
    public var destinationCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return destinations.count
    }
    
    // MARK: - Logging Methods
    
    /// Logs a debug message.
    ///
    /// - Parameters:
    ///   - message: The message to log (evaluated lazily).
    ///   - file: The file where the log is called (auto-filled).
    ///   - function: The function where the log is called (auto-filled).
    ///   - line: The line where the log is called (auto-filled).
    public func debug(
        _ message: @autoclosure () -> String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .debug, message: message(), file: file, function: function, line: line)
    }
    
    /// Logs an informational message.
    ///
    /// - Parameters:
    ///   - message: The message to log (evaluated lazily).
    ///   - file: The file where the log is called (auto-filled).
    ///   - function: The function where the log is called (auto-filled).
    ///   - line: The line where the log is called (auto-filled).
    public func info(
        _ message: @autoclosure () -> String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .info, message: message(), file: file, function: function, line: line)
    }
    
    /// Logs a warning message.
    ///
    /// - Parameters:
    ///   - message: The message to log (evaluated lazily).
    ///   - file: The file where the log is called (auto-filled).
    ///   - function: The function where the log is called (auto-filled).
    ///   - line: The line where the log is called (auto-filled).
    public func warning(
        _ message: @autoclosure () -> String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .warning, message: message(), file: file, function: function, line: line)
    }
    
    /// Logs an error message.
    ///
    /// - Parameters:
    ///   - message: The message to log (evaluated lazily).
    ///   - file: The file where the log is called (auto-filled).
    ///   - function: The function where the log is called (auto-filled).
    ///   - line: The line where the log is called (auto-filled).
    public func error(
        _ message: @autoclosure () -> String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .error, message: message(), file: file, function: function, line: line)
    }
    
    // MARK: - Private
    
    private func log(
        level: LogLevel,
        message: String,
        file: String,
        function: String,
        line: Int
    ) {
        guard level >= minimumLevel else { return }
        
        let logMessage = LogMessage(
            level: level,
            message: message,
            file: file,
            function: function,
            line: line,
            category: category
        )
        
        lock.lock()
        let currentDestinations = destinations
        lock.unlock()
        
        for destination in currentDestinations {
            destination.write(logMessage)
        }
    }
}

// MARK: - Convenience Global Functions

/// Logs a debug message using the shared logger.
public func logDebug(
    _ message: @autoclosure () -> String,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    Logger.shared.debug(message(), file: file, function: function, line: line)
}

/// Logs an informational message using the shared logger.
public func logInfo(
    _ message: @autoclosure () -> String,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    Logger.shared.info(message(), file: file, function: function, line: line)
}

/// Logs a warning message using the shared logger.
public func logWarning(
    _ message: @autoclosure () -> String,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    Logger.shared.warning(message(), file: file, function: function, line: line)
}

/// Logs an error message using the shared logger.
public func logError(
    _ message: @autoclosure () -> String,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    Logger.shared.error(message(), file: file, function: function, line: line)
}
