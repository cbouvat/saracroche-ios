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

      switch action {
      case "reset":
        handleReset(to: context)
      case "addPrefix":
        handleAddPrefix(to: context)
      default:
        break
      }
    } else {
      print("Full reload requested")
    }

    context.completeRequest()
  }

  private func patternToRange(pattern: String) -> (start: Int64, end: Int64)? {
    guard pattern.contains("#") else { return nil }

    let digits = pattern.filter { $0 != "#" }
    let xCount = pattern.filter { $0 == "#" }.count

    guard let base = Int64(digits) else { return nil }

    let multiplier = Int64(pow(10, Double(xCount)))
    let start = base * multiplier
    let end = start + multiplier - 1

    return (start, end)
  }

  private func handleReset(to context: CXCallDirectoryExtensionContext) {
    print("Resetting all entries")
    context.removeAllBlockingEntries()
    context.removeAllIdentificationEntries()
  }

  private func handleAddPrefix(to context: CXCallDirectoryExtensionContext) {
    print("Adding prefix entries")
    var blockedNumbers = Int64(
      sharedUserDefaults?.integer(forKey: "blockedNumbers") ?? 0
    )
    
    if let pattern = sharedUserDefaults?.string(forKey: "phonePattern"),
      let range = patternToRange(pattern: pattern)
    {
      let start = range.start
      let end = range.end

      print("Blocking numbers from \(start) to \(end) (pattern: \(pattern))")
      for number in start...end {
        context.addBlockingEntry(withNextSequentialPhoneNumber: number)

        blockedNumbers += 1

        if blockedNumbers % 10000 == 0 {
          sharedUserDefaults?.set(blockedNumbers, forKey: "blockedNumbers")
        }
      }

      sharedUserDefaults?.set(blockedNumbers, forKey: "blockedNumbers")
    }
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
