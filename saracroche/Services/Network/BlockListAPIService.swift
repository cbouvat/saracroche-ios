import Foundation

/// A service responsible for downloading and managing block lists from remote sources.
/// This service handles the retrieval of spam/block numbers and their storage in the application.
final class BlockListAPIService {
  /// Shared instance of the BlockListAPIService for singleton pattern access.
  static let shared = BlockListAPIService()

  /// API service used to make network requests.
  private let apiService = APIService()

  /// User defaults service for persisting block list metadata.
  private let userDefaultsService = UserDefaultsService.shared

  /// Private initializer to enforce singleton pattern.
  private init() {}

  /// Downloads the block list from the remote API and saves the update timestamp.
  ///
  /// - Returns: The raw data containing the block list.
  /// - Throws: DownloadError if the download or save operation fails.
  func downloadAndSaveBlockList() async throws -> Data {
    let url = AppConstants.apiFrenchListURL

    do {
      let data = try await apiService.get(url: URL(string: url)!)

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
    do {
      let data = try await downloadAndSaveBlockList()

      // Decode the JSON data
      let decoder = JSONDecoder()
      let blockList = try decoder.decode([String].self, from: data)

      return blockList
    } catch let error as URLError {
      throw DownloadError.networkError(error)
    } catch let error as DecodingError {
      throw DownloadError.decodingError(error)
    } catch {
      throw DownloadError.networkError(error)
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
}
