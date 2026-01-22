import CallKit
import Foundation
import OSLog

// MARK: - Error Types

enum CallDirectoryError: LocalizedError {
  case statusCheckFailed(Error)
  case settingsOpenFailed(Error)
  case reloadFailed(Error)

  var errorDescription: String? {
    switch self {
    case .statusCheckFailed(let error):
      return "Failed to check extension status: \(error.localizedDescription)"
    case .settingsOpenFailed(let error):
      return "Failed to open settings: \(error.localizedDescription)"
    case .reloadFailed(let error):
      return "Failed to reload extension: \(error.localizedDescription)"
    }
  }
}

/// Service for CallKit extension functionality
class CallDirectoryService {
  private static let logger = Logger(
    subsystem: "com.cbouvat.saracroche", category: "CallDirectoryService")
  /// The CallKit manager instance for interacting with the Call Directory extension.

  /// Check CallKit extension status
  func checkExtensionStatus() async throws -> BlockerExtensionStatus {
    try await withCheckedThrowingContinuation { continuation in
      CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(
        withIdentifier: AppConstants.callDirectoryExtensionIdentifier
      ) { status, error in
        if let error = error {
          continuation.resume(throwing: CallDirectoryError.statusCheckFailed(error))
          return
        }

        let blockerStatus: BlockerExtensionStatus
        switch status {
        case .enabled:
          blockerStatus = .enabled
        case .disabled:
          blockerStatus = .disabled
        case .unknown:
          blockerStatus = .unknown
        @unknown default:
          blockerStatus = .unexpected
        }

        continuation.resume(returning: blockerStatus)
      }
    }
  }

  /// Open CallKit settings
  func openSettings() async throws {
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      CXCallDirectoryManager.sharedInstance.openSettings { error in
        if let error = error {
          Self.logger.error("Error opening settings: \(error.localizedDescription)")
          continuation.resume(throwing: CallDirectoryError.settingsOpenFailed(error))
        } else {
          continuation.resume()
        }
      }
    }
  }

  /// Reload CallKit extension
  func reloadExtension() async throws {
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      CXCallDirectoryManager.sharedInstance.reloadExtension(
        withIdentifier: AppConstants.callDirectoryExtensionIdentifier
      ) { error in
        if let error = error {
          continuation.resume(throwing: CallDirectoryError.reloadFailed(error))
        } else {
          continuation.resume()
        }
      }
    }
  }
}
