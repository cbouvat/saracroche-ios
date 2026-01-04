import CallKit
import CoreData
import Foundation

// MARK: - API Response Models

struct APIListResponse: Codable {
  let version: String
  let name: String
  let description: String
  let blockedNumbersCount: Int
  let patterns: [APIPattern]

  enum CodingKeys: String, CodingKey {
    case version
    case name
    case description
    case blockedNumbersCount = "blocked_numbers_count"
    case patterns
  }
}

struct APIPattern: Codable {
  let operatorName: String
  let pattern: String

  enum CodingKeys: String, CodingKey {
    case operatorName = "operator"
    case pattern
  }
}

/// Service for managing block lists - downloading, converting, and processing
final class ListService {

  // MARK: - Dependencies

  private let listAPIService: ListAPIService
  private let userDefaultsService: UserDefaultsService
  private let sharedUserDefaultsService: SharedUserDefaultsService
  private let patternCoreDataService: PatternCoreDataService
  private let callDirectoryService: CallDirectoryService

  // MARK: - Initialization

  init(
    listAPIService: ListAPIService = ListAPIService(),
    userDefaultsService: UserDefaultsService = UserDefaultsService(),
    sharedUserDefaultsService: SharedUserDefaultsService = SharedUserDefaultsService(),
    patternCoreDataService: PatternCoreDataService = PatternCoreDataService(),
    callDirectoryService: CallDirectoryService = CallDirectoryService()
  ) {
    self.listAPIService = listAPIService
    self.userDefaultsService = userDefaultsService
    self.sharedUserDefaultsService = sharedUserDefaultsService
    self.patternCoreDataService = patternCoreDataService
    self.callDirectoryService = callDirectoryService
  }

  // MARK: - Public Methods

  /// Perform complete download and batch processing of block lists
  func performDownloadAndBatchProcessing(
    onProgress: @escaping () -> Void,
    completion: @escaping (Bool) -> Void
  ) {
    // Check if download is needed
    let shouldDownload = userDefaultsService.shouldDownloadBlockList()

    guard shouldDownload else {
      print("Block list is up to date, skipping download")
      // Still process pending patterns even if no download needed
      processPendingPatternsBatches(
        onProgress: onProgress,
        completion: completion
      )
      return
    }

    // Download and convert the block list
    downloadAndConvertBlockList(
      onProgress: onProgress,
      completion: { [weak self] success in
        guard let self = self else {
          completion(false)
          return
        }

        if success {
          // Process pending patterns in batches
          self.processPendingPatternsBatches(
            onProgress: onProgress,
            completion: completion
          )
        } else {
          completion(false)
        }
      }
    )
  }

  /// Check if there are pending patterns to process
  func hasPendingPatternsToProcess() -> Bool {
    // Implementation would be here
    // This is called from BlockerUpdatePipeline
    return false
  }

  /// Trigger batch processing of pending patterns
  func triggerBatchProcessing(
    onProgress: @escaping () -> Void,
    completion: @escaping (Bool) -> Void
  ) {
    // Implementation would be here
    // This is called from BlockerUpdatePipeline
    completion(true)
  }

  // MARK: - Private Methods

  /// Download the block list from API and convert to CoreData
  private func downloadAndConvertBlockList(
    onProgress: @escaping () -> Void,
    completion: @escaping (Bool) -> Void
  ) {
    Task {
      do {
        onProgress()

        // Download the block list
        let jsonResponse = try await listAPIService.downloadFrenchList()

        // Extract the version from the JSON response
        guard jsonResponse["version"] is String else {
          print("Version not found in JSON response")
          completion(false)
          return
        }

        // Convert JSON response to CoreData
        convertListToCoreData(jsonResponse: jsonResponse)

        // Update the last download timestamp
        userDefaultsService.setLastDownloadList(Date())

        completion(true)
      } catch NetworkError.serverError(let code, _) where code == 401 {
        print("Authentication failed (401)")
        completion(false)
      } catch let error as NetworkError {
        print("Network error: \(error)")
        completion(false)
      } catch {
        print("Failed to download and convert blocklist: \(error)")
        completion(false)
      }
    }
  }

  /// Convert list from API JSON to CoreData
  func convertListToCoreData(jsonResponse: [String: Any]) {
    do {
      // Convert JSON dictionary to Data
      let jsonData = try JSONSerialization.data(withJSONObject: jsonResponse)

      // Parse the JSON data
      let decoder = JSONDecoder()
      let jsonObject = try decoder.decode(APIListResponse.self, from: jsonData)

      // Delete all existing patterns
      patternCoreDataService.deleteAllPatterns()

      // Process each pattern from the API response
      for pattern in jsonObject.patterns {
        print("Storing pattern: \(pattern.pattern)")
        // Store the pattern directly in CoreData with version and list name
        _ = patternCoreDataService.addPattern(
          pattern.pattern,
          action: "block",
          source: pattern.operatorName,
          sourceListName: jsonObject.name,
          sourceVersion: jsonObject.version
        )
      }

      patternCoreDataService.saveContext()

    } catch {
      print("Error converting list to CoreData: \(error)")
      // Handle the error appropriately, e.g., log it, notify the user, or rethrow it
    }
  }

  /// Process pending patterns in batches
  private func processPendingPatternsBatches(
    onProgress: @escaping () -> Void,
    completion: @escaping (Bool) -> Void
  ) {
    // Implementation would be here
    // This handles batch processing after download
    completion(true)
  }
}
