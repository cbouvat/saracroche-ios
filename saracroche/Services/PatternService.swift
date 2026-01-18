import CoreData
import Foundation
import OSLog

/// Service for managing Pattern entities in CoreData
class PatternService {
  private let dataStack = CoreDataStack.shared
  private let logger = OSLog(subsystem: "com.saracroche", category: "PatternService")

  // MARK: - Create Operations

  /// Creates and saves a new pattern to CoreData
  /// - Parameters:
  ///   - patternString: The blocking pattern with '#' wildcards
  ///   - action: The action to take ("block", "identify", or "remove")
  ///   - name: Optional operator/source name
  ///   - source: The source of the pattern ("api" or "user")
  ///   - sourceListName: Optional list name from API
  ///   - sourceVersion: Optional list version from API
  /// - Returns: The created Pattern entity, or nil if creation fails
  func createPattern(
    patternString: String,
    action: String,
    name: String? = nil,
    source: String,
    sourceListName: String? = nil,
    sourceVersion: String? = nil
  ) -> Pattern? {
    let context = dataStack.persistentContainer.viewContext

    guard let entityDescription = NSEntityDescription.entity(forEntityName: "Pattern", in: context)
    else {
      os_log("Failed to get Pattern entity description", log: self.logger, type: .error)
      return nil
    }

    let pattern = NSManagedObject(entity: entityDescription, insertInto: context) as! Pattern
    pattern.pattern = patternString
    pattern.action = action
    pattern.name = name
    pattern.source = source
    pattern.sourceListName = sourceListName
    pattern.sourceVersion = sourceVersion
    pattern.addedDate = Date()

    save()
    return pattern
  }

  // MARK: - Read Operations

  /// Fetches all patterns from CoreData
  /// - Returns: Array of all Pattern entities
  func getAllPatterns() -> [Pattern] {
    let context = dataStack.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")

    do {
      return try context.fetch(fetchRequest)
    } catch {
      os_log(
        "Failed to fetch all patterns: %{public}@",
        log: self.logger,
        type: .error,
        error.localizedDescription
      )
      return []
    }
  }

  /// Fetches a pattern by its pattern string
  /// - Parameter pattern: The pattern string to search for
  /// - Returns: The matching Pattern entity, or nil if not found
  func getPattern(byPatternString pattern: String) -> Pattern? {
    let context = dataStack.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
    fetchRequest.predicate = NSPredicate(format: "pattern == %@", pattern)

    do {
      let results = try context.fetch(fetchRequest)
      return results.first
    } catch {
      os_log(
        "Failed to fetch pattern %{public}@: %{public}@",
        log: self.logger,
        type: .error,
        pattern,
        error.localizedDescription
      )
      return nil
    }
  }

  /// Fetches all patterns that have not been completed yet
  /// - Returns: Array of Pattern entities where completedDate is nil
  func getPendingPatterns() -> [Pattern] {
    let context = dataStack.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
    fetchRequest.predicate = NSPredicate(format: "completedDate == nil")

    do {
      return try context.fetch(fetchRequest)
    } catch {
      os_log(
        "Failed to fetch pending patterns: %{public}@",
        log: self.logger,
        type: .error,
        error.localizedDescription
      )
      return []
    }
  }

  /// Fetches patterns by source
  /// - Parameter source: The source to filter by ("api" or "user")
  /// - Returns: Array of Pattern entities matching the source
  func getPatterns(bySource source: String) -> [Pattern] {
    let context = dataStack.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
    fetchRequest.predicate = NSPredicate(format: "source == %@", source)

    do {
      return try context.fetch(fetchRequest)
    } catch {
      os_log(
        "Failed to fetch patterns by source %{public}@: %{public}@",
        log: self.logger,
        type: .error,
        source,
        error.localizedDescription
      )
      return []
    }
  }

  /// Fetches patterns by action
  /// - Parameter action: The action to filter by ("block", "identify", or "remove")
  /// - Returns: Array of Pattern entities matching the action
  func getPatterns(byAction action: String) -> [Pattern] {
    let context = dataStack.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
    fetchRequest.predicate = NSPredicate(format: "action == %@", action)

    do {
      return try context.fetch(fetchRequest)
    } catch {
      os_log(
        "Failed to fetch patterns by action %{public}@: %{public}@",
        log: self.logger,
        type: .error,
        action,
        error.localizedDescription
      )
      return []
    }
  }

  /// Checks if any patterns exist in the database
  /// - Returns: true if at least one pattern exists, false otherwise
  func hasPatterns() -> Bool {
    let context = dataStack.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
    fetchRequest.returnsObjectsAsFaults = true
    fetchRequest.resultType = .countResultType

    do {
      let count = try context.count(for: fetchRequest)
      return count > 0
    } catch {
      os_log(
        "Failed to count patterns: %{public}@",
        log: self.logger,
        type: .error,
        error.localizedDescription
      )
      return false
    }
  }

  /// Retrieves the first pending pattern for processing
  /// - Returns: The first Pattern entity where completedDate is nil, or nil if none exist
  func retrievePatternForProcessing() -> Pattern? {
    let pendingPatterns = getPendingPatterns()
    return pendingPatterns.first
  }

