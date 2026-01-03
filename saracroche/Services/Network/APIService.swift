import Foundation
import UIKit

/// Base service for interacting with the Saracroche API
class APIService {
  /// URLSession for making network requests
  let session: URLSession

  /// Common JSON headers for API requests
  var jsonHeaders: [String: String] {
    [
      "Content-Type": "application/json",
      "Accept": "application/json",
    ]
  }

  /// Device identifier for API requests
  var deviceIdentifier: String {
    return UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
  }

  /// Initializes the API service with a custom URLSession configuration
  /// - Parameter configuration: URLSessionConfiguration to use (defaults to default configuration)
  init(configuration: URLSessionConfiguration = .default) {
    configuration.timeoutIntervalForRequest = 10.0
    configuration.timeoutIntervalForResource = 30.0
    self.session = URLSession(configuration: configuration)
  }

  /// Generic GET request method
  /// - Parameter url: The URL to request
  /// - Returns: Data from the response
  func get(url: URL) async throws -> Data {
    let request = makeRequest(url: url, method: .get)
    return try await performRequest(request)
  }

  /// Creates a URLRequest with appropriate headers and method
  /// - Parameters:
  ///   - url: The URL for the request
  ///   - method: The HTTP method
  /// - Returns: Configured URLRequest
  func makeRequest(url: URL, method: HTTPMethod) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    jsonHeaders.forEach { field, value in
      request.setValue(value, forHTTPHeaderField: field)
    }
    return request
  }

  /// Performs a network request and returns the data
  /// - Parameter request: The URLRequest to perform
  /// - Returns: Data from the response
  func performRequest(_ request: URLRequest) async throws -> Data {
    do {
      let (data, response) = try await session.data(for: request)
      try handleHTTPResponse(response, data: data)
      return data
    } catch {
      throw mapNetworkError(error)
    }
  }

  /// Handles HTTP response and validates status code
  /// - Parameters:
  ///   - response: The URLResponse
  ///   - data: The response data
  func handleHTTPResponse(_ response: URLResponse, data: Data) throws {
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

  /// Maps network errors to NetworkError enum
  /// - Parameter error: The error to map
  /// - Returns: NetworkError representation
  func mapNetworkError(_ error: Error) -> NetworkError {
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

  /// Extracts error message from response data
  /// - Parameter data: The response data
  /// - Returns: Error message if found, nil otherwise
  func extractErrorMessage(from data: Data) -> String? {
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
