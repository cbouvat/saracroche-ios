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

class APIService {
  private let session: URLSession

  init() {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 10.0
    configuration.timeoutIntervalForResource = 30.0
    self.session = URLSession(configuration: configuration)
  }

  func reportPhoneNumber(_ phoneNumber: String) async throws {
    guard let url = URL(string: AppConstants.reportServerURL) else {
      throw NetworkError.invalidURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    let requestData = await ReportRequest(
      number: phoneNumber,
      deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
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
      throw NetworkError.unknown
    }
  }

  func downloadBlockedPatterns(for deviceId: String) async throws -> Data {
    guard var components = URLComponents(string: AppConstants.blockedPatternsDownloadURL) else {
      throw NetworkError.invalidURL
    }
    components.queryItems = [
      URLQueryItem(name: "device_id", value: deviceId)
    ]

    guard let url = components.url else {
      throw NetworkError.invalidURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    do {
      let (data, response) = try await session.data(for: request)
      try handleHTTPResponse(response, data: data)
      return data
    } catch {
      try handleNetworkError(error)
      throw NetworkError.unknown
    }
  }

  private func handleHTTPResponse(_ response: URLResponse, data: Data) throws {
    guard let httpResponse = response as? HTTPURLResponse else { return }

    switch httpResponse.statusCode {
    case 200...299:
      return  // Success, no action needed
    case 400...499, 500...599:
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
    if let json = try? JSONSerialization.jsonObject(with: data)
      as? [String: Any]
    {
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

    if let text = String(data: data, encoding: .utf8), !text.isEmpty {
      return text
    }

    return nil
  }
}

private struct ReportRequest: Codable {
  let number: String
  let deviceId: String
}
