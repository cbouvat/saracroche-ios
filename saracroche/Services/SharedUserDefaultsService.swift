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

  func clearAction() {
    userDefaults?.set("", forKey: Keys.action)
  }

  // MARK: - Numbers

  /// Set the numbers array for processing by the CallDirectory extension
  /// - Parameter numbers: Array of dictionaries containing number and optional name
  func setNumbers(_ numbers: [[String: Any]]) {
    userDefaults?.set(numbers, forKey: Keys.numbers)
  }

  func clearNumbers() {
    userDefaults?.set([], forKey: Keys.numbers)
  }

  // MARK: - Reset All
  func resetAllData() {
    clearAction()
    clearNumbers()
  }
}
