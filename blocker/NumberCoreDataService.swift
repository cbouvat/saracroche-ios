import CoreData

final class NumberCoreDataService {
  private let coreDataStack: CoreDataStack
  private var context: NSManagedObjectContext { coreDataStack.context }

  init(coreDataStack: CoreDataStack = CoreDataStack()) {
    self.coreDataStack = coreDataStack
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

  func getNumbersByAction(_ action: String) -> [Number] {
    let fetchRequest: NSFetchRequest<Number> = Number.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "action == %@", action)

    do {
      return try context.fetch(fetchRequest)
    } catch {
      print("Failed to fetch numbers by action: \(error)")
      return []
    }
  }

  func getNumbersByActionBatch(_ action: String, limit: Int) -> [Number] {
    let fetchRequest: NSFetchRequest<Number> = Number.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "action == %@", action)
    fetchRequest.fetchLimit = limit

    do {
      return try context.fetch(fetchRequest)
    } catch {
      print("Failed to fetch numbers by action batch: \(error)")
      return []
    }
  }

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

  func markNumbersAsCompleted(_ phoneNumbers: [String]) {
    for phoneNumber in phoneNumbers {
      if let number = getNumber(by: phoneNumber) {
        number.completedDate = Date()
      }
    }
    coreDataStack.saveContext()
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
}
