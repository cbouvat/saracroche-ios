import CoreData
import Foundation

final class BlockListConverterService {
  static let shared = BlockListConverterService()

  private let coreDataService = BlockedNumberCoreDataService.shared

  private init() {}

  func convertBlockListToCoreData(blockList: [String]) throws -> [BlockedNumber] {
    // Supprimer les anciens numéros
    coreDataService.deleteAllBlockedNumbers()

    // Ajouter les nouveaux numéros
    var result = [BlockedNumber]()

    for phoneNumber in blockList {
      // Valider le numéro de téléphone
      let blockedNumber = coreDataService.addBlockedNumber(
        phoneNumber,
        action: "block",
        source: "unknown"
      )
      result.append(blockedNumber)
    }

    // Save all changes at once
    coreDataService.saveContext()

    return result
  }

  func convertBlockListWithMetadata(
    blockList: [String],
    source: String,
    version: String
  ) throws -> [BlockedNumber] {
    coreDataService.deleteAllBlockedNumbers()

    var result = [BlockedNumber]()

    for phoneNumber in blockList {
      let blockedNumber = coreDataService.addBlockedNumber(
        phoneNumber,
        action: "block",
        source: source
      )
      // Ajouter des métadonnées
      blockedNumber.sourceVersion = version
      blockedNumber.addedDate = Date()

      result.append(blockedNumber)
    }

    // Save all changes at once
    coreDataService.saveContext()

    return result
  }

  /// Converts a block list to Core Data with incremental updates.
  /// This method updates existing numbers, adds new ones, and removes old ones.
  ///
  /// - Parameters:
  ///   - blockList: The list of phone numbers to block.
  ///   - source: The source of the block list.
  ///   - sourceListName: The name of the source list.
  ///   - sourceVersion: The version of the source list.
  /// - Returns: The list of blocked numbers that were added or updated.
  /// - Throws: An error if the conversion fails.
  func convertBlockListIncremental(
    blockList: [String],
    source: String,
    sourceListName: String,
    sourceVersion: String
  ) throws -> [BlockedNumber] {
    var result = [BlockedNumber]()
    let blockListSet = Set(blockList)

    // Get all existing numbers
    let existingNumbers = coreDataService.getAllBlockedNumbers()
    var existingNumbersSet = Set<String>()

    // Update existing numbers and track them
    for blockedNumber in existingNumbers {
      existingNumbersSet.insert(blockedNumber.number ?? "")

      if blockListSet.contains(blockedNumber.number ?? "") {
        // Update existing number with new metadata
        blockedNumber.source = source
        blockedNumber.sourceListName = sourceListName
        blockedNumber.sourceVersion = sourceVersion
        blockedNumber.addedDate = Date()
        blockedNumber.completedDate = nil  // Reset completion status for reprocessing
        blockedNumber.action = "block"  // Set action to block
        result.append(blockedNumber)
      } else {
        // Delete number that is no longer in the block list
        coreDataService.deleteBlockedNumber(blockedNumber.number ?? "")
      }
    }

    // Add new numbers
    for phoneNumber in blockList {
      if !existingNumbersSet.contains(phoneNumber) {
        let blockedNumber = coreDataService.addBlockedNumber(
          phoneNumber,
          action: "block",
          source: source
        )
        blockedNumber.sourceListName = sourceListName
        blockedNumber.sourceVersion = sourceVersion
        blockedNumber.addedDate = Date()
        blockedNumber.completedDate = nil  // Set to nil for batch processing

        result.append(blockedNumber)
      }
    }

    // Save all changes at once
    coreDataService.saveContext()

    return result
  }
}
