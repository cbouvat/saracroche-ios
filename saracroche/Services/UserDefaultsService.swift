import Foundation

class UserDefaultsService {

  static let shared = UserDefaultsService()

  private let userDefaults: UserDefaults

  // MARK: - Constants
  private struct Keys {
    static let lastUpdateCheck = "lastUpdateCheck"
    static let lastUpdate = "lastUpdate"
    static let updateStarted = "updateStarted"
    static let updateState = "updateState"
  }

  private init() {
    userDefaults = UserDefaults.standard
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

  func setLastUpdateDate(_ date: Date) {
    userDefaults.set(date, forKey: Keys.lastUpdate)
  }

  func getLastUpdateDate() -> Date? {
    return userDefaults.object(forKey: Keys.lastUpdate) as? Date
  }

  func clearLastUpdate() {
    userDefaults.removeObject(forKey: Keys.lastUpdate)
  }

  func shouldUpdateBlockList() -> Bool {
    guard let lastUpdate = getLastUpdateDate() else {
      return true  // Première fois, toujours mettre à jour
    }

    let twentyFourHours: TimeInterval = 24 * 60 * 60
    return Date().timeIntervalSince(lastUpdate) > twentyFourHours
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
    clearLastUpdateCheck()
    clearLastUpdate()
    clearUpdateStarted()
    clearUpdateState()
  }
}
