import SwiftUI

struct HelpNavigationView: View {
  @State private var showDonationSheet = false

  var body: some View {
    NavigationView {
      List {
        Section {
          HelpFAQNumbersBlockedItem()
          HelpFAQHowWorksItem()
          HelpFAQContactsNotBlockedItem()
          HelpFAQReportNumberItem()
          HelpFAQCallHistoryItem()
          HelpFAQSupportProjectItem(showDonationSheet: $showDonationSheet)
          HelpFAQPrivacyItem()
          HelpFAQWhyFreeItem(showDonationSheet: $showDonationSheet)
          HelpFAQBearPawItem()
          HelpFAQ33700Item()
          HelpFAQOperatorLookupItem()
          HelpFAQTroubleshootingItem()
        } header: {
          Text("Questions fréquentes")
        }

        Section {
          SupportItem()
        } header: {
          Text("Support")
        }

        Section(
          footer:
            Text("Bisou 😘")
            .font(.footnote)
            .frame(maxWidth: .infinity, alignment: .center)
        ) { EmptyView() }
      }
      .listStyle(.insetGrouped)
      .navigationTitle("Aide")
      .sheet(isPresented: $showDonationSheet) {
        DonationSheet()
      }
    }
  }
}

private struct HelpFAQNumbersBlockedItem: View {
  var body: some View {
    DisclosureGroup(
      content: {
        Text(
          [
            "L'application bloque les préfixes suivants, communiqués par l'ARCEP : ",
            "0162, 0163, 0270, 0271, 0377, 0378, 0424, 0425, 0568, 0569, 0948, 0949, ",
            "ainsi que ceux allant de 09475 à 09479. Ces préfixes sont réservés au démarchage téléphonique. ",
            "Elle bloque aussi des numéros de téléphone de certains opérateurs comme Manifone, DVS Connect, ",
            "Ze Telecom, Oxilog, BJT Partners, Ubicentrex, Destiny, Kav El International, ",
            "Spartel Services et Comunik CRM.",
          ].joined()
        )
      },
      label: {
        Image(systemName: "questionmark.circle.fill")
          .foregroundColor(.accent)
          .frame(width: 12)
        Text("Quels numéros sont bloqués ?")
          .multilineTextAlignment(.leading)
      }
    )
  }
}

private struct HelpFAQHowWorksItem: View {
  var body: some View {
    DisclosureGroup(
      content: {
        Text(
          [
            "L'application utilise une extension de blocage d'appels et de SMS fournie par le système ",
            "pour filtrer les numéros indésirables. Elle est conçue pour être simple et efficace, ",
            "sans nécessiter de configuration complexe.",
          ].joined()
        )
      },
      label: {
        Image(systemName: "info.circle.fill")
          .foregroundColor(.accent)
          .frame(width: 12)
        Text("Comment fonctionne l'application ?")
          .multilineTextAlignment(.leading)
      }
    )
  }
}

private struct HelpFAQContactsNotBlockedItem: View {
  var body: some View {
    DisclosureGroup(
      content: {
        Text(
          [
            "Les numéros de téléphone enregistrés dans vos contacts ne seront jamais bloqués ",
            "par l'application. iOS donne automatiquement la priorité aux contacts enregistrés ",
            "et les exclut du système de filtrage. Si vous voulez qu'un numéro ne soit plus ",
            "bloqué, ajoutez-le simplement à vos contacts.",
          ].joined()
        )
      },
      label: {
        Image(systemName: "person.fill.checkmark")
          .foregroundColor(.accent)
          .frame(width: 12)
        Text("Comment exclure un numéro ?")
          .multilineTextAlignment(.leading)
      }
    )
  }
}

