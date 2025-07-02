import CallKit
import Combine
import SwiftUI

enum BlockerExtensionStatus {
  case enabled
  case disabled
  case error
  case unexpected
  case unknown
}

enum BlockerActionState {
  case update
  case delete
  case finish
  case nothing
}

class SaracrocheViewModel: ObservableObject {
  @Published var blockerExtensionStatus: BlockerExtensionStatus = .unknown
  @Published var blockerActionState: BlockerActionState = .nothing
  @Published var blockerPhoneNumberBlocked: Int64 = 0
  @Published var blockerPhoneNumberTotal: Int64 = 0
  @Published var blocklistInstalledVersion: String = ""
  @Published var blocklistVersion: String = "4"
  @Published var showBlockerStatusSheet: Bool = false

  private var statusTimer: Timer? = nil
  private var updateTimer: Timer? = nil

  let sharedUserDefaults = UserDefaults(
    suiteName: "group.com.cbouvat.saracroche"
  )

  init() {
    checkBlockerExtensionStatus()
    startTimerBlockerExtensionStatus()
    startUpdateTimer()
  }

  deinit {
    stopStatusBlockerExtensionStatus()
    stopUpdateTimer()
  }

  func checkBlockerExtensionStatus() {
    guard self.blockerActionState == .nothing else {
      // If an action is in progress, we don't check the status
      self.blockerExtensionStatus = .unknown
      return
    }

    let manager = CXCallDirectoryManager.sharedInstance

    manager.getEnabledStatusForExtension(
      withIdentifier: "com.cbouvat.saracroche.blocker"
    ) {
      status,
      error in
      DispatchQueue.main.async {
        if error != nil {
          self.blockerExtensionStatus = .error
          return
        }

        switch status {
        case .enabled:
          self.blockerExtensionStatus = .enabled
        case .disabled:
          self.blockerExtensionStatus = .disabled
        case .unknown:
          self.blockerExtensionStatus = .unknown
        @unknown default:
          self.blockerExtensionStatus = .unexpected
        }
      }
    }
  }

