import Foundation
import UIKit

struct BlockedPattern: Codable {
  let operatorName: String?
  let pattern: String
  let start: String?
  let end: String?
}

final class BlockedPatternsService {

  enum BlockedPatternsError: Error {
    case unavailableDirectory
  }

  static let shared = BlockedPatternsService()

  private let apiService = APIService()
  private let userDefaults = UserDefaultsService.shared
  private let fileManager = FileManager.default
  private let decoder: JSONDecoder

  private var cachedPatterns: [BlockedPattern]?
  private var isRefreshingFlag: Bool = false
  private let stateQueue = DispatchQueue(label: "BlockedPatternsService.state")

  private init() {
    decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
  }

  var patternStrings: [String] {
    loadPatterns().map { $0.pattern }
  }

  func shouldCheckForNewPatterns(force: Bool = false) -> Bool {
    guard !isRefreshing else { return false }
    if force { return true }
    guard let lastCheck = userDefaults.getBlockedPatternsLastCheck() else { return true }
    return Date().timeIntervalSince(lastCheck) >= AppConstants.blockedPatternsDownloadInterval
  }

  func ensureLatestPatternsIfNeeded(force: Bool = false) async throws -> Bool {
    guard shouldCheckForNewPatterns(force: force) else { return false }

    setRefreshing(true)
    defer {
      setRefreshing(false)
      userDefaults.setBlockedPatternsLastCheck(Date())
    }

    let deviceID = await UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    let data = try await apiService.downloadBlockedPatterns(for: deviceID)
    let patterns = try decodePatterns(from: data)
    try savePatterns(data)
    cachedPatterns = patterns
    return true
  }

  private var isRefreshing: Bool {
    stateQueue.sync { isRefreshingFlag }
  }

  private func setRefreshing(_ value: Bool) {
    stateQueue.sync { isRefreshingFlag = value }
  }

  private func loadPatterns() -> [BlockedPattern] {
    if let cached = cachedPatterns {
      return cached
    }

    if let diskPatterns = try? loadCachedPatterns() {
      cachedPatterns = diskPatterns
      return diskPatterns
    }

    cachedPatterns = []
    return []
  }

  private func loadCachedPatterns() throws -> [BlockedPattern] {
    guard let url = patternsFileURL() else { throw BlockedPatternsError.unavailableDirectory }
    let data = try Data(contentsOf: url)
    return try decodePatterns(from: data)
  }

  private func decodePatterns(from data: Data) throws -> [BlockedPattern] {
    try decoder.decode([BlockedPattern].self, from: data)
  }

  private func savePatterns(_ data: Data) throws {
    guard let url = patternsFileURL() else { throw BlockedPatternsError.unavailableDirectory }
    try data.write(to: url, options: .atomic)
  }

  private func patternsFileURL() -> URL? {
    guard let directory = try? applicationSupportDirectory() else { return nil }
    return directory.appendingPathComponent(AppConstants.blockedPatternsCacheFileName)
  }

  private func applicationSupportDirectory() throws -> URL {
    guard
      let supportURL =
        fileManager
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)
        .first
    else {
      throw BlockedPatternsError.unavailableDirectory
    }

    let directory = supportURL.appendingPathComponent("Saracroche", isDirectory: true)
    try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory
  }
}
