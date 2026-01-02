import Foundation

/// Helper functions for phone number pattern manipulation
enum PhoneNumberHelpers {
  /// Counts the number of phone numbers represented by a blocking pattern
  /// - Parameter pattern: The blocking pattern to count
  /// - Returns: The count of phone numbers represented by the pattern
  static func countPhoneNumbers(for pattern: String) -> Int64 {
    let hashCount = pattern.filter { $0 == "#" }.count
    return Int64(pow(10, Double(hashCount)))
  }

  /// Expands a blocking pattern into individual phone numbers
  /// - Parameter pattern: The blocking pattern to expand
  /// - Returns: Array of phone numbers represented by the pattern
  static func expandBlockingPattern(_ pattern: String) -> [String] {
    if !pattern.contains("#") {
      return [pattern]
    }

    let minNumberInPrefix =
      Int64(pattern.replacingOccurrences(of: "#", with: "0")) ?? 0
    let maxNumberInPrefix =
      Int64(pattern.replacingOccurrences(of: "#", with: "9")) ?? 0

    var results: [String] = []

    for number in minNumberInPrefix...maxNumberInPrefix {
      results.append(String(number))
    }

    return results
  }
}
