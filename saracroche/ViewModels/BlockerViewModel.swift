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
    lastSuccessfulUpdateAt = userDefaults.getLastSuccessfulUpdateAt()
    lastListDownloadAt = userDefaults.getLastListDownloadAt()
    lastBackgroundLaunchAt = userDefaults.getLastBackgroundLaunchAt()

    totalPhoneNumbersCount = await patternService.getTotalPhoneNumbersCount()
    completedPhoneNumbersCount = await patternService.getCompletedPhoneNumbersCount()
    completedPatternsCount = await patternService.getCompletedPatternsCount()
    pendingPatternsCount = await patternService.getPendingPatternsCount()
    lastCompletionDate = await patternService.getLastCompletionDate()
  }

  /// Performs update with state management
  func performUpdateWithStateManagement() async {
    var retryCount = 0
    let maxRetries = 4

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
        // Perform the update
        try await blockerService.performUpdate()

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

        // Check for cancellation after count refresh
        if Task.isCancelled {
          Logger.debug("Update task cancelled after count refresh", category: .blockerViewModel)
          return
        }

        // Reset retry counter on success
        retryCount = 0
      } catch is CancellationError {
        // Task was cancelled - set ok state and return
        Logger.debug("Update task cancelled", category: .blockerViewModel)
        return
      } catch {
        retryCount += 1

        if retryCount <= maxRetries {
          // Calculate exponential backoff delay (1s, 2s, 4s)
          let delaySeconds = pow(2.0, Double(retryCount - 1))

          Logger.error(
            "Update failed (attempt \(retryCount)/\(maxRetries)), retrying in \(delaySeconds)s",
            category: .blockerViewModel, error: error
          )

          // Wait before retrying
          do {
            try await Task.sleep(nanoseconds: UInt64(delaySeconds) * 1_000_000_000)
          } catch is CancellationError {
            // Task was cancelled during sleep
            Logger.debug("Update task cancelled during retry sleep", category: .blockerViewModel)
            return
          } catch {
            // Ignore other errors (shouldn't happen with Task.sleep)
          }

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
}
