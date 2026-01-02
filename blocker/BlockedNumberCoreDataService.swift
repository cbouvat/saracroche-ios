import CoreData

final class BlockedNumberCoreDataService {
  static let shared = BlockedNumberCoreDataService()

  private let coreDataStack = CoreDataStack.shared
  private var context: NSManagedObjectContext { coreDataStack.context }

  func getAllBlockedNumbers() -> [BlockedNumber] {
    let fetchRequest: NSFetchRequest<BlockedNumber> = BlockedNumber.fetchRequest()

    do {
      return try context.fetch(fetchRequest)
    } catch {
      print("Failed to fetch blocked numbers: \(error)")
      return []
    }
  }

  func getBlockedNumbersByAction(_ action: String) -> [BlockedNumber] {
    let fetchRequest: NSFetchRequest<BlockedNumber> = BlockedNumber.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "action == %@", action)

    do {
      return try context.fetch(fetchRequest)
    } catch {
      print("Failed to fetch blocked numbers by action: \(error)")
      return []
    }
  }

  func getBlockedNumbersByActionBatch(_ action: String, limit: Int) -> [BlockedNumber] {
    let fetchRequest: NSFetchRequest<BlockedNumber> = BlockedNumber.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "action == %@", action)
    fetchRequest.fetchLimit = limit

    do {
      return try context.fetch(fetchRequest)
    } catch {
      print("Failed to fetch blocked numbers by action batch: \(error)")
      return []
    }
  }

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

  func markBlockedNumbersAsCompleted(_ phoneNumbers: [String]) {
    for phoneNumber in phoneNumbers {
      if let blockedNumber = getBlockedNumber(by: phoneNumber) {
        blockedNumber.completedDate = Date()
      }
    }
    coreDataStack.saveContext()
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
}
