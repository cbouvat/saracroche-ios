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


  /// Get the count of patterns waiting to be processed
  /// - Returns: Number of pending patterns
  func getPendingPatternCount() -> Int {
    return patternCoreDataService.getPendingPatternsCount()
  }
}
