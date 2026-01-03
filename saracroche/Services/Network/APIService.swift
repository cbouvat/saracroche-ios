import Foundation
import UIKit

/// Service to interact with the Saracroche API
class APIService {
  private let session: URLSession
  private var jsonHeaders: [String: String] {
    [
      "Content-Type": "application/json",
      "Accept": "application/json",
    ]
  }

  private var deviceIdentifier: String {
    return UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
  }

  /// User defaults service for persisting block list metadata.
  private let userDefaultsService = UserDefaultsService.shared

  init() {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 10.0
    configuration.timeoutIntervalForResource = 30.0
    self.session = URLSession(configuration: configuration)
  }

  func report(_ phone: Int64) async throws {
    guard let url = URL(string: AppConstants.apiReportURL) else {
      throw NetworkError.invalidURL
    }

    let requestData = ReportRequest(phone: phone, device_id: deviceIdentifier)
    let jsonData = try JSONEncoder().encode(requestData)

    var request = makeRequest(url: url, method: .post)
    request.httpBody = jsonData

    _ = try await performRequest(request)
  }

  func downloadFrenchList() async throws -> Data {
    guard var components = URLComponents(string: AppConstants.apiFrenchListURL) else {
      throw NetworkError.invalidURL
    }
    components.queryItems = [
      URLQueryItem(name: "device_id", value: deviceIdentifier)
    ]

    guard let url = components.url else {
      throw NetworkError.invalidURL
    }

    let request = makeRequest(url: url, method: .get)
    return try await performRequest(request)
  }

  func get(url: URL) async throws -> Data {
    let request = makeRequest(url: url, method: .get)
    return try await performRequest(request)
  }

  /// Downloads the block list from the remote API and saves the update timestamp.
  ///
  /// - Returns: The raw data containing the block list.
  /// - Throws: DownloadError if the download or save operation fails.
  func downloadAndSaveBlockList() async throws -> Data {
    do {
      let data = try await downloadFrenchList()

      // Save the update timestamp
      userDefaultsService.setLastUpdateDate(Date())

      return data
    } catch {
      print("Failed to download blocklist: \(error)")
      throw error
    }
  }

  /// Downloads and decodes the block list from the remote API.
  ///
  /// - Returns: An array of strings representing phone numbers to block.
  /// - Throws: DownloadError if the download, decoding, or network operation fails.
  func downloadBlockList() async throws -> [String] {
    let data = try await downloadAndSaveBlockList()

    // Parse the JSON data
    guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let patterns = json["patterns"] as? [[String: Any]] else {
      throw DownloadError.invalidResponse
    }

    // Extract pattern strings from the array of dictionaries
    return patterns.compactMap { $0["pattern"] as? String }
  }

  private func makeRequest(url: URL, method: HTTPMethod) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    jsonHeaders.forEach { field, value in
      request.setValue(value, forHTTPHeaderField: field)
    }
    return request
  }

  private func performRequest(_ request: URLRequest) async throws -> Data {
    do {
      let (data, response) = try await session.data(for: request)
      try handleHTTPResponse(response, data: data)
      return data
    } catch {
      throw mapNetworkError(error)
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

  private func mapNetworkError(_ error: Error) -> NetworkError {
    if let networkError = error as? NetworkError {
      return networkError
    }

    let nsError = error as NSError
    switch nsError.code {
    case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
      return .networkUnavailable
    case NSURLErrorTimedOut:
      return .timeout
    default:
      return .unknown
    }
  }

  private func extractErrorMessage(from data: Data) -> String? {
    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
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
  let phone: Int64
  let device_id: String
}

/// Errors that can occur during block list download operations.
enum DownloadError: Error {
  /// The URL provided was invalid or malformed.
  case invalidURL

  /// A network-related error occurred during the download.
  /// - Parameter error: The underlying network error.
  case networkError(Error)

  /// The server responded with an invalid format.
  case invalidResponse

  /// An error occurred while decoding the JSON response.
  /// - Parameter error: The underlying decoding error.
  case decodingError(Error)

  /// The request was unauthorized (authentication failed).
  case unauthorized

  /// The server returned an error status code.
  /// - Parameter statusCode: The HTTP status code received.
  case serverError(Int)
}
