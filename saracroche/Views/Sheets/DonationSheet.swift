import SwiftUI

struct DonationSheet: View {
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          VStack(spacing: 16) {
            if #available(iOS 18.0, *) {
              Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundColor(.pink)
                .symbolEffect(.bounce.down.byLayer, options: .repeat(.periodic(delay: 0.5)))
            } else {
              Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundColor(.pink)
            }

            Text("Soutenez Saracroche")
              .font(.title)
              .fontWeight(.bold)
              .multilineTextAlignment(.center)
          }

          VStack(alignment: .leading, spacing: 16) {
            Text(
              "Saracroche est développée bénévolement par Camille sur son temps libre. Vos dons lui permettent d’améliorer l’application et de maintenir les listes de blocage à jour. "
                + "Une note sur le store, ça fait toujours plaisir et aide beaucoup !"
            )
            .font(.body)
            .multilineTextAlignment(.leading)

            Spacer()

            Text("Pourquoi donner ?")
              .font(.headline)
              .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
              DonationBenefitRow(
                icon: "curlybraces.square.fill",
                title: "Projet open source",
                description: "Code source ouvert et transparent"
              )

              DonationBenefitRow(
                icon: "gift.fill",
                title: "Entièrement gratuit",
                description:
                  "Pas de pub, pas d'abonnement, pas de version premium"
              )

              DonationBenefitRow(
                icon: "person.fill",
                title: "Développeur indépendant",
                description:
                  "Camille développe bénévolement sur son temps libre"
              )

              DonationBenefitRow(
                icon: "arrow.clockwise.circle.fill",
                title: "Mises à jour régulières",
                description:
                  "Nouvelles listes de blocage et améliorations continues"
              )

              DonationBenefitRow(
                icon: "lock.shield.fill",
                title: "Confidentialité respectée",
                description:
                  "Aucune donnée collectée, tout reste sur votre appareil"
              )
            }
          }

          Spacer()

          VStack(spacing: 16) {
            Button {
              if let url = URL(string: "https://donate.stripe.com/9B6aEXcJ8flofsgfIU2oE01") {
                UIApplication.shared.open(url)
              }
            } label: {
              HStack {
                Image(systemName: "creditcard.fill")
                Text("Carte Bancaire & Apple Pay")
              }
            }
            .buttonStyle(
              .fullWidth(background: .indigo, foreground: .white)
            )

            Button {
              if let url = URL(
                string: "https://www.paypal.com/donate/?hosted_button_id=WJYS344L5MMYJ&locale.x=fr_FR")
              {
                UIApplication.shared.open(url)
              }
            } label: {
              HStack {
                Image(systemName: "wallet.bifold.fill")
                Text("PayPal")
              }
            }
            .buttonStyle(
              .fullWidth(background: .blue, foreground: .white)
            )

            HStack(spacing: 12) {
              Button {
                if let url = URL(string: "https://github.com/sponsors/cbouvat") {
                  UIApplication.shared.open(url)
                }
              } label: {
                HStack {
                  Text("GitHub")
                }
              }
              .buttonStyle(
                .fullWidth(background: .black, foreground: .white)
              )

              Button {
                if let url = URL(string: "https://liberapay.com/cbouvat") {
                  UIApplication.shared.open(url)
                }
              } label: {
                HStack {
                  Text("Liberapay")
                }
              }
              .buttonStyle(
                .fullWidth(background: .yellow, foreground: .black)
              )
            }

            Spacer()

            Button {
              if let url = URL(
                string:
                  "https://apps.apple.com/app/id6743679292?action=write-review"
              ) {
                UIApplication.shared.open(url)
              }
            } label: {
              Label("Noter l'application", systemImage: "star.bubble.fill")
            }
            .buttonStyle(
              .fullWidth(background: .pink, foreground: .white)
            )
          }
        }
        .padding()
      }
      .toolbar {
        ToolbarItem {
          Button("Fermer") {
            dismiss()
          }
        }
      }
    }
  }
}

struct DonationBenefitRow: View {
  let icon: String
  let title: String
  let description: String

  var body: some View {
    HStack(alignment: .center, spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 20))
        .foregroundColor(.accent)
        .frame(width: 24)

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.subheadline)
          .fontWeight(.medium)

        Text(description)
          .font(.caption)
          .foregroundColor(.secondary)
      }

      Spacer()
    }
  }
}

#Preview {
  DonationSheet()
}
