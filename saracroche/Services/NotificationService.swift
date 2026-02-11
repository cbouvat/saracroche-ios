import UserNotifications

/// Service for managing local notification reminders
class NotificationService {

  private static let reminderIdentifier = "com.cbouvat.saracroche.update-reminder"

  private let center = UNUserNotificationCenter.current()
  private let userDefaults: UserDefaultsService

  init(userDefaults: UserDefaultsService) {
    self.userDefaults = userDefaults
  }

  /// Requests notification authorization (alert only, no sound)
  /// - Returns: `true` if authorization was granted
  func requestAuthorization() async -> Bool {
    do {
      let granted = try await center.requestAuthorization(options: [.alert])
      Logger.info(
        "Notification authorization \(granted ? "granted" : "denied")",
        category: .notificationService
      )
      return granted
    } catch {
      Logger.error(
        "Failed to request notification authorization",
        category: .notificationService, error: error
      )
      return false
    }
  }

  /// Checks whether notification authorization is currently granted
  /// - Returns: `true` if notifications are authorized
  private func isAuthorized() async -> Bool {
    let settings = await center.notificationSettings()
    return settings.authorizationStatus == .authorized
  }

  /// Schedules a repeating silent reminder notification every 15 days
  func scheduleReminderNotification() async {
    // Remove any existing reminder before scheduling
    cancelReminderNotification()

    let content = UNMutableNotificationContent()
    content.title = "Saracroche"
    content.body =
      "Ouvrez l'application pour mettre à jour votre liste de blocage."

    let trigger = UNTimeIntervalNotificationTrigger(
      timeInterval: AppConstants.notificationReminderInterval,
      repeats: true
    )

    let request = UNNotificationRequest(
      identifier: Self.reminderIdentifier,
      content: content,
      trigger: trigger
    )

    do {
      try await center.add(request)
      Logger.info("Reminder notification scheduled", category: .notificationService)
    } catch {
      Logger.error(
        "Failed to schedule reminder notification",
        category: .notificationService, error: error
      )
    }
  }

  /// Cancels the pending reminder notification
  func cancelReminderNotification() {
    center.removePendingNotificationRequests(
      withIdentifiers: [Self.reminderIdentifier]
    )
    Logger.info("Reminder notification cancelled", category: .notificationService)
  }

  /// Syncs the reminder state on launch:
  /// - If enabled in UserDefaults but permission revoked → disables the preference
  /// - If enabled and authorized but no pending notification → re-schedules
  func syncReminderStateOnLaunch() async {
    guard userDefaults.getNotificationReminderEnabled() else {
      return
    }

    let authorized = await isAuthorized()

    if !authorized {
      // Permission was revoked — disable the preference
      userDefaults.setNotificationReminderEnabled(false)
      Logger.info(
        "Notification permission revoked, disabling reminder preference",
        category: .notificationService
      )
      return
    }

    // Check if the notification is still pending
    let pendingRequests = await center.pendingNotificationRequests()
    let hasReminder = pendingRequests.contains { $0.identifier == Self.reminderIdentifier }

    if !hasReminder {
      await scheduleReminderNotification()
      Logger.info(
        "Re-scheduled missing reminder notification",
        category: .notificationService
      )
    }
  }
}
