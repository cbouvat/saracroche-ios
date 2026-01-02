import Foundation

/// A service for managing persistent data storage using UserDefaults.
/// This service provides methods to store and retrieve various application states and settings.
class UserDefaultsService {

  /// Shared instance of the UserDefaultsService for singleton pattern access.
  static let shared = UserDefaultsService()

  /// The UserDefaults instance used for persistence.
  private let userDefaults: UserDefaults

  /// MARK: - Constants
  /// Keys used for storing data in UserDefaults.
  private struct Keys {
    static let lastUpdateCheck = "lastUpdateCheck"
    static let lastUpdate = "lastUpdate"
    static let updateStarted = "updateStarted"
    static let updateState = "updateState"
    static let lastDownloadList = "lastDownloadList"
  }

  /// Private initializer to enforce singleton pattern.
  private init() {
    userDefaults = UserDefaults.standard
  }

  /// MARK: - Last Update Check
  ///
  /// Sets the date of the last update check.
  ///
  /// - Parameter date: The date to store.
  func setLastUpdateCheck(_ date: Date) {
    userDefaults.set(date, forKey: Keys.lastUpdateCheck)
  }

  /// Retrieves the date of the last update check.
  ///
  /// - Returns: The stored date, or nil if not set.
  func getLastUpdateCheck() -> Date? {
    return userDefaults.object(forKey: Keys.lastUpdateCheck) as? Date
  }

  /// Clears the last update check date from storage.
  func clearLastUpdateCheck() {
    userDefaults.removeObject(forKey: Keys.lastUpdateCheck)
  }

  /// MARK: - Last Update
  ///
  /// Sets the date of the last successful update.
  ///
  /// - Parameter date: The date to store.
  func setLastUpdate(_ date: Date) {
    userDefaults.set(date, forKey: Keys.lastUpdate)
  }

  /// Retrieves the date of the last successful update.
  ///
  /// - Returns: The stored date, or nil if not set.
  func getLastUpdate() -> Date? {
    return userDefaults.object(forKey: Keys.lastUpdate) as? Date
  }

  /// Sets the date of the last update (alias for setLastUpdate).
  ///
  /// - Parameter date: The date to store.
  func setLastUpdateDate(_ date: Date) {
    userDefaults.set(date, forKey: Keys.lastUpdate)
  }

  /// Retrieves the date of the last update (alias for getLastUpdate).
  ///
  /// - Returns: The stored date, or nil if not set.
  func getLastUpdateDate() -> Date? {
    return userDefaults.object(forKey: Keys.lastUpdate) as? Date
  }

  /// Clears the last update date from storage.
  func clearLastUpdate() {
    userDefaults.removeObject(forKey: Keys.lastUpdate)
  }

  /// Determines whether the block list should be updated.
  ///
  /// The block list should be updated if:
  /// - No previous update has been recorded, or
  /// - More than 24 hours have passed since the last update
  ///
  /// - Returns: true if an update is needed, false otherwise.
  func shouldUpdateBlockList() -> Bool {
    guard let lastUpdate = getLastUpdateDate() else {
      return true  // First time, always update
    }

    let twentyFourHours: TimeInterval = 24 * 60 * 60
    return Date().timeIntervalSince(lastUpdate) > twentyFourHours
  }

  /// MARK: - Update Started
  ///
  /// Sets the date when the update process started.
  ///
  /// - Parameter date: The date to store.
  func setUpdateStarted(_ date: Date) {
    userDefaults.set(date, forKey: Keys.updateStarted)
  }

  /// Retrieves the date when the update process started.
  ///
  /// - Returns: The stored date, or nil if not set.
  func getUpdateStarted() -> Date? {
    return userDefaults.object(forKey: Keys.updateStarted) as? Date
  }

  /// Clears the update started date from storage.
  func clearUpdateStarted() {
    userDefaults.removeObject(forKey: Keys.updateStarted)
  }

  /// MARK: - Next Scheduled Update

  /// MARK: - Update State
  ///
  /// Sets the current update state.
  ///
  /// - Parameter state: The update state to store.
  func setUpdateState(_ state: UpdateState) {
    userDefaults.set(state.rawValue, forKey: Keys.updateState)
  }

  /// Retrieves the current update state.
  ///
  /// - Returns: The stored update state, or .idle if not set.
  func getUpdateState() -> UpdateState {
    guard let stateString = userDefaults.string(forKey: Keys.updateState),
      let state = UpdateState(rawValue: stateString)
    else {
      return .idle
    }
    return state
  }

  /// Clears the update state from storage.
  func clearUpdateState() {
    userDefaults.removeObject(forKey: Keys.updateState)
  }

  /// MARK: - Last Download List
  ///
  /// Sets the date of the last block list download.
  ///
  /// - Parameter date: The date to store.
  func setLastDownloadList(_ date: Date) {
    userDefaults.set(date, forKey: Keys.lastDownloadList)
  }

  /// Retrieves the date of the last block list download.
  ///
  /// - Returns: The stored date, or nil if not set.
  func getLastDownloadList() -> Date? {
    return userDefaults.object(forKey: Keys.lastDownloadList) as? Date
  }

  /// Clears the last download list date from storage.
  func clearLastDownloadList() {
    userDefaults.removeObject(forKey: Keys.lastDownloadList)
  }

  /// Determines whether the block list should be downloaded.
  ///
  /// The block list should be downloaded if:
  /// - No previous download has been recorded, or
  /// - More than blockedListDownloadInterval has passed since the last download
  ///
  /// - Returns: true if a download is needed, false otherwise.
  func shouldDownloadBlockList() -> Bool {
    guard let lastDownload = getLastDownloadList() else {
      return true  // First time, always download
    }

    return Date().timeIntervalSince(lastDownload) > AppConstants.blockedListDownloadInterval
  }

  /// MARK: - Reset All
  ///
  /// Clears all stored data from UserDefaults.
  /// This is useful for resetting the application state.
  func resetAllData() {
    clearLastUpdateCheck()
    clearLastUpdate()
    clearUpdateStarted()
    clearUpdateState()
  }
}
