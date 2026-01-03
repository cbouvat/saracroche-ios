import Foundation
import SwiftUI

/// Status of CallKit blocker extension
enum BlockerExtensionStatus {
  case enabled
  case disabled
  case error
  case unexpected
  case unknown

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
