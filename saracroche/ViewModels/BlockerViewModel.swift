import Combine
import SwiftUI

class BlockerViewModel: ObservableObject {
  @Published var blockerExtensionStatus: BlockerExtensionStatus = .unknown
  @Published var blockerActionState: BlockerActionState = .nothing
  @Published var blockerPhoneNumberBlocked: Int64 = 0
  @Published var blockerPhoneNumberTotal: Int64 = 0
  @Published var blocklistInstalledVersion: String = ""
  @Published var blocklistVersion: String = AppConstants.currentBlocklistVersion
  @Published var showBlockerStatusSheet: Bool = false

  private let callDirectoryService = CallDirectoryService.shared
  private let sharedUserDefaults = SharedUserDefaultsService.shared

  // MARK: - Status Management
  func checkBlockerExtensionStatus() {
    callDirectoryService.checkExtensionStatus { [weak self] status in
      self?.blockerExtensionStatus = status
      self?.updateBlockerState()
    }
  }

  func updateBlockerState() {
    let blockerActionState = sharedUserDefaults.getBlockerActionState()
    let blockedNumbers = sharedUserDefaults.getBlockedNumbers()
    let totalBlockedNumbers = sharedUserDefaults.getTotalBlockedNumbers()
    let blocklistInstalledVersion = sharedUserDefaults.getBlocklistVersion()

    switch blockerActionState {
    case "update":
      self.blockerActionState = .update
    case "delete":
      self.blockerActionState = .delete
    case "finish":
      self.blockerActionState = .finish
    default:
      self.blockerActionState = .nothing
    }

    self.blockerPhoneNumberBlocked = Int64(blockedNumbers)
    self.blockerPhoneNumberTotal = Int64(totalBlockedNumbers)
    self.blocklistInstalledVersion = blocklistInstalledVersion

    switch self.blockerActionState {
    case .update, .delete, .finish:
      self.showBlockerStatusSheet = true
    case .nothing:
      self.showBlockerStatusSheet = false
    }
  }

  // MARK: - Actions
  func updateBlockerList() {
    callDirectoryService.updateBlockerList(
      onProgress: { [weak self] in
        self?.updateBlockerState()
      },
      onCompletion: { [weak self] success in
        if !success {
          self?.blockerExtensionStatus = .error
          self?.cancelUpdateBlockerAction()
        } else {
          self?.checkBlockerExtensionStatus()
        }
      }
    )
  }

  func removeBlockerList() {
    callDirectoryService.removeBlockerList(
      onProgress: { [weak self] in
        self?.updateBlockerState()
      },
      onCompletion: { [weak self] success in
        if !success {
          self?.blockerExtensionStatus = .error
        }
        self?.checkBlockerExtensionStatus()
      }
    )
  }

  func cancelUpdateBlockerAction() {
    callDirectoryService.cancelUpdateAction()
    checkBlockerExtensionStatus()
  }

  func cancelRemoveBlockerAction() {
    callDirectoryService.cancelRemoveAction()
    checkBlockerExtensionStatus()
  }

  func markBlockerActionFinished() {
    callDirectoryService.markActionFinished()
    checkBlockerExtensionStatus()
  }

  func openSettings() {
    callDirectoryService.openSettings()
  }
}
