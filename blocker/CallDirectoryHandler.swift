import CallKit
import Foundation

class CallDirectoryHandler: CXCallDirectoryProvider {

  let sharedUserDefaults = UserDefaults(
    suiteName: "group.com.cbouvat.saracroche"
  )

  override func beginRequest(with context: CXCallDirectoryExtensionContext) {
    context.delegate = self

    if context.isIncremental {
      print("Incremental update requested")

      let action = sharedUserDefaults?.string(forKey: "action")

      if action == "resetNumbersList" {
        handleResetNumbersList(to: context)
      } else if action == "addNumbersList" {
        handleAddNumbersList(to: context)
      }
      
      sharedUserDefaults?.set("", forKey: "action")
    }

    context.completeRequest()
  }

  private func handleResetNumbersList(
    to context: CXCallDirectoryExtensionContext
  ) {
    print("Resetting all numbers list")
    context.removeAllBlockingEntries()
    context.removeAllIdentificationEntries()
  }

  private func handleAddNumbersList(to context: CXCallDirectoryExtensionContext)
  {
    var blockedNumbers = Int64(
      sharedUserDefaults?.integer(forKey: "blockedNumbers") ?? 0
    )

    let numbersList =
      sharedUserDefaults?.stringArray(forKey: "numbersList") ?? []

    print("Adding numbers : count \(numbersList.count), first \(numbersList.first ?? "")")

    for number in numbersList {
      let number = Int64("\(number)") ?? 0
      context.addBlockingEntry(withNextSequentialPhoneNumber: number)
      blockedNumbers += 1
    }

    sharedUserDefaults?.set(blockedNumbers, forKey: "blockedNumbers")
  }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

  func requestFailed(
    for extensionContext: CXCallDirectoryExtensionContext,
    withError error: Error
  ) {
    // An error occurred while adding blocking or identification entries, check the NSError for details.
    // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
    //
    // This may be used to store the error details in a location accessible by the extension's containing app, so that the
    // app may be notified about errors which occurred while loading data even if the request to load data was initiated by
    // the user in Settings instead of via the app itself.
  }

}
