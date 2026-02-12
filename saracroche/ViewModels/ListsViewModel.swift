import Combine
import Foundation

@MainActor
class ListsViewModel: ObservableObject {
  // MARK: - Published Properties

  // French list metadata
  @Published var frenchListName: String = ""
  @Published var frenchListVersion: String = ""
  @Published var frenchListBlockedCount: Int = 0

  // Pattern arrays
  @Published var apiPatterns: [Pattern] = []
  @Published var userPatterns: [Pattern] = []

  // UI State
  @Published var patternError: String? = nil
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
      .filter { !($0.action?.hasPrefix("remove_") ?? false) }
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
    patternError = nil

    // Validate pattern format
    if let error = ListsViewModel.validatePatternFormat(patternString) {
      patternError = error
      return
    }

    // Check for duplicates
    if await patternService.getPattern(byPatternString: patternString) != nil {
      patternError = "Ce préfixe existe déjà dans votre liste."
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
      Logger.info("Prefix created: \(patternString)", category: .listsViewModel)
      // Reload data
      await loadData()
    } else {
      patternError = "Impossible de créer le préfixe."
    }

    isLoading = false
  }

  func deletePattern(_ pattern: Pattern) async {
    await patternService.markPatternForDeletion(pattern)
    Logger.info("Prefix marked for removal: \(pattern.pattern ?? "")", category: .listsViewModel)
    await loadData()
  }

  // MARK: - Validation

  /// Validates a pattern string and returns an error message if invalid, or `nil` if valid.
  static func validatePatternFormat(_ pattern: String) -> String? {
    let trimmed = pattern.trimmingCharacters(in: .whitespacesAndNewlines)

    if trimmed.isEmpty {
      return "Le préfixe ne peut pas être vide."
    }

    if trimmed.contains(" ") {
      return "Le préfixe ne doit pas contenir d'espaces."
    }

    let allowedCharacters = CharacterSet(charactersIn: "0123456789#+")
    if trimmed.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
      return "Le préfixe ne peut contenir que des chiffres, '+' et '#'."
    }

    if !trimmed.hasPrefix("+") {
      return "Le préfixe doit commencer par '+' (format international)."
    }

    let hashCount = trimmed.filter { $0 == "#" }.count
    if hashCount > 0, let firstHash = trimmed.firstIndex(of: "#") {
      let afterFirstHash = trimmed[firstHash...]
      if afterFirstHash.contains(where: { $0 != "#" }) {
        return "Les jokers '#' doivent être uniquement en fin de numéro."
      }
    }

    if trimmed.count < 4 {
      return "Le préfixe est trop court (minimum 4 caractères)."
    }

    if hashCount > 6 {
      return "Trop de jokers '#'. Maximum 6 jokers dans un préfixe."
    }

    return nil
  }

}
