import SwiftUI

struct HelpNavigationView: View {
  @State private var showDonationSheet = false

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          VStack(alignment: .leading, spacing: 16) {
            Text("Questions fréquentes")
              .font(.title2)
              .bold()
              .padding(.bottom, 4)

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
                      "Si vous apprécier l'application et souhaitez soutenir son développement, vous pouvez faire un don. ",
                      "Cela permet de financer le temps de développment et d'amélioration de l'application. ",
                      "Vous pouvez également partager l'application avec vos amis et votre famille pour aider à la faire connaître.",
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
                  Text("Comment soutenir le projet ?")
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
                  Text("Respect de la vie privée ?")
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
                  [
                    "Sarah est une ourse qui a été sauvée par Camille, le développeur de l'application. ",
                    "C'est elle qui raccroche en disant : « Tu connais Sarah ? », l'autre répond : « Sarah qui ? », ",
                    "et elle répond : « Sarah Croche ! » à chaque appel indésirable qu'elle reçoit. Merci à Sarah.",
                  ].joined()
                )
                .font(.body)
                .padding(.top, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
              },
              label: {
                HStack(alignment: .center) {
                  Image(systemName: "teddybear.fill")
                    .foregroundStyle(.brown)
                  Text("Pourquoi une patte d'ours ?")
                    .multilineTextAlignment(.leading)
                }
                .font(.headline)
              }
            )
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

          }

          VStack(alignment: .leading, spacing: 16) {
            Text("Support")
              .font(.title2)
              .bold()
              .padding(.bottom, 4)

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
          }

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