  func updateBlockerState() {
    let blockerActionState =
      sharedUserDefaults?.string(forKey: "blockerActionState") ?? ""
    let blockedNumbers =
      sharedUserDefaults?.integer(forKey: "blockedNumbers") ?? 0
    let totalBlockedNumbers =
      sharedUserDefaults?.integer(forKey: "totalBlockedNumbers") ?? 0
    let blocklistInstalledVersion =
      sharedUserDefaults?.string(forKey: "blocklistVersion") ?? ""

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

  func updateBlockerList() {
    UIApplication.shared.isIdleTimerDisabled = true
    let manager = CXCallDirectoryManager.sharedInstance

    sharedUserDefaults?.set("update", forKey: "blockerActionState")
    sharedUserDefaults?.set(0, forKey: "blockedNumbers")
    sharedUserDefaults?.set(self.blocklistVersion, forKey: "blocklistVersion")
    sharedUserDefaults?.set(
      countAllBlockedNumbers(),
      forKey: "totalBlockedNumbers"
    )

    var patternsToProcess = loadPhoneNumberPatterns()

    func processNextPattern() {
      if !patternsToProcess.isEmpty {
        let pattern = patternsToProcess.removeFirst()
        let numbersListForPattern = generatePhoneNumbers(prefix: pattern)

        let chunkSize = 10_000
        var chunkIndex = 0

        func processNextChunk() {
          guard
            sharedUserDefaults?.string(forKey: "blockerActionState") == "update"
          else {
            return
          }

          let start = chunkIndex * chunkSize
          let end = min(start + chunkSize, numbersListForPattern.count)
          if start < end {
            let chunk = Array(numbersListForPattern[start..<end])
            sharedUserDefaults?.set("addNumbersList", forKey: "action")
            sharedUserDefaults?.set(chunk, forKey: "numbersList")
            manager.reloadExtension(
              withIdentifier: "com.cbouvat.saracroche.blocker"
            ) { error in
              DispatchQueue.main.async {
                if error != nil {
                  self.blockerExtensionStatus = .error
                }
                chunkIndex += 1
                processNextChunk()
              }
            }
          } else {
            processNextPattern()
          }
        }

        processNextChunk()
      } else {
        sharedUserDefaults?.set("finish", forKey: "blockerActionState")
        UIApplication.shared.isIdleTimerDisabled = false
      }
    }

    sharedUserDefaults?.set("resetNumbersList", forKey: "action")
    manager.reloadExtension(withIdentifier: "com.cbouvat.saracroche.blocker") {
      error in
      DispatchQueue.main.async {
        if error != nil {
          self.blockerExtensionStatus = .error
        }

        processNextPattern()
      }
    }
  }

  func cancelUpdateBlockerAction() {
    UIApplication.shared.isIdleTimerDisabled = false
    sharedUserDefaults?.set("", forKey: "blockerActionState")
    updateBlockerState()
  }

  func removeBlockerList() {
    UIApplication.shared.isIdleTimerDisabled = true
    sharedUserDefaults?.set("delete", forKey: "blockerActionState")
    sharedUserDefaults?.set(0, forKey: "blockedNumbers")

    let manager = CXCallDirectoryManager.sharedInstance

    sharedUserDefaults?.set("resetNumbersList", forKey: "action")
    manager.reloadExtension(withIdentifier: "com.cbouvat.saracroche.blocker") {
      error in
      DispatchQueue.main.async {
        if error != nil {
          self.blockerExtensionStatus = .error
        }
        self.sharedUserDefaults?.set("", forKey: "blockerActionState")
        UIApplication.shared.isIdleTimerDisabled = false
      }
    }
  }

  func cancelRemoveBlockerAction() {
    UIApplication.shared.isIdleTimerDisabled = false
    sharedUserDefaults?.set("", forKey: "blockerActionState")
    updateBlockerState()
  }

  func markBlockerActionFinished() {
    UIApplication.shared.isIdleTimerDisabled = false
    sharedUserDefaults?.set("", forKey: "blockerActionState")
    updateBlockerState()
  }

  func openSettings() {
    let manager = CXCallDirectoryManager.sharedInstance
    manager.openSettings(completionHandler: { error in
      if let error = error {
        print(
          "Erreur lors de l'ouverture des réglages: \(error.localizedDescription)"
        )
      }
    })
  }

  private func loadPhoneNumberPatterns() -> [String] {
    if let url = Bundle.main.url(forResource: "prefixes", withExtension: "json")
    {
      do {
        let data = try Data(contentsOf: url)
        if let jsonArray = try JSONSerialization.jsonObject(
          with: data,
          options: []
        ) as? [[String: String]] {
          return jsonArray.compactMap { $0["prefix"] }
        }
      } catch {
        print("Error loading prefixes.json: \(error.localizedDescription)")
      }
    } else {
      print("prefixes.json not found in bundle.")
    }
    return []
  }

  private func countAllBlockedNumbers() -> Int64 {
    var totalCount: Int64 = 0

    for pattern in loadPhoneNumberPatterns() {
      let xCount = pattern.filter { $0 == "#" }.count
      totalCount += Int64(pow(10, Double(xCount)))
    }

    return totalCount
  }

  func generatePhoneNumbers(prefix: String) -> [String] {
    if !prefix.contains("#") {
      return [prefix]
    }
    
    let replacements = (0...9).map { String($0) }
    let firstWildcard = prefix.firstIndex(of: "#")!
    
    return replacements.flatMap { digit in
      var newPrefix = prefix
      newPrefix.replaceSubrange(firstWildcard...firstWildcard, with: digit)
      return generatePhoneNumbers(prefix: newPrefix)
    }
  }

  private func startTimerBlockerExtensionStatus() {
    statusTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) {
      [weak self] _ in
      self?.checkBlockerExtensionStatus()
    }
  }

  private func stopStatusBlockerExtensionStatus() {
    statusTimer?.invalidate()
    statusTimer = nil
  }

  private func startUpdateTimer() {
    updateTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) {
      [weak self] _ in
      self?.updateBlockerState()
    }
  }

  private func stopUpdateTimer() {
    updateTimer?.invalidate()
    updateTimer = nil
  }
}
