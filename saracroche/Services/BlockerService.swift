import Foundation

/// Service for managing blocklist updates
final class BlockerService {

  private let callDirectoryService: CallDirectoryService
  private let userDefaultsService: UserDefaultsService
  private let listService: ListService

  init(
    callDirectoryService: CallDirectoryService = CallDirectoryService(),
    userDefaultsService: UserDefaultsService = UserDefaultsService(),
    listService: ListService = ListService()
  ) {
    self.callDirectoryService = callDirectoryService
    self.userDefaultsService = userDefaultsService
    self.listService = listService
  }

  /// Perform background update
  func performBackgroundUpdate(completion: @escaping (Bool) -> Void) {
    print("[BlockerService] performBackgroundUpdate called")
    performUpdate(onProgress: {}, completion: completion)
  }

  /// Perform update with progress callback
  func performUpdate(
    onProgress: @escaping () -> Void,
    completion: @escaping (Bool) -> Void
  ) {
    print("[BlockerService] performUpdate called")

  }
}
