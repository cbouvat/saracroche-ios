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
        coreDataService.addBlockedNumber(phoneNumber)

        if let blockedNumber = coreDataService.getBlockedNumber(by: phoneNumber) {
          result.append(blockedNumber)
        }
    }

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
        coreDataService.addBlockedNumber(phoneNumber)

        if let blockedNumber = coreDataService.getBlockedNumber(by: phoneNumber) {
          // Ajouter des métadonnées
          blockedNumber.source = source
          blockedNumber.sourceVersion = version
          blockedNumber.addedDate = Date()

          result.append(blockedNumber)
        }
    }

    return result
  }
}
