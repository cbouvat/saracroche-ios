import CoreData

final class CoreDataStack {

  private lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Database")

    // Configure the persistent store for App Groups
    guard
      let containerURL = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: "group.com.cbouvat.saracroche")
    else {
      fatalError("Unable to create container URL")
    }

    let storeURL = containerURL.appendingPathComponent("Database.sqlite")
    let description = NSPersistentStoreDescription(url: storeURL)
    container.persistentStoreDescriptions = [description]

    // Load the model first
    container.loadPersistentStores { storeDescription, error in
      if let error = error as NSError? {
        fatalError("Unresolved error: \(error)")
      }
    }

    // Verify the model is loaded
    if container.persistentStoreCoordinator.managedObjectModel.entities.isEmpty {
      fatalError("No entities found in the Core Data model!")
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
