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
    let blockerActionState = sharedUserDefaults.getBlockerActionState()
    let blockedNumbers = sharedUserDefaults.getBlockedNumbers()
    let totalBlockedNumbers = sharedUserDefaults.getTotalBlockedNumbers()
    let blocklistInstalledVersion = sharedUserDefaults.getBlocklistVersion()

    self.blockerPhoneNumberBlocked = Int64(blockedNumbers)
    self.blockerPhoneNumberTotal = Int64(totalBlockedNumbers)
    self.blocklistInstalledVersion = blocklistInstalledVersion

    switch blockerActionState {
    case "update":
      self.blockerActionState = .update
      self.showUpdateListSheet = true
      self.showDeleteBlockerSheet = false
      self.showUpdateListFinishedSheet = false
      self.showDeleteFinishedSheet = false
      self.showActionErrorSheet = false
    case "delete":
      self.blockerActionState = .delete
      self.showDeleteBlockerSheet = true
      self.showUpdateListSheet = false
      self.showUpdateListFinishedSheet = false
      self.showDeleteFinishedSheet = false
      self.showActionErrorSheet = false
    case "update_finish":
      self.blockerActionState = .update_finish
      self.showUpdateListFinishedSheet = true
      self.showDeleteBlockerSheet = false
      self.showUpdateListSheet = false
      self.showDeleteFinishedSheet = false
      self.showActionErrorSheet = false
    case "delete_finish":
      self.blockerActionState = .delete_finish
      self.showDeleteFinishedSheet = true
      self.showUpdateListSheet = false
      self.showDeleteBlockerSheet = false
      self.showUpdateListFinishedSheet = false
      self.showActionErrorSheet = false
    case "error":
      self.blockerActionState = .error
      self.showActionErrorSheet = true
      self.showUpdateListSheet = false
      self.showDeleteBlockerSheet = false
      self.showUpdateListFinishedSheet = false
      self.showDeleteFinishedSheet = false
    default:
      self.blockerActionState = .nothing
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
    sharedUserDefaults.setBlockerActionState("update")
    sharedUserDefaults.setBlocklistVersion(AppConstants.currentBlocklistVersion)
    sharedUserDefaults.setBlockedNumbers(0)
    sharedUserDefaults.setTotalBlockedNumbers(phoneNumberService.countAllBlockedNumbers())
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
    sharedUserDefaults.setBlockerActionState("update_finish")
    self.updateBlockerState()
  }

  func removeBlockerList() {
    UIApplication.shared.isIdleTimerDisabled = true
    sharedUserDefaults.setBlockerActionState("delete")
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
    self.sharedUserDefaults.setBlockerActionState("delete_finish")
    self.updateBlockerState()
  }

  func errorAction() {
    UIApplication.shared.isIdleTimerDisabled = false
    sharedUserDefaults.setBlockerActionState("error")
    sharedUserDefaults.clearAction()
    self.updateBlockerState()
  }

  func clearAction() {
    UIApplication.shared.isIdleTimerDisabled = false
    sharedUserDefaults.clearBlockerActionState()
    sharedUserDefaults.clearAction()
    self.checkBlockerExtensionStatus()
  }

  func openSettings() {
    callDirectoryService.openSettings()
  }

  func closeApp() {
    sharedUserDefaults.clearBlockerActionState()
    sharedUserDefaults.clearAction()
    exit(0)
  }
}
