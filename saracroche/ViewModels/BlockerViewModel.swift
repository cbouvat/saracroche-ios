import Combine
import SwiftUI

/// View model for call blocker functionality
class BlockerViewModel: ObservableObject {
  @Published var blockerExtensionStatus: BlockerExtensionStatus = .unknown
  @Published var updateState: UpdateState = .idle
  @Published var lastUpdateCheck: Date? = nil
  @Published var lastUpdate: Date? = nil
  @Published var updateStarted: Date? = nil

  private let callDirectoryService = CallDirectoryService.shared
  private let sharedUserDefaults = SharedUserDefaultsService.shared
  private let userDefaults = UserDefaultsService.shared
  private let blockerUpdatePipeline = BlockerUpdatePipeline.shared
  private var statusCheckTimer: Timer?

  deinit {
    statusCheckTimer?.invalidate()
  }

  init() {
  }

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

    if updateState.isInProgress {
      return
    }

    checkBlockerExtensionStatus()
    checkAndForceUpdateIfNeeded()
  }

  func checkBlockerExtensionStatus() {
    callDirectoryService.checkExtensionStatus { [weak self] status in
      self?.blockerExtensionStatus = status
    }
  }

  func checkUpdateState() {
    DispatchQueue.main.async { [weak self] in
      self?.updateState = self?.userDefaults.getUpdateState() ?? .idle
      self?.lastUpdateCheck = self?.userDefaults.getLastUpdateCheck()
      self?.lastUpdate = self?.userDefaults.getLastUpdate()
      self?.updateStarted = self?.userDefaults.getUpdateStarted()
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

      self.forceUpdateBlockerList()
    }
  }

  func forceUpdateBlockerList() {
    print("🔄 [BlockerViewModel] forceUpdateBlockerList called")
    blockerUpdatePipeline.performUpdate(
      onProgress: { [weak self] in
        self?.checkUpdateState()
      },
      completion: { [weak self] success in
        self?.checkUpdateState()
      }
    )
  }

  func openSettings() {
    callDirectoryService.openSettings()
  }

  func resetApplication() {
    // Clear all UserDefaults data
    userDefaults.resetAllData()

    // Clear all SharedUserDefaults data
    sharedUserDefaults.resetAllData()

    // Exit the application
    exit(0)
  }
}
