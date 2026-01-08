import CoreData
import Foundation
import OSLog

/// Core Data stack manager for the Saracroche app.
///
/// Manages the Core Data persistent container with App Group support for data sharing
/// between the main app and extensions. Provides context management and error handling.
final class CoreDataStack {

  // MARK: - Properties

  private let logger = Logger(subsystem: "com.cbouvat.saracroche", category: "CoreDataStack")

  /// The persistent container for Core Data stack with App Group configuration
  private lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: AppConstants.coreDataModelName)

    // Configure the persistent store for App Groups
    guard
      let containerURL = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupIdentifier)
    else {
      logger.error("Unable to create container URL for App Group")
      // Fallback to default container if App Group is not available
      container.loadPersistentStores { storeDescription, error in
        if let error = error as NSError? {
          self.logger.error("Failed to load persistent stores: \(error.localizedDescription)")
        }
      }
      return container
    }

    let storeURL = containerURL.appendingPathComponent("\(AppConstants.coreDataModelName).sqlite")
    let description = NSPersistentStoreDescription(url: storeURL)
    container.persistentStoreDescriptions = [description]

    // Load the persistent stores
    container.loadPersistentStores { storeDescription, error in
      if let error = error as NSError? {
        self.logger.error(
          "Failed to load persistent stores: \(error.localizedDescription), user info: \(error.userInfo)"
        )
        // In production, handle this more gracefully (e.g., try to delete and recreate the store)
        #if DEBUG
          fatalError("Unresolved error: \(error)")
        #endif
      } else {
        self.logger.info(
          "Persistent store loaded successfully at: \(storeDescription.url?.path ?? "unknown")")
      }
    }

    // Verify the model is loaded
    if container.persistentStoreCoordinator.managedObjectModel.entities.isEmpty {
      logger.warning("No entities found in the Core Data model!")
    }

    return container
  }()

  // MARK: - Public API

  /// The main view context for Core Data operations
  var context: NSManagedObjectContext {
    return persistentContainer.viewContext
  }

  /// Saves the current context if there are any changes
  ///
  /// - Throws: An error if the save operation fails
  func saveContext() throws {
    guard context.hasChanges else {
      return
    }

    do {
      try context.save()
      logger.debug("Context saved successfully")
    } catch {
      let nserror = error as NSError
      logger.error(
        "Failed to save context: \(nserror.localizedDescription), user info: \(nserror.userInfo)")
      throw error
    }
  }
}
