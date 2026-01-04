import CallKit
import Foundation

/// Call Directory extension handler
class CallDirectoryHandler: CXCallDirectoryProvider {
  /// Pattern store for accessing blocked patterns.
  private let patternStore: PatternStore

  init(patternStore: PatternStore = PatternStore()) {
    self.patternStore = patternStore
    super.init()
  }

  /// Handle CallKit request
  override func beginRequest(with context: CXCallDirectoryExtensionContext) {
    print("CallDirectoryHandler: Starting request processing")
    context.delegate = self

    if context.isIncremental {
      incrementalUpdate(to: context)
    }

    context.completeRequest()
  }

  /// Get shared UserDefaults
  private func sharedUserDefaults() -> UserDefaults? {
    UserDefaults(suiteName: "group.com.cbouvat.saracroche")
  }

  /// Process incremental update
  private func incrementalUpdate(
    to context: CXCallDirectoryExtensionContext
  ) {
    let action = sharedUserDefaults()?.string(forKey: "action") ?? ""

    if action == "batch" {
      processBatch(to: context)
    } else {
      print("Unknown action: \(action)")
    }
  }

  /// Process batch of phone patterns
  private func processBatch(
    to context: CXCallDirectoryExtensionContext
  ) {
    print("CallDirectoryHandler: Processing batch update")
    sharedUserDefaults()?.set("", forKey: "action")

    // Get the batch of pending patterns from pattern store
    let pendingPatternsList = patternStore.getPendingPatternsBatch(
      limit: 10_000
    )

    print("Processing batch: count \(pendingPatternsList.count)")

    var blockedCount = 0
    var removedCount = 0
    var identifiedCount = 0

    for pattern in pendingPatternsList {
      // Expand the pattern to individual phone numbers
      let numbers = PhoneNumberHelpers.expandBlockingPattern(pattern)

      for numberString in numbers {
        // Convert to Int64 for CallKit
        let number = Int64(numberString) ?? 0

        context.addBlockingEntry(withNextSequentialPhoneNumber: number)
        blockedCount += 1
      }
    }

    // Mark these patterns as completed
    patternStore.markPatternsAsCompleted(pendingPatternsList)

    print(
      "Successfully processed batch: \(blockedCount) blocked, \(removedCount) removed, \(identifiedCount) identified"
    )
  }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

  /// Handle request failure
  func requestFailed(
    for extensionContext: CXCallDirectoryExtensionContext,
    withError error: Error
  ) {
    print("Request failed with error: \(error.localizedDescription)")
  }

}
