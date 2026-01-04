import Foundation

/// Service for managing persistent data storage
class UserDefaultsService {

  private let userDefaults: UserDefaults

  private struct Keys {
    static let lastUpdateCheck = "lastUpdateCheck"
    static let lastUpdate = "lastUpdate"
    static let updateStarted = "updateStarted"
    static let updateState = "updateState"
    static let lastDownloadList = "lastDownloadList"
  }

  init() {
    userDefaults = UserDefaults.standard
  }

  func setLastUpdateCheck(_ date: Date) {
    userDefaults.set(date, forKey: Keys.lastUpdateCheck)
  }

  func getLastUpdateCheck() -> Date? {
    return userDefaults.object(forKey: Keys.lastUpdateCheck) as? Date
  }

  func clearLastUpdateCheck() {
    userDefaults.removeObject(forKey: Keys.lastUpdateCheck)
  }

  func setLastUpdate(_ date: Date) {
    userDefaults.set(date, forKey: Keys.lastUpdate)
  }

  func getLastUpdate() -> Date? {
    return userDefaults.object(forKey: Keys.lastUpdate) as? Date
  }

  func setLastUpdateDate(_ date: Date) {
    userDefaults.set(date, forKey: Keys.lastUpdate)
  }

  func getLastUpdateDate() -> Date? {
    return userDefaults.object(forKey: Keys.lastUpdate) as? Date
  }

  func clearLastUpdate() {
    userDefaults.removeObject(forKey: Keys.lastUpdate)
  }

  func shouldUpdateList() -> Bool {
    guard let lastUpdate = getLastUpdateDate() else {
      return true  // First time, always update
    }

    let twentyFourHours: TimeInterval = 24 * 60 * 60
    return Date().timeIntervalSince(lastUpdate) > twentyFourHours
  }

  func setUpdateStarted(_ date: Date) {
    userDefaults.set(date, forKey: Keys.updateStarted)
  }

  func getUpdateStarted() -> Date? {
    return userDefaults.object(forKey: Keys.updateStarted) as? Date
  }

  func clearUpdateStarted() {
    userDefaults.removeObject(forKey: Keys.updateStarted)
  }

  func setUpdateState(_ state: UpdateState) {
    userDefaults.set(state.rawValue, forKey: Keys.updateState)
  }

  func getUpdateState() -> UpdateState {
    guard let stateString = userDefaults.string(forKey: Keys.updateState),
      let state = UpdateState(rawValue: stateString)
    else {
      return .idle
    }
    return state
  }

  func clearUpdateState() {
    userDefaults.removeObject(forKey: Keys.updateState)
  }

  func setLastDownloadList(_ date: Date) {
    userDefaults.set(date, forKey: Keys.lastDownloadList)
  }

  func getLastDownloadList() -> Date? {
    return userDefaults.object(forKey: Keys.lastDownloadList) as? Date
  }

  func clearLastDownloadList() {
    userDefaults.removeObject(forKey: Keys.lastDownloadList)
  }

  func shouldDownloadList() -> Bool {
    guard let lastDownload = getLastDownloadList() else {
      return true  // First time, always download
    }

    return Date().timeIntervalSince(lastDownload) > AppConstants.listDownloadInterval
  }

  func resetAllData() {
    clearLastUpdateCheck()
    clearLastUpdate()
    clearUpdateStarted()
    clearUpdateState()
  }
}