private struct HelpFAQTroubleshootingItem: View {
  var body: some View {
    DisclosureGroup(
      content: {
        VStack(alignment: .leading, spacing: 12) {
          Text(
            "Vérifiez que l'extension de blocage d'appels est activée dans les réglages et attendez quelques minutes avant de réessayer."
          )

          Text("Si le problème persiste :")
            .font(.headline)
            .fontWeight(.semibold)

          VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
              Text("1")
                .fontWeight(.bold)
              Text("Désactivez Saracroche dans les réglages, si elle apparaît.")
                .multilineTextAlignment(.leading)
            }

            HStack(alignment: .top, spacing: 10) {
              Text("2")
                .fontWeight(.bold)
              Text("Désinstallez l'application Saracroche.")
                .multilineTextAlignment(.leading)
            }

            HStack(alignment: .top, spacing: 10) {
              Text("3")
                .fontWeight(.bold)
              Text("Redémarrez votre appareil.")
                .multilineTextAlignment(.leading)
            }

            HStack(alignment: .top, spacing: 10) {
              Text("4")
                .fontWeight(.bold)
              Text("Réinstallez l'application Saracroche depuis l'App Store.")
                .multilineTextAlignment(.leading)
            }
          }

          Text(
            "Si malgré tout le problème perdure, signalez-le."
          )
        }
      },
      label: {
        Image(systemName: "exclamationmark.triangle.fill")
          .foregroundColor(.red)
          .frame(width: 12)
        Text("L'application rencontre un problème ?")
          .multilineTextAlignment(.leading)
      }
    )
  }
}

private struct HelpFAQReportNumberItem: View {
  var body: some View {
    DisclosureGroup(
      content: {
        Text(
          [
            "Pour signaler un numéro indésirable, allez dans l'onglet 'Signaler' de l'application. ",
            "Cela aide à améliorer la liste de blocage et à rendre l’application plus efficace.",
          ].joined()
        )
      },
      label: {
        Image(systemName: "exclamationmark.shield.fill")
          .foregroundColor(.accent)
          .frame(width: 12)
        Text("Comment signaler un numéro ?")
          .multilineTextAlignment(.leading)
      }
    )
  }
}

private struct HelpFAQCallHistoryItem: View {
  var body: some View {
    DisclosureGroup(
      content: {
        Text(
          [
            "Depuis iOS 18, les numéros bloqués par les extensions de blocage d'appels sont visibles dans ",
            "l'historique des appels. Cela permet de garder une trace des appels bloqués, mais ne signifie ",
            "pas que l'appel a été reçu ou que vous devez y répondre.",
          ].joined()
        )
      },
      label: {
        Image(systemName: "clock.fill")
          .foregroundColor(.accent)
          .frame(width: 12)
        Text(
          "Pourquoi les numéros bloqués apparaissent-ils dans l'historique des appels ?"
        )
        .multilineTextAlignment(.leading)
      }
    )
  }
}

private struct HelpFAQSupportProjectItem: View {
  @Binding var showDonationSheet: Bool
  var body: some View {
    DisclosureGroup(
      content: {
        VStack(alignment: .leading, spacing: 16) {
          Text(
            [
              "Si vous apprécier l'application et souhaitez soutenir son développement, ",
              "vous pouvez faire un don et noter l'application. ",
              "Cela permet de financer le temps de développment et d'amélioration de l'application. ",
              "Vous pouvez également partager l'application avec vos amis et votre famille ",
              "pour aider à la faire connaître.",
            ].joined()
          )

          Button {
            showDonationSheet = true
          } label: {
            HStack {
              Image(systemName: "heart.fill")
              Text("Soutenez Saracroche")
            }
          }
          .buttonStyle(.fullWidth(background: .pink, foreground: .white))
        }
      },
      label: {
        Image(systemName: "gift.fill")
          .foregroundColor(.accent)
          .frame(width: 12)
        Text("Comment soutenir le projet ?")
          .multilineTextAlignment(.leading)
      }
    )
  }
}

private struct HelpFAQPrivacyItem: View {
  var body: some View {
    DisclosureGroup(
      content: {
        Text(
          [
            "Saracroche ne collecte aucune donnée personnelle, n’utilise aucun service tiers et ne transmet ",
            "aucune information à qui que ce soit. Toutes les données restent sur votre appareil. ",
            "Le respect de la vie privée est un droit fondamental, même si on n’a rien à cacher.",
          ].joined()
        )
      },
      label: {
        Image(systemName: "lock.shield.fill")
          .foregroundColor(.accent)
          .frame(width: 12)
        Text("Respect de la vie privée ?")
          .multilineTextAlignment(.leading)
      }
    )
  }
}

