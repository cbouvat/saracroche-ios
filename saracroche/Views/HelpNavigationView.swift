import SwiftUI

struct HelpNavigationView: View {
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack {
          GroupBox(
            label:
              Label {
                Text("Quels numéros sont bloqués ?")
              } icon: {
                Image(systemName: "questionmark.circle.fill")
                  .foregroundStyle(.blue)
              }
          ) {
            Text(
              "L'application bloque les préfixes suivants, communiqués par l'ARCEP : " +
              "0162, 0163, 0270, 0271, 0377, 0378, 0424, 0425, 0568, 0569, 0948, 0949, " +
              "ainsi que ceux allant de 09475 à 09479. Ces préfixes sont réservés au démarchage téléphonique. " +
              "Elle bloque aussi des numéros de téléphone de certains opérateurs comme Manifone, DVS Connect et bientôt d’autres."
            )
            .font(.body)
            .padding(.top, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
          }

          GroupBox(
            label:
              Label {
                Text("Comment fonctionne l'application ?")
              } icon: {
                Image(systemName: "info.circle.fill")
                  .foregroundStyle(.teal)
              }
          ) {
            Text(
              "L'application utilise une extension de blocage d'appels et de SMS fournie par le système pour filtrer les numéros indésirables. Elle est conçue pour être simple et efficace, sans nécessiter de configuration complexe."
            )
            .font(.body)
            .padding(.top, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
          }

          GroupBox(
            label:
              Label {
                Text("Comment signaler un numéro ?")
              } icon: {
                Image(systemName: "exclamationmark.shield.fill")
                  .foregroundStyle(.orange)
              }
          ) {
            Text(
              "Pour signaler un numéro indésirable, utilisez le bouton 'Signaler' dans l'onglet 'Signaler'. Cela aide à améliorer la liste de blocage et à rendre l’application plus efficace."
            )
            .font(.body)
            .padding(.top, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
          }

          GroupBox(
            label:
              Label {
                Text(
                  "Pourquoi les numéros bloqués apparaissent-ils dans l'historique des appels ?"
                )
              } icon: {
                Image(systemName: "clock.fill")
                  .foregroundStyle(.purple)
              }
          ) {
            Text(
              "Depuis iOS 18, les numéros bloqués par les extensions de blocage d'appels sont visibles dans l'historique des appels. Cela permet de garder une trace des appels bloqués, mais ne signifie pas que l'appel a été reçu ou que vous devez y répondre."
            )
            .font(.body)
            .padding(.top, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
          }

          GroupBox(
            label:
              Label {
                Text("Comment participer au projet ?")
              } icon: {
                Image(systemName: "gift.fill")
                  .foregroundStyle(.pink)
              }
          ) {
            Text(
              "L’application Saracroche est open source et développée bénévolement. Vous pouvez soutenir le projet, ce qui est précieux pour maintenir et améliorer l’application."
            )
            .font(.body)
            .padding(.top, 4)
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
              if let url = URL(string: "https://github.com/sponsors/cbouvat") {
                UIApplication.shared.open(url)
              }
            } label: {
              HStack {
                Image(systemName: "heart.fill")
                Text("Soutenir le projet sur GitHub")
              }
            }
            .font(.body)
            .padding(.top, 4)
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
              if let url = URL(string: "https://liberapay.com/cbouvat") {
                UIApplication.shared.open(url)
              }
            } label: {
              HStack {
                Image(systemName: "heart.fill")
                Text("Soutenir le projet sur Liberapay")
              }
            }
            .font(.body)
            .padding(.top, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
          }

          GroupBox(
            label:
              Label {
                Text("Comment noter l'application ?")
              } icon: {
                Image(systemName: "star.fill")
                  .foregroundStyle(.yellow)
              }
          ) {
            Text(
              "Si l'application Saracroche vous est utile, une évaluation sur l'App Store serait appréciée. Ce soutien aide à toucher davantage de personnes et à améliorer continuellement l'application."
            )
            .font(.body)
            .padding(.top, 4)
            .frame(maxWidth: .infinity, alignment: .leading)

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
            .font(.body)
            .padding(.top, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
          }

          GroupBox(
            label:
              Label {
                Text("Comment signaler un bug ?")
              } icon: {
                Image(systemName: "ladybug.fill")
                  .foregroundStyle(.red)
              }
          ) {
            Text(
              "En cas de bug ou de problème avec l'application, merci de le signaler sur GitHub ou par e-mail."
            )
            .font(.body)
            .padding(.top, 4)
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
              if let url = URL(
                string: "https://github.com/cbouvat/saracroche/issues"
              ) {
                UIApplication.shared.open(url)
              }
            } label: {
              HStack {
                Image(systemName: "chevron.left.slash.chevron.right")
                Text("Signaler un bug sur GitHub")
              }
            }
            .font(.body)
            .padding(.top, 4)
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
              if let url = URL(
                string: "mailto:saracroche@cbouvat.com?subject=Signalement bug"
              ) {
                UIApplication.shared.open(url)
              }
            } label: {
              HStack {
                Image(systemName: "envelope.fill")
                Text("Envoyer un email")
              }
            }
            .font(.body)
            .padding(.top, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
          }

          GroupBox(
            label:
              Label {
                Text("Pourquoi l'application est-elle gratuite ?")
              } icon: {
                Image(systemName: "dollarsign.circle.fill")
                  .foregroundStyle(.green)
              }
          ) {
            Text(
              "L’application Saracroche est gratuite et sans publicité. Elle est développée bénévolement par un développeur indépendant (Camille), qui en avait assez de recevoir des appels indésirables. L’application est développée sur son temps libre. Vous pouvez soutenir le projet en faisant un don sur GitHub ou Liberapay."
            )
            .font(.body)
            .padding(.top, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
          }

          GroupBox(
            label:
              Label {
                Text("Respect de la vie privée")
              } icon: {
                Image(systemName: "lock.shield.fill")
                  .foregroundStyle(.gray)
              }
          ) {
            Text(
              "Saracroche ne collecte aucune donnée personnelle, n’utilise aucun service tiers et ne transmet aucune information à qui que ce soit. Toutes les données restent sur votre appareil. Le respect de la vie privée est un droit fondamental, même si on n’a rien à cacher."
            )
            .font(.body)
            .padding(.top, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
          }
          .padding(.bottom)

          Text(
            "Bisous 😘"
          )
          .font(.footnote)
          .padding(.top)
          .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
      }
      .navigationTitle("Aide")
    }
  }
}
