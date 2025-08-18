import Foundation
import SwiftUI

@MainActor
class ReportViewModel: ObservableObject {
  @Published var phoneNumber: String = ""
  @Published var showAlert: Bool = false
  @Published var alertMessage: String = ""
  @Published var alertType: AlertType = .info

  enum AlertType {
    case success, error, info

    var title: String {
      switch self {
      case .success: return "Succès"
      case .error: return "Erreur"
      case .info: return "Information"
      }
    }
  }

  private let networkService = NetworkService()

  func submitPhoneNumber() async {
    // Formater le numéro avant validation
    phoneNumber = formatPhoneNumber(phoneNumber)

    guard validatePhoneNumber() else { return }

    do {
      try await networkService.reportPhoneNumber(phoneNumber)
      handleSuccess()
    } catch {
      handleError(error)
    }
  }

  private func validatePhoneNumber() -> Bool {
    let trimmedNumber = phoneNumber.trimmingCharacters(
      in: .whitespacesAndNewlines
    )

    // Validation for E.164 format
    let e164Regex = "^\\+[1-9]\\d{7,14}$"
    let isValidFormat = trimmedNumber.matches(e164Regex)

    if trimmedNumber.isEmpty {
      showError("Veuillez saisir un numéro de téléphone.")
      return false
    }

    if !isValidFormat {
      showError("Le numéro doit être au format E.164 (ex: +33612345678).")
      return false
    }

    // Validation for French numbers
    if trimmedNumber.hasPrefix("+33") && trimmedNumber.count != 12 {
      showError("Les numéros français doivent contenir 12 caractères au total.")
      return false
    }

    return true
  }

  private func handleSuccess() {
    phoneNumber = ""
    alertType = .success
    alertMessage = "Numéro signalé avec succès ! Merci de votre contribution 😊"
    showAlert = true
  }

  private func handleError(_ error: Error) {
    if let networkError = error as? NetworkError {
      alertType = .error
      alertMessage = networkError.userMessage
    } else {
      alertType = .error
      alertMessage = "Une erreur inattendue s'est produite. Veuillez réessayer."
    }
    showAlert = true
  }

  private func showError(_ message: String) {
    alertType = .error
    alertMessage = message
    showAlert = true
  }

  func formatPhoneNumber(_ input: String) -> String {
    let cleaned = input.replacingOccurrences(of: " ", with: "")
    return cleaned.filter { $0.isNumber || $0 == "+" }
  }
}

// Extension for String to match regex
extension String {
  fileprivate func matches(_ regex: String) -> Bool {
    return self.range(of: regex, options: .regularExpression) != nil
  }
}
