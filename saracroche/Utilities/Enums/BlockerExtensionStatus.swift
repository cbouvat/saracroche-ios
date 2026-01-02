import Foundation
import SwiftUI

/// Represents the status of the CallKit blocker extension.
/// This enum is used to track whether the call blocking extension is enabled, disabled, or in an error state.
enum BlockerExtensionStatus {
  /// The extension is enabled and actively blocking calls.
  case enabled

  /// The extension is disabled and not blocking calls.
  case disabled

  /// An error occurred while checking the extension status.
  case error

  /// The extension is in an unexpected state.
  case unexpected

  /// The extension status is unknown (still being verified).
  case unknown

  /// A localized description of the status for display to the user.
  var description: String {
    switch self {
    case .enabled:
      return "Actif"
    case .disabled:
      return "Désactivé"
    case .error:
      return "Erreur"
    case .unexpected:
      return "État inattendu"
    case .unknown:
      return "Vérification en cours"
    }
  }

  /// The SF Symbol name to use for this status.
  var iconName: String {
    switch self {
    case .enabled:
      return "checkmark.shield.fill"
    case .disabled:
      return "xmark.circle.fill"
    case .error:
      return "xmark.octagon.fill"
    case .unexpected:
      return "exclamationmark.triangle.fill"
    case .unknown:
      return "questionmark.circle.fill"
    }
  }

  /// The color to use for UI elements representing this status.
  var color: Color {
    switch self {
    case .enabled:
      return .green
    case .disabled:
      return .red
    case .error:
      return .red
    case .unexpected:
      return .orange
    case .unknown:
      return .orange
    }
  }
}
