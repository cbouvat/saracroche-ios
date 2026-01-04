import CallKit
import Foundation

/// Service for managing blocklist updates
final class BlockerService {

  private let callDirectoryService: CallDirectoryService
  private let userDefaultsService: UserDefaultsService
  private let listService: ListService

  init(
    callDirectoryService: CallDirectoryService = CallDirectoryService(),
    userDefaultsService: UserDefaultsService = UserDefaultsService(),
    listService: ListService = ListService()
  ) {
    self.callDirectoryService = callDirectoryService
    self.userDefaultsService = userDefaultsService
    self.listService = listService
  }

  /// Perform background update
  func performBackgroundUpdate(completion: @escaping (Bool) -> Void) {
    print("🔄 [BlockerService] performBackgroundUpdate called")
    performUpdate(onProgress: {}, completion: completion)
  }

  /// Perform update with progress callback
  func performUpdate(
    onProgress: @escaping () -> Void,
    completion: @escaping (Bool) -> Void
  ) {
    print("🔄 [BlockerService] performUpdate called")

    guard userDefaultsService.shouldUpdateBlockList() else {
      print("✅ [BlockerService] Block list is up to date")
      checkAndProcessPendingBatch(
        onProgress: onProgress,
        completion: completion
      )
      return
    }

    print("⬇️ [BlockerService] Block list needs update, checking extension status")
    checkExtensionStatus(
      onProgress: onProgress,
      completion: completion
    )
  }

  /// Check for pending patterns and process them if found
  func checkAndProcessPendingBatch(
    onProgress: @escaping () -> Void,
    completion: @escaping (Bool) -> Void
  ) {
    print("🔍 [BlockerService] checkAndProcessPendingBatch called")
    let hasPendingPatterns = listService.hasPendingPatternsToProcess()
    print("📊 [BlockerService] Has pending patterns: \(hasPendingPatterns)")

    guard hasPendingPatterns else {
      print("✅ [BlockerService] No pending patterns to process")
      completion(true)
      return
    }

    print("⚡ [BlockerService] Found pending patterns, triggering batch processing")
    onProgress()

    listService.triggerBatchProcessing(
      onProgress: onProgress,
      completion: completion
    )
  }

  /// Check CallKit extension status
  func checkExtensionStatus(
    onProgress: @escaping () -> Void,
    completion: @escaping (Bool) -> Void
  ) {
    print("🔍 [BlockerService] checkExtensionStatus called")
    callDirectoryService.checkExtensionStatus { [weak self] status in
      guard let self = self else {
        print("❌ [BlockerService] Self is nil in checkExtensionStatus callback")
        completion(false)
        return
      }

      print("📱 [BlockerService] Extension status: \(status)")
      if status == .enabled {
        print("✅ [BlockerService] Extension enabled, proceeding with download")
        self.downloadAndConvertList(
          onProgress: onProgress,
          completion: completion
        )
      } else {
        print("❌ [BlockerService] Extension not enabled, aborting update")
        completion(false)
      }
    }
  }

  /// Download and convert the block list
  func downloadAndConvertList(
    onProgress: @escaping () -> Void,
    completion: @escaping (Bool) -> Void
  ) {
    print("⬇️ [BlockerService] downloadAndConvertBlockList called")
    listService.performDownloadAndBatchProcessing(
      onProgress: onProgress,
      completion: completion
    )
  }
}
