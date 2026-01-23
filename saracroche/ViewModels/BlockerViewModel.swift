import Combine
import OSLog
import SwiftUI

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
  private var refreshTask: Task<Void, Never>?

  deinit {
    refreshTask?.cancel()
  }

  init() {
    self.callDirectoryService = CallDirectoryService()
    self.userDefaults = UserDefaultsService()
    self.sharedUserDefaults = SharedUserDefaultsService()
    self.blockerService = BlockerService()
    self.patternService = PatternService()
  }

  func startAutoRefresh() {
    stopAutoRefresh()

    refreshTask = Task { @MainActor [weak self] in
      while !Task.isCancelled {
        self?.loadData()

        try? await Task.sleep(nanoseconds: 2_000_000_000)
      }
    }
  }

  func stopAutoRefresh() {
    refreshTask?.cancel()
    refreshTask = nil
  }

  func loadData() {
    lastUpdateCheck = userDefaults.getLastBlockListUpdateCheckAt()
    lastUpdate = userDefaults.getLastBlockListUpdateAt()
    updateStarted = userDefaults.getBlockListUpdateStartedAt()

    completedPhoneNumbersCount = patternService.getCompletedPhoneNumbersCount()
    completedPatternsCount = patternService.getCompletedPatternsCount()
    pendingPatternsCount = patternService.getPendingPatternsCount()
    lastCompletionDate = patternService.getLastCompletionDate()

    isBackgroundRefreshEnabled = UIApplication.shared.backgroundRefreshStatus == .available

    if updateState.isInProgress {
      return
    }

    // Check if there's work to do
    let hasPendingPatterns = pendingPatternsCount > 0
    let needsUpdate = userDefaults.shouldUpdateList()

    if hasPendingPatterns || needsUpdate {
      Task {
        await performUpdateWithStateManagement()
      }
    }
  }

  /// Performs update with state management
  private func performUpdateWithStateManagement() async {
    // Set starting state
    updateState = .starting

    do {
      // Perform the update (handles all UserDefaults state persistence)
      try await blockerService.performUpdate()

      // Success - set idle state
      updateState = .idle

    } catch {
      // Error - set error state
      logger.error("Update failed: \(error)")
      updateState = .error
    }
  }

  func checkBlockerExtensionStatus() async {
    do {
      blockerExtensionStatus = try await callDirectoryService.checkExtensionStatus()
    } catch {
      logger.error("Failed to check extension status: \(error)")
      blockerExtensionStatus = .error
    }
  }

  func openSettings() async {
    do {
      try await callDirectoryService.openSettings()
    } catch {
      logger.error("Failed to open settings: \(error)")
    }
  }

  func resetApplication() {
    // Clear all CoreData patterns
    patternService.deleteAllPatterns()

    // Clear all UserDefaults data
    userDefaults.resetAllData()

    // Clear all SharedUserDefaults data
    sharedUserDefaults.resetAllData()

    // Exit the application
    exit(0)
  }
}
