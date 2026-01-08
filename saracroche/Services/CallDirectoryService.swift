import CallKit
import Foundation
import OSLog

/// Service for CallKit extension functionality
class CallDirectoryService {
  private let logger = Logger(subsystem: "com.cbouvat.saracroche", category: "CallDirectoryService")
  /// The CallKit manager instance for interacting with the Call Directory extension.
  private let manager = CXCallDirectoryManager.sharedInstance

  /// Check CallKit extension status
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

  /// Open CallKit settings
  func openSettings() {
    manager.openSettings { error in
      if let error = error {
        self.logger.error(
          "Error opening settings: \(error.localizedDescription)"
        )
      }
    }
  }

  /// Reload CallKit extension with completion
  func reloadExtension(completion: @escaping (Bool) -> Void) {
    self.manager.reloadExtension(
      withIdentifier: AppConstants.callDirectoryExtensionIdentifier
    ) { error in
      DispatchQueue.main.async {
        completion(error == nil)
      }
    }
  }

  /// Reload CallKit extension
  func reloadExtension() {
    self.manager.reloadExtension(
      withIdentifier: AppConstants.callDirectoryExtensionIdentifier
    ) { error in
      if let error = error {
        self.logger.error("Error reloading extension: \(error.localizedDescription)")
      }
    }
  }
}
