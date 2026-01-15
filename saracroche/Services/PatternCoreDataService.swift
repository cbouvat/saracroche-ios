import CoreData
import OSLog

final class PatternCoreDataService {
  private let logger = Logger(
    subsystem: "com.cbouvat.saracroche", category: "PatternCoreDataService")
  private let coreDataStack: CoreDataStack
  private var context: NSManagedObjectContext { coreDataStack.context }

  init(coreDataStack: CoreDataStack = CoreDataStack()) {
    self.coreDataStack = coreDataStack
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

  func saveContext() throws {
    try coreDataStack.saveContext()
  }

  func getAllPatterns() -> [Pattern] {
    let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")

    do {
      return try context.fetch(fetchRequest)
    } catch {
      logger.error("Failed to fetch patterns: \(error)")
      return []
    }
  }

  func deleteAllPatterns() {
    logger.debug("Delete all patterns in CoreData")
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pattern")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

    do {
      try context.execute(deleteRequest)
      try coreDataStack.saveContext()
    } catch {
      logger.error("Failed to delete patterns: \(error)")
    }
  }

  func getPattern(by pattern: String) -> Pattern? {
    let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
    fetchRequest.predicate = NSPredicate(format: "pattern == %@", pattern)
    fetchRequest.fetchLimit = 1

    do {
      return try context.fetch(fetchRequest).first
    } catch {
      logger.error("Failed to fetch pattern: \(error)")
      return nil
    }
  }

  func deletePattern(_ pattern: String) {
    if let patternObj = getPattern(by: pattern) {
      context.delete(patternObj)
      do {
        try coreDataStack.saveContext()
      } catch {
        logger.error("Failed to save after deleting pattern: \(error)")
      }
    }
  }

  func updatePattern(_ pattern: String, with newData: [String: Any]) {
    if let patternObj = getPattern(by: pattern) {
      for (key, value) in newData {
        patternObj.setValue(value, forKey: key)
      }
      // Note: Context is not saved here to allow batch updates
      // Caller should call saveContext() after all modifications
    }
  }

  /// Get pending patterns
  func getPendingPatterns() -> [Pattern] {
    let fetchRequest = NSFetchRequest<Pattern>(entityName: "Pattern")
    fetchRequest.predicate = NSPredicate(format: "completedDate == nil")

    do {
      return try context.fetch(fetchRequest)
    } catch {
      logger.error("Failed to fetch pending patterns: \(error)")
      return []
    }
  }

  /// Mark pattern as completed
  func markPatternAsCompleted(_ pattern: String) {
    if let patternObj = getPattern(by: pattern) {
      patternObj.completedDate = Date()
      // Note: Context is not saved here to allow batch updates
      // Caller should call saveContext() after all modifications
    }
  }
}
