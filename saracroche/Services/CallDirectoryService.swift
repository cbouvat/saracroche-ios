import CallKit
import Foundation

/// Handles the CallKit extension functionality for blocking phone numbers
class CallDirectoryService {

  static let shared = CallDirectoryService()

  private let manager = CXCallDirectoryManager.sharedInstance
  private let sharedUserDefaults = SharedUserDefaultsService.shared
  private let userDefaults = UserDefaultsService.shared

  private init() {}

  /// Checks the status of the CallKit extension
  func checkExtensionStatus(
    completion: @escaping (BlockerExtensionStatus) -> Void
  ) {
    manager.getEnabledStatusForExtension(
      withIdentifier: AppConstants.callDirectoryExtensionIdentifier
    ) { status, error in
      DispatchQueue.main.async {
        if error != nil {
          completion(.error)
          return
        }

        switch status {
        case .enabled:
          completion(.enabled)
        case .disabled:
          completion(.disabled)
        case .unknown:
          completion(.unknown)
        @unknown default:
          completion(.unexpected)
        }
      }
    }
  }

  /// Open activation panel in the iOS settings
  func openSettings() {
    manager.openSettings { error in
      if let error = error {
        print(
          "Error opening settings: \(error.localizedDescription)"
        )
      }
    }
  }

  /// Reloads the CallKit extension
  func reloadExtension(completion: @escaping (Bool) -> Void) {
    self.manager.reloadExtension(
      withIdentifier: AppConstants.callDirectoryExtensionIdentifier
    ) { error in
      DispatchQueue.main.async {
        completion(error == nil)
      }
    }
  }

  /// Reloads the CallKit extension without completion handler
  func reloadExtension() {
    self.manager.reloadExtension(
      withIdentifier: AppConstants.callDirectoryExtensionIdentifier
    ) { error in
      if let error = error {
        print("Error reloading extension: \(error.localizedDescription)")
      }
    }
  }
}
