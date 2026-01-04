import CoreData
import Foundation

final class ListConverterService {

  private let patternCoreDataService: PatternCoreDataService

  init(patternCoreDataService: PatternCoreDataService = PatternCoreDataService()) {
    self.patternCoreDataService = patternCoreDataService
  }

  /// Convert list from API JSON to CoreData
  func convertListToCoreData(jsonResponse: [String: Any]) {
    do {
      // Convert JSON dictionary to Data
      let jsonData = try JSONSerialization.data(withJSONObject: jsonResponse)

      // Parse the JSON data
      let decoder = JSONDecoder()
      let jsonObject = try decoder.decode(APIListResponse.self, from: jsonData)

      // Delete all existing patterns
      patternCoreDataService.deleteAllPatterns()

      // Process each pattern from the API response
      for pattern in jsonObject.patterns {
        print("Storing pattern: \(pattern.pattern)")
        // Store the pattern directly in CoreData with version and list name
        _ = patternCoreDataService.addPattern(
          pattern.pattern,
          action: "block",
          source: pattern.operatorName,
          sourceListName: jsonObject.name,
          sourceVersion: jsonObject.version
        )
      }

      patternCoreDataService.saveContext()

    } catch {
      print("Error converting list to CoreData: \(error)")
      // Handle the error appropriately, e.g., log it, notify the user, or rethrow it
    }
  }

}

// MARK: - API Response Models

struct APIListResponse: Codable {
  let version: String
  let name: String
  let description: String
  let blockedNumbersCount: Int
  let patterns: [Pattern]

  enum CodingKeys: String, CodingKey {
    case version
    case name
    case description
    case blockedNumbersCount = "blocked_numbers_count"
    case patterns
  }
}

struct Pattern: Codable {
  let operatorName: String
  let pattern: String

  enum CodingKeys: String, CodingKey {
    case operatorName = "operator"
    case pattern
  }
}
