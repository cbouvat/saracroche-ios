import BackgroundTasks
import Foundation
import OSLog

/// Background service for periodic updates
final class BackgroundService: ObservableObject {
  private let logger = Logger(subsystem: "com.cbouvat.saracroche", category: "BackgroundService")

  // MARK: - Constants
  private let backgroundServiceIdentifier = AppConstants.backgroundServiceIdentifier
  private let backgroundUpdateInterval = AppConstants.backgroundUpdateInterval

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

    // Use Task to bridge sync context to async
    Task {
      do {
        try await BlockerService().performUpdate()
        task.setTaskCompleted(success: true)
      } catch {
        logger.error("Background update failed: \(error)")
        task.setTaskCompleted(success: false)
      }
    }
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
