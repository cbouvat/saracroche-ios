import SwiftUI

struct SettingsNavigationView: View {
  @ObservedObject var viewModel: SaracrocheViewModel
  @Binding var showDeleteConfirmation: Bool
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Extension de blocage")) {
          Button {
            viewModel.openSettings()
          } label: {
            Label(
              "L’extension de blocage dans Réglages",
              systemImage: "gear"
            )
          }
        }

        Section(header: Text("Liste de blocage")) {
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
              "Code source sur GitHub",
              systemImage: "chevron.left.slash.chevron.right"
            )
          }
          Button {
            if let url = URL(string: "https://cbouvat.com/saracroche") {
              UIApplication.shared.open(url)
            }
          } label: {
            Label("Site officiel", systemImage: "safari")
          }
          Button {
            if let url = URL(string: "https://mastodon.social/@cbouvat") {
              UIApplication.shared.open(url)
            }
          } label: {
            Label("Mastodon : @cbouvat", systemImage: "at")
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
        }
      }
      .navigationTitle("Réglages")
    }
  }
}
