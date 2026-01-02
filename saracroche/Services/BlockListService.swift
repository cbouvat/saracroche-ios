import Foundation

final class BlockListService {
  static let shared = BlockListService()

  private let apiService = APIService()
  private let userDefaultsService = UserDefaultsService.shared

  private init() {}

  func downloadAndSaveBlockList() async throws -> Data {
    let url = AppConstants.apiFrenchListURL

    do {
      let data = try await apiService.get(url: URL(string: url)!)

      // Sauvegarder la date de mise à jour
      userDefaultsService.setLastUpdateDate(Date())

      return data
    } catch {
      print("Failed to download blocklist: \(error)")
      throw error
    }
  }

  func downloadBlockList() async throws -> [String] {
    do {
      let data = try await downloadAndSaveBlockList()

      // Décoder les données JSON
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

  enum DownloadError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case unauthorized
    case serverError(Int)
  }
}
