import Foundation

/// A collection of helper functions for manipulating and processing phone number patterns.
/// These functions are used to work with blocking patterns that may contain wildcards (#).
enum PhoneNumberHelpers {
  /// Counts the number of phone numbers represented by a blocking pattern.
  ///
  /// For example, a pattern like "123#" represents 10 numbers (1230-1239),
  /// and "123##" represents 100 numbers (12300-12399).
  ///
  /// - Parameter pattern: The blocking pattern to count (may contain # wildcards).
  /// - Returns: The count of phone numbers represented by the pattern.
  static func countPhoneNumbers(for pattern: String) -> Int64 {
    let hashCount = pattern.filter { $0 == "#" }.count
    return Int64(pow(10, Double(hashCount)))
  }

  /// Expands a blocking pattern into individual phone numbers.
  ///
  /// For example, the pattern "123#" would expand to ["1230", "1231", "1232", "1233", "1234", "1235", "1236", "1237", "1238", "1239"].
  ///
  /// - Parameter pattern: The blocking pattern to expand (may contain # wildcards).
  /// - Returns: An array of phone numbers represented by the pattern.
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
