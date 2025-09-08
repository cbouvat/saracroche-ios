import BackgroundTasks
import Foundation

class BackgroundUpdateService: ObservableObject {

  static let shared = BackgroundUpdateService()

  // MARK: - Constants
  //private let backgroundUpdateIdentifier = AppConstants.backgroundUpdateIdentifier
  //private let backgroundUpdateInterval = AppConstants.backgroundUpdateInterval
  private let currentBlocklistVersion = AppConstants.currentBlocklistVersion

  // MARK: - Services
  private let callDirectoryService = CallDirectoryService.shared
  private let sharedUserDefaults = SharedUserDefaultsService.shared
  private let userDefaults = UserDefaultsService.shared

  private init() {
    setupBackgroundTasks()
    scheduleBackgroundTask()
  }

  // MARK: - Public Methods

  func forceBackgroundUpdate(completion: @escaping (Bool) -> Void) {
    performBackgroundUpdate(completion: completion)
  }

  // MARK: - Private Methods
  private func setupBackgroundTasks() {
    BGTaskScheduler.shared.register(
      forTaskWithIdentifier: "com.cbouvat.saracroche.background-update",
      using: nil
    ) { task in
      self.handleBackgroundUpdate(task: task as! BGProcessingTask)
    }
  }

  private func scheduleBackgroundTask() {
    let taskRequest = BGProcessingTaskRequest(
      identifier: "com.cbouvat.saracroche.background-update")
    taskRequest.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60 * 60)
    taskRequest.requiresNetworkConnectivity = false
    taskRequest.requiresExternalPower = false

    do {
      try BGTaskScheduler.shared.submit(taskRequest)
      print(
        "Background app refresh task scheduled for \(Date(timeIntervalSinceNow: 1 * 60 * 60))"
      )
    } catch {
      print("Failed to schedule background app refresh: \(error)")
    }
  }

  private func handleBackgroundUpdate(task: BGProcessingTask) {
    print("Handling background app refresh")

    scheduleBackgroundTask()

    task.expirationHandler = {
      print("Background app refresh task expired")
      task.setTaskCompleted(success: false)
    }

    let currentBlockedNumbers = sharedUserDefaults.getBlockedNumbers()
    let currentVersion = userDefaults.getBlocklistVersion()
    let availableVersion = currentBlocklistVersion

    self.userDefaults.setLastUpdateCheck(Date())

    if currentVersion != availableVersion || currentBlockedNumbers == 0 {
      print("Update needed: \(currentVersion) -> \(availableVersion)")
      self.performBackgroundUpdate { success in
        task.setTaskCompleted(success: success)
      }
      return
    } else {
      print("No update needed")
    }

    task.setTaskCompleted(success: true)
  }

  private func performBackgroundUpdate(completion: @escaping (Bool) -> Void) {
    print("Performing background update")
    self.userDefaults.setUpdateStarted(Date())
    self.userDefaults.setUpdateState(.starting)

    // Check extension status
    callDirectoryService.checkExtensionStatus { [weak self] status in
      guard status == .enabled else {
        self?.userDefaults.setUpdateState(.error)
        self?.userDefaults.clearUpdateStarted()
        completion(false)
        return
      }

      // Use the service directly for the update
      self?.callDirectoryService.updateBlockerList(
        onProgress: {
          self?.userDefaults.setUpdateState(.installing)
        },
        onCompletion: { success in
          if success {

            self?.userDefaults.setLastUpdate(Date())
            self?.userDefaults.setUpdateState(.idle)
          }
          self?.userDefaults.clearUpdateStarted()
          completion(success)
        }
      )
    }
  }
}

// MARK: - App Lifecycle Methods

extension BackgroundUpdateService {
  func applicationDidEnterBackground() {
    scheduleBackgroundTask()
  }

  func applicationWillTerminate() {
    scheduleBackgroundTask()
  }
}