  /// Fetches all patterns that have been completed
  /// - Returns: Array of Pattern entities where completedDate is not nil
  func getCompletedPatterns() -> [Pattern] {
    let context = dataStack.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
    fetchRequest.predicate = NSPredicate(format: "completedDate != nil")

    do {
      return try context.fetch(fetchRequest)
    } catch {
      os_log(
        "Failed to fetch completed patterns: %{public}@",
        log: self.logger,
        type: .error,
        error.localizedDescription
      )
      return []
    }
  }

  /// Counts the total number of phone numbers represented by completed patterns
  /// - Returns: Total count of phone numbers
  func getCompletedPhoneNumbersCount() -> Int64 {
    let completedPatterns = getCompletedPatterns()
    return completedPatterns.reduce(0) { total, pattern in
      guard let patternString = pattern.pattern else { return total }
      return total + Int64(PhoneNumberHelpers.countPhoneNumbers(for: patternString))
    }
  }

  /// Gets the most recent completion date from all completed patterns
  /// - Returns: The most recent completedDate, or nil if no patterns are completed
  func getLastCompletionDate() -> Date? {
    let completedPatterns = getCompletedPatterns()
    return completedPatterns.compactMap { $0.completedDate }.max()
  }

  /// Counts the number of completed patterns
  /// - Returns: Count of patterns with completedDate != nil
  func getCompletedPatternsCount() -> Int {
    return getCompletedPatterns().count
  }

  /// Counts the number of pending patterns
  /// - Returns: Count of patterns with completedDate == nil
  func getPendingPatternsCount() -> Int {
    return getPendingPatterns().count
  }

  // MARK: - Update Operations

  /// Updates an existing pattern
  /// - Parameters:
  ///   - pattern: The Pattern entity to update
  ///   - action: New action value (optional)
  ///   - name: New name value (optional)
  ///   - sourceListName: New sourceListName value (optional)
  ///   - sourceVersion: New sourceVersion value (optional)
  func updatePattern(
    _ pattern: Pattern,
    action: String? = nil,
    name: String? = nil,
    sourceListName: String? = nil,
    sourceVersion: String? = nil
  ) {
    if let action = action {
      pattern.action = action
    }
    if let name = name {
      pattern.name = name
    }
    if let sourceListName = sourceListName {
      pattern.sourceListName = sourceListName
    }
    if let sourceVersion = sourceVersion {
      pattern.sourceVersion = sourceVersion
    }

    save()
  }

  /// Marks a pattern as completed
  /// - Parameter pattern: The Pattern entity to mark as completed
  func markPatternAsCompleted(_ pattern: Pattern) {
    pattern.completedDate = Date()
    save()
  }

  // MARK: - Delete Operations

  /// Deletes a pattern from CoreData
  /// - Parameter pattern: The Pattern entity to delete
  func deletePattern(_ pattern: Pattern) {
    let context = dataStack.persistentContainer.viewContext
    context.delete(pattern)
    save()
  }

  /// Deletes all patterns
  func deleteAllPatterns() {
    let context = dataStack.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")

    do {
      let patterns = try context.fetch(fetchRequest)
      for pattern in patterns {
        context.delete(pattern)
      }
      save()
    } catch {
      os_log(
        "Failed to delete all patterns: %{public}@",
        log: self.logger,
        type: .error,
        error.localizedDescription
      )
    }
  }

  /// Deletes all patterns from a specific source
  /// - Parameter source: The source to filter by ("api" or "user")
  func deletePatterns(bySource source: String) {
    let context = dataStack.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
    fetchRequest.predicate = NSPredicate(format: "source == %@", source)

    do {
      let patterns = try context.fetch(fetchRequest)
      for pattern in patterns {
        context.delete(pattern)
      }
      save()
    } catch {
      os_log(
        "Failed to delete patterns by source %{public}@: %{public}@",
        log: self.logger,
        type: .error,
        source,
        error.localizedDescription
      )
    }
  }

  // MARK: - Batch Operations

  /// Creates multiple patterns in batch
  /// - Parameter patternsData: Array of tuples containing pattern data
  /// - Returns: Array of created Pattern entities
  func createPatterns(
    _ patternsData: [(
      patternString: String, action: String, name: String?, source: String, sourceListName: String?,
      sourceVersion: String?
    )]
  ) -> [Pattern] {
    var createdPatterns: [Pattern] = []

    for data in patternsData {
      if let pattern = createPattern(
        patternString: data.patternString,
        action: data.action,
        name: data.name,
        source: data.source,
        sourceListName: data.sourceListName,
        sourceVersion: data.sourceVersion
      ) {
        createdPatterns.append(pattern)
      }
    }

    return createdPatterns
  }

  /// Marks multiple patterns as completed
  /// - Parameter patterns: Array of Pattern entities to mark as completed
  func markPatternsAsCompleted(_ patterns: [Pattern]) {
    for pattern in patterns {
      pattern.completedDate = Date()
    }
    save()
  }

  // MARK: - Private Methods

  /// Saves changes to the CoreData context
  private func save() {
    let context = dataStack.persistentContainer.viewContext

    guard context.hasChanges else { return }

    do {
      try context.save()
    } catch {
      os_log(
        "Failed to save context: %{public}@",
        log: self.logger,
        type: .error,
        error.localizedDescription
      )
    }
  }
}
