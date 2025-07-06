import Foundation

class SharedUserDefaultsService {
  
  static let shared = SharedUserDefaultsService()
  
  private let userDefaults: UserDefaults?
  
  private init() {
    userDefaults = UserDefaults(suiteName: AppConstants.appGroupIdentifier)
  }
  
  // MARK: - Blocker Action State
  func setBlockerActionState(_ state: String) {
    userDefaults?.set(state, forKey: AppConstants.UserDefaultsKeys.blockerActionState)
  }
  
  func getBlockerActionState() -> String {
    return userDefaults?.string(forKey: AppConstants.UserDefaultsKeys.blockerActionState) ?? ""
  }
  
  // MARK: - Blocked Numbers Count
  func setBlockedNumbers(_ count: Int) {
    userDefaults?.set(count, forKey: AppConstants.UserDefaultsKeys.blockedNumbers)
  }
  
  func getBlockedNumbers() -> Int {
    return userDefaults?.integer(forKey: AppConstants.UserDefaultsKeys.blockedNumbers) ?? 0
  }
  
  // MARK: - Total Blocked Numbers
  func setTotalBlockedNumbers(_ count: Int64) {
    userDefaults?.set(count, forKey: AppConstants.UserDefaultsKeys.totalBlockedNumbers)
  }
  
  func getTotalBlockedNumbers() -> Int {
    return userDefaults?.integer(forKey: AppConstants.UserDefaultsKeys.totalBlockedNumbers) ?? 0
  }
  
  // MARK: - Blocklist Version
  func setBlocklistVersion(_ version: String) {
    userDefaults?.set(version, forKey: AppConstants.UserDefaultsKeys.blocklistVersion)
  }
  
  func getBlocklistVersion() -> String {
    return userDefaults?.string(forKey: AppConstants.UserDefaultsKeys.blocklistVersion) ?? ""
  }
  
  // MARK: - Action
  func setAction(_ action: String) {
    userDefaults?.set(action, forKey: AppConstants.UserDefaultsKeys.action)
  }
  
  func clearAction() {
    userDefaults?.set("", forKey: AppConstants.UserDefaultsKeys.action)
  }
  
  // MARK: - Numbers List
  func setNumbersList(_ numbers: [String]) {
    userDefaults?.set(numbers, forKey: AppConstants.UserDefaultsKeys.numbersList)
  }
  
  // MARK: - Clear State
  func clearBlockerActionState() {
    userDefaults?.set("", forKey: AppConstants.UserDefaultsKeys.blockerActionState)
  }
}
