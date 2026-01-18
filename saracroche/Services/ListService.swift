import CoreData
import Foundation
import OSLog

private let logger = Logger(subsystem: "com.cbouvat.saracroche", category: "ListService")

// MARK: - Error Types

enum ListServiceError: LocalizedError {
  case downloadFailed(Error)
  case decodingFailed(Error)

  var errorDescription: String? {
    switch self {
    case .downloadFailed(let error):
      return "Failed to download blocklist: \(error.localizedDescription)"
    case .decodingFailed(let error):
      return "Failed to decode blocklist: \(error.localizedDescription)"
    }
  }
}

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
  private let patternService: PatternService

  // MARK: - Initialization

  init(
    listAPIService: ListAPIService = ListAPIService(),
    userDefaultsService: UserDefaultsService = UserDefaultsService(),
    patternService: PatternService = PatternService()
  ) {
    self.listAPIService = listAPIService
    self.userDefaultsService = userDefaultsService
    self.patternService = patternService
  }

  // MARK: - Public API

  /// Download and update the French block list
  func update() async throws {
    logger.debug("Starting list update")
    userDefaultsService.setLastDownloadList(Date())

    do {
      let jsonResponse = try await listAPIService.downloadFrenchList()
      let apiResponse = try decodeListResponse(jsonResponse)
      updateCoreData(apiResponse)
      logger.info("List update completed successfully")
    } catch {
      logger.error("Failed to download blocklist: \(error)")
      throw ListServiceError.downloadFailed(error)
    }
  }

  private func decodeListResponse(_ json: [String: Any]) throws -> APIListResponse {
    let jsonData = try JSONSerialization.data(withJSONObject: json)
    return try JSONDecoder().decode(APIListResponse.self, from: jsonData)
  }

  /// Convert list from API response to CoreData
  private func updateCoreData(_ apiResponse: APIListResponse) {
    let newPatternStrings: Set<String> = Set(apiResponse.patterns.map { $0.pattern })
    let existingPatterns = patternService.getAllPatterns()

    logger.info(
      "Starting updateCoreData - Found \(apiResponse.patterns.count) patterns in API response")
    logger.info("Existing patterns in CoreData: \(existingPatterns.count)")

    var removedCount = 0
    var updatedCount = 0
    var addedCount = 0

    // Create a dictionary of existing patterns for efficient lookup
    // This avoids calling getPattern(by:) during enumeration which can cause conflicts
    let existingPatternsDict = [String: Pattern](
      uniqueKeysWithValues:
        existingPatterns.compactMap { pattern in
          guard let patternString = pattern.pattern else { return nil }
          return (patternString, pattern)
        }
    )

    // Find patterns to remove (those no longer in the new list)
    let patternsToRemove = existingPatternsDict.keys.filter { !newPatternStrings.contains($0) }

    // Mark patterns that are no longer in the new list for removal
    for patternString in patternsToRemove {
      if let pattern = existingPatternsDict[patternString] {
        patternService.updatePattern(
          pattern,
          action: "remove"
        )
        removedCount += 1
      }
    }

    // Add or update patterns from the API response
    for newPattern in apiResponse.patterns {
      if let existingPattern = existingPatternsDict[newPattern.pattern] {
        patternService.updatePattern(
          existingPattern,
          action: newPattern.action,
          name: newPattern.name,
          sourceListName: apiResponse.name,
          sourceVersion: apiResponse.version
        )
        updatedCount += 1
      } else {
        _ = patternService.createPattern(
          patternString: newPattern.pattern,
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
  }
}
