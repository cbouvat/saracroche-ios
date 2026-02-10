import Foundation

// MARK: - Error Types

enum BlockerServiceError: LocalizedError {
  case listUpdateFailed(Error)
  case patternProcessingFailed(Error)
  case extensionReloadFailed(Error)

  var errorDescription: String? {
    switch self {
    case .listUpdateFailed(let error):
      return "List update failed: \(error.localizedDescription)"
    case .patternProcessingFailed(let error):
      return "Pattern processing failed: \(error.localizedDescription)"
    case .extensionReloadFailed(let error):
      return "Extension reload failed: \(error.localizedDescription)"
    }
  }
}

/// Service for managing blocklist updates
final class BlockerService {
  private let callDirectoryService: CallDirectoryService
  private let userDefaultsService: UserDefaultsService
  private let listService: ListService
  private let patternService: PatternService
  private let sharedUserDefaultsService: SharedUserDefaultsService

  init(
    callDirectoryService: CallDirectoryService = CallDirectoryService(),
    userDefaultsService: UserDefaultsService = UserDefaultsService(),
    listService: ListService = ListService(),
    patternService: PatternService = PatternService(),
    sharedUserDefaultsService: SharedUserDefaultsService = SharedUserDefaultsService()
  ) {
    self.callDirectoryService = callDirectoryService
    self.userDefaultsService = userDefaultsService
    self.listService = listService
    self.patternService = patternService
    self.sharedUserDefaultsService = sharedUserDefaultsService
  }

  /// Perform update
  func performUpdate() async throws {
    Logger.debug("performUpdate called", category: .blockerService)

    // 1. Requeue expired patterns so the Call Directory extension stays up to date
    let resetCount = await patternService.resetExpiredCompletedPatterns()
    if resetCount > 0 {
      Logger.debug(
        "Reset \(resetCount) expired completed patterns", category: .blockerService)
    }

    // 2. Process pending patterns (includes freshly requeued ones)
    let pendingCount = await patternService.getPendingPatternsCount()
    if pendingCount > 0 {
      Logger.debug("Pending patterns found", category: .blockerService)
      do {
        try await processPatternsUpToLimit()
        userDefaultsService.setLastSuccessfulUpdateAt(Date())
      } catch {
        throw BlockerServiceError.patternProcessingFailed(error)
      }
      return
    }

    // 3. First launch: no patterns at all → download the list
    let hasPatterns = await patternService.hasPatterns()
    if !hasPatterns {
      Logger.debug("No patterns found, launching update", category: .blockerService)
      do {
        try await listService.update()
        userDefaultsService.setLastSuccessfulUpdateAt(Date())
      } catch {
        throw BlockerServiceError.listUpdateFailed(error)
      }
      return
    }

    // 4. Stale list: refresh if last download was more than 24 h ago
    if userDefaultsService.shouldUpdateList() {
      Logger.debug("Update needed based on date", category: .blockerService)
      do {
        try await listService.update()
        userDefaultsService.setLastSuccessfulUpdateAt(Date())
      } catch {
        throw BlockerServiceError.listUpdateFailed(error)
      }
      return
    }

    // 5. Nothing to do — all patterns are installed and the list is fresh
    Logger.debug("No update needed, all patterns are completed", category: .blockerService)
  }

  /// Process multiple pending patterns up to a limit of 250,000 numbers
  private func processPatternsUpToLimit() async throws {
    var totalProcessedNumbers: Int64 = 0
    let maxNumbers = AppConstants.maxNumbersPerBatch
    var isFirstPattern = true

    while true {
      // Get next pending pattern
      guard let pattern = await patternService.retrievePatternForProcessing(),
        let patternString = pattern.pattern
      else {
        // No more patterns to process
        Logger.debug("No more pending patterns", category: .blockerService)
        return
      }

      // Check if this pattern would exceed the limit (except for first pattern)
      let patternNumberCount = PhoneNumberHelpers.countPhoneNumbers(for: patternString)
      if !isFirstPattern && (totalProcessedNumbers + patternNumberCount > maxNumbers) {
        Logger.debug(
          "Pattern \(patternString) would exceed \(maxNumbers) limit. Stopping processing.",
          category: .blockerService
        )
        return
      }

      Logger.debug("Processing pattern: \(patternString)", category: .blockerService)

      // Process the pattern
      let numbers = PhoneNumberHelpers.expandBlockingPattern(patternString)
      let chunkSize = AppConstants.numberChunkSize
      let chunks = stride(from: 0, to: numbers.count, by: chunkSize).map {
        Array(numbers[$0..<min($0 + chunkSize, numbers.count)])
      }

      do {
        try await processChunks(chunks, for: pattern)
        Logger.debug("Completed pattern: \(patternString)", category: .blockerService)
        await patternService.markPatternAsCompleted(pattern)

        // Update cumulative count and first pattern flag
        totalProcessedNumbers += patternNumberCount
        isFirstPattern = false
      } catch {
        Logger.error(
          "Failed to process pattern \(patternString)",
          category: .blockerService,
          error: error
        )
        throw BlockerServiceError.patternProcessingFailed(error)
      }
    }
  }

  /// Process chunks iteratively
  private func processChunks(_ chunks: [[String]], for pattern: Pattern) async throws {
    for chunk in chunks {
      let numbersData = chunk.map { ["number": $0, "name": pattern.name ?? ""] }

      sharedUserDefaultsService.setAction(pattern.action ?? "block")
      sharedUserDefaultsService.setNumbers(numbersData)

      do {
        try await callDirectoryService.reloadExtension()
      } catch {
        Logger.error(
          "Failed to reload extension for chunk",
          category: .blockerService,
          error: error
        )
        throw BlockerServiceError.extensionReloadFailed(error)
      }
    }
  }
}
