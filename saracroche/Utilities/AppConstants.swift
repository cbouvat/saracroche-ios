import Foundation

struct AppConstants {

  /// The App Group Identifier for sharing data between the main app and its extensions.
  static let appGroupIdentifier = "group.com.cbouvat.saracroche"

  /// The Call Directory Extension Identifier for the call blocking extension.
  static let callDirectoryExtensionIdentifier = "com.cbouvat.saracroche.blocker"

  /// The base URL for the API endpoints used in the application.
  static let apiBaseURL = "https://saracroche.org/api"
  static let apiReportURL = "\(apiBaseURL)/report"
  static let apiListsURL = "\(apiBaseURL)/lists"
  static let apiFrenchListURL = "\(apiBaseURL)/lists/french-list-arcep-operators"

  /// The background service identifier for scheduled background updates.
  static let backgroundServiceIdentifier = "com.cbouvat.saracroche.background-update"
  static let backgroundUpdateInterval: TimeInterval = 4 * 60 * 60  // 4 hours in seconds

  /// The size of the size of chunks used when processing phone numbers
  static let phoneNumberChunkSize = 10_000

  /// The name of the file used to store the downloaded blocklist data temporarily before processing
  static let blockedListTmpFileName = "block-list.tmp.json"
  static let blockedListDownloadInterval: TimeInterval = 12 * 60 * 60
}
