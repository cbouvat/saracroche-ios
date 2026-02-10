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

  var body: some View {
    NavigationView {
      Form {
        Section {
          VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
              Text("Préfixe")
                .font(.subheadline)
                .fontWeight(.semibold)
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
                      isPatternFieldFocused ? Color("AppColor") : Color(.systemGray4),
                      lineWidth: 1
                    )
                )
                .accessibilityLabel("Champ de saisie du préfixe de blocage")
                .accessibilityHint(
                  "Entrez un numéro avec des jokers '#' en fin de numéro. Exemple: +33612345####"
                )
              Text(
                "Format international avec '#' comme joker en fin de numéro. Ex: +33612345####"
              )
              .font(.caption)
              .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
              Text("Nom")
                .font(.subheadline)
                .fontWeight(.semibold)
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
                .font(.caption)
                .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
              Text("Action")
                .font(.subheadline)
                .fontWeight(.semibold)
              ReportChoiceButton(
                title: "Bloquer",
                description: "Bloquer les appels correspondants",
                icon: "shield.fill",
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
                if !viewModel.showAlert {
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
            .disabled(viewModel.isLoading || patternString.isEmpty || name.isEmpty)
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
          .font(.body.weight(.bold))
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