private struct HelpFAQWhyFreeItem: View {
  @Binding var showDonationSheet: Bool
  var body: some View {
    DisclosureGroup(
      content: {
        VStack(alignment: .leading, spacing: 16) {
          Text(
            [
              "Elle est développée bénévolement par un développeur indépendant (Camille), ",
              "qui en avait assez de recevoir des appels indésirables. L’application est développée sur ",
              "son temps libre. Vous pouvez soutenir le projet en faisant un don et noter l'application",
            ].joined()
          )

          Button {
            showDonationSheet = true
          } label: {
            HStack {
              Image(systemName: "heart.fill")
              Text("Soutenez Saracroche")
            }
          }
          .buttonStyle(.fullWidth(background: .red, foreground: .white))
        }
      },
      label: {
        Image(systemName: "dollarsign.circle.fill")
          .foregroundColor(.accent)
          .frame(width: 12)
        Text("Pourquoi l'application est-elle gratuite et sans publicité ?")
          .multilineTextAlignment(.leading)
      }
    )
  }
}

private struct HelpFAQBearPawItem: View {
  var body: some View {
    DisclosureGroup(
      content: {
        Text(
          [
            "Sarah est une ourse qui a été sauvée par Camille, le développeur de l'application. ",
            "C'est elle qui raccroche en disant : « Tu connais Sarah ? », l'autre répond : « Sarah qui ? », ",
            "et elle répond : « Sarah Croche ! » à chaque appel indésirable qu'elle reçoit. Merci à Sarah.",
          ].joined()
        )
      },
      label: {
        Image(systemName: "teddybear.fill")
          .foregroundColor(.accent)
          .frame(width: 12)
        Text("Pourquoi une patte d'ours ?")
          .multilineTextAlignment(.leading)
      }
    )
  }
}

private struct HelpFAQ33700Item: View {
  var body: some View {
    DisclosureGroup(
      content: {
        VStack(alignment: .leading, spacing: 16) {
          Text(
            [
              "Le service 33700 est un service gratuit mis en place par les opérateurs de téléphonie mobile ",
              "pour signaler les appels et SMS indésirables. Il permet aux utilisateurs de signaler les numéros ",
              "directement auprès de leur opérateur, qui peut ensuite prendre des mesures pour bloquer ces ",
              "numéros",
            ].joined()
          )

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
        }
      },
      label: {
        Image(systemName: "flag.fill")
          .foregroundColor(.accent)
          .frame(width: 12)
        Text("C'est quoi le service 33700 ?")
          .multilineTextAlignment(.leading)
      }
    )
  }
}

private struct HelpFAQOperatorLookupItem: View {
  var body: some View {
    DisclosureGroup(
      content: {
        VStack(alignment: .leading, spacing: 16) {
          Text(
            [
              "Pour connaître l'opérateur d'un numéro, vous pouvez utiliser le service gratuit de l'ARCEP. ",
              "Le service est accessible via le lien ci-dessous. Il vous suffit de saisir le numéro de ",
              "téléphone pour obtenir des informations sur l'opérateur.",
            ].joined()
          )

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
        }
      },
      label: {
        Image(systemName: "person.fill.questionmark")
          .foregroundColor(.accent)
          .frame(width: 12)
        Text("Comment connaitre l'opérateur d'un numéro ?")
          .multilineTextAlignment(.leading)
      }
    )
  }
}

private struct SupportItem: View {
  var body: some View {
    VStack(spacing: 16) {
      Text(
        "Vous avez besoin d'aide ?"
      )
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

            (Votre message ici ou description du bug avec une capture d'écran si possible)

            \(deviceInfo)
            """

          let encodedBody =
            body.addingPercentEncoding(
              withAllowedCharacters: .urlQueryAllowed
            ) ?? ""
          let urlString =
            "mailto:mail@cbouvat.com?subject=Bug%20-%20Saracroche%20iOS&body="
            + encodedBody
          if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
          }
        }
      } label: {
        HStack {
          Image(systemName: "envelope.fill")
          Text("Envoyer un e-mail")
        }
      }
      .buttonStyle(.fullWidth(background: .app, foreground: .black))

      Button {
        if let url = URL(string: "https://github.com/cbouvat/saracroche-ios/issues") {
          UIApplication.shared.open(url)
        }
      } label: {
        HStack {
          Image(systemName: "exclamationmark.bubble.fill")
          Text("Créer une issue sur GitHub")
        }
      }
      .buttonStyle(.fullWidth(background: .black, foreground: .white))
    }
    .padding(.vertical, 6)
  }
}

#Preview {
  HelpNavigationView()
}
