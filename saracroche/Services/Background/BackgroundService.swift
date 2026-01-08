import BackgroundTasks
import Foundation
import OSLog

/// Background service for periodic updates
final class BackgroundService: ObservableObject {
  private let logger = Logger(subsystem: "com.cbouvat.saracroche", category: "BackgroundService")

  // MARK: - Constants
  private let backgroundServiceIdentifier = AppConstants.backgroundServiceIdentifier
  private let backgroundUpdateInterval = AppConstants.backgroundUpdateInterval
  private let blockerService: BlockerService

  init() {
    self.blockerService = BlockerService()
    setupBackgroundTasks()
  }

  // MARK: - Public Methods

  /// Force background update
  func forceBackgroundUpdate(completion: @escaping (Bool) -> Void) {
    performBackgroundUpdate(completion: completion)
  }

  // MARK: - Private Methods

  /// Setup background tasks
  private func setupBackgroundTasks() {
    BGTaskScheduler.shared.register(
      forTaskWithIdentifier: backgroundServiceIdentifier,
      using: nil
    ) { task in
      self.handleBackgroundUpdate(task: task as! BGProcessingTask)
    }
  }

  /// Schedule background task
  private func scheduleBackgroundTask() {
    let taskRequest = BGProcessingTaskRequest(identifier: backgroundServiceIdentifier)
    let scheduledDate = Date(timeIntervalSinceNow: backgroundUpdateInterval)
    taskRequest.earliestBeginDate = scheduledDate
    taskRequest.requiresNetworkConnectivity = true
    taskRequest.requiresExternalPower = true

    do {
      try BGTaskScheduler.shared.submit(taskRequest)
      logger.info("Background app refresh task scheduled for \(scheduledDate)")
    } catch {
      logger.error("Failed to schedule background app refresh: \(error)")
    }
  }

  /// Handle background update
  private func handleBackgroundUpdate(task: BGProcessingTask) {
    logger.info("Handling background app refresh")

    scheduleBackgroundTask()

    task.expirationHandler = {
      self.logger.warning("Background app refresh task expired")
      task.setTaskCompleted(success: false)
    }

    self.performBackgroundUpdate { success in
      task.setTaskCompleted(success: success)
    }
  }

  /// Perform background update
  private func performBackgroundUpdate(
    completion: @escaping (Bool) -> Void
  ) {
    logger.debug("Performing background update")
    blockerService.performBackgroundUpdate(completion: completion)
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
