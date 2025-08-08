import SwiftUI

struct HelpSupportSection: View {
  var body: some View {
    Section {
      DisclosureGroup(
        content: {
          VStack(alignment: .leading, spacing: 16) {
            Text(
              "En cas de bug ou de problème avec l'application, merci de le signaler sur GitHub ou par e-mail."
            )

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
                  Bonjour,

                  J'ai rencontré un problème avec l'application et voici une capture d'écran :

                  \(deviceInfo)

                  Bisou 😘
                  """

                let encodedBody =
                body.addingPercentEncoding(
                  withAllowedCharacters: .urlQueryAllowed
                ) ?? ""
                let urlString =
                "mailto:saracroche@cbouvat.com?subject=Bug%20-%20Saracroche%20iOS&body="
                + encodedBody
                if let url = URL(string: urlString) {
                  UIApplication.shared.open(url)
                }
              }
            }
            label: {
              HStack {
                Image(systemName: "envelope.fill")
                Text("Signaler un bug")
              }
            }
            .buttonStyle(.fullWidth(background: .red, foreground: .white))
          }
        },
        label: {
          Image(systemName: "ladybug.fill")
            .foregroundColor(.red)
            .frame(width: 12)
          Text("Comment signaler un bug ?")
            .multilineTextAlignment(.leading)
        }
      )

      DisclosureGroup(
        content: {
          VStack(alignment: .leading, spacing: 16) {
            Text(
              [
                "Si l'application Saracroche vous est utile, une évaluation sur l'App Store serait appréciée. ",
                "Ce soutien aide à toucher davantage de personnes et à améliorer continuellement l'application.",
              ].joined()
            )

            Button {
              if let url = URL(
                string:
                  "https://apps.apple.com/app/id6743679292?action=write-review"
              ) {
                UIApplication.shared.open(url)
              }
            } label: {
              HStack {
                Image(systemName: "star.fill")
                Text("Noter l'application")
              }
            }
            .buttonStyle(.fullWidth(background: .yellow, foreground: .black))
          }
        },
        label: {
          Image(systemName: "star.fill")
            .foregroundColor(.yellow)
            .frame(width: 12)
          Text("Comment noter l'application ?")
            .multilineTextAlignment(.leading)
        }
      )
    } header: {
      Text("Support")
    }
  }
}
