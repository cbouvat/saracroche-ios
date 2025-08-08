import SwiftUI

struct HelpNavigationView: View {
  @State private var showDonationSheet = false

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 16) {
          VStack(alignment: .leading, spacing: 12) {
            Text("Questions fréquentes")
              .font(.title2)
              .bold()
            Divider()

            DisclosureGroup(
              content: {
                Text(
                  [
                    "L'application bloque les préfixes suivants, communiqués par l'ARCEP : ",
                    "0162, 0163, 0270, 0271, 0377, 0378, 0424, 0425, 0568, 0569, 0948, 0949, ",
                    "ainsi que ceux allant de 09475 à 09479. Ces préfixes sont réservés au démarchage téléphonique. ",
                    "Elle bloque aussi des numéros de téléphone de certains opérateurs comme Manifone, DVS Connect, ",
                    "Ze Telecom, Oxilog, BJT Partners, Ubicentrex, Destiny, Kav El International, ",
                    "Spartel Services et Comunik CRM."
                  ].joined()
                )
                .font(.body)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)
              },
              label: {
                HStack(alignment: .center) {
                  Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(.blue)
                  Text("Quels numéros sont bloqués ?")
                    .multilineTextAlignment(.leading)
                }
                .font(.body.weight(.bold))
              }
            )

            DisclosureGroup(
              content: {
                Text(
                  [
                    "L'application utilise une extension de blocage d'appels et de SMS fournie par le système ",
                    "pour filtrer les numéros indésirables. Elle est conçue pour être simple et efficace, ",
                    "sans nécessiter de configuration complexe."
                  ].joined()
                )
                .font(.body)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)
              },
              label: {
                HStack(alignment: .center) {
                  Image(systemName: "info.circle.fill")
                    .foregroundColor(.cyan)
                  Text("Comment fonctionne l'application ?")
                    .multilineTextAlignment(.leading)
                }
                .font(.body.weight(.bold))
              }
            )

            DisclosureGroup(
              content: {
                Text(
                  [
                    "Pour signaler un numéro indésirable, allez dans l'onglet 'Signaler' de l'application. ",
                    "Cela aide à améliorer la liste de blocage et à rendre l’application plus efficace."
                  ].joined()
                )
                .font(.body)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)
              },
              label: {
                HStack(alignment: .center) {
                  Image(systemName: "exclamationmark.shield.fill")
                    .foregroundColor(.orange)
                  Text("Comment signaler un numéro ?")
                    .multilineTextAlignment(.leading)
                }
                .font(.body.weight(.bold))
              }
            )

            DisclosureGroup(
              content: {
                Text(
                  [
                    "Depuis iOS 18, les numéros bloqués par les extensions de blocage d'appels sont visibles dans ",
                    "l'historique des appels. Cela permet de garder une trace des appels bloqués, mais ne signifie ",
                    "pas que l'appel a été reçu ou que vous devez y répondre."
                  ].joined()
                )
                .font(.body)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)
              },
              label: {
                HStack(alignment: .center) {
                  Image(systemName: "clock.fill")
                    .foregroundColor(.purple)
                  Text("Pourquoi les numéros bloqués apparaissent-ils dans l'historique des appels ?")
                    .multilineTextAlignment(.leading)
                }
                .font(.body.weight(.bold))
              }
            )

            DisclosureGroup(
              content: {
                VStack(alignment: .leading, spacing: 0) {
                  Text(
                    [
                      "Si vous apprécier l'application et souhaitez soutenir son développement, ",
                      "vous pouvez faire un don. ",
                      "Cela permet de financer le temps de développment et d'amélioration de l'application. ",
                      "Vous pouvez également partager l'application avec vos amis et votre famille ",
                      "pour aider à la faire connaître."
                    ].joined()
                  )
                  .font(.body)
                  .padding(.vertical)
                  .frame(maxWidth: .infinity, alignment: .leading)

                  Button {
                    showDonationSheet = true
                  } label: {
                    HStack {
                      Image(systemName: "heart.fill")
                      Text("Faire un don")
                    }
                  }
                  .buttonStyle(.fullWidth(background: .pink, foreground: .white))
                  .padding(.bottom)
                }
              },
              label: {
                HStack(alignment: .center) {
                  Image(systemName: "gift.fill")
                    .foregroundColor(.pink)
                  Text("Comment soutenir le projet ?")
                    .multilineTextAlignment(.leading)
                }
                .font(.body.weight(.bold))
              }
            )

            DisclosureGroup(
              content: {
                Text(
                  [
                    "Saracroche ne collecte aucune donnée personnelle, n’utilise aucun service tiers et ne transmet ",
                    "aucune information à qui que ce soit. Toutes les données restent sur votre appareil. ",
                    "Le respect de la vie privée est un droit fondamental, même si on n’a rien à cacher."
                  ].joined()
                )
                .font(.body)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)
              },
              label: {
                HStack(alignment: .center) {
                  Image(systemName: "lock.shield.fill")
                    .foregroundColor(.green)
                  Text("Respect de la vie privée ?")
                    .multilineTextAlignment(.leading)
                }
                .font(.body.weight(.bold))
              }
            )

            DisclosureGroup(
              content: {
                Text(
                  [
                    "Elle est développée bénévolement par un développeur indépendant (Camille), ",
                    "qui en avait assez de recevoir des appels indésirables. L’application est développée sur ",
                    "son temps libre. Vous pouvez soutenir le projet en faisant un don."
                  ].joined()
                )
                .font(.body)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                  showDonationSheet = true
                } label: {
                  HStack {
                    Image(systemName: "heart.fill")
                    Text("Faire un don")
                  }
                }
                .buttonStyle(.fullWidth(background: .red, foreground: .white))
                .padding(.bottom)
              },
              label: {
                HStack(alignment: .center) {
                  Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.mint)
                  Text("Pourquoi l'application est-elle gratuite et sans publicité ?")
                    .multilineTextAlignment(.leading)
                }
                .font(.body.weight(.bold))
              }
            )

            DisclosureGroup(
              content: {
                Text(
                  [
                    "Sarah est une ourse qui a été sauvée par Camille, le développeur de l'application. ",
                    "C'est elle qui raccroche en disant : « Tu connais Sarah ? », l'autre répond : « Sarah qui ? », ",
                    "et elle répond : « Sarah Croche ! » à chaque appel indésirable qu'elle reçoit. Merci à Sarah."
                  ].joined()
                )
                .font(.body)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)
              },
              label: {
                HStack(alignment: .center) {
                  Image(systemName: "teddybear.fill")
                    .foregroundColor(.brown)
                  Text("Pourquoi une patte d'ours ?")
                    .multilineTextAlignment(.leading)
                }
                .font(.body.weight(.bold))
              }
            )

            DisclosureGroup(
              content: {
                Text(
                  [
                    "Le service 33700 est un service gratuit mis en place par les opérateurs de téléphonie mobile ",
                    "pour signaler les appels et SMS indésirables. Il permet aux utilisateurs de signaler les numéros ",
                    "directement auprès de leur opérateur, qui peut ensuite prendre des mesures pour bloquer ces ",
                    "numéros"
                  ].joined()
                )
                .font(.body)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                  if let url = URL(
                    string: "https://www.33700.fr/"
                  ) {
                    UIApplication.shared.open(url)
                  }
                } label: {
                  HStack {
                    Image(systemName: "flag.fill")
                    Text("Accéder au service 33700")
                  }
                }
                .buttonStyle(.fullWidth(background: .orange, foreground: .white))
                .padding(.bottom)
              },
              label: {
                HStack(alignment: .center) {
                  Image(systemName: "flag.fill")
                    .foregroundColor(.orange)
                  Text("C'est quoi le service 33700 ?")
                    .multilineTextAlignment(.leading)
                }
                .font(.body.weight(.bold))
              }
            )

            DisclosureGroup(
              content: {
                Text(
                  [
                    "Pour connaître l'opérateur d'un numéro, vous pouvez utiliser le service gratuit de l'ARCEP. ",
                    "Le service est accessible via le lien ci-dessous. Il vous suffit de saisir le numéro de ",
                    "téléphone pour obtenir des informations sur l'opérateur."
                  ].joined()
                )
                .font(.body)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                  if let url = URL(
                    string:
                      "https://www.arcep.fr/mes-demarches-et-services/entreprises/fiches-pratiques/"
                      + "base-numerotation.html"
                  ) {
                    UIApplication.shared.open(url)
                  }
                } label: {
                  HStack {
                    Image(systemName: "person.fill.questionmark")
                    Text("Connaitre l'opérateur")
                  }
                }
                .buttonStyle(.fullWidth(background: .blue, foreground: .white))
                .padding(.bottom)
              },
              label: {
                HStack(alignment: .center) {
                  Image(systemName: "person.fill.questionmark")
                    .foregroundColor(.blue)
                  Text("Comment connaitre l'opérateur d'un numéro ?")
                    .multilineTextAlignment(.leading)
                }
                .font(.body.weight(.bold))
              }
            )
          }

          VStack(alignment: .leading, spacing: 12) {
            Text("Support")
              .font(.title2)
              .bold()

            Divider()
            DisclosureGroup(
              content: {
                Text(
                  "En cas de bug ou de problème avec l'application, merci de le signaler sur GitHub ou par e-mail."
                )
                .font(.body)
                .padding(.vertical)
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
                  }
                }
                .buttonStyle(.fullWidth(background: .red, foreground: .white))
                .padding(.bottom)
              },
              label: {
                HStack(alignment: .center) {
                  Image(systemName: "ladybug.fill")
                    .foregroundColor(.red)
                  Text("Comment signaler un bug ?")
                    .multilineTextAlignment(.leading)
                }
                .font(.body.weight(.bold))
              }
            )

            DisclosureGroup(
              content: {
                VStack(alignment: .leading, spacing: 0) {
                  Text(
                    [
                      "Si l'application Saracroche vous est utile, une évaluation sur l'App Store serait appréciée. ",
                      "Ce soutien aide à toucher davantage de personnes et à améliorer continuellement l'application."
                    ].joined()
                  )
                  .font(.body)
                  .padding(.vertical)
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
                  .buttonStyle(.fullWidth(background: .yellow, foreground: .black))
                  .padding(.bottom)
                }
              },
              label: {
                HStack(alignment: .center) {
                  Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                  Text("Comment noter l'application ?")
                    .multilineTextAlignment(.leading)
                }
                .font(.body.weight(.bold))
              }
            )
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
