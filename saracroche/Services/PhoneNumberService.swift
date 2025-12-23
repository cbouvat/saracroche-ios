import Foundation

class PhoneNumberService {

  static let shared = PhoneNumberService()

  private init() {}

  func loadPhoneNumberPatterns() -> [String] {
    BlockedPatternsService.shared.patternStrings
  }

  // MARK: - Count Phone Numbers Represented by All Blocking Patterns
  func countPhoneNumbersRepresentedByAllBlockingPatterns() -> Int64 {
    var totalCount: Int64 = 0

    for pattern in loadPhoneNumberPatterns() {
      let hashCount = pattern.filter { $0 == "#" }.count
      totalCount += Int64(pow(10, Double(hashCount)))
    }

    return totalCount
  }

  // MARK: - Expand Blocking Pattern Into Phone Numbers
  func expandBlockingPatternIntoPhoneNumbers(
    from pattern: String
  ) -> [String] {
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
