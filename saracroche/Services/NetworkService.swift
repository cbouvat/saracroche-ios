import Foundation
import UIKit

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

class NetworkService {
  private let session: URLSession

  init() {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 10.0
    configuration.timeoutIntervalForResource = 30.0
    self.session = URLSession(configuration: configuration)
  }

  func reportPhoneNumber(_ phoneNumber: String) async throws {
    guard let url = URL(string: "https://saracroche-server.cbouvat.com/report") else {
      throw NetworkError.invalidURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let requestData = await ReportRequest(
      number: phoneNumber,
      deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "unknown",
      appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        as? String ?? "unknown"
    )

    do {
      let jsonData = try JSONEncoder().encode(requestData)
      request.httpBody = jsonData
    } catch {
      throw NetworkError.decodingError
    }

    do {
      let (data, response) = try await session.data(for: request)
      try handleHTTPResponse(response, data: data)
    } catch {
      try handleNetworkError(error)
    }
  }

  private func handleHTTPResponse(_ response: URLResponse, data: Data) throws {
    guard let httpResponse = response as? HTTPURLResponse else { return }

    switch httpResponse.statusCode {
    case 200...299:
      return  // Success, no action needed
    case 400...499, 500...599:
      // Try to extract error message from response
      let errorMessage = extractErrorMessage(from: data)
      throw NetworkError.serverError(httpResponse.statusCode, errorMessage)
    default:
      throw NetworkError.unknown
    }
  }

  private func handleNetworkError(_ error: Error) throws {
    if error is NetworkError {
      throw error
    }

    let nsError = error as NSError
    switch nsError.code {
    case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
      throw NetworkError.networkUnavailable
    case NSURLErrorTimedOut:
      throw NetworkError.timeout
    default:
      throw NetworkError.unknown
    }
  }

  private func extractErrorMessage(from data: Data) -> String? {
    // Try to decode JSON error response
    if let json = try? JSONSerialization.jsonObject(with: data)
      as? [String: Any]
    {
      // Common error message keys
      if let message = json["message"] as? String {
        return message
      }
      if let error = json["error"] as? String {
        return error
      }
      if let detail = json["detail"] as? String {
        return detail
      }
    }

    // Try to decode as plain text
    if let text = String(data: data, encoding: .utf8), !text.isEmpty {
      return text
    }

    return nil
  }
}

private struct ReportRequest: Codable {
  let number: String
  let deviceId: String
  let appVersion: String
}
