import Foundation

class PhoneNumberService {

  static let shared = PhoneNumberService()

  private init() {}

  // MARK: - Load Patterns
  func loadPhoneNumberPatterns() -> [String] {
    guard
      let url = Bundle.main.url(forResource: "blocked-patterns", withExtension: "json")
    else {
      print("blocked-patterns.json not found in bundle.")
      return []
    }

    do {
      let data = try Data(contentsOf: url)
      if let jsonArray = try JSONSerialization.jsonObject(
        with: data,
        options: []
      ) as? [[String: String]] {
        return jsonArray.compactMap { $0["pattern"] }
      }
    } catch {
      print("Error loading blocked-patterns.json: \(error.localizedDescription)")
    }

    return []
  }

  // MARK: - Count All Blocked Numbers
  func countAllBlockedNumbers() -> Int64 {
    var totalCount: Int64 = 0

    for pattern in loadPhoneNumberPatterns() {
      let hashCount = pattern.filter { $0 == "#" }.count
      totalCount += Int64(pow(10, Double(hashCount)))
    }

    return totalCount
  }

  // MARK: - Generate Phone Numbers
  func generatePhoneNumbers(pattern: String) -> [String] {
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
