import CoreData

final class BlockedNumberCoreDataService {
  static let shared = BlockedNumberCoreDataService()

  private let coreDataStack = CoreDataStack.shared
  private var context: NSManagedObjectContext { coreDataStack.context }

  func addBlockedNumber(_ phoneNumber: String) {
    let blockedNumber = BlockedNumber(context: context)
    blockedNumber.number = phoneNumber
    blockedNumber.addedDate = Date()

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
}
