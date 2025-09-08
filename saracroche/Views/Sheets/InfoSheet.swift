import SwiftUI

struct InfoSheet: View {
  @Environment(\.dismiss) private var dismiss
  @ObservedObject var viewModel: BlockerViewModel

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          VStack(spacing: 16) {
            if #available(iOS 18.0, *) {
              Image(systemName: "phone.bubble.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .symbolEffect(.wiggle.clockwise.byLayer, options: .repeat(.periodic(delay: 2)))
            } else {
              Image(systemName: "phone.bubble.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            }

            Text("Informations sur le blocage")
              .font(.title)
              .fontWeight(.bold)
              .multilineTextAlignment(.center)
          }

          updateInfoView

          VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
              Text("Quels numéros sont bloqués ?")
                .font(.title3)
                .fontWeight(.semibold)

              Text(
                """
                Plus de **16,7 millions de numéros** sont bloqués, dont **12,5 millions** correspondent aux préfixes réservés au démarchage téléphonique, communiqués par l’ARCEP : 0162, 0163, 0270, 0271, 0377, 0378, 0424, 0425, 0568, 0569, 0948, 0949, ainsi que ceux allant de 09475 à 09479.

                **En plus**, elle bloque aussi des numéros de téléphone des opérateurs : Manifone, DVS Connect, Ze Telecom, Oxilog, BJT Partners, Ubicentrex, Destiny, Kav El International, Spartel Services et Comunik CRM. Ce qui représente plus de **4,2 millions de numéros** supplémentaires dont des numéros de **téléphone mobiles**.

                Ces numéros sont mis à jour régulièrement pour s'assurer que l'application reste efficace contre les appels indésirables. Les signalements permettent d'améliorer la liste de blocage en ajoutant de nouveaux opérateurs.
                """
              )
              .font(.body)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
            )

            VStack(alignment: .leading, spacing: 16) {
              Text("Pourquoi les numéros bloqués apparaissent-ils dans l'historique des appels ?")
                .font(.title3)
                .fontWeight(.semibold)

              Text(
                """
                Depuis iOS 18, les numéros bloqués par les extensions de blocage d'appels sont visibles dans l'historique des appels. Cela permet de garder une trace des appels bloqués, mais ne signifie pas que l'appel a été reçu ou que vous devez y répondre.
                """
              )
              .font(.body)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
            )

            VStack(alignment: .leading, spacing: 8) {
              Text("D'autres questions ?")
                .font(.title3)
                .fontWeight(.semibold)

              Text(
                """
                Si vous avez d'autres questions ou besoin d'aide, n'hésitez pas à vous rendre sur la **[page web d'aide](https://cbouvat.com/saracroche/help/)**.
                """
              )
              .font(.body)

              Button {
                if let url = URL(string: "https://cbouvat.com/saracroche/help/") {
                  UIApplication.shared.open(url)
                }
              } label: {
                Label("Ouvrir la page d'aide", systemImage: "questionmark.circle.fill")
              }
              .buttonStyle(
                .fullWidth(background: .blue, foreground: .white)
              )

            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
            )
          }
        }
        .padding()
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Fermer") {
            dismiss()
          }
        }
      }
    }
  }

  @ViewBuilder
  private var updateInfoView: some View {
    VStack(spacing: 16) {
      // État du service background
      HStack(spacing: 12) {
        Image(
          systemName: viewModel.isBackgroundServiceActive
            ? "checkmark.circle.fill" : "xmark.circle.fill"
        )
        .font(.system(size: 20))
        .foregroundColor(viewModel.isBackgroundServiceActive ? .green : .red)

        VStack(alignment: .leading, spacing: 2) {
          Text("Service de mise à jour automatique")
            .font(.subheadline)
            .foregroundColor(.primary)
          Text(viewModel.isBackgroundServiceActive ? "Actif" : "Inactif")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        Spacer()
      }
      .padding(.vertical, 4)

      // Dernière vérification
      if let lastUpdateCheck = viewModel.lastUpdateCheck {
        HStack(spacing: 12) {
          Image(systemName: "magnifyingglass.circle.fill")
            .font(.system(size: 20))
            .foregroundColor(.green)

          VStack(alignment: .leading, spacing: 2) {
            Text("Dernière vérification")
              .font(.subheadline)
              .foregroundColor(.primary)
            Text(formatDate(lastUpdateCheck))
              .font(.caption)
              .foregroundColor(.secondary)
          }
          Spacer()
        }
        .padding(.vertical, 4)
      }

      // Dernière mise à jour
      if let lastUpdate = viewModel.lastUpdate {
        HStack(spacing: 12) {
          Image(systemName: "arrow.clockwise.circle.fill")
            .font(.system(size: 20))
            .foregroundColor(.blue)

          VStack(alignment: .leading, spacing: 2) {
            Text("Dernière mise à jour")
              .font(.subheadline)
              .foregroundColor(.primary)
            Text(formatDate(lastUpdate))
              .font(.caption)
              .foregroundColor(.secondary)
          }
          Spacer()
        }
        .padding(.vertical, 4)
      }
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.gray.opacity(0.1))
    )
  }

  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.locale = Locale(identifier: "fr_FR")
    return formatter.string(from: date)
  }
}

#Preview {
  InfoSheet(viewModel: BlockerViewModel())
}
