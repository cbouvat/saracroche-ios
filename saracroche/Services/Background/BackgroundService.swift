import BackgroundTasks
import Foundation

/// Background service to handle periodic updates and background tasks
final class BackgroundService: ObservableObject {

  /// Lazy initialization to avoid circular dependency
  private static var _shared: BackgroundService?

  // MARK: - Constants
  private let backgroundServiceIdentifier = AppConstants.backgroundServiceIdentifier
  private let backgroundUpdateInterval = AppConstants.backgroundUpdateInterval

  private init() {
    setupBackgroundTasks()
    scheduleBackgroundTask()
  }

  /// Shared instance with lazy initialization to avoid circular dependency
  static var shared: BackgroundService {
    if let instance = _shared {
      return instance
    }
    let instance = BackgroundService()
    _shared = instance
    return instance
  }

  // MARK: - Public Methods

  /// Triggers an immediate background update.
  func forceBackgroundUpdate(completion: @escaping (Bool) -> Void) {
    performBackgroundUpdate(completion: completion)
  }

  // MARK: - Private Methods

  /// Setup background task.
  private func setupBackgroundTasks() {
    BGTaskScheduler.shared.register(
      forTaskWithIdentifier: backgroundServiceIdentifier,
      using: nil
    ) { task in
      self.handleBackgroundUpdate(task: task as! BGProcessingTask)
    }
  }

  /// Shedule background task.
  private func scheduleBackgroundTask() {
    let taskRequest = BGProcessingTaskRequest(identifier: backgroundServiceIdentifier)
    let scheduledDate = Date(timeIntervalSinceNow: backgroundUpdateInterval)
    taskRequest.earliestBeginDate = scheduledDate
    taskRequest.requiresNetworkConnectivity = true
    taskRequest.requiresExternalPower = true

    do {
      try BGTaskScheduler.shared.submit(taskRequest)
      print("Background app refresh task scheduled for \(scheduledDate)")
    } catch {
      print("Failed to schedule background app refresh: \(error)")
    }
  }

  /// Handles the system-provided task by kicking off the refresh pipeline and capturing expiration.
  private func handleBackgroundUpdate(task: BGProcessingTask) {
    print("Handling background app refresh")

    scheduleBackgroundTask()

    task.expirationHandler = {
      print("Background app refresh task expired")
      task.setTaskCompleted(success: false)
    }

    self.performBackgroundUpdate { success in
      task.setTaskCompleted(success: success)
    }
  }

  /// Delegates the blocklist refresh to the pipeline workflow.
  private func performBackgroundUpdate(
    completion: @escaping (Bool) -> Void
  ) {
    print("Performing background update")
    BlockerUpdatePipeline.shared.performBackgroundUpdate(completion: completion)
  }
}

// MARK: - App Lifecycle Methods
extension BackgroundService {
  func applicationDidEnterBackground() {
    scheduleBackgroundTask()
  }

  func applicationWillTerminate() {
    scheduleBackgroundTask()
  }
}
