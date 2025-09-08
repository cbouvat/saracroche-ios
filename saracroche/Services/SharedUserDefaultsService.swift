import Foundation

class SharedUserDefaultsService {

  static let shared = SharedUserDefaultsService()

  private let userDefaults: UserDefaults?

  // MARK: - Constants
  private struct Keys {
    static let blockedNumbers = "blockedNumbers"
    static let action = "action"
    static let numbersList = "numbersList"
  }

  private init() {
    userDefaults = UserDefaults(suiteName: AppConstants.appGroupIdentifier)
  }

  // MARK: - Blocked Numbers Count
  func setBlockedNumbers(_ count: Int) {
    userDefaults?.set(count, forKey: Keys.blockedNumbers)
  }

  func getBlockedNumbers() -> Int {
    return userDefaults?.integer(forKey: Keys.blockedNumbers) ?? 0
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

  // MARK: - Numbers List
  func setNumbersList(_ numbers: [String]) {
    userDefaults?.set(numbers, forKey: Keys.numbersList)
  }

  func getNumbersList() -> [String] {
    return userDefaults?.stringArray(forKey: Keys.numbersList) ?? []
  }

  // MARK: - Reset All
  func resetAllData() {
    userDefaults?.removeObject(forKey: Keys.blockedNumbers)
    userDefaults?.removeObject(forKey: Keys.action)
    userDefaults?.removeObject(forKey: Keys.numbersList)
  }
}
