import CallKit
import Foundation

/// Service for downloading and processing block lists
final class ListDownloadService {

  private let listAPIService: ListAPIService
  private let listConverterService: ListConverterService
  private let userDefaultsService: UserDefaultsService
  private let sharedUserDefaultsService: SharedUserDefaultsService
  private let patternCoreDataService: PatternCoreDataService
  private let callDirectoryService: CallDirectoryService

  init(
    listAPIService: ListAPIService = ListAPIService(),
    listConverterService: ListConverterService = ListConverterService(),
    userDefaultsService: UserDefaultsService = UserDefaultsService(),
    sharedUserDefaultsService: SharedUserDefaultsService = SharedUserDefaultsService(),
    patternCoreDataService: PatternCoreDataService = PatternCoreDataService(),
    callDirectoryService: CallDirectoryService = CallDirectoryService()
  ) {
    self.listAPIService = listAPIService
    self.listConverterService = listConverterService
    self.userDefaultsService = userDefaultsService
    self.sharedUserDefaultsService = sharedUserDefaultsService
    self.patternCoreDataService = patternCoreDataService
    self.callDirectoryService = callDirectoryService
  }

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

        // Convert JSON response using the converter service
        listConverterService.convertListToCoreData(jsonResponse: jsonResponse)

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
}
