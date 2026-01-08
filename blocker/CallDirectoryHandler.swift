import CallKit
import Foundation
import OSLog

/// Call Directory extension handler
class CallDirectoryHandler: CXCallDirectoryProvider {
  private let logger = Logger(subsystem: "com.saracroche.blocker", category: "CallDirectoryHandler")

  /// Handle CallKit request
  override func beginRequest(with context: CXCallDirectoryExtensionContext) {
    logger.info("Starting request processing")

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
      logger.error(
        "Could not access shared UserDefaults")
      return
    }

    let action = sharedDefaults.string(forKey: "action") ?? ""
    let numbersData = sharedDefaults.array(forKey: "numbers") as? [[String: Any]] ?? []

    logger.info(
      "Processing action \(action) with \(numbersData.count) numbers")

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
        logger.info(
          "Blocked number: \(numberString) - \(name ?? "")")
      case "identify":
        context.addIdentificationEntry(withNextSequentialPhoneNumber: number, label: name ?? "")
        logger.info(
          "Identified number: \(numberString) - \(name ?? "")")
      case "remove":
        context.removeBlockingEntry(withPhoneNumber: number)
        logger.info(
          "Removed number: \(numberString)")
      case "":
        // No action specified, do nothing
        logger.debug(
          "No action specified")
        break
      default:
        logger.warning(
          "Unknown action: \(action)")
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
    logger.error(
      "Request failed with error: \(error.localizedDescription)")
  }
}
