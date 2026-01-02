import Foundation
import SwiftUI

/// A view model for handling phone number reporting functionality.
/// This view model manages the state and logic for submitting unwanted phone numbers to the server.
@MainActor
class ReportViewModel: ObservableObject {
  /// The phone number to be reported.
  @Published var phoneNumber: String = ""

  /// Controls whether an alert should be displayed.
  @Published var showAlert: Bool = false

  /// The message to display in the alert.
  @Published var alertMessage: String = ""

  /// The type of alert to display (success, error, or info).
  @Published var alertType: AlertType = .info

  /// Types of alerts that can be displayed.
  enum AlertType {
    /// A success alert indicating the operation completed successfully.
    case success

    /// An error alert indicating the operation failed.
    case error

    /// An informational alert providing additional information.
    case info

    /// The localized title for the alert type.
    var title: String {
      switch self {
      case .success: return "Success"
      case .error: return "Error"
      case .info: return "Information"
      }
    }
  }

  /// Service for making API requests to report phone numbers.
  private let apiService = APIService()

  /// Submits the phone number to be reported to the server.
  ///
  /// This method:
  /// 1. Formats the phone number
  /// 2. Validates the phone number format
  /// 3. Converts the phone number to Int64
  /// 4. Sends the report via the API service
  /// 5. Handles success or error responses appropriately
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

  /// Validates the phone number format.
  ///
  /// The phone number must:
  /// - Not be empty
  /// - Match the E.164 format (e.g., +33612345678)
  ///
  /// - Returns: true if the phone number is valid, false otherwise.
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

  /// Handles the success case when a phone number is successfully reported.
  ///
  /// Resets the phone number field and shows a success alert to the user.
  private func handleSuccess() {
    phoneNumber = ""
    alertType = .success
    alertMessage = "Phone number reported successfully! Thank you for your contribution 😊"
    showAlert = true
  }

  /// Handles error cases when reporting a phone number fails.
  ///
  /// - Parameter error: The error that occurred during the reporting process.
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

  /// Displays an error alert to the user.
  ///
  /// - Parameter message: The error message to display.
  private func showError(_ message: String) {
    alertType = .error
    alertMessage = message
    showAlert = true
  }

  /// Formats a phone number by removing spaces and keeping only digits and the plus sign.
  ///
  /// - Parameter input: The phone number string to format.
  /// - Returns: The formatted phone number string.
  func formatPhoneNumber(_ input: String) -> String {
    let cleaned = input.replacingOccurrences(of: " ", with: "")
    return cleaned.filter { $0.isNumber || $0 == "+" }
  }

  /// Converts a phone number string to Int64 by extracting only the digits.
  ///
  /// - Parameter phoneNumber: The phone number string to convert.
  /// - Returns: The phone number as Int64, or 0 if conversion fails.
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
