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

        LazyVGrid(
          columns: [GridItem(.flexible()), GridItem(.flexible())],
          spacing: 12
        ) {
          statisticsCard(
            icon: "shield.fill",
            value: "\(blockerViewModel.completedPhoneNumbersCount.formatted())",
            label: "Numéros bloqués"
          )

          statisticsCard(
            icon: "checkmark.circle.fill",
            value: "\(blockerViewModel.completedPatternsCount)",
            label: "Préfixes actifs"
          )

          statisticsCard(
            icon: "clock.fill",
            value: "\(blockerViewModel.pendingPatternsCount)",
            label: "En attente"
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

        // État de l'extension
        HStack(spacing: 12) {
          Image(
            systemName: extensionStatusIcon
          )
          .font(.system(size: 20))
          .foregroundColor(extensionStatusColor)

          VStack(alignment: .leading, spacing: 2) {
            Text("État de l'extension")
              .font(.subheadline)
              .foregroundColor(.primary)
            Text(extensionStatusText)
              .font(.caption)
              .foregroundColor(.secondary)
          }
          Spacer()
        }
        .padding(.vertical, 4)

        // État du service en arrière-plan
        HStack(spacing: 12) {
          Image(systemName: backgroundServiceIcon)
            .font(.system(size: 20))
            .foregroundColor(backgroundServiceColor)

          VStack(alignment: .leading, spacing: 2) {
            Text("Service en arrière-plan")
              .font(.subheadline)
              .foregroundColor(.primary)
            Text(backgroundServiceText)
              .font(.caption)
              .foregroundColor(.secondary)
          }
          Spacer()
        }
        .padding(.vertical, 4)

        // État de la mise à jour (si applicable)
        if blockerViewModel.updateState != .ok {
          HStack(spacing: 12) {
            Image(systemName: "arrow.down.circle.fill")
              .font(.system(size: 20))
              .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 2) {
              Text("État de la mise à jour")
                .font(.subheadline)
                .foregroundColor(.primary)
              Text(blockerViewModel.updateState.description)
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

        // Dernière téléchargement de la liste
        if let lastListDownloadAt = blockerViewModel.lastListDownloadAt {
          HStack(spacing: 12) {
            Image(systemName: "arrow.down.circle.fill")
              .font(.system(size: 20))
              .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 2) {
              Text("Dernier téléchargement de la liste")
                .font(.subheadline)
                .foregroundColor(.primary)
              Text(formatDate(lastListDownloadAt))
                .font(.caption)
                .foregroundColor(.secondary)
            }
            Spacer()
          }
          .padding(.vertical, 4)
        }

        // Dernière mise à jour réussie
        if let lastSuccessfulUpdateAt = blockerViewModel.lastSuccessfulUpdateAt {
          HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
              .font(.system(size: 20))
              .foregroundColor(.green)

            VStack(alignment: .leading, spacing: 2) {
              Text("Dernière mise à jour réussie")
                .font(.subheadline)
                .foregroundColor(.primary)
              Text(formatDate(lastSuccessfulUpdateAt))
                .font(.caption)
                .foregroundColor(.secondary)
            }
            Spacer()
          }
          .padding(.vertical, 4)
        }

        // Dernier lancement en arrière-plan
        if let lastBackgroundLaunchAt = blockerViewModel.lastBackgroundLaunchAt {
          HStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
              .font(.system(size: 20))
              .foregroundColor(.purple)

            VStack(alignment: .leading, spacing: 2) {
              Text("Dernier lancement en arrière-plan")
                .font(.subheadline)
                .foregroundColor(.primary)
              Text(formatDate(lastBackgroundLaunchAt))
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
  }

  // MARK: - Helpers

  @ViewBuilder
  private func statisticsCard(
    icon: String,
    value: String,
    label: String
  ) -> some View {
    VStack(spacing: 6) {
      Image(systemName: icon)
        .font(.system(size: 18))
        .foregroundColor(.gray)

      Text(value)
        .font(.body)
        .fontWeight(.bold)
        .foregroundColor(.primary)

      Text(label)
        .font(.caption2)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 8)
    .padding(.horizontal, 4)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(Color.gray.opacity(0.08))
    )
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
