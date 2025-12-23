import CallKit
import Foundation
import UIKit

class CallDirectoryService {

  static let shared = CallDirectoryService()

  private let manager = CXCallDirectoryManager.sharedInstance
  private let sharedUserDefaults = SharedUserDefaultsService.shared
  private let userDefaults = UserDefaultsService.shared
  private let phoneNumberService = PhoneNumberService.shared

  private init() {}

  // MARK: - Check Extension Status
  func checkExtensionStatus(
    completion: @escaping (BlockerExtensionStatus) -> Void
  ) {
    manager.getEnabledStatusForExtension(
      withIdentifier: AppConstants.callDirectoryExtensionIdentifier
    ) { status, error in
      DispatchQueue.main.async {
        if error != nil {
          completion(.error)
          return
        }

        switch status {
        case .enabled:
          completion(.enabled)
        case .disabled:
          completion(.disabled)
        case .unknown:
          completion(.unknown)
        @unknown default:
          completion(.unexpected)
        }
      }
    }
  }

  // MARK: - Open Settings
  func openSettings() {
    manager.openSettings { error in
      if let error = error {
        print(
          "Error opening settings: \(error.localizedDescription)"
        )
      }
    }
  }

  // MARK: - Reload Extension
  func reloadExtension(completion: @escaping (Bool) -> Void) {
    // Add a millisecond delay before reloading the extension
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
      self.manager.reloadExtension(
        withIdentifier: AppConstants.callDirectoryExtensionIdentifier
      ) { error in
        DispatchQueue.main.async {
          completion(error == nil)
        }
      }
    }
  }

  // MARK: - Update Blocker List
  func updateBlockerList(
    onProgress: @escaping () -> Void,
    onCompletion: @escaping (Bool) -> Void
  ) {
    var patternsToProcess = phoneNumberService.loadPhoneNumberPatterns()

    sharedUserDefaults.setBlockedNumbers(0)
    userDefaults.setBlocklistVersion(AppConstants.currentBlocklistVersion)
    userDefaults.setTotalBlockedNumbers(
      phoneNumberService.countPhoneNumbersRepresentedByAllBlockingPatterns()
    )

    func processNextPattern() {
      if !patternsToProcess.isEmpty {
        let pattern = patternsToProcess.removeFirst()
        let numbersListForPattern =
          phoneNumberService.expandBlockingPatternIntoPhoneNumbers(
            from: pattern
          )

        var chunkIndex = 0

        func processNextChunk() {
          onProgress()

          let start = chunkIndex * AppConstants.phoneNumberChunkSize
          let end = min(
            start + AppConstants.phoneNumberChunkSize,
            numbersListForPattern.count
          )

          if start < end {
            let chunk = Array(numbersListForPattern[start..<end])
            sharedUserDefaults.setAction(AppConstants.Actions.addNumbersList)
            sharedUserDefaults.setNumbersList(chunk)

            self.reloadExtension { success in
              if success {
                chunkIndex += 1
                processNextChunk()
              } else {
                onCompletion(false)
              }
            }
          } else {
            processNextPattern()
          }
        }

        processNextChunk()
      } else {
        onCompletion(true)
      }
    }

    sharedUserDefaults.setAction(AppConstants.Actions.resetNumbersList)
    self.reloadExtension { success in
      if success {
        processNextPattern()
      } else {
        onCompletion(false)
      }
    }
  }

  // MARK: - Remove Blocker List
  func removeBlockerList(
    onProgress: @escaping () -> Void,
    onCompletion: @escaping (Bool) -> Void
  ) {
    sharedUserDefaults.setAction(AppConstants.Actions.resetNumbersList)

    self.reloadExtension { success in
      if success {
        onCompletion(true)
      } else {
        onCompletion(false)
      }
    }
  }
}
