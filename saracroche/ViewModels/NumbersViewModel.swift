import Combine
import Foundation

@MainActor
class NumbersViewModel: ObservableObject {
  // MARK: - Published Properties

  // French list metadata
  @Published var frenchListName: String = ""
  @Published var frenchListVersion: String = ""
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

  // MARK: - Initialization

  init(
    patternService: PatternService = PatternService(),
    blockerService: BlockerService = BlockerService()
  ) {
    self.patternService = patternService
    self.blockerService = blockerService
    Task { [weak self] in
      await self?.loadData()
    }
  }

  // MARK: - Data Loading

  func loadData() async {
    await loadAPIPatterns()
    await loadUserPatterns()
    updateFrenchListMetadata()
  }

  private func loadAPIPatterns() async {
    apiPatterns = await patternService.getPatterns(bySource: "api")
  }

  private func loadUserPatterns() async {
    userPatterns = await patternService.getPatterns(bySource: "user")
      .sorted { ($0.addedDate ?? Date()) > ($1.addedDate ?? Date()) }
  }

  private func updateFrenchListMetadata() {
    // Extract metadata from the first API pattern
    if let firstPattern = apiPatterns.first {
      frenchListName = firstPattern.sourceListName ?? "Liste Française"
      frenchListVersion = firstPattern.sourceVersion ?? "1.0"
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
    if await patternService.getPattern(byPatternString: patternString) != nil {
      showError("Ce préfixe existe déjà dans votre liste.")
      return
    }

    isLoading = true

    // Create pattern
    if await patternService.createPattern(
      patternString: patternString,
      action: action,
      name: name?.isEmpty == true ? nil : name,
      source: "user"
    ) != nil {
      Logger.info("Prefix created: \(patternString)", category: .numbersViewModel)
      // Reload data
      await loadData()
    } else {
      showError("Impossible de créer le préfixe.")
    }

    isLoading = false
  }

  func deletePattern(_ pattern: Pattern) async {
    let action = pattern.action ?? "block"
    await patternService.deletePattern(pattern)

    // Mark for removal with action-specific removal type
    if let patternString = pattern.pattern {
      let removeAction = action == "identify" ? "remove_identify" : "remove_block"
      _ = await patternService.createPattern(
        patternString: patternString,
        action: removeAction,
        name: pattern.name,
        source: "user"
      )
      Logger.info("Prefix marked for removal: \(patternString)", category: .numbersViewModel)
    }

    // Trigger blocker update
    Task {
      await loadData()
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

    // Check for spaces
    if trimmed.contains(" ") {
      showError("Le préfixe ne doit pas contenir d'espaces.")
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

    // Check that # wildcards are only at the end
    let hashCount = trimmed.filter { $0 == "#" }.count
    if hashCount > 0, let firstHash = trimmed.firstIndex(of: "#") {
      let afterFirstHash = trimmed[firstHash...]
      if afterFirstHash.contains(where: { $0 != "#" }) {
        showError("Les jokers '#' doivent être uniquement en fin de numéro.")
        return false
      }
    }

    // Minimum length check (e.g., +33 + at least 6 digits)
    if trimmed.count < 9 {
      showError("Le préfixe est trop court. Format attendu: +33XXXXXXXXX")
      return false
    }

    // Check that # wildcards don't create too many numbers
    if hashCount > 4 {
      showError("Trop de jokers '#'. Maximum 4 jokers dans un préfixe.")
      return false
    }

    return true
  }

  // MARK: - Alert Helpers

  private func showError(_ message: String) {
    alertMessage = message
    showAlert = true
  }
}
