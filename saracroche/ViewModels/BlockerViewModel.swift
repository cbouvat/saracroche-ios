import Combine
import OSLog
import SwiftUI

private let logger = Logger(subsystem: "com.cbouvat.saracroche", category: "BlockerViewModel")

/// View model for call blocker functionality
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

    if updateState.isInProgress {
      return
    }

    checkBlockerExtensionStatus()
    loadPatternStatistics()
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

  /// Loads statistics about patterns and phone numbers from CoreData
  private func loadPatternStatistics() {
    DispatchQueue.main.async { [weak self] in
      self?.completedPhoneNumbersCount = self?.patternService.getCompletedPhoneNumbersCount() ?? 0
      self?.completedPatternsCount = self?.patternService.getCompletedPatternsCount() ?? 0
      self?.pendingPatternsCount = self?.patternService.getPendingPatternsCount() ?? 0
      self?.lastCompletionDate = self?.patternService.getLastCompletionDate()
    }
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
