import CoreData

final class CoreDataStack {
  static let shared = CoreDataStack()

  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Database")
    container.loadPersistentStores { _, error in
      if let error = error as NSError? {
        fatalError("Unresolved error: \(error)")
      }
    }
    return container
  }()

  var context: NSManagedObjectContext {
    return persistentContainer.viewContext
  }

  func saveContext() {
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error: \(nserror)")
      }
    }
  }
}
