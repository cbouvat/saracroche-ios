import CallKit
import CoreData
import Foundation
import OSLog

private let logger = Logger(subsystem: "com.cbouvat.saracroche", category: "ListService")

// MARK: - API Response Models

struct APIListResponse: Codable {
  let version: String
  let name: String
  let patterns: [APIPattern]

  enum CodingKeys: String, CodingKey {
    case version
    case name
    case patterns
  }
}

struct APIPattern: Codable {
  let name: String
  let action: String
  let pattern: String
}

/// Service for managing block lists - downloading, converting, and processing
final class ListService {

  // MARK: - Dependencies

  private let listAPIService: ListAPIService
  private let userDefaultsService: UserDefaultsService
  private let sharedUserDefaultsService: SharedUserDefaultsService
  private let patternCoreDataService: PatternCoreDataService
  private let callDirectoryService: CallDirectoryService

  // MARK: - Initialization

  init(
    listAPIService: ListAPIService = ListAPIService(),
    userDefaultsService: UserDefaultsService = UserDefaultsService(),
    sharedUserDefaultsService: SharedUserDefaultsService = SharedUserDefaultsService(),
    patternCoreDataService: PatternCoreDataService = PatternCoreDataService(),
    callDirectoryService: CallDirectoryService = CallDirectoryService()
  ) {
    self.listAPIService = listAPIService
    self.userDefaultsService = userDefaultsService
    self.sharedUserDefaultsService = sharedUserDefaultsService
    self.patternCoreDataService = patternCoreDataService
    self.callDirectoryService = callDirectoryService
  }

  /// Download the list from API and convert to CoreData
  func update(
    onProgress: @escaping () -> Void,
    completion: @escaping (Bool) -> Void
  ) {
    Task {
      onProgress()
      userDefaultsService.setLastDownloadList(Date())

      do {
        let jsonResponse = try await listAPIService.downloadFrenchList()
        let apiResponse = try decodeListResponse(jsonResponse)
        updateCoreData(apiResponse)
        completion(true)
      } catch {
        logger.error("Failed to download blocklist: \(error)")
        completion(false)
      }
    }
  }

  private func decodeListResponse(_ json: [String: Any]) throws -> APIListResponse {
    let jsonData = try JSONSerialization.data(withJSONObject: json)
    return try JSONDecoder().decode(APIListResponse.self, from: jsonData)
  }

  /// Convert list from API response to CoreData
  private func updateCoreData(_ apiResponse: APIListResponse) {
    let newPatternStrings: Set<String> = Set(apiResponse.patterns.map { $0.pattern })
    let existingPatterns = patternCoreDataService.getAllPatterns()

    logger.info(
      "Starting updateCoreData - Found \(apiResponse.patterns.count) patterns in API response")
    logger.info("Existing patterns in CoreData: \(existingPatterns.count)")

    var removedCount = 0
    var updatedCount = 0
    var addedCount = 0

    // Find patterns to remove (those no longer in the new list)
    let patternsToRemove = existingPatterns.compactMap { pattern -> String? in
      guard let patternString = pattern.pattern else { return nil }
      return !newPatternStrings.contains(patternString) ? patternString : nil
    }

    // Mark patterns that are no longer in the new list for removal
    for patternString in patternsToRemove {
      patternCoreDataService.updatePattern(
        patternString,
        with: ["action": "remove", "completedDate": nil]
      )
      removedCount += 1
    }

    // Add or update patterns from the API response
    for newPattern in apiResponse.patterns {
      if patternCoreDataService.getPattern(by: newPattern.pattern) != nil {
        patternCoreDataService.updatePattern(
          newPattern.pattern,
          with: [
            "action": newPattern.action,
            "name": newPattern.name,
            "source": "api",
            "sourceListName": apiResponse.name,
            "sourceVersion": apiResponse.version,
          ]
        )
        updatedCount += 1
      } else {
        patternCoreDataService.addPattern(
          newPattern.pattern,
          action: newPattern.action,
          name: newPattern.name,
          source: "api",
          sourceListName: apiResponse.name,
          sourceVersion: apiResponse.version
        )
        addedCount += 1
      }
    }

    logger.info(
      "updateCoreData completed - Added: \(addedCount), Updated: \(updatedCount), Removed: \(removedCount)"
    )

    patternCoreDataService.saveContext()
  }
}
