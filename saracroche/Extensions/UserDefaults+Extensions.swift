import Foundation

extension UserDefaults {

  /// Shared UserDefaults for App Group communication
  static let shared = UserDefaults(suiteName: AppConstants.appGroupIdentifier)

  /// Helper to safely get values from shared UserDefaults
  func safeValue<T>(forKey key: String, defaultValue: T) -> T {
    return object(forKey: key) as? T ?? defaultValue
  }
}
