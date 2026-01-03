import CallKit
import CoreData
import Foundation

/// Call Directory extension handler
class CallDirectoryHandler: CXCallDirectoryProvider {
  /// Core Data service for accessing blocked numbers.
  private let coreDataService = BlockedNumberCoreDataService.shared
  /// Called by CallKit when a request needs to be processed.
  ///
  /// - Parameter context: The extension context containing information about the request.
  override func beginRequest(with context: CXCallDirectoryExtensionContext) {
    print("CallDirectoryHandler: Starting request processing")
    context.delegate = self

    if context.isIncremental {
      incrementalUpdate(to: context)
    }

    context.completeRequest()
  }

  /// Retrieves the shared UserDefaults instance for accessing data across app extensions.
  ///
  /// - Returns: The shared UserDefaults instance, or nil if it couldn't be created.
  private func sharedUserDefaults() -> UserDefaults? {
    UserDefaults(suiteName: "group.com.cbouvat.saracroche")
  }

  /// Processes incremental updates to the call directory.
  ///
  /// - Parameter context: The extension context for adding/removing entries.
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

  /// Processes a batch of phone numbers based on their action in Core Data.
  /// This method retrieves pending numbers and processes them according to their action:
  /// - "block": Add the number to the blocking list
  /// - "remove": Remove the number from the blocking list
  /// - "identify": Add the number to the identification list
  ///
  /// - Parameter context: The extension context for adding/removing entries.
  private func processBatch(
    to context: CXCallDirectoryExtensionContext
  ) {
    print("CallDirectoryHandler: Processing batch update")
    sharedUserDefaults()?.set("", forKey: "action")

    // Get the batch of pending numbers from Core Data
    let pendingNumbersList = coreDataService.getPendingBlockedNumbersBatch(
      limit: 10_000
    )

    print("Processing batch: count \(pendingNumbersList.count)")

    var blockedCount = 0
    var removedCount = 0
    var identifiedCount = 0

    for blockedNumber in pendingNumbersList {
      guard let phoneNumber = blockedNumber.number,
        let action = blockedNumber.action
      else {
        continue
      }

      let number = Int64(phoneNumber) ?? 0

      switch action {
      case "block":
        context.addBlockingEntry(withNextSequentialPhoneNumber: number)
        blockedCount += 1
      case "remove":
        context.removeBlockingEntry(withPhoneNumber: number)
        removedCount += 1
      case "identify":
        if let name = blockedNumber.name {
          context.addIdentificationEntry(
            withNextSequentialPhoneNumber: number,
            label: name
          )
          identifiedCount += 1
        }
      default:
        print("Unknown action for number \(phoneNumber): \(action)")
      }
    }

    // Mark these numbers as completed
    let phoneNumbers = pendingNumbersList.compactMap { $0.number }
    coreDataService.markBlockedNumbersAsCompleted(phoneNumbers)

    print(
      "Successfully processed batch: \(blockedCount) blocked, \(removedCount) removed, \(identifiedCount) identified"
    )
  }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

  /// Called when a request fails with an error.
  ///
  /// - Parameters:
  ///   - extensionContext: The extension context that failed.
  ///   - error: The error that occurred.
  func requestFailed(
    for extensionContext: CXCallDirectoryExtensionContext,
    withError error: Error
  ) {
    print("Request failed with error: \(error.localizedDescription)")
  }

}
