import CoreData
import Foundation

final class ListConverterService {
  static let shared = ListConverterService()

  private let coreDataService = BlockedNumberCoreDataService.shared

  private init() {}

  /// Convert block list from API JSON to CoreData
  /// - Parameter jsonResponse: JSON dictionary containing the API response
  /// - Returns: Array of BlockedNumber objects
  /// - Throws: Error if JSON parsing fails or if there are issues with CoreData operations
  func convertBlockListToCoreData(jsonResponse: [String: Any]) throws -> [BlockedNumber] {
    // Convert JSON dictionary to Data
    let jsonData = try JSONSerialization.data(withJSONObject: jsonResponse, options: [])
    
    // Parse the JSON data
    let decoder = JSONDecoder()
    let jsonObject = try decoder.decode(APIBlockListResponse.self, from: jsonData)

    // Delete all existing blocked numbers
    coreDataService.deleteAllBlockedNumbers()

    var result = [BlockedNumber]()

    // Process each pattern from the API response
    for pattern in jsonObject.patterns {
      // Generate phone numbers from the pattern using PhoneNumberHelpers
      let phoneNumbers = PhoneNumberHelpers.expandBlockingPattern(pattern.pattern)

      for phoneNumber in phoneNumbers {
        // Add each phone number to CoreData
        let blockedNumber = coreDataService.addBlockedNumber(
          phoneNumber,
          action: "block",
          source: pattern.operatorName
        )

        // Set additional metadata
        blockedNumber.sourceVersion = jsonObject.version
        blockedNumber.sourceListName = jsonObject.name
        blockedNumber.addedDate = Date()

        result.append(blockedNumber)
      }
    }

    // Save all changes at once
    coreDataService.saveContext()

    return result
  }

}

// MARK: - API Response Models

struct APIBlockListResponse: Codable {
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
