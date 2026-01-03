import CallKit
import Foundation

/// A service responsible for orchestrating the block list download and batch processing workflow.
/// This service manages:
/// 1. Checking if a download is needed based on the last download time
/// 2. Downloading the block list from the server
/// 3. Converting the list to Core Data with metadata
/// 4. Processing pending numbers in batches via CallKit
final class BlockListDownloadService {
  /// Shared instance of the BlockListDownloadService for singleton pattern access.
  static let shared = BlockListDownloadService()

  /// Service for downloading block lists from remote sources.
  private let listAPIService: ListAPIService

  /// Service for converting block lists to Core Data format.
  private let blockListConverterService: BlockListConverterService

  /// Service for managing persistent data storage.
  private let userDefaultsService: UserDefaultsService

  /// Service for managing shared UserDefaults across app extensions.
  private let sharedUserDefaultsService: SharedUserDefaultsService

  /// Service for managing Core Data operations.
  private let coreDataService: BlockedNumberCoreDataService

  /// Service for managing CallKit extension functionality.
  private let callDirectoryService: CallDirectoryService

  /// Private initializer with dependency injection for testing.
  ///
  /// - Parameters:
  ///   - blockListService: The BlockListAPIService instance (defaults to shared).
  ///   - blockListConverterService: The BlockListConverterService instance (defaults to shared).
  ///   - userDefaultsService: The UserDefaultsService instance (defaults to shared).
  ///   - sharedUserDefaultsService: The SharedUserDefaultsService instance (defaults to shared).
  ///   - coreDataService: The BlockedNumberCoreDataService instance (defaults to shared).
  ///   - callDirectoryService: The CallDirectoryService instance (defaults to shared).
  private init(
    listAPIService: ListAPIService = ListAPIService(),
    blockListConverterService: BlockListConverterService = .shared,
    userDefaultsService: UserDefaultsService = .shared,
    sharedUserDefaultsService: SharedUserDefaultsService = .shared,
    coreDataService: BlockedNumberCoreDataService = .shared,
    callDirectoryService: CallDirectoryService = .shared
  ) {
    self.listAPIService = listAPIService
    self.blockListConverterService = blockListConverterService
    self.userDefaultsService = userDefaultsService
    self.sharedUserDefaultsService = sharedUserDefaultsService
    self.coreDataService = coreDataService
    self.callDirectoryService = callDirectoryService
  }

  /// Performs the complete block list download and batch processing workflow.
  ///
  /// This method:
  /// 1. Checks if a download is needed based on the last download time
  /// 2. Downloads the block list if needed
  /// 3. Converts the list to Core Data with metadata
  /// 4. Processes pending numbers in batches
  ///
  /// - Parameters:
  ///   - onProgress: A closure called periodically to report progress.
  ///   - completion: A closure that receives a boolean indicating success (true) or failure (false).
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

  /// Downloads the block list from the server and converts it to Core Data format.
  ///
  /// - Parameters:
  ///   - onProgress: A closure called to report progress.
  ///   - completion: A closure that receives a boolean indicating success (true) or failure (false).
  private func downloadAndConvertBlockList(
    onProgress: @escaping () -> Void,
    completion: @escaping (Bool) -> Void
  ) {
    Task {
      do {
        onProgress()

        // Download the block list
        let list = try await listAPIService.downloadFrenchList()

        let _ = try blockListConverterService.convertBlockListIncremental(
          list: list,
          source: source,
          sourceListName: sourceListName,
          sourceVersion: sourceVersion
        )

        // Update the last download timestamp
        userDefaultsService.setLastDownloadList(Date())

        print(
          "Successfully downloaded and converted block list with \(list.count) numbers"
        )
        completion(true)
      } catch DownloadError.unauthorized {
        print("Authentication failed")
        completion(false)
      } catch DownloadError.networkError(let error) {
        print("Network error: \(error)")
        completion(false)
      } catch {
        print("Failed to download and convert blocklist: \(error)")
        completion(false)
      }
    }
  }

  /// Processes pending numbers in batches via CallKit.
  ///
  /// This method retrieves numbers with completedDate = nil and processes them
  /// in batches of 10,000. Each batch is sent to the CallKit extension
  /// for processing.
  ///
  /// - Parameters:
  ///   - onProgress: A closure called to report progress.
  ///   - completion: A closure that receives a boolean indicating success (true) or failure (false).
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

  /// Processes the next batch of pending numbers.
  ///
  /// - Parameters:
  ///   - onProgress: A closure called to report progress.
  ///   - completion: A closure that receives a boolean indicating success (true) or failure (false).
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
  /// Checks if there are any pending numbers to process.
  ///
  /// - Returns: true if there are numbers with completedDate = nil, false otherwise.
  func hasPendingNumbersToProcess() -> Bool {
    let pendingCount = coreDataService.getPendingBlockedNumbersCount()
    return pendingCount > 0
  }

  /// Triggers batch processing of pending numbers without downloading a new block list.
  ///
  /// This method is useful when you want to process pending numbers that were previously
  /// downloaded but not yet added to the CallKit extension.
  ///
  /// - Parameters:
  ///   - onProgress: A closure called periodically to report progress.
  ///   - completion: A closure that receives a boolean indicating success (true) or failure (false).
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
