import SwiftUI

struct HelpFAQSection: View {
  @Binding var showDonationSheet: Bool

  var body: some View {
    Section {
      HelpFAQNumbersBlockedItem()
      HelpFAQHowWorksItem()
      HelpFAQReportNumberItem()
      HelpFAQCallHistoryItem()
      HelpFAQSupportProjectItem(showDonationSheet: $showDonationSheet)
      HelpFAQPrivacyItem()
      HelpFAQWhyFreeItem(showDonationSheet: $showDonationSheet)
      HelpFAQBearPawItem()
      HelpFAQ33700Item()
      HelpFAQOperatorLookupItem()
    } header: {
      Text("Questions fréquentes")
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
          .foregroundColor(.blue)
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
          .foregroundColor(.cyan)
          .frame(width: 12)
        Text("Comment fonctionne l'application ?")
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
          .foregroundColor(.orange)
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
          .foregroundColor(.purple)
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
              "vous pouvez faire un don. ",
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
              Text("Faire un don")
            }
          }
          .buttonStyle(.fullWidth(background: .pink, foreground: .white))
          .padding(.bottom)
        }
      },
      label: {
        Image(systemName: "gift.fill")
          .foregroundColor(.pink)
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
          .foregroundColor(.green)
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
              "son temps libre. Vous pouvez soutenir le projet en faisant un don.",
            ].joined()
          )

          Button {
            showDonationSheet = true
          } label: {
            HStack {
              Image(systemName: "heart.fill")
              Text("Faire un don")
            }
          }
          .buttonStyle(.fullWidth(background: .red, foreground: .white))
        }
      },
      label: {
        Image(systemName: "dollarsign.circle.fill")
          .foregroundColor(.mint)
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
          .foregroundColor(.brown)
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
              "numéros"
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
          .foregroundColor(.orange)
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
          .foregroundColor(.blue)
          .frame(width: 12)
        Text("Comment connaitre l'opérateur d'un numéro ?")
          .multilineTextAlignment(.leading)
      }
    )
  }
}
