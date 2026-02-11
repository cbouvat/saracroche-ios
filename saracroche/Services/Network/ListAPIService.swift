import Foundation

/// Service for downloading block lists
class ListAPIService: APIService {
  /// User defaults service for persisting block list metadata.
  private let userDefaultsService: UserDefaultsService

  /// Initialize ListAPIService
  override init(configuration: URLSessionConfiguration = .default) {
    self.userDefaultsService = UserDefaultsService()
    super.init(configuration: configuration)
  }

  /// Download French block list
  func downloadFrenchList() async throws -> [String: Any] {
    guard let url = URL(string: AppConstants.apiFrenchListURL) else {
      throw NetworkError.invalidURL
    }

    let request = makeRequest(url: url, method: .get)
    let data = try await performRequest(request)

    // Parse the JSON data
    guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      throw NetworkError.decodingError
    }

    return json
  }
}
