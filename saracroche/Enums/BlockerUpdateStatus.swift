import Foundation
import SwiftUI

/// States of a block list update process
enum BlockerUpdateStatus {
  case ok
  case inProgress
  case error

  var description: String {
    switch self {
    case .ok:
      return "À jour"
    case .inProgress:
      return "Mise à jour en cours, gardez l'application ouverte"
    case .error:
      return "Erreur lors de la mise à jour, redémarrer votre téléphone"
    }
  }

  var iconName: String {
    switch self {
    case .ok:
      return "checkmark.circle.fill"
    case .inProgress:
      return "arrow.clockwise.circle.fill"
    case .error:
      return "exclamationmark.circle.fill"
    }
  }

  var color: Color {
    switch self {
    case .ok:
      return .green
    case .inProgress:
      return .blue
    case .error:
      return .red
    }
  }
}
