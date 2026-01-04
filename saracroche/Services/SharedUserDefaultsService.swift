import Foundation

class SharedUserDefaultsService {

  private let userDefaults: UserDefaults?

  // MARK: - Constants
  private struct Keys {
    static let action = "action"
    static let numbers = "numbers"
  }

  init() {
    userDefaults = UserDefaults(suiteName: AppConstants.appGroupIdentifier)
  }

  // MARK: - Action
  func setAction(_ action: String) {
    userDefaults?.set(action, forKey: Keys.action)
  }

  /// Clear the action
  func clearAction() {
    userDefaults?.set("", forKey: Keys.action)
  }

  /// Get the action
  func getAction() -> String {
    return userDefaults?.string(forKey: Keys.action) ?? ""
  }

  // MARK: - Numbers

  /// Set the numbers array for processing by the CallDirectory extension
  /// - Parameter numbers: Array of dictionaries containing number and optional name
  func setNumbers(_ numbers: [[String: Any]]) {
    userDefaults?.set(numbers, forKey: Keys.numbers)
  }

  /// Clear the numbers array
  func clearNumbers() {
    userDefaults?.set([], forKey: Keys.numbers)
  }

  /// Get the numbers array
  /// - Returns: Array of dictionaries containing number and optional name
  func getNumbers() -> [[String: Any]] {
    return userDefaults?.array(forKey: Keys.numbers) as? [[String: Any]] ?? []
  }

  // MARK: - Reset All
  func resetAllData() {
    userDefaults?.removeObject(forKey: Keys.action)
    userDefaults?.removeObject(forKey: Keys.numbers)
  }
}
