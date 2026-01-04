import Foundation

/// Simple pattern storage using UserDefaults for the blocker extension
final class PatternStore {
    private let userDefaults: UserDefaults?

    init() {
        userDefaults = UserDefaults(suiteName: "group.com.cbouvat.saracroche")
    }

    private struct Keys {
        static let pendingPatterns = "pendingPatterns"
        static let completedPatterns = "completedPatterns"
    }

    /// Add a pattern to the pending list
    func addPattern(_ pattern: String, action: String, name: String? = nil) {
        guard var pendingPatterns = userDefaults?.array(forKey: Keys.pendingPatterns) as? [String] else {
            userDefaults?.set([pattern], forKey: Keys.pendingPatterns)
            return
        }

        if !pendingPatterns.contains(pattern) {
            pendingPatterns.append(pattern)
            userDefaults?.set(pendingPatterns, forKey: Keys.pendingPatterns)
        }
    }

    /// Get pending patterns batch
    func getPendingPatternsBatch(limit: Int) -> [String] {
        guard let pendingPatterns = userDefaults?.array(forKey: Keys.pendingPatterns) as? [String] else {
            return []
        }

        let batch = Array(pendingPatterns.prefix(limit))
        return batch
    }

    /// Mark patterns as completed
    func markPatternsAsCompleted(_ patterns: [String]) {
        guard var pendingPatterns = userDefaults?.array(forKey: Keys.pendingPatterns) as? [String] else {
            return
        }

        // Remove completed patterns from pending list
        let filteredPending = pendingPatterns.filter { !patterns.contains($0) }
        userDefaults?.set(filteredPending, forKey: Keys.pendingPatterns)

        // Add to completed list
        var completedPatterns = userDefaults?.array(forKey: Keys.completedPatterns) as? [String] ?? []
        completedPatterns.append(contentsOf: patterns)
        userDefaults?.set(completedPatterns, forKey: Keys.completedPatterns)
    }

    /// Get all patterns by action (simplified - returns all pending patterns)
    func getPatternsByAction(_ action: String) -> [String] {
        guard let pendingPatterns = userDefaults?.array(forKey: Keys.pendingPatterns) as? [String] else {
            return []
        }
        return pendingPatterns
    }

    /// Delete all patterns
    func deleteAllPatterns() {
        userDefaults?.removeObject(forKey: Keys.pendingPatterns)
        userDefaults?.removeObject(forKey: Keys.completedPatterns)
    }
}
