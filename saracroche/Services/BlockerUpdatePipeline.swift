import CallKit
import Foundation

/// Orchestrates blocklist update process
final class BlockerUpdatePipeline {

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

  func performBackgroundUpdate(completion: @escaping (Bool) -> Void) {
    print("🔄 [BlockerUpdatePipeline] performBackgroundUpdate called")
    performUpdate(onProgress: {}, completion: completion)
  }

  func performUpdate(
    onProgress: @escaping () -> Void,
    completion: @escaping (Bool) -> Void
  ) {
    print("🔄 [BlockerUpdatePipeline] performUpdate called")

    guard userDefaultsService.shouldUpdateBlockList() else {
      print("✅ [BlockerUpdatePipeline] Block list is up to date")
      checkAndProcessPendingBatch(
        onProgress: onProgress,
        completion: completion
      )
      return
    }

    print("⬇️ [BlockerUpdatePipeline] Block list needs update, checking extension status")
    checkExtensionStatus(
      onProgress: onProgress,
      completion: completion
    )
  }

  private func checkAndProcessPendingBatch(
    onProgress: @escaping () -> Void,
    completion: @escaping (Bool) -> Void
  ) {
    print("🔍 [BlockerUpdatePipeline] checkAndProcessPendingBatch called")
    let hasPendingPatterns = listService.hasPendingPatternsToProcess()
    print("📊 [BlockerUpdatePipeline] Has pending patterns: \(hasPendingPatterns)")

    guard hasPendingPatterns else {
      print("✅ [BlockerUpdatePipeline] No pending patterns to process")
      completion(true)
      return
    }

    print("⚡ [BlockerUpdatePipeline] Found pending patterns, triggering batch processing")
    onProgress()

    listService.triggerBatchProcessing(
      onProgress: onProgress,
      completion: completion
    )
  }

  private func checkExtensionStatus(
    onProgress: @escaping () -> Void,
    completion: @escaping (Bool) -> Void
  ) {
    print("🔍 [BlockerUpdatePipeline] checkExtensionStatus called")
    callDirectoryService.checkExtensionStatus { [weak self] status in
      guard let self = self else {
        print("❌ [BlockerUpdatePipeline] Self is nil in checkExtensionStatus callback")
        completion(false)
        return
      }

      print("📱 [BlockerUpdatePipeline] Extension status: \(status)")
      if status == .enabled {
        print("✅ [BlockerUpdatePipeline] Extension enabled, proceeding with download")
        self.downloadAndConvertList(
          onProgress: onProgress,
          completion: completion
        )
      } else {
        print("❌ [BlockerUpdatePipeline] Extension not enabled, aborting update")
        completion(false)
      }
    }
  }

  private func downloadAndConvertList(
    onProgress: @escaping () -> Void,
    completion: @escaping (Bool) -> Void
  ) {
    print("⬇️ [BlockerUpdatePipeline] downloadAndConvertBlockList called")
    listService.performDownloadAndBatchProcessing(
      onProgress: onProgress,
      completion: completion
    )
  }
}
