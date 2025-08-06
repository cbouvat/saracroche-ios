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

  private let callDirectoryService = CallDirectoryService.shared
  private let sharedUserDefaults = SharedUserDefaultsService.shared

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
    case "delete":
      self.blockerActionState = .delete
      self.showDeleteBlockerSheet = true
      self.showUpdateListSheet = false
      self.showUpdateListFinishedSheet = false
      self.showDeleteFinishedSheet = false
    case "update_finish":
      self.blockerActionState = .update_finish
      self.showUpdateListFinishedSheet = true
      self.showDeleteBlockerSheet = false
      self.showUpdateListSheet = false
      self.showDeleteFinishedSheet = false
    case "delete_finish":
      self.blockerActionState = .delete_finish
      self.showDeleteFinishedSheet = true
      self.showUpdateListSheet = false
      self.showDeleteBlockerSheet = false
      self.showUpdateListFinishedSheet = false
    default:
      self.blockerActionState = .nothing
      self.showUpdateListSheet = false
      self.showDeleteBlockerSheet = false
      self.showUpdateListFinishedSheet = false
      self.showDeleteFinishedSheet = false
    }
  }

  // MARK: - Actions
  func updateBlockerList() {
    callDirectoryService.updateBlockerList(
      onProgress: { [weak self] in
        self?.updateBlockerState()
      },
      onCompletion: { [weak self] success in
        self?.updateBlockerState()
      }
    )
  }

  func removeBlockerList() {
    callDirectoryService.removeBlockerList(
      onProgress: { [weak self] in
        self?.updateBlockerState()
      },
      onCompletion: { [weak self] success in
        self?.updateBlockerState()
      }
    )
  }

  func clearAction() {
    callDirectoryService.cancelAction()
    self.checkBlockerExtensionStatus()
  }

  func openSettings() {
    callDirectoryService.openSettings()
  }
}
