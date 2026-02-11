import OSLog

/// Centralized logging system for the application
enum Logger {
  /// Application subsystem identifier
  private static let subsystem = "com.saracroche"

  /// Available log categories
  enum Category: String {
    case patternService = "PatternService"
    case blockerService = "BlockerService"
    case listService = "ListService"
    case backgroundService = "BackgroundService"
    case callDirectoryService = "CallDirectoryService"
    case blockerViewModel = "BlockerViewModel"
    case numbersViewModel = "NumbersViewModel"
    case callDirectoryHandler = "CallDirectoryHandler"
    case messageFilterExtension = "MessageFilterExtension"
    case notificationService = "NotificationService"
  }

  /// Logs a message with the specified category and level
  /// - Parameters:
  ///   - message: The message to log
  ///   - category: The log category (optional)
  ///   - type: The log level (default: .info)
  ///   - error: Optional error to include in the log
  static func log(
    _ message: String,
    category: Category? = nil,
    type: OSLogType = .info,
    error: Error? = nil
  ) {
    let categoryName = category?.rawValue ?? "general"
    let logger = OSLog(subsystem: subsystem, category: categoryName)

    if let error = error {
      os_log("%{public}@", log: logger, type: type, message)
      os_log("Error: %{public}@", log: logger, type: .error, error.localizedDescription)
    } else {
      os_log("%{public}@", log: logger, type: type, message)
    }
  }

  /// Logs an error message
  /// - Parameters:
  ///   - message: The error message
  ///   - category: The log category
  ///   - error: The error to log
  static func error(
    _ message: String,
    category: Category,
    error: Error
  ) {
    log(message, category: category, type: .error, error: error)
  }

  /// Logs a debug message
  /// - Parameters:
  ///   - message: The debug message
  ///   - category: The log category
  static func debug(
    _ message: String,
    category: Category
  ) {
    log(message, category: category, type: .debug)
  }

  /// Logs an info message
  /// - Parameters:
  ///   - message: The info message
  ///   - category: The log category
  static func info(
    _ message: String,
    category: Category
  ) {
    log(message, category: category, type: .info)
  }

  /// Logs a fault message
  /// - Parameters:
  ///   - message: The fault message
  ///   - category: The log category
  static func fault(
    _ message: String,
    category: Category
  ) {
    log(message, category: category, type: .fault)
  }
}
