import Foundation

class SharedUserDefaultsService {

  private let userDefaults: UserDefaults?

  // MARK: - Constants
  private struct Keys {
    static let action = "action"
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

  func getAction() -> String {
    return userDefaults?.string(forKey: Keys.action) ?? ""
  }

  // MARK: - Reset All
  func resetAllData() {
    userDefaults?.removeObject(forKey: Keys.action)
  }
}
