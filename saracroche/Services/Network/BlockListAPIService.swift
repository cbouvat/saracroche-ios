import Foundation
import UIKit

/// Service to download and manage block lists from the Saracroche API
class BlockListAPIService: APIService {
  /// User defaults service for persisting block list metadata.
  private let userDefaultsService = UserDefaultsService.shared

  /// Initializes the BlockListAPIService
  /// - Parameter configuration: URLSessionConfiguration to use (defaults to default configuration)
  override init(configuration: URLSessionConfiguration = .default) {
    super.init(configuration: configuration)
  }

  /// Downloads the French block list from the remote API.
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

  /// Downloads the block list from the remote API and saves the update timestamp.
  func downloadAndSaveBlockList() async throws -> Data {
    do {
      let data = try await downloadFrenchList()

      // Save the update timestamp
      userDefaultsService.setLastUpdateDate(Date())

      return data
    } catch {
      print("Failed to download blocklist: $error")
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
      let patterns = json["patterns"] as? [[String: Any]]
    else {
      throw DownloadError.invalidResponse
    }

    // Extract pattern strings from the array of dictionaries
    return patterns.compactMap { $0["pattern"] as? String }
  }
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
