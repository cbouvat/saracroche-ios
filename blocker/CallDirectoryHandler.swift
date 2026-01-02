import CallKit
import Foundation

/// The Call Directory extension handler that processes blocking requests from CallKit.
/// This class is responsible for adding, removing, and managing phone numbers to be blocked.
class CallDirectoryHandler: CXCallDirectoryProvider {
  /// Called by CallKit when a request needs to be processed.
  ///
  /// - Parameter context: The extension context containing information about the request.
  override func beginRequest(with context: CXCallDirectoryExtensionContext) {
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

    if action == "resetNumbersList" {
      resetNumbersList(to: context)
    } else if action == "addNumbersList" {
      addNumbersList(to: context)
    } else {
      print("Unknown action: \(action)")
    }
  }

  /// Resets all blocking and identification entries in the call directory.
  ///
  /// - Parameter context: The extension context for removing entries.
  private func resetNumbersList(
    to context: CXCallDirectoryExtensionContext
  ) {

    print("Resetting all numbers list")
    sharedUserDefaults()?.set("", forKey: "action")
    sharedUserDefaults()?.set(0, forKey: "blockedNumbers")

    context.removeAllBlockingEntries()
    context.removeAllIdentificationEntries()

    print("Successfully reset all numbers list")
  }

  /// Adds a list of phone numbers to be blocked.
  ///
  /// - Parameter context: The extension context for adding blocking entries.
  private func addNumbersList(
    to context: CXCallDirectoryExtensionContext
  ) {
    sharedUserDefaults()?.set("", forKey: "action")

    var blockedNumbers = Int64(
      sharedUserDefaults()?.integer(forKey: "blockedNumbers") ?? 0
    )

    let numbersList =
      sharedUserDefaults()?.stringArray(forKey: "numbersList") ?? []

    print(
      "Adding numbers : count \(numbersList.count), first \(numbersList.first ?? "")"
    )

    for number in numbersList {
      let number = Int64("\(number)") ?? 0
      context.addBlockingEntry(withNextSequentialPhoneNumber: number)
      blockedNumbers += 1
    }

    sharedUserDefaults()?.set(blockedNumbers, forKey: "blockedNumbers")
  }
}

/// Extension to handle request failure notifications from CallKit.
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
