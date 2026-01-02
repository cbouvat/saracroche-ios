import CallKit
import Foundation

/// A service that manages CallKit extension functionality for blocking phone numbers.
/// This service provides methods to check extension status, open settings, and reload the extension.
class CallDirectoryService {

  /// Shared instance of the CallDirectoryService for singleton pattern access.
  static let shared = CallDirectoryService()

  /// The CallKit manager instance for interacting with the Call Directory extension.
  private let manager = CXCallDirectoryManager.sharedInstance

  /// Private initializer to enforce singleton pattern.
  private init() {}

  /// Checks the current status of the CallKit extension.
  ///
  /// - Parameter completion: A closure that receives the extension status.
  ///   The closure is called on the main thread.
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

  /// Opens the activation panel in iOS Settings for the Call Directory extension.
  /// This allows users to enable or disable the call blocking extension.
  func openSettings() {
    manager.openSettings { error in
      if let error = error {
        print(
          "Error opening settings: \(error.localizedDescription)"
        )
      }
    }
  }

  /// Reloads the CallKit extension with a completion handler.
  ///
  /// - Parameter completion: A closure that receives a boolean indicating success (true) or failure (false).
  ///   The closure is called on the main thread.
  func reloadExtension(completion: @escaping (Bool) -> Void) {
    self.manager.reloadExtension(
      withIdentifier: AppConstants.callDirectoryExtensionIdentifier
    ) { error in
      DispatchQueue.main.async {
        completion(error == nil)
      }
    }
  }

  /// Reloads the CallKit extension without a completion handler.
  /// Errors are logged to the console if they occur.
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
