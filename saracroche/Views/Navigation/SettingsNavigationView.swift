import SwiftUI

struct SettingsNavigationView: View {
  @ObservedObject var blockerViewModel: BlockerViewModel
  @State private var showingBusinessCodeSheet = false
  @State private var showingReinstallSheet = false
  @State private var showingResetSheet = false
  @State private var bisouTapCount = 0
  @State private var showingDebugSheet = false

  var body: some View {
    NavigationView {
      Form {
        Section {
          Button {
            Task {
              await blockerViewModel.openSettings()
            }
          } label: {
            Label(
              "Activer ou désactiver Saracroche dans **Réglages**",
              systemImage: "gearshape.fill"
            )
          }

          Button {
            showingBusinessCodeSheet = true
          } label: {
            Label("Code entreprise", systemImage: "building.2.fill")
          }

          Button {
            showingReinstallSheet = true
          } label: {
            Label(
              "Réinstaller la liste de blocage",
              systemImage: "arrow.clockwise.circle.fill"
            )
          }

          Button {
            showingResetSheet = true
          } label: {
            Label(
              "Réinitialiser l'application",
              systemImage: "trash.fill"
            )
          }
          .foregroundColor(.red)
        } header: {
          Text("Configuration")
            .appFont(.subheadlineSemiBold)
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
            .appFont(.subheadlineSemiBold)
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
            .appFont(.subheadlineSemiBold)
        } footer: {
          Button {
            bisouTapCount += 1
            if bisouTapCount >= 3 {
              showingDebugSheet = true
              bisouTapCount = 0
            }
          } label: {
            VStack(spacing: 8) {
              Text(
                "Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
              )
              .padding(.vertical, 4)
              .frame(maxWidth: .infinity)
              .multilineTextAlignment(.center)

              Text("Bisou 😘")
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            }
          }
          .buttonStyle(.plain)
          .padding(.vertical, 8)
        }
      }
      .appFont(.body)
      .tint(.primary)
      .navigationTitle("Réglages")
      .sheet(isPresented: $showingBusinessCodeSheet) {
        BusinessCodeSheet()
      }
      .sheet(isPresented: $showingReinstallSheet) {
        ReinstallSheet(blockerViewModel: blockerViewModel)
      }
      .sheet(isPresented: $showingResetSheet) {
        ResetSheet(blockerViewModel: blockerViewModel)
      }
      .sheet(isPresented: $showingDebugSheet) {
        DebugSheet()
      }
    }
  }
}

#Preview {
  SettingsNavigationView(
    blockerViewModel: BlockerViewModel()
  )
}
