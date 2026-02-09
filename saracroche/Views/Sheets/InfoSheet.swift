import SwiftUI

struct InfoSheet: View {
  @Environment(\.dismiss) private var dismiss
  @ObservedObject var blockerViewModel: BlockerViewModel

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
        ToolbarItem {
          Button("Fermer") {
            dismiss()
          }
        }
      }
    }
  }

  @ViewBuilder
  private var updateInfoView: some View {
    VStack(spacing: 20) {
      // SECTION: STATISTIQUES
      VStack(spacing: 16) {
        HStack {
          Image(systemName: "chart.bar.fill")
            .font(.system(size: 18))
            .foregroundColor(.gray)

          Text("Statistiques")
            .font(.headline)
            .fontWeight(.semibold)

          Spacer()
        }

        VStack(spacing: 8) {
          statisticsListItem(
            icon: "shield.fill",
            value: "\(blockerViewModel.completedPhoneNumbersCount.formatted())",
            label: "Numéros bloqués",
            color: .gray
          )

          statisticsListItem(
            icon: "checkmark.circle.fill",
            value: "\(blockerViewModel.completedPatternsCount)",
            label: "Préfixes actifs",
            color: .gray
          )

          statisticsListItem(
            icon: "clock.fill",
            value: "\(blockerViewModel.pendingPatternsCount)",
            label: "En attente",
            color: .gray
          )
        }
      }
      .padding()
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(Color.gray.opacity(0.1))
      )

      // SECTION: ÉTAT
      VStack(spacing: 16) {
        HStack {
          Image(systemName: "checkmark.shield.fill")
            .font(.system(size: 18))
            .foregroundColor(.gray)

          Text("État du service")
            .font(.headline)
            .fontWeight(.semibold)

          Spacer()
        }

        VStack(spacing: 8) {
          // État de l'extension
          statisticsListItem(
            icon: extensionStatusIcon,
            value: extensionStatusText,
            label: "État de l'extension",
            color: extensionStatusColor
          )

          // État du service en arrière-plan
          statisticsListItem(
            icon: backgroundServiceIcon,
            value: backgroundServiceText,
            label: "Service en arrière-plan",
            color: backgroundServiceColor
          )

          // État de la mise à jour (si applicable)
          if blockerViewModel.updateState != .ok {
            statisticsListItem(
              icon: "arrow.down.circle.fill",
              value: blockerViewModel.updateState.description,
              label: "État de la mise à jour",
              color: .blue
            )
          }
        }
      }
      .padding()
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(Color.gray.opacity(0.1))
      )

      // SECTION: DATES
      VStack(spacing: 16) {
        HStack {
          Image(systemName: "calendar.circle.fill")
            .font(.system(size: 18))
            .foregroundColor(.gray)

          Text("Dates et historique")
            .font(.headline)
            .fontWeight(.semibold)

          Spacer()
        }

        VStack(spacing: 8) {
          // Dernière téléchargement de la liste
          if let lastListDownloadAt = blockerViewModel.lastListDownloadAt {
            statisticsListItem(
              icon: "arrow.down.circle.fill",
              value: formatDate(lastListDownloadAt),
              label: "Dernier téléchargement de la liste",
              color: .blue
            )
          }

          // Dernière mise à jour réussie
          if let lastSuccessfulUpdateAt = blockerViewModel.lastSuccessfulUpdateAt {
            statisticsListItem(
              icon: "checkmark.circle.fill",
              value: formatDate(lastSuccessfulUpdateAt),
              label: "Dernière mise à jour réussie",
              color: .green
            )
          }

          // Dernier lancement en arrière-plan
          if let lastBackgroundLaunchAt = blockerViewModel.lastBackgroundLaunchAt {
            statisticsListItem(
              icon: "clock.arrow.circlepath",
              value: formatDate(lastBackgroundLaunchAt),
              label: "Dernier lancement en arrière-plan",
              color: .purple
            )
          }
        }
      }
      .padding()
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(Color.gray.opacity(0.1))
      )
    }
  }

  // MARK: - Helpers

  @ViewBuilder
  private func statisticsListItem(
    icon: String,
    value: String,
    label: String,
    color: Color
  ) -> some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 20))
        .foregroundColor(color)
        .frame(width: 24)

      VStack(alignment: .leading, spacing: 2) {
        Text(value)
          .font(.headline)
          .foregroundColor(.primary)

        Text(label)
          .font(.subheadline)
          .foregroundColor(.secondary)
      }

      Spacer()
    }
    .padding(.vertical, 8)
  }

  private var extensionStatusIcon: String {
    switch blockerViewModel.blockerExtensionStatus {
    case .enabled:
      return "checkmark.circle.fill"
    case .disabled:
      return "xmark.circle.fill"
    case .unknown:
      return "questionmark.circle.fill"
    case .error:
      return "exclamationmark.circle.fill"
    case .unexpected:
      return "exclamationmark.triangle.fill"
    }
  }

  private var extensionStatusColor: Color {
    switch blockerViewModel.blockerExtensionStatus {
    case .enabled:
      return .green
    case .disabled:
      return .red
    case .unknown:
      return .orange
    case .error:
      return .red
    case .unexpected:
      return .orange
    }
  }

  private var extensionStatusText: String {
    switch blockerViewModel.blockerExtensionStatus {
    case .enabled:
      return "Actif"
    case .disabled:
      return "Désactivé"
    case .unknown:
      return "Vérification en cours"
    case .error:
      return "Erreur de vérification"
    case .unexpected:
      return "Statut inattendu"
    }
  }

  private var backgroundServiceIcon: String {
    blockerViewModel.isBackgroundRefreshEnabled
      ? "arrow.clockwise.circle.fill" : "xmark.circle.fill"
  }

  private var backgroundServiceColor: Color {
    blockerViewModel.isBackgroundRefreshEnabled ? .green : .red
  }

  private var backgroundServiceText: String {
    blockerViewModel.isBackgroundRefreshEnabled
      ? "Actif - mises à jour automatiques toutes les 4h"
      : "Désactivé - activer dans Réglages > Général > Actualisation en arrière-plan"
  }

  private var lastCompletionDateFormatted: String {
    guard let date = blockerViewModel.lastCompletionDate else {
      return "Jamais"
    }

    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .short
    formatter.locale = Locale(identifier: "fr_FR")
    return formatter.localizedString(for: date, relativeTo: Date())
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
  InfoSheet(blockerViewModel: BlockerViewModel())
}
