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

  init() {
    self.callDirectoryService = CallDirectoryService()
    self.userDefaults = UserDefaultsService()
    self.sharedUserDefaults = SharedUserDefaultsService()
    self.blockerService = BlockerService()
    self.patternService = PatternService()
  }

  func loadData() {
    lastUpdateCheck = userDefaults.getLastBlockListUpdateCheckAt()
    lastUpdate = userDefaults.getLastBlockListUpdateAt()
    updateStarted = userDefaults.getBlockListUpdateStartedAt()

    completedPhoneNumbersCount = patternService.getCompletedPhoneNumbersCount()
    completedPatternsCount = patternService.getCompletedPatternsCount()
    pendingPatternsCount = patternService.getPendingPatternsCount()
    lastCompletionDate = patternService.getLastCompletionDate()
  }

  /// Performs update with state management
  func performUpdateWithStateManagement() async {
    var retryCount = 0
    let maxRetries = 10

    // Set starting state
    updateState = .starting

    // Loop while there are pending patterns OR the list is empty
    while pendingPatternsCount > 0 || completedPatternsCount == 0 {
      do {
        // Perform the update
        try await blockerService.performUpdate()

        // Refresh counts after each update
        completedPhoneNumbersCount = patternService.getCompletedPhoneNumbersCount()
        completedPatternsCount = patternService.getCompletedPatternsCount()
        pendingPatternsCount = patternService.getPendingPatternsCount()

        // Add small delay to prevent tight looping
        try await Task.sleep(nanoseconds: 100_000_000)  // 100ms

        // Reset retry counter on success
        retryCount = 0
      } catch {
        retryCount += 1

        if retryCount <= maxRetries {
          // Calculate exponential backoff delay (1s, 2s, 4s)
          let delaySeconds = pow(2.0, Double(retryCount - 1))

          // Update state to show retrying
          updateState = .retrying

          logger.error(
            "Update failed (attempt \(retryCount)/\(maxRetries)), retrying in \(delaySeconds)s: \(error)"
          )

          // Wait before retrying
          try? await Task.sleep(nanoseconds: UInt64(delaySeconds) * 1_000_000_000)

          // Continue to retry
          continue
        } else {
          // All retries exhausted - set error state
          logger.error("Update failed after \(maxRetries) attempts: \(error)")
          updateState = .error
          updateError = error.localizedDescription
          break
        }
      }
    }

    // Success - set idle state
    if updateState != .error {
      updateState = .idle
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

  func checkBackgroundStatus() async {
    isBackgroundRefreshEnabled = UIApplication.shared.backgroundRefreshStatus == .available
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
