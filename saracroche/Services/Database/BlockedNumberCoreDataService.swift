import CoreData

final class BlockedNumberCoreDataService {

  private let coreDataStack: CoreDataStack
  private var context: NSManagedObjectContext { coreDataStack.context }

  init(coreDataStack: CoreDataStack = CoreDataStack()) {
    self.coreDataStack = coreDataStack
  }

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

  /// Get pending blocked numbers
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

  /// Get pending blocked numbers batch
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

  /// Mark blocked number as completed
  func markBlockedNumberAsCompleted(_ phoneNumber: String) {
    if let blockedNumber = getBlockedNumber(by: phoneNumber) {
      blockedNumber.completedDate = Date()
      coreDataStack.saveContext()
    }
  }

  /// Mark multiple blocked numbers as completed
  func markBlockedNumbersAsCompleted(_ phoneNumbers: [String]) {
    for phoneNumber in phoneNumbers {
      markBlockedNumberAsCompleted(phoneNumber)
    }
  }

  /// Get pending blocked numbers count
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
