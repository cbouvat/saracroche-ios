import BackgroundTasks
import Combine
import SwiftUI

class BlockerViewModel: ObservableObject {
  @Published var blockerExtensionStatus: BlockerExtensionStatus = .unknown
  @Published var isBackgroundServiceActive: Bool = false
  @Published var updateState: UpdateState = .idle

  @Published var blockerPhoneNumberBlocked: Int64 = 0
  @Published var blockerPhoneNumberTotal: Int64 = 0
  @Published var blocklistInstalledVersion: String = ""
  @Published var blocklistVersion: String = ""
  @Published var lastUpdateCheck: Date? = nil
  @Published var lastUpdate: Date? = nil
  @Published var updateStarted: Date? = nil
  @Published var blockedPatternsLastCheck: Date? = nil

  private let callDirectoryService = CallDirectoryService.shared
  private let BackgroundService = BackgroundService.shared
  private let sharedUserDefaults = SharedUserDefaultsService.shared
  private let userDefaults = UserDefaultsService.shared
  private var statusCheckTimer: Timer?

  deinit {
    statusCheckTimer?.invalidate()
  }

  init() {}

  // MARK: - Refresh Management
  func startPeriodicRefresh() {
    stopPeriodicRefresh()
    statusCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      self?.refreshData()
    }
  }

  func stopPeriodicRefresh() {
    statusCheckTimer?.invalidate()
    statusCheckTimer = nil
  }

  func refreshData() {
    checkUpdateState()

    checkBlockedPatternsForDailyRefresh()

    if updateState.isInProgress {
      return
    }

    checkBackgroundServiceStatus()
    checkBlockerExtensionStatus()
    checkAndForceUpdateIfNeeded()
  }

  // MARK: - Status Management
  func checkBlockerExtensionStatus() {
    callDirectoryService.checkExtensionStatus { [weak self] status in
      self?.blockerExtensionStatus = status
    }
  }

  func checkBackgroundServiceStatus() {
    BGTaskScheduler.shared.getPendingTaskRequests { [weak self] requests in
      DispatchQueue.main.async {
        self?.isBackgroundServiceActive = requests.contains {
          $0.identifier == "com.cbouvat.saracroche.background-update"
        }
      }
    }
  }

  private func checkBlockedPatternsForDailyRefresh() {
    guard BlockedPatternsService.shared.shouldCheckForNewPatterns() else { return }
    Task {
      do {
        try await BlockedPatternsService.shared.ensureLatestPatternsIfNeeded()
      } catch {
        print("Blocked patterns refresh failed: \(error.localizedDescription)")
      }
    }
  }

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

  // MARK: - Actions
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

  // MARK: - Open Settings
  func openSettings() {
    callDirectoryService.openSettings()
  }

  // MARK: - Reset Application
  func resetApplication() {
    // Clear all UserDefaults data
    userDefaults.resetAllData()

    // Clear all SharedUserDefaults data
    sharedUserDefaults.resetAllData()

    // Exit the application
    exit(0)
  }
}
