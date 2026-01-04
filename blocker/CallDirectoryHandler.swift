import CallKit
import CoreData
import Foundation

/// Call Directory extension handler
class CallDirectoryHandler: CXCallDirectoryProvider {
  /// Core Data service for accessing blocked numbers.
  private let coreDataService: NumberCoreDataService

  init(coreDataService: NumberCoreDataService = NumberCoreDataService()) {
    self.coreDataService = coreDataService
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

  /// Process batch of phone numbers
  private func processBatch(
    to context: CXCallDirectoryExtensionContext
  ) {
    print("CallDirectoryHandler: Processing batch update")
    sharedUserDefaults()?.set("", forKey: "action")

    // Get the batch of pending numbers from Core Data
    let pendingNumbersList = coreDataService.getPendingNumbersBatch(
      limit: 10_000
    )

    print("Processing batch: count \(pendingNumbersList.count)")

    var blockedCount = 0
    var removedCount = 0
    var identifiedCount = 0

    for numberEntity in pendingNumbersList {
      guard let phoneNumber = numberEntity.number,
        let action = numberEntity.action
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
        if let name = numberEntity.name {
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
    coreDataService.markNumbersAsCompleted(phoneNumbers)

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
