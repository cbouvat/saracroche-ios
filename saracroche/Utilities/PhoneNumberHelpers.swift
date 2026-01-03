import Foundation

/// Helper functions for phone number patterns
public enum PhoneNumberHelpers {
  public static func countPhoneNumbers(for pattern: String) -> Int64 {
    let hashCount = pattern.filter { $0 == "#" }.count
    return Int64(pow(10, Double(hashCount)))
  }

  public static func expandBlockingPattern(_ pattern: String) -> [String] {
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
