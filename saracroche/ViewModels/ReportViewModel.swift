import Foundation
import SwiftUI

/// View model for phone number reporting
@MainActor
class ReportViewModel: ObservableObject {
  @Published var phoneNumber: String = ""
  @Published var showAlert: Bool = false
  @Published var alertMessage: String = ""
  @Published var alertType: AlertType = .info

  enum AlertType {
    case success
    case error
    case info

    var title: String {
      switch self {
      case .success: return "Success"
      case .error: return "Error"
      case .info: return "Information"
      }
    }
  }

  private let apiService = ReportAPIService()

  func submitPhoneNumber() async {
    // Format the phone number before validation
    phoneNumber = formatPhoneNumber(phoneNumber)

    guard validatePhoneNumber() else { return }

    do {
      let phoneNumberInt64 = convertToInt64(phoneNumber)
      try await apiService.report(phoneNumberInt64)
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
      showError("Please enter a phone number.")
      return false
    }

    if !isValidFormat {
      showError("The number must be in E.164 format (e.g., +33612345678).")
      return false
    }

    return true
  }

  private func handleSuccess() {
    phoneNumber = ""
    alertType = .success
    alertMessage = "Phone number reported successfully! Thank you for your contribution 😊"
    showAlert = true
  }

  private func handleError(_ error: Error) {
    if let networkError = error as? NetworkError {
      alertType = .error
      alertMessage = networkError.userMessage
    } else {
      alertType = .error
      alertMessage = "An unexpected error occurred. Please try again."
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

  private func convertToInt64(_ phoneNumber: String) -> Int64 {
    let digitsOnly = phoneNumber.filter { $0.isNumber }
    return Int64(digitsOnly) ?? 0
  }
}

// Extension for String to match regex
extension String {
  fileprivate func matches(_ regex: String) -> Bool {
    return self.range(of: regex, options: .regularExpression) != nil
  }
}
