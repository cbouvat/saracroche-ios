import Foundation

struct AppConstants {

  // MARK: - App Group
  static let appGroupIdentifier = "group.com.cbouvat.saracroche"

  // MARK: - Call Directory Extension
  static let callDirectoryExtensionIdentifier = "com.cbouvat.saracroche.blocker"

  // MARK: - Server URLs
  static let reportServerURL = "https://saracroche.org/api/report"

  // MARK: - Background Tasks
  //static let backgroundUpdateIdentifier = "com.cbouvat.saracroche.background-update"
  //static let backgroundUpdateInterval: TimeInterval = 4 * 60 * 60  // In seconds

  // MARK: - Actions
  struct Actions {
    static let resetNumbersList = "resetNumbersList"
    static let addNumbersList = "addNumbersList"
  }

  // MARK: - Processing
  static let phoneNumberChunkSize = 5_000
  static let currentBlocklistVersion = "8"
}
