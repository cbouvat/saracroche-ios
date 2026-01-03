import Foundation

/// Application-wide constants
struct AppConstants {

  static let appGroupIdentifier = "group.com.cbouvat.saracroche"

  static let callDirectoryExtensionIdentifier = "com.cbouvat.saracroche.blocker"

  static let apiBaseURL = "https://saracroche.org/api"

  static let apiReportURL = "\(apiBaseURL)/report"

  static let apiListsURL = "\(apiBaseURL)/lists"

  static let apiFrenchListURL = "\(apiBaseURL)/lists/french-list-arcep-operators"

  static let backgroundServiceIdentifier = "com.cbouvat.saracroche.background-update"

  static let backgroundUpdateInterval: TimeInterval = 4 * 60 * 60

  static let blockedListTmpFileName = "block-list.tmp.json"

  static let blockedListDownloadInterval: TimeInterval = 12 * 60 * 60
}
