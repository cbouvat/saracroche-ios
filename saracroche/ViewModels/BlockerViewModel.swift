import Combine
import OSLog
import SwiftUI
import UIKit

private let logger = Logger(subsystem: "com.cbouvat.saracroche", category: "BlockerViewModel")

/// View model for call blocker functionality
@MainActor
class BlockerViewModel: ObservableObject {
  @Published var blockerExtensionStatus: BlockerExtensionStatus = .unknown
  @Published var updateState: UpdateState = .idle
  @Published var lastUpdateCheck: Date? = nil
  @Published var lastUpdate: Date? = nil
  @Published var updateStarted: Date? = nil

  // Statistics for blocked numbers
  @Published var completedPhoneNumbersCount: Int64 = 0
  @Published var completedPatternsCount: Int = 0
  @Published var pendingPatternsCount: Int = 0
  @Published var lastCompletionDate: Date? = nil

  // Update state
  @Published var isUpdating: Bool = false
  @Published var updateError: String?
  @Published var isBackgroundRefreshEnabled: Bool = false

  private let callDirectoryService: CallDirectoryService
  private let sharedUserDefaults: SharedUserDefaultsService
  private let userDefaults: UserDefaultsService
  private let blockerService: BlockerService
  private let patternService: PatternService
  private var statusCheckTimer: Timer?

  deinit {
    statusCheckTimer?.invalidate()
  }

  init() {
    self.callDirectoryService = CallDirectoryService()
    self.userDefaults = UserDefaultsService()
    self.sharedUserDefaults = SharedUserDefaultsService()
    self.blockerService = BlockerService()
    self.patternService = PatternService()
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
    checkBackgroundServiceStatus()

    if updateState.isInProgress {
      return
    }

    Task {
      await checkBlockerExtensionStatus()
    }
    loadPatternStatistics()
  }

  func checkBlockerExtensionStatus() async {
    do {
      blockerExtensionStatus = try await callDirectoryService.checkExtensionStatus()
    } catch {
      logger.error("Failed to check extension status: \(error)")
      blockerExtensionStatus = .error
    }
  }

  func checkUpdateState() {
    updateState = userDefaults.getUpdateState()
    lastUpdateCheck = userDefaults.getLastUpdateCheck()
    lastUpdate = userDefaults.getLastUpdate()
    updateStarted = userDefaults.getUpdateStarted()
  }

  func checkBackgroundServiceStatus() {
    isBackgroundRefreshEnabled = UIApplication.shared.backgroundRefreshStatus == .available
  }

  /// Loads statistics about patterns and phone numbers from CoreData
  private func loadPatternStatistics() {
    completedPhoneNumbersCount = patternService.getCompletedPhoneNumbersCount()
    completedPatternsCount = patternService.getCompletedPatternsCount()
    pendingPatternsCount = patternService.getPendingPatternsCount()
    lastCompletionDate = patternService.getLastCompletionDate()
  }

  func openSettings() async {
    do {
      try await callDirectoryService.openSettings()
    } catch {
      logger.error("Failed to open settings: \(error)")
    }
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
