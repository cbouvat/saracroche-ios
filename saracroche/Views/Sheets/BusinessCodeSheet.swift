import SwiftUI

struct BusinessCodeSheet: View {
  @Environment(\.dismiss) private var dismiss

  /// Valid Sqids characters: lowercase, uppercase letters and digits.
  private static let sqidsCharacterSet = CharacterSet.alphanumerics

  @State private var code: String = ""
  @State private var showError: Bool = false
  @FocusState private var isCodeFieldFocused: Bool

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          VStack(spacing: 16) {
            if #available(iOS 18.0, *) {
              Image(systemName: "building.2.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .symbolEffect(.bounce.down.byLayer, options: .repeat(.periodic(delay: 0.5)))
            } else {
              Image(systemName: "building.2.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            }

            Text("Saracroche pour les entreprises")
              .appFont(.titleBold)
              .multilineTextAlignment(.center)
          }

          VStack(alignment: .leading, spacing: 8) {
            Text(
              "Protégez les flottes mobiles de votre entreprise avec une gestion centralisée."
            )
            .appFont(.body)
            .multilineTextAlignment(.leading)
          }

          VStack(alignment: .leading, spacing: 8) {
            Text("Avantages")
              .appFont(.headlineSemiBold)
              .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 16) {
              BenefitRow(
                icon: "chart.bar.doc.horizontal.fill",
                title: "Dashboard de gestion",
                description:
                  "Gérez les signalements et les données de blocage depuis une interface centralisée"
              )

              BenefitRow(
                icon: "person.3.fill",
                title: "Listes personnalisées",
                description:
                  "Créez et gérez vos listes autorisées pour toujours recevoir les appels des numéros de confiance."
              )

              BenefitRow(
                icon: "exclamationmark.bubble.fill",
                title: "Signalement centralisé",
                description:
                  "Remontée centralisée des appels indésirables pour toute l'entreprise"
              )

              BenefitRow(
                icon: "phone.fill.badge.checkmark",
                title: "Blocage multi-canaux",
                description:
                  "Blocage des appels et SMS indésirables, protection contre le phishing"
              )

              BenefitRow(
                icon: "server.rack",
                title: "Déploiement MDM",
                description:
                  "Configuration centralisée via Intune, déploiement sans intervention utilisateur"
              )

              BenefitRow(
                icon: "arrow.clockwise.circle.fill",
                title: "Mises à jour automatiques",
                description:
                  "Protection toujours à jour grâce aux mises à jour en arrière-plan"
              )
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
              RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
            )
          }

          VStack(alignment: .leading, spacing: 8) {
            TextField("Entrez votre code entreprise", text: $code)
              .keyboardType(.asciiCapable)
              .textInputAutocapitalization(.never)
              .autocorrectionDisabled(true)
              .textFieldStyle(.plain)
              .focused($isCodeFieldFocused)
              .padding(12)
              .background(Color(.systemBackground))
              .cornerRadius(12)
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(
                    showError
                      ? Color.red
                      : isCodeFieldFocused ? Color.blue : Color(.systemGray4),
                    lineWidth: 1
                  )
              )
              .accessibilityLabel("Champ de saisie du code entreprise")
              .accessibilityHint("Entrez le code fourni par votre administrateur")
              .onChange(of: code) { _ in
                let filtered = code.unicodeScalars.filter {
                  Self.sqidsCharacterSet.contains($0)
                }
                let filteredString = String(String.UnicodeScalarView(filtered))
                if filteredString != code {
                  code = filteredString
                }
                showError = false
              }

            if showError {
              Text("Code invalide. Veuillez vérifier votre code entreprise.")
                .appFont(.caption)
                .foregroundColor(.red)
                .accessibilityLabel("Erreur: Code invalide")
            } else {
              Text("Code fourni par l'administrateur de votre entreprise.")
                .appFont(.caption)
                .foregroundColor(.secondary)
            }
          }

          Button {
            showError = true
          } label: {
            HStack {
              Image(systemName: "checkmark.circle.fill")
              Text("Activer")
            }
          }
          .buttonStyle(.fullWidth(background: .blue, foreground: .white))
          .disabled(code.isEmpty)
        }
        .padding()
      }
      .toolbar {
        ToolbarItem {
          Button("Fermer") {
            dismiss()
          }
        }
        ToolbarItemGroup(placement: .keyboard) {
          Spacer()
          Button("Terminé") {
            isCodeFieldFocused = false
          }
          .appFont(.bodyBold)
        }
      }
    }
  }
}

#Preview {
  BusinessCodeSheet()
}
