import SwiftUI

struct AddPatternSheet: View {
  @Environment(\.dismiss) private var dismiss
  @ObservedObject var viewModel: NumbersViewModel
  @Binding var isPresented: Bool

  @State private var patternString: String = ""
  @State private var isBlock: Bool = true
  @State private var name: String = ""
  @FocusState private var isPatternFieldFocused: Bool
  @FocusState private var isNameFieldFocused: Bool

  /// Real-time format validation error (computed from current input).
  private var formatError: String? {
    guard !patternString.isEmpty else { return nil }
    return NumbersViewModel.validatePatternFormat(patternString)
  }

  /// The error to display: async errors from the view model take priority, then format errors.
  private var displayedError: String? {
    viewModel.patternError ?? formatError
  }

  /// Whether the pattern contains `#` wildcards and has no format errors.
  private var showRange: Bool {
    patternString.contains("#") && formatError == nil && !patternString.isEmpty
  }

  var body: some View {
    NavigationView {
      Form {
        Section {
          VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
              Text("Préfixe")
                .appFont(.subheadlineSemiBold)
              TextField("+33612345####", text: $patternString)
                .keyboardType(.phonePad)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .textFieldStyle(.plain)
                .focused($isPatternFieldFocused)
                .padding(12)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                  RoundedRectangle(cornerRadius: 12)
                    .stroke(
                      displayedError != nil
                        ? Color.red
                        : isPatternFieldFocused ? Color("AppColor") : Color(.systemGray4),
                      lineWidth: 1
                    )
                )
                .accessibilityLabel("Champ de saisie du préfixe de blocage")
                .accessibilityHint(
                  "Entrez un numéro avec des jokers '#' en fin de numéro. Exemple: +33612345####"
                )
                .onChange(of: patternString) { _ in
                  viewModel.patternError = nil
                }

              if let error = displayedError {
                Text(error)
                  .appFont(.caption)
                  .foregroundColor(.red)
                  .accessibilityLabel("Erreur: \(error)")
              } else {
                Text(
                  "Format international avec '#' comme joker en fin de numéro. Ex: +33612345####"
                )
                .appFont(.caption)
                .foregroundColor(.secondary)
              }

              if showRange {
                let trimmed = patternString.trimmingCharacters(in: .whitespacesAndNewlines)
                let minValue = trimmed.replacingOccurrences(of: "#", with: "0")
                let maxValue = trimmed.replacingOccurrences(of: "#", with: "9")
                let count = PhoneNumberHelpers.countPhoneNumbers(for: trimmed)
                Text("Plage: \(minValue) → \(maxValue) (\(count) numéros)")
                  .appFont(.caption)
                  .foregroundColor(.secondary)
                  .accessibilityElement(children: .combine)
                  .accessibilityLabel(
                    "Plage de \(minValue) à \(maxValue), \(count) numéros"
                  )
              }
            }

            VStack(alignment: .leading, spacing: 4) {
              Text("Nom")
                .appFont(.subheadlineSemiBold)
              TextField("Spam Marketing", text: $name)
                .textInputAutocapitalization(.words)
                .textFieldStyle(.plain)
                .focused($isNameFieldFocused)
                .padding(12)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                  RoundedRectangle(cornerRadius: 12)
                    .stroke(
                      isNameFieldFocused ? Color("AppColor") : Color(.systemGray4),
                      lineWidth: 1
                    )
                )
                .accessibilityLabel("Nom du préfixe")
                .accessibilityHint("Entrez un nom pour identifier ce préfixe")
              Text("Un nom pour identifier ce préfixe, par exemple 'Spam Marketing'.")
                .appFont(.caption)
                .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
              Text("Action")
                .appFont(.subheadlineSemiBold)
              ReportChoiceButton(
                title: "Bloquer",
                description: "Bloquer les appels correspondants",
                icon: "xmark.circle.fill",
                isSelected: isBlock,
                color: .red,
                action: { isBlock = true }
              )
              ReportChoiceButton(
                title: "Identifier",
                description: "Identifier les appels correspondants",
                icon: "info.circle.fill",
                isSelected: !isBlock,
                color: .blue,
                action: { isBlock = false }
              )
            }

            Button {
              Task {
                await viewModel.addPattern(
                  patternString: patternString,
                  action: isBlock ? "block" : "identify",
                  name: name
                )
                if viewModel.patternError == nil {
                  isPresented = false
                }
              }
            } label: {
              HStack {
                Image(systemName: "plus.circle.fill")
                Text("Ajouter")
              }
            }
            .buttonStyle(.fullWidth(background: Color("AppColor"), foreground: .black))
            .disabled(
              viewModel.isLoading || patternString.isEmpty || name.isEmpty || formatError != nil)
          }
          .padding(.vertical, 6)
        }
      }
      .navigationTitle("Nouveau Préfixe")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Annuler") {
            isPresented = false
          }
        }
        ToolbarItemGroup(placement: .keyboard) {
          Spacer()
          Button("Terminé") {
            isPatternFieldFocused = false
            isNameFieldFocused = false
          }
          .appFont(.bodyBold)
        }
      }
    }
  }
}

#Preview {
  AddPatternSheet(
    viewModel: NumbersViewModel(), isPresented: .constant(true)
  )
}
