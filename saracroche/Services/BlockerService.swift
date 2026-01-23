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

    // 1. Check if pending patterns exist
    let pendingCount = await patternService.getPendingPatternsCount()

    // 2. If pending patterns exist → process ONE pattern and return
    if pendingCount > 0 {
      Logger.debug("Pending patterns found", category: .blockerService)
      do {
        try await processSinglePattern()
        // Success - set last update timestamp
        userDefaultsService.setLastSuccessfulUpdateAt(Date())
      } catch {
        throw BlockerServiceError.patternProcessingFailed(error)
      }
      return
    }

    // 3. If no pending patterns → check if update is needed
    let hasPatterns = await patternService.hasPatterns()
    if !hasPatterns {
      Logger.debug("No patterns found, launching update", category: .blockerService)
      do {
        try await listService.update()
        // Success - set last update timestamp
        userDefaultsService.setLastSuccessfulUpdateAt(Date())
      } catch {
        throw BlockerServiceError.listUpdateFailed(error)
      }
      return
    }

    if userDefaultsService.shouldUpdateList() {
      Logger.debug("Update needed based on date", category: .blockerService)
      do {
        try await listService.update()
        // Success - set last update timestamp
        userDefaultsService.setLastSuccessfulUpdateAt(Date())
      } catch {
        throw BlockerServiceError.listUpdateFailed(error)
      }
      return
    }

    // 4. No update needed, all patterns are completed
    Logger.debug("No update needed, all patterns are completed", category: .blockerService)
  }

  /// Process a single pending pattern
  private func processSinglePattern() async throws {
    guard let pattern = await patternService.retrievePatternForProcessing(),
      let patternString = pattern.pattern
    else {
      Logger.debug("No pending patterns", category: .blockerService)
      return
    }

    Logger.debug("Processing pattern: \(patternString)", category: .blockerService)

    let numbers = PhoneNumberHelpers.expandBlockingPattern(patternString)
    let chunkSize = AppConstants.numberChunkSize
    let chunks = stride(from: 0, to: numbers.count, by: chunkSize).map {
      Array(numbers[$0..<min($0 + chunkSize, numbers.count)])
    }

    do {
      try await processChunks(chunks, for: pattern)
      Logger.debug("Completed pattern: \(patternString)", category: .blockerService)
      await patternService.markPatternAsCompleted(pattern)
    } catch {
      Logger.error(
        "Failed to process pattern \(patternString)", category: .blockerService, error: error)
      throw BlockerServiceError.patternProcessingFailed(error)
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
          "Failed to reload extension for chunk", category: .blockerService, error: error)
        throw BlockerServiceError.extensionReloadFailed(error)
      }
    }
  }
}
