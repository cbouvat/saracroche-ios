import SwiftUI

struct AddPatternSheet: View {
  @Environment(\.dismiss) private var dismiss
  @ObservedObject var viewModel: ListsViewModel
  @Binding var isPresented: Bool

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
              await viewModel.addPattern(
                patternString: patternString,
                action: action,
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
          .disabled(viewModel.isLoading || patternString.isEmpty)
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
          }
          .font(.body.weight(.bold))
        }
      }
    }
  }
}

#Preview {
  AddPatternSheet(
    viewModel: ListsViewModel(), isPresented: .constant(true)
  )
}
