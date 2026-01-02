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
      if isValidPhoneNumber(phoneNumber) {
        coreDataService.addBlockedNumber(phoneNumber)

        if let blockedNumber = coreDataService.getBlockedNumber(by: phoneNumber) {
          result.append(blockedNumber)
        }
      }
    }

    return result
  }

  func convertBlockListWithMetadata(
    blockList: [String],
    source: String = "api",
    version: String = "1.0"
  ) throws -> [BlockedNumber] {
    coreDataService.deleteAllBlockedNumbers()

    var result = [BlockedNumber]()

    for phoneNumber in blockList {
      if isValidPhoneNumber(phoneNumber) {
        coreDataService.addBlockedNumber(phoneNumber)

        if let blockedNumber = coreDataService.getBlockedNumber(by: phoneNumber) {
          // Ajouter des métadonnées
          blockedNumber.source = source
          blockedNumber.sourceVersion = version
          blockedNumber.addedDate = Date()

          result.append(blockedNumber)
        }
      }
    }

    return result
  }

  private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
    // Implémentez votre logique de validation ici
    // Par exemple, vérifier le format, la longueur, etc.
    return !phoneNumber.isEmpty && phoneNumber.count >= 5
  }
}
