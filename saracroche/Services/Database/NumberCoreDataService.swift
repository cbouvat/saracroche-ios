import CoreData

final class PatternCoreDataService {

  private let coreDataStack: CoreDataStack
  private var context: NSManagedObjectContext { coreDataStack.context }

  init(coreDataStack: CoreDataStack = CoreDataStack()) {
    self.coreDataStack = coreDataStack
  }

  /// Sync pending patterns to shared UserDefaults for the blocker extension
  func syncToSharedUserDefaults() {
    let pendingPatterns = getPendingPatterns()
    let patterns = pendingPatterns.compactMap { $0.pattern }

    let sharedUserDefaults = UserDefaults(suiteName: AppConstants.appGroupIdentifier)
    sharedUserDefaults?.set(patterns, forKey: "pendingPatterns")
  }

  /// Clear pending patterns from shared UserDefaults after processing
  func clearSharedUserDefaults() {
    let sharedUserDefaults = UserDefaults(suiteName: AppConstants.appGroupIdentifier)
    sharedUserDefaults?.removeObject(forKey: "pendingPatterns")
  }

  func addPattern(
    _ pattern: String,
    action: String = "block",
    name: String = "",
    source: String = "unknown",
    sourceListName: String = "",
    sourceVersion: String = ""
  ) -> Pattern {
    let patternObj = Pattern(context: context)
    patternObj.pattern = pattern
    patternObj.action = action
    patternObj.source = source
    patternObj.sourceListName = sourceListName
    patternObj.sourceVersion = sourceVersion
    patternObj.addedDate = Date()
    return patternObj
  }

  func saveContext() {
    coreDataStack.saveContext()
  }

  func getAllPatterns() -> [Pattern] {
    let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")

    do {
      return try context.fetch(fetchRequest)
    } catch {
      print("Failed to fetch patterns: \(error)")
      return []
    }
  }

  func deleteAllPatterns() {
    print("Delete all patterns in CoreData")
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pattern")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

    do {
      try context.execute(deleteRequest)
      coreDataStack.saveContext()
    } catch {
      print("Failed to delete patterns: \(error)")
    }
  }

  func getPattern(by pattern: String) -> Pattern? {
    let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
    fetchRequest.predicate = NSPredicate(format: "pattern == %@", pattern)
    fetchRequest.fetchLimit = 1

    do {
      return try context.fetch(fetchRequest).first
    } catch {
      print("Failed to fetch pattern: \(error)")
      return nil
    }
  }

  func deletePattern(_ pattern: String) {
    if let patternObj = getPattern(by: pattern) {
      context.delete(patternObj)
      coreDataStack.saveContext()
    }
  }

  func updatePattern(_ pattern: String, with newData: [String: Any]) {
    if let patternObj = getPattern(by: pattern) {
      for (key, value) in newData {
        patternObj.setValue(value, forKey: key)
      }
      coreDataStack.saveContext()
    }
  }

  /// Get pending patterns
  func getPendingPatterns() -> [Pattern] {
    let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
    fetchRequest.predicate = NSPredicate(format: "completedDate == nil")

    do {
      return try context.fetch(fetchRequest)
    } catch {
      print("Failed to fetch pending patterns: \(error)")
      return []
    }
  }

  /// Get pending patterns batch
  func getPendingPatternsBatch(limit: Int) -> [Pattern] {
    let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
    fetchRequest.predicate = NSPredicate(format: "completedDate == nil")
    fetchRequest.fetchLimit = limit

    do {
      return try context.fetch(fetchRequest)
    } catch {
      print("Failed to fetch pending patterns batch: \(error)")
      return []
    }
  }

  /// Mark pattern as completed
  func markPatternAsCompleted(_ pattern: String) {
    if let patternObj = getPattern(by: pattern) {
      patternObj.completedDate = Date()
      coreDataStack.saveContext()
    }
  }

  /// Mark multiple patterns as completed
  func markPatternsAsCompleted(_ patterns: [String]) {
    for pattern in patterns {
      markPatternAsCompleted(pattern)
    }
  }

  /// Get pending patterns count
  func getPendingPatternsCount() -> Int {
    let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
    fetchRequest.predicate = NSPredicate(format: "completedDate == nil")

    do {
      return try context.count(for: fetchRequest)
    } catch {
      print("Failed to count pending patterns: \(error)")
      return 0
    }
  }
}
