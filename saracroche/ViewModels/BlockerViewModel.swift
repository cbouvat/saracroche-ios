import Combine
import SwiftUI

class BlockerViewModel: ObservableObject {
  @Published var blockerExtensionStatus: BlockerExtensionStatus = .unknown
  @Published var blockerActionState: BlockerActionState = .nothing
  @Published var blockerPhoneNumberBlocked: Int64 = 0
  @Published var blockerPhoneNumberTotal: Int64 = 0
  @Published var blocklistInstalledVersion: String = ""
  @Published var blocklistVersion: String = AppConstants.currentBlocklistVersion
  @Published var showUpdateListSheet: Bool = false
  @Published var showDeleteBlockerSheet: Bool = false
  @Published var showUpdateListFinishedSheet: Bool = false
  @Published var showDeleteFinishedSheet: Bool = false
  @Published var showActionErrorSheet: Bool = false

  private let callDirectoryService = CallDirectoryService.shared
  private let sharedUserDefaults = SharedUserDefaultsService.shared
  private let phoneNumberService = PhoneNumberService.shared

  // MARK: - Status Management
  func checkBlockerExtensionStatus() {
    callDirectoryService.checkExtensionStatus { [weak self] status in
      print("Blocker extension status: \(status)")
      self?.blockerExtensionStatus = status
      self?.updateBlockerState()
    }
  }

  func updateBlockerState() {
    let blockedNumbers = sharedUserDefaults.getBlockedNumbers()
    let totalBlockedNumbers = sharedUserDefaults.getTotalBlockedNumbers()
    let blocklistInstalledVersion = sharedUserDefaults.getBlocklistVersion()

    self.blockerPhoneNumberBlocked = Int64(blockedNumbers)
    self.blockerPhoneNumberTotal = Int64(totalBlockedNumbers)
    self.blocklistInstalledVersion = blocklistInstalledVersion

    switch blockerActionState {
    case .update:
      self.showUpdateListSheet = true
      self.showDeleteBlockerSheet = false
      self.showUpdateListFinishedSheet = false
      self.showDeleteFinishedSheet = false
      self.showActionErrorSheet = false
    case .delete:
      self.showDeleteBlockerSheet = true
      self.showUpdateListSheet = false
      self.showUpdateListFinishedSheet = false
      self.showDeleteFinishedSheet = false
      self.showActionErrorSheet = false
    case .updateFinish:
      self.showUpdateListFinishedSheet = true
      self.showDeleteBlockerSheet = false
      self.showUpdateListSheet = false
      self.showDeleteFinishedSheet = false
      self.showActionErrorSheet = false
    case .deleteFinish:
      self.showDeleteFinishedSheet = true
      self.showUpdateListSheet = false
      self.showDeleteBlockerSheet = false
      self.showUpdateListFinishedSheet = false
      self.showActionErrorSheet = false
    case .error:
      self.showActionErrorSheet = true
      self.showUpdateListSheet = false
      self.showDeleteBlockerSheet = false
      self.showUpdateListFinishedSheet = false
      self.showDeleteFinishedSheet = false
    default:
      self.showUpdateListSheet = false
      self.showDeleteBlockerSheet = false
      self.showUpdateListFinishedSheet = false
      self.showDeleteFinishedSheet = false
      self.showActionErrorSheet = false
    }
  }

  // MARK: - Actions
  func updateBlockerList() {
    UIApplication.shared.isIdleTimerDisabled = true
    self.blockerActionState = .update
    self.sharedUserDefaults.setBlocklistVersion(AppConstants.currentBlocklistVersion)
    self.sharedUserDefaults.setBlockedNumbers(0)
    self.sharedUserDefaults.setTotalBlockedNumbers(
      phoneNumberService.countAllBlockedNumbers()
    )
    self.updateBlockerState()

    callDirectoryService.updateBlockerList(
      onProgress: { [weak self] in
        self?.updateBlockerState()
      },
      onCompletion: { [weak self] success in
        if success {
          self?.updateBlockerListFinished()
        } else {
          self?.errorAction()
        }
      }
    )
  }

  func updateBlockerListFinished() {
    UIApplication.shared.isIdleTimerDisabled = false
    self.blockerActionState = .updateFinish
    self.updateBlockerState()
  }

  func removeBlockerList() {
    UIApplication.shared.isIdleTimerDisabled = true
    self.blockerActionState = .delete
    self.updateBlockerState()

    callDirectoryService.removeBlockerList(
      onProgress: { [weak self] in
        self?.updateBlockerState()
      },
      onCompletion: { [weak self] success in
        if success {
          self?.removeBlockerListFinished()
        } else {
          self?.errorAction()
        }
      }
    )
  }

  func removeBlockerListFinished() {
    UIApplication.shared.isIdleTimerDisabled = false
    self.blockerActionState = .deleteFinish
    self.updateBlockerState()
  }

  func errorAction() {
    UIApplication.shared.isIdleTimerDisabled = false
    self.blockerActionState = .error
    self.sharedUserDefaults.clearAction()
    self.updateBlockerState()
  }

  func clearAction() {
    UIApplication.shared.isIdleTimerDisabled = false
    self.blockerActionState = .nothing
    self.sharedUserDefaults.clearAction()
    self.checkBlockerExtensionStatus()
  }

  func checkExtensionStatusAction() {
    self.blockerExtensionStatus = .unknown
    // Wait 2 seconds to ensure the UI is updated before checking the status
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      self.checkBlockerExtensionStatus()
    }
  }

  func openSettings() {
    callDirectoryService.openSettings()
  }
}
