import Combine
import SwiftUI

/// View model for call blocker functionality
@MainActor
class BlockerViewModel: ObservableObject {
  @Published var blockerExtensionStatus: BlockerExtensionStatus = .unknown
  @Published var updateState: BlockerUpdateStatus = .ok
  @Published var lastSuccessfulUpdateAt: Date? = nil

  // Statistics for blocked numbers
  @Published var totalPhoneNumbersCount: Int64 = 0
  @Published var completedPhoneNumbersCount: Int64 = 0
  @Published var completedPatternsCount: Int = 0
  @Published var pendingPatternsCount: Int = 0
  @Published var lastCompletionDate: Date? = nil
  @Published var lastListDownloadAt: Date? = nil
  @Published var lastBackgroundLaunchAt: Date? = nil

  // Update state
  @Published var isUpdating: Bool = false
  @Published var updateError: String?
  @Published var isBackgroundRefreshEnabled: Bool = false
  @Published var isNotificationReminderEnabled: Bool = false
  @Published var isExtensionsSetupDismissed: Bool = false

  private let callDirectoryService: CallDirectoryService
  private let sharedUserDefaults: SharedUserDefaultsService
  private let userDefaults: UserDefaultsService
  private let blockerService: BlockerService
  private let patternService: PatternService
  private let notificationService: NotificationService

  init() {
    self.callDirectoryService = CallDirectoryService()
    self.userDefaults = UserDefaultsService()
    self.sharedUserDefaults = SharedUserDefaultsService()
    self.blockerService = BlockerService()
    self.patternService = PatternService()
    self.notificationService = NotificationService(userDefaults: self.userDefaults)
  }

  func loadData() async {
    lastSuccessfulUpdateAt = userDefaults.getLastSuccessfulUpdateAt()
    lastListDownloadAt = userDefaults.getLastListDownloadAt()
    lastBackgroundLaunchAt = userDefaults.getLastBackgroundLaunchAt()

    isNotificationReminderEnabled = userDefaults.getNotificationReminderEnabled()
    await notificationService.syncReminderStateOnLaunch()
    isNotificationReminderEnabled = userDefaults.getNotificationReminderEnabled()

    isExtensionsSetupDismissed = userDefaults.getExtensionsSetupDismissed()

    totalPhoneNumbersCount = await patternService.getTotalPhoneNumbersCount()
    completedPhoneNumbersCount = await patternService.getCompletedPhoneNumbersCount()
    completedPatternsCount = await patternService.getCompletedPatternsCount()
    pendingPatternsCount = await patternService.getPendingPatternsCount()
    lastCompletionDate = await patternService.getLastCompletionDate()
  }

  /// Performs update with state management
  func performUpdateWithStateManagement() async {
    // Set starting state
    updateState = .inProgress

    // Loop while there are pending patterns OR the list is empty
    while pendingPatternsCount > 0 || completedPatternsCount == 0 {
      // Check for cancellation at the beginning of each iteration
      if Task.isCancelled {
        Logger.debug("Update task cancelled", category: .blockerViewModel)
        return
      }

      do {
        // Perform the update with retry handled by the service
        try await blockerService.performUpdateWithRetry()

        // Check for cancellation after update
        if Task.isCancelled {
          Logger.debug("Update task cancelled after performUpdate", category: .blockerViewModel)
          return
        }

        // Refresh counts after each update
        totalPhoneNumbersCount = await patternService.getTotalPhoneNumbersCount()
        completedPhoneNumbersCount = await patternService.getCompletedPhoneNumbersCount()
        completedPatternsCount = await patternService.getCompletedPatternsCount()
        pendingPatternsCount = await patternService.getPendingPatternsCount()
      } catch is CancellationError {
        Logger.debug("Update task cancelled", category: .blockerViewModel)
        return
      } catch {
        Logger.error("Update failed", category: .blockerViewModel, error: error)
        updateState = .error
        updateError = error.localizedDescription
        return
      }
    }

    // Success - set ok state
    updateState = .ok
  }

  /// Enables the notification reminder after requesting permission
  func enableNotificationReminder() async {
    let granted = await notificationService.requestAuthorization()
    if granted {
      await notificationService.scheduleReminderNotification()
      userDefaults.setNotificationReminderEnabled(true)
      isNotificationReminderEnabled = true
    }
  }

  /// Dismisses the extensions setup card
  func dismissExtensionsSetup() {
    userDefaults.setExtensionsSetupDismissed(true)
    isExtensionsSetupDismissed = true
  }

  /// Disables the notification reminder
  func disableNotificationReminder() {
    notificationService.cancelReminderNotification()
    userDefaults.setNotificationReminderEnabled(false)
    isNotificationReminderEnabled = false
  }

  func checkBlockerExtensionStatus() async {
    do {
      blockerExtensionStatus = try await callDirectoryService.checkExtensionStatus()
    } catch {
      Logger.error("Failed to check extension status", category: .blockerViewModel, error: error)
      blockerExtensionStatus = .error
    }
  }

  func checkBackgroundStatus() async {
    isBackgroundRefreshEnabled = UIApplication.shared.backgroundRefreshStatus == .available
  }

  func openSettings() async {
    do {
      try await callDirectoryService.openSettings()
    } catch {
      Logger.error("Failed to open settings", category: .blockerViewModel, error: error)
    }
  }

  func resetApplication() async {
    // Cancel any pending notification reminders
    notificationService.cancelReminderNotification()

    // Clear all CoreData patterns
    await patternService.deleteAllPatterns()

    // Clear all UserDefaults data
    userDefaults.resetAllData()

    // Clear all SharedUserDefaults data
    sharedUserDefaults.resetAllData()

    // Send reset action to CallDirectory extension to remove all entries
    sharedUserDefaults.setAction("reset")
    sharedUserDefaults.setNumbers([])

    // Reload the extension to process the reset action
    do {
      try await callDirectoryService.reloadExtension()
    } catch {
      Logger.error(
        "Failed to reload extension during reset", category: .blockerViewModel, error: error)
    }

    // Exit the application
    exit(0)
  }

  /// Reinstalls the block list by resetting the extension and marking all patterns as pending
  func reinstallBlockList() async {
    await blockerService.resetExtensionState()

    // Refresh data to update counters
    await loadData()
  }
}
