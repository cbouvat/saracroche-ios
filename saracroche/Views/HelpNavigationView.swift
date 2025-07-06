import SwiftUI

struct HelpNavigationView: View {
  @State private var showDonationSheet = false
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 16) {
          DisclosureGroup(
            content: {
              Text(
                [
                  "L'application bloque les préfixes suivants, communiqués par l'ARCEP : ",
                  "0162, 0163, 0270, 0271, 0377, 0378, 0424, 0425, 0568, 0569, 0948, 0949, ",
                  "ainsi que ceux allant de 09475 à 09479. Ces préfixes sont réservés au démarchage téléphonique. ",
                  "Elle bloque aussi des numéros de téléphone de certains opérateurs comme Manifone, DVS Connect, ",
                  "Ze Telecom, Oxilog, BJT Partners, Ubicentrex, Destiny, Kav El International, Spartel Services et d'autres.",
                ].joined()
              )
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)
            },
            label: {
              HStack(alignment: .center) {
                Image(systemName: "questionmark.circle.fill")
                  .foregroundStyle(.blue)
                Text("Quels numéros sont bloqués ?")
                  .multilineTextAlignment(.leading)
              }
              .font(.headline)
            }
          )
          .padding()
          .background(Color(.systemGray6))
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

          DisclosureGroup(
            content: {
              Text(
                [
                  "L'application utilise une extension de blocage d'appels et de SMS fournie par le système pour filtrer ",
                  "les numéros indésirables. Elle est conçue pour être simple et efficace, sans nécessiter de configuration complexe.",
                ].joined()
              )
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)
            },
            label: {
              HStack(alignment: .center) {
                Image(systemName: "info.circle.fill")
                  .foregroundStyle(.teal)
                Text("Comment fonctionne l'application ?")
                  .multilineTextAlignment(.leading)
              }
              .font(.headline)
            }
          )
          .padding()
          .background(Color(.systemGray6))
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

          DisclosureGroup(
            content: {
              Text(
                [
                  "Pour signaler un numéro indésirable, allez dans l'onglet 'Signaler' de l'application. ",
                  "Cela aide à améliorer la liste de blocage et à rendre l’application plus efficace.",
                ].joined()
              )
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)
            },
            label: {
              HStack(alignment: .center) {
                Image(systemName: "exclamationmark.shield.fill")
                  .foregroundStyle(.orange)
                Text("Comment signaler un numéro ?")
                  .multilineTextAlignment(.leading)
              }
              .font(.headline)
            }
          )
          .padding()
          .background(Color(.systemGray6))
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

          DisclosureGroup(
            content: {
              Text(
                [
                  "Depuis iOS 18, les numéros bloqués par les extensions de blocage d'appels sont visibles dans ",
                  "l'historique des appels. Cela permet de garder une trace des appels bloqués, mais ne signifie ",
                  "pas que l'appel a été reçu ou que vous devez y répondre.",
                ].joined()
              )
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)
            },
            label: {
              HStack(alignment: .center) {
                Image(systemName: "clock.fill")
                  .foregroundStyle(.purple)
                Text(
                  "Pourquoi les numéros bloqués apparaissent-ils dans l'historique des appels ?"
                )
                .multilineTextAlignment(.leading)
              }
              .font(.headline)
            }
          )
          .padding()
          .background(Color(.systemGray6))
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

          DisclosureGroup(
            content: {
              VStack(alignment: .leading, spacing: 0) {
                Text(
                  [
                    "L’application Saracroche est open source et développée bénévolement. Vous pouvez soutenir le projet, ",
                    "ce qui est précieux pour maintenir et améliorer l’application.",
                  ].joined()
                )
                .font(.body)
                .padding(.top, 4)
                .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                  showDonationSheet = true
                } label: {
                  HStack {
                    Image(systemName: "heart.fill")
                    Text("Faire un don")
                  }
                }
                .font(.body)
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)
              }
            },
            label: {
              HStack(alignment: .center) {
                Image(systemName: "gift.fill")
                  .foregroundStyle(.pink)
                Text("Comment faire un don ?")
                  .multilineTextAlignment(.leading)
              }
              .font(.headline)
            }
          )
          .padding()
          .background(Color(.systemGray6))
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

          DisclosureGroup(
            content: {
              Text(
                "En cas de bug ou de problème avec l'application, merci de le signaler sur GitHub ou par e-mail."
              )
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)

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
                    + version + " (" + build + ")\n" + "Appareil : "
                    + deviceModel + "\n" + "Version iOS : " + systemVersion
                  let encodedBody =
                    body.addingPercentEncoding(
                      withAllowedCharacters: .urlQueryAllowed
                    ) ?? ""
                  let urlString =
                    "mailto:saracroche@cbouvat.com?subject=Bug&body="
                    + encodedBody
                  if let url = URL(string: urlString) {
                    UIApplication.shared.open(url)
                  }
                }
              } label: {
                HStack {
                  Image(systemName: "envelope.fill")
                  Text("Signaler un bug")
                    .multilineTextAlignment(.leading)
                }
              }
              .font(.body)
              .padding(.top)
              .frame(maxWidth: .infinity, alignment: .leading)
            },
            label: {
              HStack(alignment: .center) {
                Image(systemName: "ladybug.fill")
                  .foregroundStyle(.red)
                Text("Comment signaler un bug ?")
                  .multilineTextAlignment(.leading)
              }
              .font(.headline)
            }
          )
          .padding()
          .background(Color(.systemGray6))
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

          DisclosureGroup(
            content: {
              VStack(alignment: .leading, spacing: 0) {
                Text(
                  [
                    "Si l'application Saracroche vous est utile, une évaluation sur l'App Store serait appréciée. ",
                    "Ce soutien aide à toucher davantage de personnes et à améliorer continuellement l'application.",
                  ].joined()
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
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)
              }
            },
            label: {
              HStack(alignment: .center) {
                Image(systemName: "star.fill")
                  .foregroundStyle(.yellow)
                Text("Comment noter l'application ?")
                  .multilineTextAlignment(.leading)
              }
              .font(.headline)
            }
          )
          .padding()
          .background(Color(.systemGray6))
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

          DisclosureGroup(
            content: {
              Text(
                [
                  "Elle est développée bénévolement par un développeur indépendant (Camille), ",
                  "qui en avait assez de recevoir des appels indésirables. L’application est développée sur ",
                  "son temps libre. Vous pouvez soutenir le projet en faisant un don.",
                ].joined()
              )
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)

              Button {
                  showDonationSheet = true
                } label: {
                  HStack {
                    Image(systemName: "heart.fill")
                    Text("Faire un don")
                  }
                }
                .font(.body)
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)
            },
            label: {
              HStack(alignment: .center) {
                Image(systemName: "dollarsign.circle.fill")
                  .foregroundStyle(.green)
                Text(
                  "Pourquoi l'application est-elle gratuite et sans publicité ?"
                )
                .multilineTextAlignment(.leading)
              }
              .font(.headline)
            }
          )
          .padding()
          .background(Color(.systemGray6))
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

          DisclosureGroup(
            content: {
              Text(
                "Saracroche ne collecte aucune donnée personnelle, n’utilise aucun service tiers et ne transmet aucune information à qui que ce soit. Toutes les données restent sur votre appareil. Le respect de la vie privée est un droit fondamental, même si on n’a rien à cacher."
              )
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)
            },
            label: {
              HStack(alignment: .center) {
                Image(systemName: "lock.shield.fill")
                  .foregroundStyle(.gray)
                Text("Respect de la vie privée")
                  .multilineTextAlignment(.leading)
              }
              .font(.headline)
            }
          )
          .padding()
          .background(Color(.systemGray6))
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

          Text("Bisou 😘")
            .font(.footnote)
            .multilineTextAlignment(.center)
            .padding(.top)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
      }
      .navigationTitle("Aide")
      .sheet(isPresented: $showDonationSheet) {
        DonationSheet()
      }
    }
  }
}
