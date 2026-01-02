import Foundation

/// A collection of application-wide constants used throughout the app and its extensions.
struct AppConstants {

  /// The App Group Identifier for sharing data between the main app and its extensions.
  /// This allows different parts of the application to access shared UserDefaults and files.
  static let appGroupIdentifier = "group.com.cbouvat.saracroche"

  /// The Call Directory Extension Identifier for the call blocking extension.
  /// This is used by CallKit to identify and manage the extension.
  static let callDirectoryExtensionIdentifier = "com.cbouvat.saracroche.blocker"

  /// The base URL for the API endpoints used in the application.
  static let apiBaseURL = "https://saracroche.org/api"

  /// The URL for reporting unwanted phone numbers to the server.
  static let apiReportURL = "\(apiBaseURL)/report"

  /// The base URL for accessing block lists.
  static let apiListsURL = "\(apiBaseURL)/lists"

  /// The URL for downloading the French ARCEP operators block list.
  static let apiFrenchListURL = "\(apiBaseURL)/lists/french-list-arcep-operators"

  /// The background service identifier for scheduled background updates.
  /// This is used by BGTaskScheduler to identify the background task.
  static let backgroundServiceIdentifier = "com.cbouvat.saracroche.background-update"

  /// The interval at which background updates should occur (4 hours in seconds).
  static let backgroundUpdateInterval: TimeInterval = 4 * 60 * 60

  /// The size of chunks used when processing phone numbers for efficiency.
  /// Larger chunks improve performance but use more memory.
  static let phoneNumberChunkSize = 10_000

  /// The name of the file used to store the downloaded blocklist data temporarily before processing.
  static let blockedListTmpFileName = "block-list.tmp.json"

  /// The interval at which the block list should be downloaded (12 hours in seconds).
  static let blockedListDownloadInterval: TimeInterval = 12 * 60 * 60
}
