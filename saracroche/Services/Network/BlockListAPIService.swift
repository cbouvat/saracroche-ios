import Foundation
import UIKit

/// Service to download and manage block lists from the Saracroche API
class ListAPIService: APIService {
  /// User defaults service for persisting block list metadata.
  private let userDefaultsService = UserDefaultsService.shared

  /// Initializes the ListAPIService
  /// - Parameter configuration: URLSessionConfiguration to use (defaults to default configuration)
  override init(configuration: URLSessionConfiguration = .default) {
    super.init(configuration: configuration)
  }

  /// Downloads and decodes the French block list from the remote API.
  ///
  /// - Returns: A dictionary representing the complete JSON response.
  /// - Throws: DownloadError if the download, decoding, or network operation fails.
  func downloadFrenchList() async throws -> [String: Any] {
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
    let data = try await performRequest(request)

    // Save the update timestamp
    userDefaultsService.setLastUpdateDate(Date())

    // Parse the JSON data
    guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      throw DownloadError.invalidResponse
    }

    return json
  }
}

