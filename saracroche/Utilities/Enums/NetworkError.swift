import Foundation

/// Represents various network-related errors that can occur during API requests.
enum NetworkError: Error {
  /// The URL provided was invalid or malformed.
  case invalidURL

  /// No data was received from the server.
  case noData

  /// An error occurred while decoding the server response.
  case decodingError

  /// The server returned an error status code.
  /// - Parameters:
  ///   - code: The HTTP status code received.
  ///   - message: An optional error message from the server.
  case serverError(Int, String?)

  /// The network connection is unavailable.
  case networkUnavailable

  /// The request timed out before receiving a response.
  case timeout

  /// An unknown error occurred.
  case unknown

  /// A user-friendly message describing the error.
  /// This message is suitable for display in the UI.
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
