import CoreData
import Foundation

/// Service for managing Pattern entities in CoreData
class PatternService {
  private let dataStack = CoreDataStack.shared

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
  ) async -> Pattern? {
    let context = dataStack.persistentContainer.viewContext

    return await withCheckedContinuation { continuation in
      context.perform {
        guard
          let entityDescription = NSEntityDescription.entity(forEntityName: "Pattern", in: context)
        else {
          Logger.error(
            "Failed to get Pattern entity description", category: .patternService,
            error: NSError(
              domain: "PatternService", code: 1,
              userInfo: [NSLocalizedDescriptionKey: "Failed to get Pattern entity description"]))
          continuation.resume(returning: nil)
          return
        }

        let pattern = NSManagedObject(entity: entityDescription, insertInto: context) as! Pattern
        pattern.pattern = patternString
        pattern.action = action
        pattern.name = name
        pattern.source = source
        pattern.sourceListName = sourceListName
        pattern.sourceVersion = sourceVersion
        pattern.addedDate = Date()

        Self.save(context: context)
        continuation.resume(returning: pattern)
      }
    }
  }

  // MARK: - Read Operations

  /// Fetches all patterns from CoreData
  /// - Returns: Array of all Pattern entities
  func getAllPatterns() async -> [Pattern] {
    let context = dataStack.persistentContainer.viewContext

    return await withCheckedContinuation { continuation in
      context.perform {
        let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")

        do {
          let patterns = try context.fetch(fetchRequest)
          continuation.resume(returning: patterns)
        } catch {
          Logger.error(
            "Failed to fetch all patterns: %{public}@",
            category: .patternService,
            error: error
          )
          continuation.resume(returning: [])
        }
      }
    }
  }

  /// Fetches a pattern by its pattern string
  /// - Parameter pattern: The pattern string to search for
  /// - Returns: The matching Pattern entity, or nil if not found
  func getPattern(byPatternString pattern: String) async -> Pattern? {
    let context = dataStack.persistentContainer.viewContext

    return await withCheckedContinuation { continuation in
      context.perform {
        let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
        fetchRequest.predicate = NSPredicate(format: "pattern == %@", pattern)

        do {
          let results = try context.fetch(fetchRequest)
          continuation.resume(returning: results.first)
        } catch {
          Logger.error(
            "Failed to fetch pattern %{public}@: %{public}@",
            category: .patternService,
            error: error
          )
          continuation.resume(returning: nil)
        }
      }
    }
  }

  /// Fetches all patterns that have not been completed yet
  /// - Returns: Array of Pattern entities where completedDate is nil
  func getPendingPatterns() async -> [Pattern] {
    let context = dataStack.persistentContainer.viewContext

    return await withCheckedContinuation { continuation in
      context.perform {
        let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
        fetchRequest.predicate = NSPredicate(format: "completedDate == nil")

        do {
          let patterns = try context.fetch(fetchRequest)
          continuation.resume(returning: patterns)
        } catch {
          Logger.error(
            "Failed to fetch pending patterns: %{public}@",
            category: .patternService,
            error: error
          )
          continuation.resume(returning: [])
        }
      }
    }
  }

  /// Fetches patterns by source
  /// - Parameter source: The source to filter by ("api" or "user")
  /// - Returns: Array of Pattern entities matching the source
  func getPatterns(bySource source: String) async -> [Pattern] {
    let context = dataStack.persistentContainer.viewContext

    return await withCheckedContinuation { continuation in
      context.perform {
        let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
        fetchRequest.predicate = NSPredicate(format: "source == %@", source)

        do {
          let patterns = try context.fetch(fetchRequest)
          continuation.resume(returning: patterns)
        } catch {
          Logger.error(
            "Failed to fetch patterns by source %{public}@: %{public}@",
            category: .patternService,
            error: error
          )
          continuation.resume(returning: [])
        }
      }
    }
  }

  /// Checks if any patterns exist in the database
  /// - Returns: true if at least one pattern exists, false otherwise
  func hasPatterns() async -> Bool {
    let context = dataStack.persistentContainer.viewContext

    return await withCheckedContinuation { continuation in
      context.perform {
        let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.resultType = .countResultType

        do {
          let count = try context.count(for: fetchRequest)
          continuation.resume(returning: count > 0)
        } catch {
          Logger.error(
            "Failed to count patterns: %{public}@",
            category: .patternService,
            error: error
          )
          continuation.resume(returning: false)
        }
      }
    }
  }

  /// Retrieves the oldest pending pattern for processing (FIFO order)
  /// - Returns: The oldest Pattern entity where completedDate is nil, or nil if none exist
  func retrievePatternForProcessing() async -> Pattern? {
    let pendingPatterns = await getPendingPatterns()
    return pendingPatterns.sorted {
      ($0.addedDate ?? .distantPast) < ($1.addedDate ?? .distantPast)
    }
    .first
  }

  /// Fetches all patterns that have been completed
  /// - Returns: Array of Pattern entities where completedDate is not nil
  func getCompletedPatterns() async -> [Pattern] {
    let context = dataStack.persistentContainer.viewContext

    return await withCheckedContinuation { continuation in
      context.perform {
        let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
        fetchRequest.predicate = NSPredicate(format: "completedDate != nil")

        do {
          let patterns = try context.fetch(fetchRequest)
          continuation.resume(returning: patterns)
        } catch {
          Logger.error(
            "Failed to fetch completed patterns: %{public}@",
            category: .patternService,
            error: error
          )
          continuation.resume(returning: [])
        }
      }
    }
  }

  /// Counts the total number of phone numbers represented by completed patterns
  /// - Returns: Total count of phone numbers
  func getCompletedPhoneNumbersCount() async -> Int64 {
    let completedPatterns = await getCompletedPatterns()
    return completedPatterns.reduce(0) { total, pattern in
      guard let patternString = pattern.pattern else { return total }
      return total + Int64(PhoneNumberHelpers.countPhoneNumbers(for: patternString))
    }
  }

  /// Counts the total number of phone numbers represented by all patterns in the database
  /// - Returns: Total count of phone numbers across all patterns
  func getTotalPhoneNumbersCount() async -> Int64 {
    let allPatterns = await getAllPatterns()
    return allPatterns.reduce(0) { total, pattern in
      guard let patternString = pattern.pattern else { return total }
      return total + Int64(PhoneNumberHelpers.countPhoneNumbers(for: patternString))
    }
  }

  /// Gets the most recent completion date from all completed patterns
  /// - Returns: The most recent completedDate, or nil if no patterns are completed
  func getLastCompletionDate() async -> Date? {
    let completedPatterns = await getCompletedPatterns()
    return completedPatterns.compactMap { $0.completedDate }.max()
  }

  /// Counts the number of completed patterns
  /// - Returns: Count of patterns with completedDate != nil
  func getCompletedPatternsCount() async -> Int {
    return await getCompletedPatterns().count
  }

  /// Counts the number of pending patterns
  /// - Returns: Count of patterns with completedDate == nil
  func getPendingPatternsCount() async -> Int {
    return await getPendingPatterns().count
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
  ) async {
    let context = dataStack.persistentContainer.viewContext
    let objectID = pattern.objectID

    await withCheckedContinuation { continuation in
      context.perform {
        let patternInContext = context.object(with: objectID) as! Pattern
        if let action = action {
          patternInContext.action = action
        }
        if let name = name {
          patternInContext.name = name
        }
        if let sourceListName = sourceListName {
          patternInContext.sourceListName = sourceListName
        }
        if let sourceVersion = sourceVersion {
          patternInContext.sourceVersion = sourceVersion
        }

        Self.save(context: context)
        continuation.resume()
      }
    }
  }

  /// Marks a pattern as completed
  /// - Parameter pattern: The Pattern entity to mark as completed
  func markPatternAsCompleted(_ pattern: Pattern) async {
    let context = dataStack.persistentContainer.viewContext
    let objectID = pattern.objectID

    await withCheckedContinuation { continuation in
      context.perform {
        let patternInContext = context.object(with: objectID) as! Pattern
        patternInContext.completedDate = Date()
        Self.save(context: context)
        continuation.resume()
      }
    }
  }

  /// Marks a pattern for deletion by changing its action and resetting completedDate
  /// - Parameters:
  ///   - pattern: The Pattern entity to mark for deletion
  ///   - removalAction: The removal action ("remove_block" or "remove_identify")
  func markPatternForDeletion(_ pattern: Pattern, removalAction: String) async {
    let context = dataStack.persistentContainer.viewContext
    let objectID = pattern.objectID

    await withCheckedContinuation { continuation in
      context.perform {
        let patternInContext = context.object(with: objectID) as! Pattern
        patternInContext.action = removalAction
        patternInContext.completedDate = nil
        Self.save(context: context)
        continuation.resume()
      }
    }
  }

  // MARK: - Delete Operations

  /// Deletes all patterns
  func deleteAllPatterns() async {
    let context = dataStack.persistentContainer.viewContext

    await withCheckedContinuation { continuation in
      context.perform {
        let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")

        do {
          let patterns = try context.fetch(fetchRequest)
          for pattern in patterns {
            context.delete(pattern)
          }
          Self.save(context: context)
          continuation.resume()
        } catch {
          Logger.error(
            "Failed to delete all patterns: %{public}@",
            category: .patternService,
            error: error
          )
          continuation.resume()
        }
      }
    }
  }

  /// Clears the completedDate on all patterns, making them pending again for reinstallation
  func clearAllCompletedDates() async {
    let context = dataStack.persistentContainer.viewContext

    await withCheckedContinuation { continuation in
      context.perform {
        let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")

        do {
          let patterns = try context.fetch(fetchRequest)
          for pattern in patterns {
            pattern.completedDate = nil
          }
          Self.save(context: context)
          continuation.resume()
        } catch {
          Logger.error(
            "Failed to clear completed dates: %{public}@",
            category: .patternService,
            error: error
          )
          continuation.resume()
        }
      }
    }
  }

  // MARK: - Private Methods

  /// Saves changes to the CoreData context
  private static func save(context: NSManagedObjectContext) {
    guard context.hasChanges else { return }

    do {
      try context.save()
    } catch {
      Logger.error(
        "Failed to save context: %{public}@",
        category: .patternService,
        error: error
      )
    }
  }
}
