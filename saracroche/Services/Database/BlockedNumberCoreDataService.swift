import CoreData

final class BlockedNumberCoreDataService {
  static let shared = BlockedNumberCoreDataService()

  private let coreDataStack = CoreDataStack.shared
  private var context: NSManagedObjectContext { coreDataStack.context }

  func addBlockedNumber(
    _ phoneNumber: String,
    action: String = "block",
    source: String = "unknown"
  ) -> BlockedNumber {
    let blockedNumber = BlockedNumber(context: context)
    blockedNumber.number = phoneNumber
    blockedNumber.action = action
    blockedNumber.source = source
    blockedNumber.addedDate = Date()
    return blockedNumber
  }

  func saveContext() {
    coreDataStack.saveContext()
  }

  func getAllBlockedNumbers() -> [BlockedNumber] {
    let fetchRequest: NSFetchRequest<BlockedNumber> = BlockedNumber.fetchRequest()

    do {
      return try context.fetch(fetchRequest)
    } catch {
      print("Failed to fetch blocked numbers: \(error)")
      return []
    }
  }

  func deleteAllBlockedNumbers() {
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = BlockedNumber.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

    do {
      try context.execute(deleteRequest)
      coreDataStack.saveContext()
    } catch {
      print("Failed to delete blocked numbers: \(error)")
    }
  }

  func getBlockedNumber(by phoneNumber: String) -> BlockedNumber? {
    let fetchRequest: NSFetchRequest<BlockedNumber> = BlockedNumber.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "number == %@", phoneNumber)
    fetchRequest.fetchLimit = 1

    do {
      return try context.fetch(fetchRequest).first
    } catch {
      print("Failed to fetch blocked number: \(error)")
      return nil
    }
  }

  func deleteBlockedNumber(_ phoneNumber: String) {
    if let blockedNumber = getBlockedNumber(by: phoneNumber) {
      context.delete(blockedNumber)
      coreDataStack.saveContext()
    }
  }

  func updateBlockedNumber(_ phoneNumber: String, with newData: [String: Any]) {
    if let blockedNumber = getBlockedNumber(by: phoneNumber) {
      for (key, value) in newData {
        blockedNumber.setValue(value, forKey: key)
      }
      coreDataStack.saveContext()
    }
  }

  /// Gets all blocked numbers that have not been completed (completedDate is nil).
  /// These numbers need to be processed in batches.
  ///
  /// - Returns: An array of blocked numbers with completedDate = nil.
  func getPendingBlockedNumbers() -> [BlockedNumber] {
    let fetchRequest: NSFetchRequest<BlockedNumber> = BlockedNumber.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "completedDate == nil")

    do {
      return try context.fetch(fetchRequest)
    } catch {
      print("Failed to fetch pending blocked numbers: \(error)")
      return []
    }
  }

  /// Gets a batch of pending blocked numbers for processing.
  ///
  /// - Parameter limit: The maximum number of numbers to return.
  /// - Returns: An array of blocked numbers with completedDate = nil, limited to the specified count.
  func getPendingBlockedNumbersBatch(limit: Int) -> [BlockedNumber] {
    let fetchRequest: NSFetchRequest<BlockedNumber> = BlockedNumber.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "completedDate == nil")
    fetchRequest.fetchLimit = limit

    do {
      return try context.fetch(fetchRequest)
    } catch {
      print("Failed to fetch pending blocked numbers batch: \(error)")
      return []
    }
  }

  /// Marks a blocked number as completed by setting its completedDate.
  ///
  /// - Parameter phoneNumber: The phone number to mark as completed.
  func markBlockedNumberAsCompleted(_ phoneNumber: String) {
    if let blockedNumber = getBlockedNumber(by: phoneNumber) {
      blockedNumber.completedDate = Date()
      coreDataStack.saveContext()
    }
  }

  /// Marks multiple blocked numbers as completed.
  ///
  /// - Parameter phoneNumbers: An array of phone numbers to mark as completed.
  func markBlockedNumbersAsCompleted(_ phoneNumbers: [String]) {
    for phoneNumber in phoneNumbers {
      markBlockedNumberAsCompleted(phoneNumber)
    }
  }

  /// Gets the count of pending blocked numbers (completedDate = nil).
  ///
  /// - Returns: The count of pending blocked numbers.
  func getPendingBlockedNumbersCount() -> Int {
    let fetchRequest: NSFetchRequest<BlockedNumber> = BlockedNumber.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "completedDate == nil")

    do {
      return try context.count(for: fetchRequest)
    } catch {
      print("Failed to count pending blocked numbers: \(error)")
      return 0
    }
  }
}
