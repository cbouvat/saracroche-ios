import Foundation

/// Service for managing persistent data storage
class UserDefaultsService {

  private let userDefaults: UserDefaults

  private struct Keys {
    static let lastBlockListUpdateCheckAt = "lastBlockListUpdateCheckAt"
    static let lastBlockListUpdateAt = "lastBlockListUpdateAt"
    static let blockListUpdateStartedAt = "blockListUpdateStartedAt"
    static let lastListDownloadAt = "lastListDownloadAt"
  }

  init() {
    userDefaults = UserDefaults.standard
  }

  func setLastBlockListUpdateCheckAt(_ date: Date) {
    userDefaults.set(date, forKey: Keys.lastBlockListUpdateCheckAt)
  }

  func getLastBlockListUpdateCheckAt() -> Date? {
    return userDefaults.object(forKey: Keys.lastBlockListUpdateCheckAt) as? Date
  }

  func clearLastBlockListUpdateCheckAt() {
    userDefaults.removeObject(forKey: Keys.lastBlockListUpdateCheckAt)
  }

  func setLastBlockListUpdateAt(_ date: Date) {
    userDefaults.set(date, forKey: Keys.lastBlockListUpdateAt)
  }

  func getLastBlockListUpdateAt() -> Date? {
    return userDefaults.object(forKey: Keys.lastBlockListUpdateAt) as? Date
  }

  func clearLastBlockListUpdateAt() {
    userDefaults.removeObject(forKey: Keys.lastBlockListUpdateAt)
  }

  func shouldUpdateList() -> Bool {
    guard let lastUpdate = getLastBlockListUpdateAt() else {
      return true  // First time, always update
    }

    let twentyFourHours: TimeInterval = 24 * 60 * 60
    return Date().timeIntervalSince(lastUpdate) > twentyFourHours
  }

  func setBlockListUpdateStartedAt(_ date: Date) {
    userDefaults.set(date, forKey: Keys.blockListUpdateStartedAt)
  }

  func getBlockListUpdateStartedAt() -> Date? {
    return userDefaults.object(forKey: Keys.blockListUpdateStartedAt) as? Date
  }

  func clearBlockListUpdateStartedAt() {
    userDefaults.removeObject(forKey: Keys.blockListUpdateStartedAt)
  }

  func setLastListDownloadAt(_ date: Date) {
    userDefaults.set(date, forKey: Keys.lastListDownloadAt)
  }

  func getLastListDownloadAt() -> Date? {
    return userDefaults.object(forKey: Keys.lastListDownloadAt) as? Date
  }

  func clearLastListDownloadAt() {
    userDefaults.removeObject(forKey: Keys.lastListDownloadAt)
  }

  func shouldDownloadList() -> Bool {
    guard let lastDownload = getLastListDownloadAt() else {
      return true  // First time, always download
    }

    return Date().timeIntervalSince(lastDownload) > AppConstants.listDownloadInterval
  }

  func resetAllData() {
    clearLastBlockListUpdateCheckAt()
    clearLastBlockListUpdateAt()
    clearBlockListUpdateStartedAt()
  }
}
