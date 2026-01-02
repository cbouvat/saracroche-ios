import Foundation

enum NetworkError: Error {
  case invalidURL
  case noData
  case decodingError
  case serverError(Int, String?)
  case networkUnavailable
  case timeout
  case unknown

  var userMessage: String {
    switch self {
    case .invalidURL:
      return "URL invalide."
    case .noData:
      return "Aucune donnée reçue du serveur."
    case .decodingError:
      return "Erreur lors du traitement des données."
    case .serverError(let code, let message):
      if let serverMessage = message, !serverMessage.isEmpty {
        return serverMessage
      }
      return "Erreur serveur (\(code)). Veuillez réessayer plus tard."
    case .networkUnavailable:
      return "Connexion réseau indisponible. Vérifiez votre connexion Internet."
    case .timeout:
      return "Délai d'attente dépassé. Veuillez réessayer."
    case .unknown:
      return "Une erreur inattendue s'est produite."
    }
  }
}
