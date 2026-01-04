import CoreData
import Foundation

final class ListConverterService {

  private let numberCoreDataService: NumberCoreDataService

  init(numberCoreDataService: NumberCoreDataService = NumberCoreDataService()) {
    self.numberCoreDataService = numberCoreDataService
  }

  /// Convert list from API JSON to CoreData
  func convertListToCoreData(jsonResponse: [String: Any]) {
    do {
      // Convert JSON dictionary to Data
      let jsonData = try JSONSerialization.data(withJSONObject: jsonResponse)

      // Parse the JSON data
      let decoder = JSONDecoder()
      let jsonObject = try decoder.decode(APIListResponse.self, from: jsonData)

      // Delete all existing numbers
      numberCoreDataService.deleteAllNumbers()

      // Process each pattern from the API response
      for pattern in jsonObject.patterns {
        print("Converting pattern : \(pattern.pattern)")
        // Generate phone numbers from the pattern using PhoneNumberHelpers
        let numbers = PhoneNumberHelpers.expandBlockingPattern(pattern.pattern)

        for number in numbers {
          // Add each phone number to CoreData with version and list name
          _ = numberCoreDataService.addNumber(
            number,
            action: "block",
            source: pattern.operatorName,
            sourceListName: jsonObject.name,
            sourceVersion: jsonObject.version
          )
        }
        
        numberCoreDataService.saveContext()
      }
      
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
