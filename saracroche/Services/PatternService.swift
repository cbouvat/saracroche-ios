import CoreData
import Foundation

/// Service for retrieving and processing patterns
final class PatternService {

  // MARK: - Dependencies

  private let patternCoreDataService: PatternCoreDataService

  // MARK: - Initialization

  init(patternCoreDataService: PatternCoreDataService = PatternCoreDataService()) {
    self.patternCoreDataService = patternCoreDataService
  }

  /// Retrieve a pattern to process
  /// - Returns: An optional Pattern object that needs processing, or nil if no patterns are available
  func retrievePatternForProcessing() -> Pattern? {
    // Get pending patterns (those without a completedDate)
    let pendingPatterns = patternCoreDataService.getPendingPatterns()

    // Return the first pending pattern if available
    return pendingPatterns.first
  }

  /// Check if there are any patterns in the database
  /// - Returns: True if there are patterns, false otherwise
  func hasPatterns() -> Bool {
    return !patternCoreDataService.getAllPatterns().isEmpty
  }

  /// Mark a pattern as completed
  /// - Parameter pattern: The pattern string to mark as completed
  func markPatternAsCompleted(_ pattern: String) {
    patternCoreDataService.markPatternAsCompleted(pattern)
  }
}
