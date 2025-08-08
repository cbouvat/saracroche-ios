import Foundation

struct AppConstants {

  // MARK: - App Group
  static let appGroupIdentifier = "group.com.cbouvat.saracroche"

  // MARK: - Call Directory Extension
  static let callDirectoryExtensionIdentifier = "com.cbouvat.saracroche.blocker"

  // MARK: - UserDefaults Keys
  struct UserDefaultsKeys {
    static let blockedNumbers = "blockedNumbers"
    static let totalBlockedNumbers = "totalBlockedNumbers"
    static let blocklistVersion = "blocklistVersion"
    static let action = "action"
    static let numbersList = "numbersList"
  }

  // MARK: - Actions
  struct Actions {
    static let resetNumbersList = "resetNumbersList"
    static let addNumbersList = "addNumbersList"
  }

  // MARK: - Processing
  static let phoneNumberChunkSize = 10_000
  static let currentBlocklistVersion = "5"
}
