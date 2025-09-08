import Foundation

class UserDefaultsService {

  static let shared = UserDefaultsService()

  private let userDefaults: UserDefaults

  // MARK: - Constants
  private struct Keys {
    static let totalBlockedNumbers = "totalBlockedNumbers"
    static let blocklistVersion = "blocklistVersion"
    static let lastUpdateCheck = "lastUpdateCheck"
    static let lastUpdate = "lastUpdate"
    static let updateStarted = "updateStarted"
    static let updateState = "updateState"
  }

  private init() {
    userDefaults = UserDefaults.standard
  }

  // MARK: - Total Blocked Numbers
  func setTotalBlockedNumbers(_ count: Int64) {
    userDefaults.set(count, forKey: Keys.totalBlockedNumbers)
  }

  func getTotalBlockedNumbers() -> Int {
    return userDefaults.integer(forKey: Keys.totalBlockedNumbers)
  }

  func clearTotalBlockedNumbers() {
    userDefaults.removeObject(forKey: Keys.totalBlockedNumbers)
  }

  // MARK: - Blocklist Version
  func setBlocklistVersion(_ version: String) {
    userDefaults.set(version, forKey: Keys.blocklistVersion)
  }

  func getBlocklistVersion() -> String {
    return userDefaults.string(forKey: Keys.blocklistVersion) ?? ""
  }

  func clearBlocklistVersion() {
    userDefaults.removeObject(forKey: Keys.blocklistVersion)
  }

  // MARK: - Last Update Check
  func setLastUpdateCheck(_ date: Date) {
    userDefaults.set(date, forKey: Keys.lastUpdateCheck)
  }

  func getLastUpdateCheck() -> Date? {
    return userDefaults.object(forKey: Keys.lastUpdateCheck) as? Date
  }

  func clearLastUpdateCheck() {
    userDefaults.removeObject(forKey: Keys.lastUpdateCheck)
  }

  // MARK: - Last Update
  func setLastUpdate(_ date: Date) {
    userDefaults.set(date, forKey: Keys.lastUpdate)
  }

  func getLastUpdate() -> Date? {
    return userDefaults.object(forKey: Keys.lastUpdate) as? Date
  }

  func clearLastUpdate() {
    userDefaults.removeObject(forKey: Keys.lastUpdate)
  }

  // MARK: - Update Started
  func setUpdateStarted(_ date: Date) {
    userDefaults.set(date, forKey: Keys.updateStarted)
  }

  func getUpdateStarted() -> Date? {
    return userDefaults.object(forKey: Keys.updateStarted) as? Date
  }

  func clearUpdateStarted() {
    userDefaults.removeObject(forKey: Keys.updateStarted)
  }

  // MARK: - Next Scheduled Update

  // MARK: - Update State
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

  // MARK: - Reset All
  func resetAllData() {
    clearTotalBlockedNumbers()
    clearBlocklistVersion()
    clearLastUpdateCheck()
    clearLastUpdate()
    clearUpdateStarted()
    clearUpdateState()
  }
}
