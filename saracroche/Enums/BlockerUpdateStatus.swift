import Foundation

/// States of a block list update process
enum UpdateState: String, CaseIterable {
  case idle = "idle"
  case starting = "starting"
  case downloading = "downloading"
  case converting = "converting"
  case installing = "installing"
  case retrying = "retrying"
  case error = "failed"

  var isInProgress: Bool {
    switch self {
    case .starting, .downloading, .converting, .installing, .retrying:
      return true
    default:
      return false
    }
  }
}
