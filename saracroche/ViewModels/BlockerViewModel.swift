import BackgroundTasks
import Combine
import SwiftUI

/// A view model that manages the state and logic for the call blocker functionality.
/// This view model handles extension status, background service status, and block list updates.
class BlockerViewModel: ObservableObject {
  /// The current status of the CallKit extension.
  @Published var blockerExtensionStatus: BlockerExtensionStatus = .unknown

  /// Indicates whether the background service is active.
  @Published var isBackgroundServiceActive: Bool = false

  /// The current state of the block list update process.
  @Published var updateState: UpdateState = .idle

  /// The number of phone numbers currently blocked by the extension.
  @Published var blockerPhoneNumberBlocked: Int64 = 0

  /// The total number of phone numbers in the block list.
  @Published var blockerPhoneNumberTotal: Int64 = 0

  /// The version of the block list currently installed.
  @Published var blocklistInstalledVersion: String = ""

  /// The latest available version of the block list.
  @Published var blocklistVersion: String = ""

  /// The date when the last update check was performed.
  @Published var lastUpdateCheck: Date? = nil

  /// The date when the last successful update occurred.
  @Published var lastUpdate: Date? = nil

  /// The date when the current update process started.
  @Published var updateStarted: Date? = nil

  /// The date when blocked patterns were last checked.
  @Published var blockedPatternsLastCheck: Date? = nil

  /// Service for managing CallKit extension functionality.
  private let callDirectoryService = CallDirectoryService.shared

  /// Service for managing background tasks.
  private let BackgroundService = BackgroundService.shared

  /// Service for accessing shared user defaults across app extensions.
  private let sharedUserDefaults = SharedUserDefaultsService.shared

  /// Service for accessing local user defaults.
  private let userDefaults = UserDefaultsService.shared

  /// Timer for periodic status checks.
  private var statusCheckTimer: Timer?

  /// Invalidates the status check timer when the view model is deallocated.
  deinit {
    statusCheckTimer?.invalidate()
  }

  /// Initializes the view model.
  init() {}

  /// MARK: - Refresh Management
  ///
  /// Starts a periodic timer to refresh data at regular intervals.
  /// The timer fires every second and calls refreshData().
  func startPeriodicRefresh() {
    stopPeriodicRefresh()
    statusCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      self?.refreshData()
    }
  }

  /// Stops the periodic refresh timer.
  func stopPeriodicRefresh() {
    statusCheckTimer?.invalidate()
    statusCheckTimer = nil
  }

  /// Refreshes all data including extension status, background service status, and update state.
  func refreshData() {
    checkUpdateState()

    if updateState.isInProgress {
      return
    }

    checkBackgroundServiceStatus()
    checkBlockerExtensionStatus()
    checkAndForceUpdateIfNeeded()
  }

  /// MARK: - Status Management
  ///
  /// Checks the current status of the CallKit extension and updates the published property.
  func checkBlockerExtensionStatus() {
    callDirectoryService.checkExtensionStatus { [weak self] status in
      self?.blockerExtensionStatus = status
    }
  }

  /// Checks the status of the background service and updates the published property.
  func checkBackgroundServiceStatus() {
    BGTaskScheduler.shared.getPendingTaskRequests { [weak self] requests in
      DispatchQueue.main.async {
        self?.isBackgroundServiceActive = requests.contains {
          $0.identifier == "com.cbouvat.saracroche.background-update"
        }
      }
    }
  }

  /// Checks and updates the current state of block list updates and related metrics.
  func checkUpdateState() {
    DispatchQueue.main.async { [weak self] in
      self?.blockerPhoneNumberBlocked = Int64(
        self?.sharedUserDefaults.getBlockedNumbers() ?? 0
      )
      self?.blockerPhoneNumberTotal = Int64(
        self?.userDefaults.getTotalBlockedNumbers() ?? 0
      )
      self?.blocklistInstalledVersion =
        self?.userDefaults
        .getBlocklistVersion() ?? ""
      self?.updateState = self?.userDefaults.getUpdateState() ?? .idle
      self?.lastUpdateCheck = self?.userDefaults.getLastUpdateCheck()
      self?.lastUpdate = self?.userDefaults.getLastUpdate()
      self?.updateStarted = self?.userDefaults.getUpdateStarted()
      self?.blockedPatternsLastCheck =
        self?.userDefaults.getBlockedPatternsLastCheck()
    }
  }

  /// Checks if an update is needed and forces an update if required.
  ///
  /// An update is forced if:
  /// - The blocker extension is enabled
  /// - No update is currently in progress
  /// - No numbers are currently blocked, or
  /// - The installed block list version doesn't match the latest version
  private func checkAndForceUpdateIfNeeded() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }

      // Only proceed if the blocker extension is enabled
      guard self.blockerExtensionStatus == .enabled else {
        return
      }

      // Only proceed if no update is currently in progress
      guard self.updateState == .idle else {
        return
      }

      if blockerPhoneNumberBlocked == 0 || blocklistInstalledVersion != blocklistVersion {
        self.forceUpdateBlockerList()
      }
    }
  }

  /// MARK: - Actions
  ///
  /// Forces an immediate update of the blocker list in the background.
  /// This bypasses the normal scheduling and triggers an update immediately.
  func forceUpdateBlockerList() {
    BackgroundService.forceBackgroundUpdate { success in
      DispatchQueue.main.async {
        if success {
          self.userDefaults.setUpdateState(.idle)
        } else {
          self.userDefaults.setUpdateState(.error)
        }
      }
    }
  }

  /// MARK: - Open Settings
  ///
  /// Opens the iOS Settings app to the Call Directory extension activation panel.
  func openSettings() {
    callDirectoryService.openSettings()
  }

  /// MARK: - Reset Application
  ///
  /// Resets the application state by clearing all stored data and exiting the app.
  /// This is useful for troubleshooting or when the app needs to be completely reset.
  func resetApplication() {
    // Clear all UserDefaults data
    userDefaults.resetAllData()

    // Clear all SharedUserDefaults data
    sharedUserDefaults.resetAllData()

    // Exit the application
    exit(0)
  }
}
