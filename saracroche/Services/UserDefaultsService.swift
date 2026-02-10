import Foundation

/// Service for managing persistent data storage
class UserDefaultsService {

  private let userDefaults: UserDefaults

  private struct Keys {
    static let lastListDownloadAt = "lastListDownloadAt"
    static let lastBackgroundLaunchAt = "lastBackgroundLaunchAt"
    static let lastSuccessfulUpdateAt = "lastSuccessfulUpdateAt"
    static let businessCode = "businessCode"
    static let notificationReminderEnabled = "notificationReminderEnabled"
  }

  init() {
    userDefaults = UserDefaults.standard
  }

  func setLastSuccessfulUpdateAt(_ date: Date) {
    userDefaults.set(date, forKey: Keys.lastSuccessfulUpdateAt)
  }

  func getLastSuccessfulUpdateAt() -> Date? {
    return userDefaults.object(forKey: Keys.lastSuccessfulUpdateAt) as? Date
  }

  func clearLastSuccessfulUpdateAt() {
    userDefaults.removeObject(forKey: Keys.lastSuccessfulUpdateAt)
  }

  func shouldUpdateList() -> Bool {
    guard let lastUpdate = getLastListDownloadAt() else {
      return true  // First time, always update
    }

    let twentyFourHours: TimeInterval = 24 * 60 * 60
    return Date().timeIntervalSince(lastUpdate) > twentyFourHours
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

  func setLastBackgroundLaunchAt(_ date: Date) {
    userDefaults.set(date, forKey: Keys.lastBackgroundLaunchAt)
  }

  func getLastBackgroundLaunchAt() -> Date? {
    return userDefaults.object(forKey: Keys.lastBackgroundLaunchAt) as? Date
  }

  func clearLastBackgroundLaunchAt() {
    userDefaults.removeObject(forKey: Keys.lastBackgroundLaunchAt)
  }

  func setBusinessCode(_ code: String) {
    userDefaults.set(code, forKey: Keys.businessCode)
  }

  func getBusinessCode() -> String? {
    return userDefaults.string(forKey: Keys.businessCode)
  }

  func clearBusinessCode() {
    userDefaults.removeObject(forKey: Keys.businessCode)
  }

  func setNotificationReminderEnabled(_ enabled: Bool) {
    userDefaults.set(enabled, forKey: Keys.notificationReminderEnabled)
  }

  func getNotificationReminderEnabled() -> Bool {
    return userDefaults.bool(forKey: Keys.notificationReminderEnabled)
  }

  func clearNotificationReminderEnabled() {
    userDefaults.removeObject(forKey: Keys.notificationReminderEnabled)
  }

  func shouldDownloadList() -> Bool {
    guard let lastDownload = getLastListDownloadAt() else {
      return true  // First time, always download
    }

    return Date().timeIntervalSince(lastDownload) > AppConstants.listDownloadInterval
  }

  func resetAllData() {
    clearLastListDownloadAt()
    clearLastBackgroundLaunchAt()
    clearLastSuccessfulUpdateAt()
    clearBusinessCode()
    clearNotificationReminderEnabled()
  }
}
