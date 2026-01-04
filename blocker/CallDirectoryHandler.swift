import CallKit
import Foundation

/// Call Directory extension handler
class CallDirectoryHandler: CXCallDirectoryProvider {
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
    guard let sharedDefaults = sharedUserDefaults() else {
      print("CallDirectoryHandler: Could not access shared UserDefaults")
      return
    }

    let action = sharedDefaults.string(forKey: "action") ?? ""
    let numbersData = sharedDefaults.array(forKey: "numbers") as? [[String: Any]] ?? []

    print("CallDirectoryHandler: Processing action \(action) with \(numbersData.count) numbers")

    for numberData in numbersData {
      guard let numberString = numberData["number"] as? String,
        let number = Int64(numberString)
      else {
        continue
      }

      let name = numberData["name"] as? String

      switch action {
      case "block":
        context.addBlockingEntry(withNextSequentialPhoneNumber: number)
        print("Blocked number: \(numberString) - \(name ?? "")")
      case "identify":
        context.addIdentificationEntry(withNextSequentialPhoneNumber: number, label: name ?? "")
        print("Identified number: \(numberString) - \(name ?? "")")
      case "remove":
        context.removeBlockingEntry(withPhoneNumber: number)
        print("Removed number: \(numberString)")
      case "":
        // No action specified, do nothing
        print("No action specified")
        break
      default:
        print("Unknown action: \(action)")
      }
    }

    // Clear the action after processing
    sharedDefaults.set("", forKey: "action")
    sharedDefaults.set([], forKey: "numbers")
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
