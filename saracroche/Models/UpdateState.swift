import Foundation

enum UpdateState: String, CaseIterable {
  case idle = "idle"
  case starting = "starting"
  case installing = "installing"
  case error = "failed"

  var isInProgress: Bool {
    switch self {
    case .starting, .installing:
      return true
    default:
      return false
    }
  }
}
