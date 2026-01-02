import CallKit
import Foundation

/// Orchestrates the complete blocklist update process.
/// This class coordinates all phases of updating the call blocking database:
/// 1. Verifies if an update is needed
/// 2. Checks if the CallKit extension is enabled
/// 3. Downloads the latest blocklist from the server
/// 4. Converts the blocklist to Core Data format
/// 5. Reloads the CallKit extension with the updated data
final class BlockerUpdatePipeline {
  /// Shared instance of the BlockerUpdatePipeline for singleton pattern access.
  static let shared = BlockerUpdatePipeline()

  /// Service for managing CallKit extension functionality.
  private let callDirectoryService: CallDirectoryService

  /// Service for downloading block lists from remote sources.
  private let blockListService: BlockListService

  /// Service for converting block lists to Core Data format.
  private let blockListConverterService: BlockListConverterService

  /// Service for managing persistent data storage.
  private let userDefaultsService: UserDefaultsService

  /// Private initializer with dependency injection for testing.
  ///
  /// - Parameters:
  ///   - callDirectoryService: The CallDirectoryService instance (defaults to shared).
  ///   - blockListService: The BlockListService instance (defaults to shared).
  ///   - blockListConverterService: The BlockListConverterService instance (defaults to shared).
  ///   - userDefaultsService: The UserDefaultsService instance (defaults to shared).
  private init(
    callDirectoryService: CallDirectoryService = .shared,
    blockListService: BlockListService = .shared,
    blockListConverterService: BlockListConverterService = .shared,
    userDefaultsService: UserDefaultsService = .shared
  ) {
    self.callDirectoryService = callDirectoryService
    self.blockListService = blockListService
    self.blockListConverterService = blockListConverterService
    self.userDefaultsService = userDefaultsService
  }

  /// Performs a background update of the blocklist.
  ///
  /// This method is designed to be called from background tasks and doesn't report progress.
  ///
  /// - Parameter completion: A closure that receives a boolean indicating success (true) or failure (false).
  func performBackgroundUpdate(
    completion: @escaping (Bool) -> Void
  ) {
    performUpdate(
      onProgress: {
      },
      completion: { success in
        completion(success)
      }
    )
  }

  /// Performs an update of the blocklist with progress reporting.
  ///
  /// This is the main entry point for the update process. It:
  /// 1. Checks if an update is needed
  /// 2. Verifies the extension is enabled
  /// 3. Downloads and converts the blocklist
  /// 4. Reloads the extension
  ///
  /// - Parameters:
  ///   - onProgress: A closure called periodically to report progress.
  ///   - completion: A closure that receives a boolean indicating success (true) or failure (false).
  func performUpdate(
    onProgress: @escaping () -> Void,
    completion: @escaping (Bool) -> Void
  ) {
    // Check if update is needed
    let shouldUpdate = userDefaultsService.shouldUpdateBlockList()

    guard shouldUpdate else {
      print("Block list is up to date")
      completion(true)
      return
    }

    // Check if the blocker extension is active
    checkExtensionStatus(
      onProgress: onProgress,
      completion: completion
    )
  }

  /// Checks the status of the CallKit extension before proceeding with the update.
  ///
  /// - Parameters:
  ///   - onProgress: A closure called to report progress.
  ///   - completion: A closure that receives a boolean indicating success (true) or failure (false).
  private func checkExtensionStatus(
    onProgress: @escaping () -> Void,
    completion: @escaping (Bool) -> Void
  ) {
    callDirectoryService.checkExtensionStatus { [weak self] status in
      guard let self = self else {
        completion(false)
        return
      }

      switch status {
      case .enabled:
        // Extension is enabled
        self.downloadAndConvertBlockList(
          onProgress: onProgress,
          completion: completion
        )

      case .disabled, .unknown:
        // Extension is disabled or status unknown, cannot proceed
        completion(false)

      case .error, .unexpected:
        // Extension encountered an error or unexpected state
        completion(false)
      }
    }
  }

  /// Downloads the blocklist from the server and converts it to Core Data format.
  ///
  /// This method handles the core update process:
  /// 1. Downloads the latest blocklist
  /// 2. Converts it to Core Data for persistent storage
  /// 3. Reloads the CallKit extension with the new data
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
        // Download the block list
        let blockList = try await blockListService.downloadBlockList()

        // Convert to Core Data
        let _ = try blockListConverterService.convertBlockListToCoreData(blockList: blockList)

        // Update the blocklist in the extension
        callDirectoryService.reloadExtension()

        print("Successfully updated block list with \(blockList.count) numbers")
        completion(true)
      } catch BlockListService.DownloadError.unauthorized {
        print("Authentication failed")
        completion(false)
      } catch BlockListService.DownloadError.networkError(let error) {
        print("Network error: \(error)")
        completion(false)
      } catch {
        print("Failed to download and convert blocklist: \(error)")
        completion(false)
      }
    }
  }
}
