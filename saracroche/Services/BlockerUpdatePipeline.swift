import CallKit
import Foundation

/// Orchestrates the blocklist update phases: extension verification, download, Core Data conversion, and chunked reload.
final class BlockerUpdatePipeline {
  static let shared = BlockerUpdatePipeline()

  private let callDirectoryService: CallDirectoryService
  private let blockListService: BlockListService
  private let blockListConverterService: BlockListConverterService
  private let userDefaultsService: UserDefaultsService

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
