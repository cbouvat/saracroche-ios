import Combine
import Foundation
import OSLog

@MainActor
class NumbersViewModel: ObservableObject {
  // MARK: - Published Properties

  // French list metadata
  @Published var frenchListName: String = ""
  @Published var frenchListVersion: String = ""
  @Published var frenchListDate: Date?
  @Published var frenchListBlockedCount: Int = 0

  // Pattern arrays
  @Published var apiPatterns: [Pattern] = []
  @Published var userPatterns: [Pattern] = []

  // UI State
  @Published var showAlert: Bool = false
  @Published var alertMessage: String = ""
  @Published var isLoading: Bool = false

  // MARK: - Dependencies

  private let patternService: PatternService
  private let blockerService: BlockerService
  private let logger = Logger(subsystem: "com.cbouvat.saracroche", category: "NumbersViewModel")

  // MARK: - Initialization

  init(
    patternService: PatternService = PatternService(),
    blockerService: BlockerService = BlockerService()
  ) {
    self.patternService = patternService
    self.blockerService = blockerService
    loadData()
  }

  // MARK: - Data Loading

  func loadData() {
    loadAPIPatterns()
    loadUserPatterns()
    updateFrenchListMetadata()
  }

  private func loadAPIPatterns() {
    apiPatterns = patternService.getPatterns(bySource: "api")
      .sorted { ($0.name ?? "") < ($1.name ?? "") }
  }

  private func loadUserPatterns() {
    userPatterns = patternService.getPatterns(bySource: "user")
      .sorted { ($0.addedDate ?? Date()) > ($1.addedDate ?? Date()) }
  }

  private func updateFrenchListMetadata() {
    // Extract metadata from the first API pattern
    if let firstPattern = apiPatterns.first {
      frenchListName = firstPattern.sourceListName ?? "Liste Française"
      frenchListVersion = firstPattern.sourceVersion ?? "1.0"
      frenchListDate = firstPattern.addedDate

      // Calculate total blocked numbers
      frenchListBlockedCount = apiPatterns.reduce(0) { total, pattern in
        guard let patternString = pattern.pattern else { return total }
        return total + Int(PhoneNumberHelpers.countPhoneNumbers(for: patternString))
      }
    }
  }

  // MARK: - Prefix CRUD Operations

  func addPattern(
    patternString: String, action: String, name: String?
  ) async {
    // Validate pattern
    guard validatePattern(patternString) else { return }

    // Check for duplicates
    if patternService.getPattern(byPatternString: patternString) != nil {
      showError("Ce préfixe existe déjà dans votre liste.")
      return
    }

    isLoading = true

    // Create pattern
    if patternService.createPattern(
      patternString: patternString,
      action: action,
      name: name?.isEmpty == true ? nil : name,
      source: "user"
    ) != nil {
      logger.info("Prefix created: \(patternString)")

      // Trigger blocker update
      await triggerPatternProcessing()

      // Reload data
      loadData()
    } else {
      showError("Impossible de créer le préfixe.")
    }

    isLoading = false
  }

  func updatePattern(
    pattern: Pattern, newPatternString: String, action: String, name: String?
  ) async {
    guard validatePattern(newPatternString) else { return }

    isLoading = true

    // If pattern string changed, check for duplicates
    if pattern.pattern != newPatternString {
      if patternService.getPattern(byPatternString: newPatternString) != nil {
        showError("Ce préfixe existe déjà.")
        isLoading = false
        return
      }

      // Delete old pattern and create new one
      patternService.deletePattern(pattern)
      _ = patternService.createPattern(
        patternString: newPatternString,
        action: action,
        name: name?.isEmpty == true ? nil : name,
        source: "user"
      )
      logger.info("Prefix updated (string changed): \(newPatternString)")
    } else {
      // Just update action and name
      patternService.updatePattern(
        pattern, action: action, name: name?.isEmpty == true ? nil : name
      )
      logger.info("Prefix updated: \(newPatternString)")
    }

    // Reload data
    loadData()

    isLoading = false
  }

  func deletePattern(_ pattern: Pattern) {
    patternService.deletePattern(pattern)

    // Mark for removal
    if let patternString = pattern.pattern {
      _ = patternService.createPattern(
        patternString: patternString,
        action: "remove",
        name: pattern.name,
        source: "user"
      )
      logger.info("Prefix marked for removal: \(patternString)")
    }

    // Trigger blocker update
    Task {
      loadData()
    }
  }

  // MARK: - Validation

  private func validatePattern(_ pattern: String) -> Bool {
    // Remove whitespace
    let trimmed = pattern.trimmingCharacters(in: .whitespacesAndNewlines)

    // Check if empty
    if trimmed.isEmpty {
      showError("Le préfixe ne peut pas être vide.")
      return false
    }

    // Check if contains only numbers, +, and #
    let allowedCharacters = CharacterSet(charactersIn: "0123456789#+")
    if trimmed.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
      showError("Le préfixe ne peut contenir que des chiffres, '+' et '#'.")
      return false
    }

    // Must start with + for international format
    if !trimmed.hasPrefix("+") {
      showError("Le préfixe doit commencer par '+' (format international).")
      return false
    }

    // Minimum length check (e.g., +33 + at least 6 digits)
    if trimmed.count < 9 {
      showError("Le préfixe est trop court. Format attendu: +33XXXXXXXXX")
      return false
    }

    // Check that # wildcards don't create too many numbers
    let hashCount = trimmed.filter { $0 == "#" }.count
    if hashCount > 4 {
      showError("Trop de jokers '#'. Maximum 4 jokers dans un préfixe.")
      return false
    }

    return true
  }

  // MARK: - Pattern Processing

  private func triggerPatternProcessing() async {
    // Call BlockerService to process pending patterns
    await withCheckedContinuation { continuation in
      blockerService.performUpdate(
        onProgress: {},
        completion: { success in
          if !success {
            self.logger.error("Failed to process patterns")
          } else {
            self.logger.info("Pattern processing completed successfully")
          }
          continuation.resume()
        })
    }
  }

  // MARK: - Alert Helpers

  private func showError(_ message: String) {
    alertMessage = message
    showAlert = true
  }
}
