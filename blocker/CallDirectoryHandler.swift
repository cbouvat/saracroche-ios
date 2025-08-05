import CallKit
import Foundation

class CallDirectoryHandler: CXCallDirectoryProvider {

  let sharedUserDefaults = UserDefaults(
    suiteName: "group.com.cbouvat.saracroche"
  )

  override func beginRequest(with context: CXCallDirectoryExtensionContext) {
    context.delegate = self

    if context.isIncremental {
      let action = sharedUserDefaults?.string(forKey: "action") ?? ""

      if action == "resetNumbersList" {
        handleResetNumbersList(to: context)
      } else if action == "addNumbersList" {
        handleAddNumbersList(to: context)
      } else {
        print("Unknown action: \(action)")
      }
    }
    
    sharedUserDefaults?.set("", forKey: "action")

    context.completeRequest()
  }

  private func handleResetNumbersList(
    to context: CXCallDirectoryExtensionContext
  ) {
    print("Resetting all numbers list")
    sharedUserDefaults?.set(0, forKey: "blockedNumbers")

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
    print("Request failed with error: \(error.localizedDescription)")
  }

}
