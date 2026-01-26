import Foundation

/// Service for reporting unwanted calls
class ReportAPIService: APIService {
  /// Initialize ReportAPIService
  override init(configuration: URLSessionConfiguration = .default) {
    super.init(configuration: configuration)
  }

  /// Report unwanted phone number
  /// - Parameters:
  ///   - phone: The phone number to report
  ///   - isGood: Whether the number is legitimate (true) or spam (false)
  func report(_ phone: Int64, isGood: Bool = false) async throws {
    guard let url = URL(string: AppConstants.apiReportURL) else {
      throw NetworkError.invalidURL
    }

    let requestData = ReportRequest(phone: phone, is_good: isGood, device_id: deviceIdentifier)
    let jsonData = try JSONEncoder().encode(requestData)

    var request = makeRequest(url: url, method: .post)
    request.httpBody = jsonData

    _ = try await performRequest(request)
  }
}

private struct ReportRequest: Codable {
  let phone: Int64
  let is_good: Bool
  let device_id: String
}
