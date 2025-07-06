import Foundation
import os.log

struct Logger {

  private static let subsystem =
    Bundle.main.bundleIdentifier ?? "com.cbouvat.saracroche"

  static let callDirectory = OSLog(
    subsystem: subsystem,
    category: "CallDirectory"
  )
  static let phoneNumber = OSLog(subsystem: subsystem, category: "PhoneNumber")
  static let userDefaults = OSLog(
    subsystem: subsystem,
    category: "UserDefaults"
  )
  static let ui = OSLog(subsystem: subsystem, category: "UI")

  static func log(
    _ message: String,
    category: OSLog = .default,
    type: OSLogType = .default
  ) {
    os_log("%@", log: category, type: type, message)
  }

  static func error(_ message: String, category: OSLog = .default) {
    os_log("%@", log: category, type: .error, message)
  }

  static func debug(_ message: String, category: OSLog = .default) {
    os_log("%@", log: category, type: .debug, message)
  }

  static func info(_ message: String, category: OSLog = .default) {
    os_log("%@", log: category, type: .info, message)
  }
}
