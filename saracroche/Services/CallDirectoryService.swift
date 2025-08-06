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
    UIApplication.shared.isIdleTimerDisabled = true
    sharedUserDefaults.setBlockerActionState("update")
    sharedUserDefaults.setBlockedNumbers(0)
    
    onProgress()

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
          pattern: pattern
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

            self.reloadExtension { success in
              if success {
                chunkIndex += 1
                processNextChunk()
              } else {
                self.cancelAction()
                onCompletion(false)
              }
            }
          } else {
            processNextPattern()
          }
        }

        processNextChunk()
      } else {
        sharedUserDefaults.setBlockerActionState("update_finish")
        UIApplication.shared.isIdleTimerDisabled = false
        onCompletion(true)
      }
    }

    sharedUserDefaults.setAction(AppConstants.Actions.resetNumbersList)
    self.reloadExtension { success in
      if success {
        processNextPattern()
      } else {
        self.cancelAction()
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
    sharedUserDefaults.setAction(AppConstants.Actions.resetNumbersList)

    onProgress()

    self.reloadExtension { success in
      if success {
        self.sharedUserDefaults.setBlockerActionState("delete_finish")
        UIApplication.shared.isIdleTimerDisabled = false
        onCompletion(true)
        
      } else {
        self.sharedUserDefaults.clearBlockerActionState()
        UIApplication.shared.isIdleTimerDisabled = false
        onCompletion(false)
      }
    }
  }

  func cancelAction() {
    UIApplication.shared.isIdleTimerDisabled = false
    sharedUserDefaults.clearBlockerActionState()
    sharedUserDefaults.clearAction()
  }
}
