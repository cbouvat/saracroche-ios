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
            Text("Besoin d'informations supplémentaires ?")
              .font(.title3)
              .fontWeight(.semibold)

            Text(
              """
              Si vous avez d'autres questions ou besoin d'aide, n'hésitez pas à vous rendre sur la page web d'aide.
              Vous y trouverez la foire aux questions (FAQ).
              """
            )
            .font(.body)

            Button {
              if let url = URL(string: "https://saracroche.org/fr/help") {
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
