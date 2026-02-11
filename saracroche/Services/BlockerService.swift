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

  // MARK: - Dependencies

  private let callDirectoryService: CallDirectoryService
  private let userDefaultsService: UserDefaultsService
  private let listService: ListService
  private let patternService: PatternService
  private let sharedUserDefaultsService: SharedUserDefaultsService

  // MARK: - Initialization

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

  // MARK: - Extension Management

  /// Checks the current status of the Call Directory extension
  func checkExtensionStatus() async throws -> BlockerExtensionStatus {
    try await callDirectoryService.checkExtensionStatus()
  }

  /// Opens the app's settings page
  func openSettings() async throws {
    try await callDirectoryService.openSettings()
  }

  /// Resets the Call Directory extension state and invalidates all patterns
  func resetExtensionState() async {
    sharedUserDefaultsService.setAction("reset")
    sharedUserDefaultsService.setNumbers([])
    do {
      try await callDirectoryService.reloadExtension()
    } catch {
      Logger.error(
        "Failed to reload extension during reset, continuing anyway",
        category: .blockerService, error: error)
    }
    await patternService.clearAllCompletedDates()
  }

  // MARK: - Update

  /// Perform update
  func performUpdate() async throws {
    Logger.debug("performUpdate called", category: .blockerService)

    // 1. Requeue expired patterns so the Call Directory extension stays up to date
    let resetCount = await patternService.resetExpiredCompletedPatterns()
    if resetCount > 0 {
      Logger.debug(
        "Reset \(resetCount) expired completed patterns", category: .blockerService)
    }

    // 2. Purge completed removal patterns that have been processed
    let deletedCount = await patternService.deleteCompletedRemovalPatterns()
    if deletedCount > 0 {
      Logger.debug(
        "Deleted \(deletedCount) completed removal patterns", category: .blockerService)
    }

    // 3. Process pending patterns (includes freshly requeued ones)
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

    // 4. First launch: no patterns at all → download the list
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

    // 5. Stale list: refresh if last download was more than 24 h ago
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

    // 6. Nothing to do — all patterns are installed and the list is fresh
    Logger.debug("No update needed, all patterns are completed", category: .blockerService)
  }

  /// Performs `performUpdate()` with retry, reset, and exponential backoff
  func performUpdateWithRetry() async throws {
    var retryCount = 0
    let maxRetries = 5

    while true {
      do {
        try Task.checkCancellation()
        try await performUpdate()
        return
      } catch is CancellationError {
        throw CancellationError()
      } catch {
        retryCount += 1

        if retryCount > maxRetries {
          Logger.error(
            "Update failed after \(maxRetries) attempts",
            category: .blockerService, error: error)
          throw error
        }

        // Calculate linear backoff delay (5s, 10s, 15s, 20s, 25s)
        let delaySeconds = 5.0 * Double(retryCount)

        Logger.error(
          "Update failed (attempt \(retryCount)/\(maxRetries)), resetting extension and retrying in \(delaySeconds)s",
          category: .blockerService, error: error)

        // Reset extension state to recover from potential corruption
        await resetExtensionState()

        // Wait before retrying
        try await Task.sleep(nanoseconds: UInt64(delaySeconds) * 1_000_000_000)
      }
    }
  }

  // MARK: - Reset

  /// Resets the entire application: cancels notifications, deletes all data, and exits
  func resetApplication(notificationService: NotificationService) async {
    notificationService.cancelReminderNotification()
    await patternService.deleteAllPatterns()
    userDefaultsService.resetAllData()
    sharedUserDefaultsService.resetAllData()
    sharedUserDefaultsService.setAction("reset")
    sharedUserDefaultsService.setNumbers([])
    do {
      try await callDirectoryService.reloadExtension()
    } catch {
      Logger.error(
        "Failed to reload extension during reset",
        category: .blockerService, error: error)
    }
    exit(0)
  }

  // MARK: - Private Helpers

  /// Process multiple pending patterns up to a limit
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
