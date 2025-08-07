import SwiftUI

struct DonationSheet: View {
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 16) {
          VStack(spacing: 16) {
            if #available(iOS 18.0, *) {
              Image(systemName: "heart.fill")
                .font(.system(size: 48))
                .foregroundColor(.pink)
                .symbolEffect(.pulse, options: .repeating)
            } else {
              Image(systemName: "heart.fill")
                .font(.system(size: 48))
                .foregroundColor(.pink)
            }

            Text("Soutenez Saracroche")
              .font(.title2)
              .fontWeight(.bold)
              .multilineTextAlignment(.center)
          }

          VStack(alignment: .leading, spacing: 16) {
            Text(
              "Saracroche est développée bénévolement par Camille sur son temps libre. " +
              "Votre don l'aide à consacrer plus de temps à l'amélioration de l'app " +
              "et au maintien des listes de blocage."
            )
            .font(.body)

            Text("Pourquoi donner ?")
              .font(.headline)
              .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
              DonationBenefitRow(
                icon: "curlybraces.square.fill",
                title: "Projet open-source",
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
              if let url = URL(string: "https://paypal.me/cbouvat") {
                UIApplication.shared.open(url)
              }
            } label: {
              HStack {
                Image(systemName: "heart.fill")
                Text("PayPal")
              }
            }
            .buttonStyle(
              .fullWidth(background: Color.blue, foreground: .white)
            )

            Button {
              if let url = URL(string: "https://github.com/sponsors/cbouvat") {
                UIApplication.shared.open(url)
              }
            } label: {
              HStack {
                Image(systemName: "heart.fill")
                Text("GitHub Sponsors")
              }
            }
            .buttonStyle(
              .fullWidth(background: Color.black, foreground: .white)
            )

            Button {
              if let url = URL(string: "https://liberapay.com/cbouvat") {
                UIApplication.shared.open(url)
              }
            } label: {
              HStack {
                Image(systemName: "heart.fill")
                Text("Liberapay")
              }
            }
            .buttonStyle(
              .fullWidth(background: Color.yellow, foreground: .black)
            )
          }
        }
        .padding()
      }
      .navigationBarBackButtonHidden(true)
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
        .foregroundColor(.app)
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
