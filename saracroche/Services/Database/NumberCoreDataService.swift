import CoreData

final class NumberCoreDataService {

  private let coreDataStack: CoreDataStack
  private var context: NSManagedObjectContext { coreDataStack.context }

  init(coreDataStack: CoreDataStack = CoreDataStack()) {
    self.coreDataStack = coreDataStack
  }

  func addNumber(
    _ phoneNumber: String,
    action: String = "block",
    source: String = "unknown"
  ) -> Number {
    let number = Number(context: context)
    number.number = phoneNumber
    number.action = action
    number.source = source
    number.addedDate = Date()
    return number
  }

  func saveContext() {
    coreDataStack.saveContext()
  }

  func getAllNumbers() -> [Number] {
    let fetchRequest: NSFetchRequest<Number> = Number.fetchRequest()

    do {
      return try context.fetch(fetchRequest)
    } catch {
      print("Failed to fetch numbers: \(error)")
      return []
    }
  }

  func deleteAllNumbers() {
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Number.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

    do {
      try context.execute(deleteRequest)
      coreDataStack.saveContext()
    } catch {
      print("Failed to delete numbers: \(error)")
    }
  }

  func getNumber(by phoneNumber: String) -> Number? {
    let fetchRequest: NSFetchRequest<Number> = Number.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "number == %@", phoneNumber)
    fetchRequest.fetchLimit = 1

    do {
      return try context.fetch(fetchRequest).first
    } catch {
      print("Failed to fetch number: \(error)")
      return nil
    }
  }

  func deleteNumber(_ phoneNumber: String) {
    if let number = getNumber(by: phoneNumber) {
      context.delete(number)
      coreDataStack.saveContext()
    }
  }

  func updateNumber(_ phoneNumber: String, with newData: [String: Any]) {
    if let number = getNumber(by: phoneNumber) {
      for (key, value) in newData {
        number.setValue(value, forKey: key)
      }
      coreDataStack.saveContext()
    }
  }

  /// Get pending numbers
  func getPendingNumbers() -> [Number] {
    let fetchRequest: NSFetchRequest<Number> = Number.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "completedDate == nil")

    do {
      return try context.fetch(fetchRequest)
    } catch {
      print("Failed to fetch pending numbers: \(error)")
      return []
    }
  }

  /// Get pending numbers batch
  func getPendingNumbersBatch(limit: Int) -> [Number] {
    let fetchRequest: NSFetchRequest<Number> = Number.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "completedDate == nil")
    fetchRequest.fetchLimit = limit

    do {
      return try context.fetch(fetchRequest)
    } catch {
      print("Failed to fetch pending numbers batch: \(error)")
      return []
    }
  }

  /// Mark number as completed
  func markNumberAsCompleted(_ phoneNumber: String) {
    if let number = getNumber(by: phoneNumber) {
      number.completedDate = Date()
      coreDataStack.saveContext()
    }
  }

  /// Mark multiple numbers as completed
  func markNumbersAsCompleted(_ phoneNumbers: [String]) {
    for phoneNumber in phoneNumbers {
      markNumberAsCompleted(phoneNumber)
    }
  }

  /// Get pending numbers count
  func getPendingNumbersCount() -> Int {
    let fetchRequest: NSFetchRequest<Number> = Number.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "completedDate == nil")

    do {
      return try context.count(for: fetchRequest)
    } catch {
      print("Failed to count pending numbers: \(error)")
      return 0
    }
  }
}
