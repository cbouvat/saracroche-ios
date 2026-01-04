import CoreData
import Foundation

final class ListConverterService {

  private let numberCoreDataService: NumberCoreDataService

  init(numberCoreDataService: NumberCoreDataService = NumberCoreDataService()) {
    self.numberCoreDataService = numberCoreDataService
  }

  /// Convert list from API JSON to CoreData
  func convertListToCoreData(jsonResponse: [String: Any]) throws -> [Number] {
    // Convert JSON dictionary to Data
    let jsonData = try JSONSerialization.data(withJSONObject: jsonResponse, options: [])

    // Parse the JSON data
    let decoder = JSONDecoder()
    let jsonObject = try decoder.decode(APIBlockListResponse.self, from: jsonData)

    // Delete all existing numbers
    numberCoreDataService.deleteAllNumbers()

    var result = [Number]()

    // Process each pattern from the API response
    for pattern in jsonObject.patterns {
      // Generate phone numbers from the pattern using PhoneNumberHelpers
      let phoneNumbers = PhoneNumberHelpers.expandBlockingPattern(pattern.pattern)

      for phoneNumber in phoneNumbers {
        // Add each phone number to CoreData
        let number = numberCoreDataService.addNumber(
          phoneNumber,
          action: "block",
          source: pattern.operatorName
        )

        // Set additional metadata
        number.sourceVersion = jsonObject.version
        number.sourceListName = jsonObject.name
        number.addedDate = Date()

        result.append(number)
      }
    }

    // Save all changes at once
    numberCoreDataService.saveContext()

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
