import Foundation
import UIKit

/// Service for reporting unwanted calls
class ReportAPIService: APIService {
  /// User defaults service for persisting block list metadata.
  private let userDefaultsService = UserDefaultsService.shared

  /// Initializes the ReportAPIService
  /// - Parameter configuration: URLSessionConfiguration to use (defaults to default configuration)
  override init(configuration: URLSessionConfiguration = .default) {
    super.init(configuration: configuration)
  }

  /// Reports a phone number as unwanted
  /// - Parameter phone: The phone number to report
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
}

private struct ReportRequest: Codable {
  let phone: Int64
  let device_id: String
}
