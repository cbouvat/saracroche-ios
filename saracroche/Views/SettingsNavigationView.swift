import SwiftUI

struct SettingsNavigationView: View {
  @ObservedObject var viewModel: BlockerViewModel
  @Binding var showDeleteConfirmation: Bool
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Configuration système")) {
          Button {
            viewModel.openSettings()
          } label: {
            Label(
              "L’extension de blocage dans Réglages de l'iPhone",
              systemImage: "gearshape.fill"
            )
          }
          
          Button(role: .destructive) {
            showDeleteConfirmation = true
          } label: {
            Label(
              "Supprimer la liste de blocage",
              systemImage: "trash.fill"
            )
            .foregroundColor(.red)
          }
          .confirmationDialog(
            "Supprimer la liste de blocage",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
          ) {
            Button("Supprimer", role: .destructive) {
              viewModel.removeBlockerList()
            }
          } message: {
            Text("Êtes-vous sûr de vouloir supprimer la liste de blocage ?")
          }
        }

        Section(header: Text("Liens utiles")) {
          Button {
            if let url = URL(string: "https://github.com/cbouvat/saracroche") {
              UIApplication.shared.open(url)
            }
          } label: {
            Label(
              "Code source",
              systemImage: "keyboard.fill"
            )
          }

          Button {
            if let url = URL(string: "https://cbouvat.com/saracroche") {
              UIApplication.shared.open(url)
            }
          } label: {
            Label("Site officiel", systemImage: "safari.fill")
          }

          Button {
            if let url = URL(string: "https://mastodon.social/@cbouvat") {
              UIApplication.shared.open(url)
            }
          } label: {
            Label("Mastodon : @cbouvat", systemImage: "person.bubble.fill")
          }
        }

        Section(header: Text("Application")) {
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
            if let version = Bundle.main.infoDictionary?[
              "CFBundleShortVersionString"
            ] as? String,
              let build = Bundle.main.infoDictionary?["CFBundleVersion"]
                as? String
            {
              let deviceModel = UIDevice.current.modelIdentifier
              let systemVersion = UIDevice.current.systemVersion

              let body =
                "\n\n" + "-----------\n" + "Version de l'application : "
                + version + " (" + build + ")\n" + "Appareil : " + deviceModel
                + "\n" + "Version iOS : " + systemVersion
              let encodedBody =
                body.addingPercentEncoding(
                  withAllowedCharacters: .urlQueryAllowed
                ) ?? ""
              let urlString =
                "mailto:saracroche@cbouvat.com?subject=Contact&body="
                + encodedBody
              if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
              }
            }
          } label: {
            Label(
              "Signaler un bug ou suggérer une amélioration",
              systemImage: "exclamationmark.bubble.fill"
            )
          }
        }
        
        HStack {
          Spacer()
          Text(
            "Version de l'application : \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
          )
          .font(.footnote)
          Spacer()
        }
      }
      .navigationTitle("Réglages")
    }
  }
}
