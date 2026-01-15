import Foundation
import OSLog

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

  /// Perform background update
  func performBackgroundUpdate(completion: @escaping (Bool) -> Void) {
    logger.debug("performBackgroundUpdate called")
    performUpdate(onProgress: {}, completion: completion)
  }

  /// Perform update with progress callback
  func performUpdate(
    onProgress: @escaping () -> Void,
    completion: @escaping (Bool) -> Void
  ) {
    logger.debug("performUpdate called")

    // 1. Check if there are blocked numbers
    if !patternService.hasPatterns() {
      // No patterns, launch update
      logger.debug("No patterns found, launching update")
      listService.update(onProgress: onProgress) { [weak self] success in
        if success {
          self?.processPendingPatterns(completion: completion)
        } else {
          completion(false)
        }
      }
    } else {
      // Patterns exist, check if update is needed
      if userDefaultsService.shouldUpdateList() {
        logger.debug("Update needed based on date")
        listService.update(onProgress: onProgress) { [weak self] success in
          if success {
            self?.processPendingPatterns(completion: completion)
          } else {
            completion(false)
          }
        }
      } else {
        logger.debug("No update needed")
        processPendingPatterns(completion: completion)
      }
    }
  }

  /// Process pending patterns recursively
  private func processPendingPatterns(completion: @escaping (Bool) -> Void) {
    guard let pattern = patternService.retrievePatternForProcessing(),
      let patternString = pattern.pattern
    else {
      logger.debug("No more pending patterns")
      completion(true)
      return
    }

    logger.debug("Processing pattern: \(patternString)")

    // Expand pattern
    let numbers = PhoneNumberHelpers.expandBlockingPattern(patternString)
    let chunkSize = AppConstants.numberChunkSize
    let chunks = stride(from: 0, to: numbers.count, by: chunkSize).map {
      Array(numbers[$0..<min($0 + chunkSize, numbers.count)])
    }

    processChunks(chunks, for: pattern) { [weak self] success in
      if success {
        self?.patternService.markPatternAsCompleted(pattern)
        self?.processPendingPatterns(completion: completion)
      } else {
        completion(false)
      }
    }
  }

  /// Process chunks recursively
  private func processChunks(
    _ chunks: [[String]],
    for pattern: Pattern,
    completion: @escaping (Bool) -> Void
  ) {
    var remainingChunks = chunks
    guard let chunk = remainingChunks.first else {
      completion(true)
      return
    }

    remainingChunks.removeFirst()

    let numbersData = chunk.map { ["number": $0, "name": pattern.name ?? ""] }

    sharedUserDefaultsService.setAction(pattern.action ?? "block")
    sharedUserDefaultsService.setNumbers(numbersData)

    callDirectoryService.reloadExtension { [weak self] success in
      if success {
        self?.processChunks(remainingChunks, for: pattern, completion: completion)
      } else {
        self?.logger.error("Failed to reload extension for chunk")
        completion(false)
      }
    }
  }
}
