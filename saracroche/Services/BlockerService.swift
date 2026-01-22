import Foundation
import OSLog

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
  private let logger = Logger(subsystem: "com.cbouvat.saracroche", category: "BlockerService")
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
    logger.debug("performUpdate called")

    // Check if update is needed
    if !patternService.hasPatterns() {
      logger.debug("No patterns found, launching update")
      do {
        try await listService.update()
      } catch {
        throw BlockerServiceError.listUpdateFailed(error)
      }
    } else if userDefaultsService.shouldUpdateList() {
      logger.debug("Update needed based on date")
      do {
        try await listService.update()
      } catch {
        throw BlockerServiceError.listUpdateFailed(error)
      }
    } else {
      logger.debug("No update needed")
    }

    // Process ONE pending pattern (if any)
    try await processSinglePattern()
  }

  /// Process a single pending pattern
  private func processSinglePattern() async throws {
    guard let pattern = patternService.retrievePatternForProcessing(),
      let patternString = pattern.pattern
    else {
      logger.debug("No pending patterns")
      return
    }

    logger.debug("Processing pattern: \(patternString)")

    let numbers = PhoneNumberHelpers.expandBlockingPattern(patternString)
    let chunkSize = AppConstants.numberChunkSize
    let chunks = stride(from: 0, to: numbers.count, by: chunkSize).map {
      Array(numbers[$0..<min($0 + chunkSize, numbers.count)])
    }

    do {
      try await processChunks(chunks, for: pattern)
      logger.debug("Completed pattern: \(patternString)")
      patternService.markPatternAsCompleted(pattern)
    } catch {
      logger.error("Failed to process pattern \(patternString): \(error)")
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
        logger.error("Failed to reload extension for chunk: \(error)")
        throw BlockerServiceError.extensionReloadFailed(error)
      }
    }
  }
}
