import CallKit
import CoreData
import Foundation

// MARK: - API Response Models

struct APIListResponse: Codable {
  let version: String
  let name: String
  let description: String
  let blockedNumbersCount: Int
  let patterns: [APIPattern]

  enum CodingKeys: String, CodingKey {
    case version
    case name
    case description
    case blockedNumbersCount = "blocked_numbers_count"
    case patterns
  }
}

struct APIPattern: Codable {
  let operatorName: String
  let pattern: String

  enum CodingKeys: String, CodingKey {
    case operatorName = "operator"
    case pattern
  }
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
      do {
        onProgress()

        // Download the block list
        let jsonResponse = try await listAPIService.downloadFrenchList()

        // Extract the version from the JSON response
        guard jsonResponse["version"] is String else {
          print("Version not found in JSON response")
          completion(false)
          return
        }

        // Update
        updateCoreData(jsonResponse: jsonResponse)

        // Update the last download timestamp
        userDefaultsService.setLastDownloadList(Date())

        completion(true)
      } catch NetworkError.serverError(let code, _) where code == 401 {
        print("Authentication failed (401)")
        completion(false)
      } catch let error as NetworkError {
        print("Network error: \(error)")
        completion(false)
      } catch {
        print("Failed to download and convert blocklist: \(error)")
        completion(false)
      }
    }
  }

  /// Convert list from API JSON to CoreData
  private func updateCoreData(jsonResponse: [String: Any]) {
    do {
      // Convert JSON dictionary to Data
      let jsonData = try JSONSerialization.data(withJSONObject: jsonResponse)

      // Parse the JSON data
      let decoder = JSONDecoder()
      let jsonObject = try decoder.decode(APIListResponse.self, from: jsonData)

      // Get patterns from API response
      let newPatterns = jsonObject.patterns
      let newPatternStrings = Set(newPatterns.map { $0.pattern })

      // Get all existing patterns from CoreData
      let existingPatterns = patternCoreDataService.getAllPatterns()

      // Process existing patterns - check which ones are no longer in the new list
      for existingPattern in existingPatterns {
        guard let patternString = existingPattern.pattern else { continue }

        // If pattern doesn't exist in new list, mark it for removal
        if !newPatternStrings.contains(patternString) {
          print("Pattern disappeared: \(patternString)")
          // Change action to "remove" and set completedDate to nil
          patternCoreDataService.updatePattern(
            patternString,
            with: [
              "action": "remove",
              "completedDate": nil,
            ])
        }
      }

      // Process new patterns - add or update
      for newPattern in newPatterns {
        print("Processing pattern: \(newPattern.pattern)")

        // Check if pattern already exists
        let existingPattern = patternCoreDataService.getPattern(by: newPattern.pattern)

        if let existingPattern = existingPattern {
          // Pattern exists, update it
          print("Updating existing pattern: \(newPattern.pattern)")
          patternCoreDataService.updatePattern(
            newPattern.pattern,
            with: [
              "action": "block",
              "name": newPattern.operatorName,
              "source": "api",
              "sourceListName": jsonObject.name,
              "sourceVersion": jsonObject.version,
            ])
        } else {
          // Pattern doesn't exist, add it
          print("Adding new pattern: \(newPattern.pattern)")
          _ = patternCoreDataService.addPattern(
            newPattern.pattern,
            action: "block",
            name: newPattern.operatorName,
            source: "api",
            sourceListName: jsonObject.name,
            sourceVersion: jsonObject.version
          )
        }
      }

      patternCoreDataService.saveContext()

    } catch {
      print("Error converting list to CoreData: \(error)")
      // Handle the error appropriately, e.g., log it, notify the user, or rethrow it
    }
  }
}
