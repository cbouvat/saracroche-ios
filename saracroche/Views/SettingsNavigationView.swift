import SwiftUI

struct SettingsNavigationView: View {
  @ObservedObject var blockerViewModel: BlockerViewModel
  @State private var showingResetAlert = false

  var body: some View {
    NavigationView {
      Form {
        Section {
          Button {
            blockerViewModel.openSettings()
          } label: {
            Label(
              "Activer ou désactiver Saracroche dans **Réglages**",
              systemImage: "gearshape.fill"
            )
          }

          Button {
            showingResetAlert = true
          } label: {
            Label(
              "Réinitialiser l'application",
              systemImage: "trash.fill"
            )
          }
          .foregroundColor(.red)
        } header: {
          Text("Configuration")
        }

        Section {
          Button {
            if let url = URL(string: "https://saracroche.org/fr/help") {
              UIApplication.shared.open(url)
            }
          } label: {
            Label("Aide & FAQ", systemImage: "questionmark.circle.fill")
          }

          Button {
            if let url = URL(string: "https://saracroche.org/fr/privacy") {
              UIApplication.shared.open(url)
            }
          } label: {
            Label("Confidentialité", systemImage: "lock.shield.fill")
          }

          Button {
            if let url = URL(string: "https://saracroche.org") {
              UIApplication.shared.open(url)
            }
          } label: {
            Label("Site officiel", systemImage: "safari.fill")
          }

          Button {
            if let url = URL(
              string:
                "https://apps.apple.com/app/id6743679292?action=write-review"
            ) {
              UIApplication.shared.open(url)
            }
          } label: {
            Label("Noter l'application", systemImage: "star.fill")
          }

          Button {
            if let url = URL(
              string: "https://github.com/cbouvat/saracroche-ios"
            ) {
              UIApplication.shared.open(url)
            }
          } label: {
            Label(
              "Code source",
              systemImage: "keyboard.fill"
            )
          }
        } header: {
          Text("Liens")
        }

        Section {
          Button {
            if let version = Bundle.main.infoDictionary?[
              "CFBundleShortVersionString"
            ] as? String {
              let deviceModel = UIDevice.current.modelIdentifier
              let systemVersion = UIDevice.current.systemVersion

              let deviceInfo = """
                Appareil : \(deviceModel)
                Version iOS : \(systemVersion)
                Version de l'application : \(version)
                """

              let body = """

                \(deviceInfo)
                """

              let encodedBody =
                body.addingPercentEncoding(
                  withAllowedCharacters: .urlQueryAllowed
                ) ?? ""
              let urlString =
                "mailto:mail@cbouvat.com?subject=Contact%20-%20Saracroche%20iOS&body="
                + encodedBody
              if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
              }
            }
          } label: {
            Label(
              "Signaler un bug ou suggérer une fonctionnalité par e-mail",
              systemImage: "envelope.fill"
            )
          }

          Button {
            if let url = URL(string: "https://mastodon.social/@cbouvat") {
              UIApplication.shared.open(url)
            }
          } label: {
            Label("Mastodon @cbouvat", systemImage: "person.bubble.fill")
          }
        } header: {
          Text("Contact")
        } footer: {
          Text(
            "Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
              + "\n\n\nBisou 😘"
          )
          .padding(.vertical)
          .frame(maxWidth: .infinity)
          .multilineTextAlignment(.center)
        }
      }
      .navigationTitle("Réglages")
      .confirmationDialog(
        "Réinitialiser l'application", isPresented: $showingResetAlert, titleVisibility: .visible
      ) {
        Button("Réinitialiser", role: .destructive) {
          blockerViewModel.resetApplication()
        }
        Button("Annuler", role: .cancel) {}
      } message: {
        Text(
          "Êtes-vous sûr de vouloir réinitialiser l'application ? Toutes les données seront supprimées et l'application se fermera. Cette action est irréversible."
        )
      }
    }
  }
}

#Preview {
  SettingsNavigationView(
    blockerViewModel: BlockerViewModel()
  )
}
