import CoreData

/// Thread-safe CoreData stack with proper context management
class CoreDataStack: ObservableObject {
  static let shared = CoreDataStack()

  private init() {}

  // MARK: - Persistent Container

  /// The main persistent container, stored in App Group for extension access
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "DataModel")

    let storeURL = FileManager.default
      .containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupIdentifier)!
      .appendingPathComponent("DataModel.sqlite")

    let description = NSPersistentStoreDescription(url: storeURL)
    container.persistentStoreDescriptions = [description]

    container.loadPersistentStores { _, error in
      if let error {
        fatalError("Failed to load persistent stores: \(error.localizedDescription)")
      }
    }
    return container
  }()

  // MARK: - Background Context

  /// Private background context for off-main-thread operations
  private lazy var _backgroundContext: NSManagedObjectContext = {
    let context = persistentContainer.newBackgroundContext()
    context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    context.automaticallyMergesChangesFromParent = true
    return context
  }()

  // MARK: - Public Methods

  /// Get the view context (main thread only)
  func viewContext() -> NSManagedObjectContext {
    return persistentContainer.viewContext
  }

  /// Get a private background context for off-main-thread operations
  func backgroundContext() -> NSManagedObjectContext {
    return _backgroundContext
  }

  /// Perform a block on the view context
  func performOnViewContext(_ block: @escaping (NSManagedObjectContext) -> Void) {
    viewContext().perform { [weak self] in
      block(
        self?.viewContext() ?? self?.persistentContainer.viewContext
          ?? NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
    }
  }

  /// Perform a block on the background context
  func performOnBackgroundContext(_ block: @escaping (NSManagedObjectContext) -> Void) {
    _backgroundContext.perform { [weak self] in
      block(
        self?._backgroundContext ?? self?.persistentContainer.newBackgroundContext()
          ?? NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType))
    }
  }

  /// Save changes in a context
  func saveContext(_ context: NSManagedObjectContext) throws {
    var saveError: Error?
    context.performAndWait {
      if context.hasChanges {
        do {
          try context.save()
        } catch {
          saveError = error
        }
      }
    }

    if let saveError {
      throw saveError
    }
  }
}
