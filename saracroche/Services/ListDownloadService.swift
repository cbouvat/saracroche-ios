import CallKit
import Foundation

/// Service for downloading and processing block lists
final class ListDownloadService {

  private let listAPIService: ListAPIService
  private let listConverterService: ListConverterService
  private let userDefaultsService: UserDefaultsService
  private let sharedUserDefaultsService: SharedUserDefaultsService
  private let coreDataService: BlockedNumberCoreDataService
  private let callDirectoryService: CallDirectoryService

  init(
    listAPIService: ListAPIService = ListAPIService(),
    listConverterService: ListConverterService = ListConverterService(),
    userDefaultsService: UserDefaultsService = UserDefaultsService(),
    sharedUserDefaultsService: SharedUserDefaultsService = SharedUserDefaultsService(),
    coreDataService: BlockedNumberCoreDataService = BlockedNumberCoreDataService(),
    callDirectoryService: CallDirectoryService = CallDirectoryService()
  ) {
    self.listAPIService = listAPIService
    self.listConverterService = listConverterService
    self.userDefaultsService = userDefaultsService
    self.sharedUserDefaultsService = sharedUserDefaultsService
    self.coreDataService = coreDataService
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
      // Still process pending numbers even if no download needed
      processPendingNumbersBatches(
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
          // Process pending numbers in batches
          self.processPendingNumbersBatches(
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
        _ = try listConverterService.convertBlockListToCoreData(jsonResponse: jsonResponse)

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

  private func processPendingNumbersBatches(
    onProgress: @escaping () -> Void,
    completion: @escaping (Bool) -> Void
  ) {
    let pendingCount = coreDataService.getPendingBlockedNumbersCount()

    print("Processing \(pendingCount) pending numbers in batches of 10,000")

    guard pendingCount > 0 else {
      print("No pending numbers to process")
      completion(true)
      return
    }

    // Process numbers in batches
    processNextBatch(
      onProgress: onProgress,
      completion: completion
    )
  }

  private func processNextBatch(
    onProgress: @escaping () -> Void,
    completion: @escaping (Bool) -> Void
  ) {
    let pendingNumbers = coreDataService.getPendingBlockedNumbersBatch(limit: 10_000)

    guard !pendingNumbers.isEmpty else {
      print("All pending numbers have been processed")
      completion(true)
      return
    }

    // Set up shared user defaults for batch processing
    sharedUserDefaultsService.setAction("batch")

    print("Processing batch of \(pendingNumbers.count) numbers")

    // Reload the extension to trigger batch processing
    callDirectoryService.reloadExtension()

    onProgress()

    // Continue with the next batch after a short delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
      self?.processNextBatch(
        onProgress: onProgress,
        completion: completion
      )
    }
  }
  func hasPendingNumbersToProcess() -> Bool {
    let pendingCount = coreDataService.getPendingBlockedNumbersCount()
    return pendingCount > 0
  }

  func triggerBatchProcessing(
    onProgress: @escaping () -> Void,
    completion: @escaping (Bool) -> Void
  ) {
    processPendingNumbersBatches(
      onProgress: onProgress,
      completion: completion
    )
  }
}
