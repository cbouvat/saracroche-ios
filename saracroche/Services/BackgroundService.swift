import BackgroundTasks
import Foundation
import UIKit

/// Background service for periodic updates
final class BackgroundService: ObservableObject {

  // MARK: - Constants
  private let backgroundServiceIdentifier = AppConstants.backgroundServiceIdentifier
  private let backgroundUpdateInterval = AppConstants.backgroundUpdateInterval

  // MARK: - Properties
  private let userDefaults: UserDefaultsService

  // MARK: - Initialization
  init() {
    self.userDefaults = UserDefaultsService()
    registerBackgroundTasks()
  }

  // MARK: - Setup

  /// Register background tasks
  private func registerBackgroundTasks() {
    Logger.info("Register background tasks", category: .backgroundService)
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
      Logger.info(
        "Background app refresh task scheduled for \(scheduledDate)", category: .backgroundService)
    } catch {
      Logger.error(
        "Failed to schedule background app refresh", category: .backgroundService, error: error)
    }
  }

  /// Handle background update
  private func handleBackgroundUpdate(task: BGProcessingTask) {
    Logger.info("Handling background app refresh", category: .backgroundService)

    // Record the background launch time
    userDefaults.setLastBackgroundLaunchAt(Date())

    scheduleBackgroundTask()

    task.expirationHandler = {
      Logger.info("Background app refresh task expired", category: .backgroundService)
      task.setTaskCompleted(success: false)
    }

    // Use Task to bridge sync context to async
    Task {
      do {
        try await BlockerService().performUpdateWithRetry()
        task.setTaskCompleted(success: true)
      } catch {
        Logger.error("Background update failed", category: .backgroundService, error: error)
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
