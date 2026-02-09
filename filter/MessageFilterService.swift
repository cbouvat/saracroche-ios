import CoreData
import OSLog

private let logger = Logger(
  subsystem: "com.cbouvat.saracroche.filter", category: "MessageFilterService")

/// Service responsible for checking incoming SMS senders against blocking patterns
final class MessageFilterService {

  /// App Group identifier shared with the main app
  private static let appGroupIdentifier = "group.com.cbouvat.saracroche"

  /// Checks if a sender should be filtered based on stored blocking patterns
  /// - Parameter sender: The phone number or identifier of the SMS sender
  /// - Returns: `true` if the sender matches a blocking pattern
  func shouldFilter(sender: String) -> Bool {
    let context = Self.persistentContainer.viewContext

    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Pattern")
    fetchRequest.predicate = NSPredicate(
      format: "action == %@ AND completedDate != nil", "block")

    do {
      let patterns = try context.fetch(fetchRequest)
      for patternObject in patterns {
        guard let pattern = patternObject.value(forKey: "pattern") as? String else {
          continue
        }
        if Self.matches(sender: sender, pattern: pattern) {
          logger.info("Sender \(sender, privacy: .private) matched pattern \(pattern)")
          return true
        }
      }
    } catch {
      logger.error("Failed to fetch patterns: \(error.localizedDescription)")
    }

    return false
  }

  /// Checks if a sender matches a blocking pattern character by character
  /// - `#` in the pattern matches any digit
  /// - Any other character must match exactly
  /// - Parameters:
  ///   - sender: The phone number to check
  ///   - pattern: The blocking pattern (e.g. `0899######`)
  /// - Returns: `true` if the sender matches the pattern
  static func matches(sender: String, pattern: String) -> Bool {
    guard sender.count == pattern.count else { return false }
    return zip(sender, pattern).allSatisfy { s, p in
      p == "#" || s == p
    }
  }

  // MARK: - CoreData Stack (read-only, lightweight)

  private static let persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "DataModel")

    let storeURL = FileManager.default
      .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)!
      .appendingPathComponent("DataModel.sqlite")

    let description = NSPersistentStoreDescription(url: storeURL)
    description.isReadOnly = true
    container.persistentStoreDescriptions = [description]

    container.loadPersistentStores { _, error in
      if let error {
        logger.error("Failed to load persistent stores: \(error.localizedDescription)")
      }
    }
    return container
  }()
}
