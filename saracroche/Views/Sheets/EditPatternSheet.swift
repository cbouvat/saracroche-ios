import SwiftUI

struct EditPatternSheet: View {
  @Environment(\.dismiss) private var dismiss
  @ObservedObject var viewModel: NumbersViewModel
  @Binding var isPresented: Pattern?

  let pattern: Pattern

  @State private var patternString: String = ""
  @State private var action: String = "block"
  @State private var name: String = ""
  @FocusState private var isPatternFieldFocused: Bool

  var body: some View {
    NavigationView {
      Form {
        Section {
          VStack(alignment: .leading, spacing: 4) {
            Text("Saisissez le préfixe au format international avec des jokers '#'")
              .font(.caption)
              .foregroundColor(.secondary)

            TextField("+33612345####", text: $patternString)
              .keyboardType(.phonePad)
              .textInputAutocapitalization(.never)
              .autocorrectionDisabled(true)
              .focused($isPatternFieldFocused)
              .accessibilityLabel("Champ de saisie du préfixe de blocage")
              .accessibilityHint(
                "Entrez un numéro avec des jokers '#'. Exemple: +33612345####"
              )
          }
        } header: {
          Text("Préfixe")
        } footer: {
          Text(
            "Utilisez '#' comme joker. Exemple: +33612345#### bloque de +33612345000 à +33612345999."
          )
        }

        Section {
          Picker("Action", selection: $action) {
            Text("Bloquer").tag("block")
            Text("Identifier").tag("identify")
          }
          .pickerStyle(.segmented)
          .accessibilityLabel("Action du pattern")
          .accessibilityHint("Choisissez si le pattern doit bloquer ou identifier les numéros")
        } header: {
          Text("Action")
        }

        Section {
          TextField("Optionnel", text: $name)
            .textInputAutocapitalization(.words)
            .accessibilityLabel("Nom du préfixe")
            .accessibilityHint("Entrez un nom optionnel pour identifier ce préfixe")
        } header: {
          Text("Nom")
        } footer: {
          Text("Un nom optionnel pour identifier ce préfixe (ex: 'Spam Marketing').")
        }

        Section {
          Button {
            Task {
              await viewModel.updatePattern(
                pattern: pattern,
                newPatternString: patternString,
                action: action,
                name: name
              )
              if !viewModel.showAlert {
                isPresented = nil
              }
            }
          } label: {
            HStack {
              Image(systemName: "checkmark.circle.fill")
              Text("Enregistrer")
            }
          }
          .buttonStyle(.fullWidth(background: Color("AppColor"), foreground: .black))
          .disabled(viewModel.isLoading || patternString.isEmpty)
        }
      }
      .navigationTitle("Modifier Préfixe")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Annuler") {
            isPresented = nil
          }
        }
        ToolbarItemGroup(placement: .keyboard) {
          Spacer()
          Button("Terminé") {
            isPatternFieldFocused = false
          }
          .font(.body.weight(.bold))
        }
      }
      .onAppear {
        patternString = pattern.pattern ?? ""
        action = pattern.action ?? "block"
        name = pattern.name ?? ""
      }
    }
  }
}

#Preview {
  EditPatternSheet(
    viewModel: NumbersViewModel(),
    isPresented: .constant(nil),
    pattern: Pattern()
  )
}
