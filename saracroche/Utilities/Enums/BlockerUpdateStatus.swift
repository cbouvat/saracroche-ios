import Foundation

/// Represents the different states of a block list update process.
/// This enum is used to track the progress of updating the call blocking database.
enum UpdateState: String, CaseIterable {
  /// The update process is idle (not started or completed).
  case idle = "idle"

  /// The update process is starting (initializing).
  case starting = "starting"

  /// The block list is being downloaded from the server.
  case downloading = "downloading"

  /// The downloaded data is being converted to the appropriate format.
  case converting = "converting"

  /// The converted data is being installed in the CallKit extension.
  case installing = "installing"

  /// An error occurred during the update process.
  case error = "failed"

  /// Indicates whether the update process is currently in progress.
  ///
  /// - Returns: true if the update is in progress (starting, downloading, converting, or installing),
  ///            false otherwise (idle or error).
  var isInProgress: Bool {
    switch self {
    case .starting, .downloading, .converting, .installing:
      return true
    default:
      return false
    }
  }
}
