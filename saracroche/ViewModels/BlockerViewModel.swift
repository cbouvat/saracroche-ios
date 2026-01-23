import Combine
import SwiftUI

/// View model for call blocker functionality
@MainActor
class BlockerViewModel: ObservableObject {
  @Published var blockerExtensionStatus: BlockerExtensionStatus = .unknown
  @Published var updateState: BlockerUpdateStatus = .ok
  @Published var lastUpdateCheck: Date? = nil
  @Published var lastUpdate: Date? = nil
  @Published var updateStarted: Date? = nil

  // Statistics for blocked numbers
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

  func loadData() async {
    lastUpdateCheck = userDefaults.getLastBlockListUpdateCheckAt()
    lastUpdate = userDefaults.getLastBlockListUpdateAt()
    updateStarted = userDefaults.getBlockListUpdateStartedAt()
    lastListDownloadAt = userDefaults.getLastListDownloadAt()
    lastBackgroundLaunchAt = userDefaults.getLastBackgroundLaunchAt()

    completedPhoneNumbersCount = await patternService.getCompletedPhoneNumbersCount()
    completedPatternsCount = await patternService.getCompletedPatternsCount()
    pendingPatternsCount = await patternService.getPendingPatternsCount()
    lastCompletionDate = await patternService.getLastCompletionDate()
  }

  /// Performs update with state management
  func performUpdateWithStateManagement() async {
    var retryCount = 0
    let maxRetries = 5

    // Set starting state
    updateState = .inProgress

    // Loop while there are pending patterns OR the list is empty
    while pendingPatternsCount > 0 || completedPatternsCount == 0 {
      do {
        // Perform the update
        try await blockerService.performUpdate()

        // Refresh counts after each update
        completedPhoneNumbersCount = await patternService.getCompletedPhoneNumbersCount()
        completedPatternsCount = await patternService.getCompletedPatternsCount()
        pendingPatternsCount = await patternService.getPendingPatternsCount()

        // Reset retry counter on success
        retryCount = 0
      } catch {
        retryCount += 1

        if retryCount <= maxRetries {
          // Calculate exponential backoff delay (1s, 2s, 4s)
          let delaySeconds = pow(2.0, Double(retryCount - 1))

          // Update state to show retrying
          updateState = .inProgress

          Logger.error(
            "Update failed (attempt \(retryCount)/\(maxRetries)), retrying in \(delaySeconds)s",
            category: .blockerViewModel, error: error
          )

          // Wait before retrying
          try? await Task.sleep(nanoseconds: UInt64(delaySeconds) * 1_000_000_000)

          // Continue to retry
          continue
        } else {
          // All retries exhausted - set error state
          Logger.error(
            "Update failed after \(maxRetries) attempts", category: .blockerViewModel, error: error)
          updateState = .error
          updateError = error.localizedDescription
          break
        }
      }
    }

    // Success - set ok state
    if updateState != .error {
      updateState = .ok
    }
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
    // Clear all CoreData patterns
    await patternService.deleteAllPatterns()

    // Clear all UserDefaults data
    userDefaults.resetAllData()

    // Clear all SharedUserDefaults data
    sharedUserDefaults.resetAllData()

    // Exit the application
    exit(0)
  }
}
