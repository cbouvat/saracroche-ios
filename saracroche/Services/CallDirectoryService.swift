import CallKit
import Foundation
import UIKit

class CallDirectoryService {

  static let shared = CallDirectoryService()

  private let manager = CXCallDirectoryManager.sharedInstance
  private let sharedUserDefaults = SharedUserDefaultsService.shared
  private let phoneNumberService = PhoneNumberService.shared

  private init() {}

  // MARK: - Check Extension Status
  func checkExtensionStatus(
    completion: @escaping (BlockerExtensionStatus) -> Void
  ) {
    print("Checking blocker extension status...")

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
          "Erreur lors de l'ouverture des réglages: \(error.localizedDescription)"
        )
      }
    }
  }

  // MARK: - Reload Extension
  func reloadExtension(completion: @escaping (Bool) -> Void) {
    manager.reloadExtension(
      withIdentifier: AppConstants.callDirectoryExtensionIdentifier
    ) { error in
      DispatchQueue.main.async {
        completion(error == nil)
      }
    }
  }

  // MARK: - Update Blocker List
  func updateBlockerList(
    onProgress: @escaping () -> Void,
    onCompletion: @escaping (Bool) -> Void
  ) {
    sharedUserDefaults.setBlockerActionState("update")

    UIApplication.shared.isIdleTimerDisabled = true

    var patternsToProcess = phoneNumberService.loadPhoneNumberPatterns()

    sharedUserDefaults.setBlocklistVersion(
      AppConstants.currentBlocklistVersion
    )

    sharedUserDefaults.setTotalBlockedNumbers(
      phoneNumberService.countAllBlockedNumbers()
    )

    func processNextPattern() {
      if !patternsToProcess.isEmpty {
        let pattern = patternsToProcess.removeFirst()
        let numbersListForPattern = phoneNumberService.generatePhoneNumbers(
          prefix: pattern
        )

        var chunkIndex = 0

        func processNextChunk() {
          onProgress()

          guard sharedUserDefaults.getBlockerActionState() == "update" else {
            return
          }

          let start = chunkIndex * AppConstants.phoneNumberChunkSize
          let end = min(
            start + AppConstants.phoneNumberChunkSize,
            numbersListForPattern.count
          )

          if start < end {
            let chunk = Array(numbersListForPattern[start..<end])
            sharedUserDefaults.setAction(AppConstants.Actions.addNumbersList)
            sharedUserDefaults.setNumbersList(chunk)

            reloadExtension { success in
              if success {
                chunkIndex += 1
                processNextChunk()
              } else {
                self.cancelUpdateAction()
                onCompletion(false)
              }
            }
          } else {
            processNextPattern()
          }
        }

        processNextChunk()
      } else {
        sharedUserDefaults.setBlockerActionState("finish")
        UIApplication.shared.isIdleTimerDisabled = false
        onCompletion(true)
      }
    }

    sharedUserDefaults.setAction(AppConstants.Actions.resetNumbersList)
    reloadExtension { success in
      if success {
        processNextPattern()
      } else {
        self.cancelUpdateAction()
        onCompletion(false)
      }
    }
  }

  // MARK: - Remove Blocker List
  func removeBlockerList(
    onProgress: @escaping () -> Void,
    onCompletion: @escaping (Bool) -> Void
  ) {
    UIApplication.shared.isIdleTimerDisabled = true
    sharedUserDefaults.setBlockerActionState("delete")

    onProgress()

    sharedUserDefaults.setAction(AppConstants.Actions.resetNumbersList)
    reloadExtension { success in
      if !success {
        onCompletion(false)
      }
      self.sharedUserDefaults.clearBlockerActionState()
      UIApplication.shared.isIdleTimerDisabled = false
      onCompletion(success)
    }
  }

  // MARK: - Cancel Actions
  func cancelUpdateAction() {
    UIApplication.shared.isIdleTimerDisabled = false
    sharedUserDefaults.clearBlockerActionState()
    sharedUserDefaults.clearAction()
  }

  func cancelRemoveAction() {
    UIApplication.shared.isIdleTimerDisabled = false
    sharedUserDefaults.clearBlockerActionState()
  }

  func markActionFinished() {
    UIApplication.shared.isIdleTimerDisabled = false
    sharedUserDefaults.clearBlockerActionState()
  }
}
