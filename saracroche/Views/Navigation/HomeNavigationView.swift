import SwiftUI

struct HomeNavigationView: View {
  @ObservedObject var blockerViewModel: BlockerViewModel
  @State private var showDonationSheet = false
  @State private var showInfoSheet = false

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 16) {
          if blockerViewModel.blockerExtensionStatus == .enabled {
            enabledExtensionContentView
          } else {
            disabledExtensionContentView
          }
        }
        .padding()
      }
      .navigationTitle("Saracroche")
      .task {
        await blockerViewModel.loadData()
        await blockerViewModel.checkBlockerExtensionStatus()
        await blockerViewModel.checkBackgroundStatus()
        await blockerViewModel.performUpdateWithStateManagement()
      }
      .sheet(isPresented: $showDonationSheet) {
        DonationSheet()
      }
      .sheet(isPresented: $showInfoSheet) {
        InfoSheet(blockerViewModel: blockerViewModel)
      }
    }
  }

  private var enabledExtensionContentView: some View {
    VStack(spacing: 16) {
      activeStatusView
      donationView
    }
  }

  private var activeStatusView: some View {
    VStack(spacing: 16) {
      // Header : icône bouclier + texte
      VStack(alignment: .center, spacing: 16) {
        if #available(iOS 18.0, *) {
          Image(systemName: "checkmark.shield.fill")
            .font(.system(size: 60))
            .symbolEffect(.bounce.up.byLayer, options: .repeat(.periodic(delay: 2.0)))
            .foregroundColor(.green)
        } else {
          Image(systemName: "checkmark.shield.fill")
            .font(.system(size: 60))
            .foregroundColor(.green)
        }

        Text("Le bloqueur est actif")
          .appFont(.title3Bold)
          .multilineTextAlignment(.center)
      }
      .padding(.bottom, 8)

      // Bandeau d'état + statistiques
      updateStateBanner

      // Bouton "En savoir plus"
      Button {
        showInfoSheet = true
      } label: {
        HStack {
          Image(systemName: "info.circle.fill")
          Text("En savoir plus")
        }
      }
      .buttonStyle(
        .fullWidth(background: .green, foreground: .white)
      )
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.green.opacity(0.15))
    )
  }

  private var disabledExtensionContentView: some View {
    VStack(alignment: .center, spacing: 16) {
      if blockerViewModel.blockerExtensionStatus == .disabled {
        if #available(iOS 18.0, *) {
          Image(systemName: "xmark.circle.fill")
            .font(.system(size: 60))
            .symbolEffect(
              .pulse.byLayer,
              options: .repeat(.periodic(delay: 2.0))
            )
            .foregroundColor(.red)
        } else {
          Image(systemName: "xmark.circle.fill")
            .font(.system(size: 60))
            .foregroundColor(.red)
        }

        Text("Le bloqueur n'est pas activé")
          .appFont(.title3Bold)
          .multilineTextAlignment(.center)

        Text(
          "Pour activer le bloqueur, il suffit d'utiliser le bouton ci-dessous et d'activer "
            + "Saracroche dans les réglages. Une fois l'activation effectuée, "
            + "la liste de blocage sera automatiquement installée."
        )
        .appFont(.body)
        .frame(maxWidth: .infinity, alignment: .leading)

        Button {
          Task {
            await blockerViewModel.openSettings()
          }
        } label: {
          HStack {
            Image(systemName: "gear")
            Text("Activer dans les réglages de l'iPhone")
          }
        }
        .buttonStyle(
          .fullWidth(background: Color.red, foreground: .white)
        )
      } else if blockerViewModel.blockerExtensionStatus == .unknown {
        if #available(iOS 18.0, *) {
          Image(systemName: "questionmark.circle.fill")
            .font(.system(size: 60))
            .symbolEffect(.wiggle.clockwise.byLayer, options: .repeat(.periodic(delay: 1.0)))
            .foregroundColor(.orange)
        } else {
          Image(systemName: "questionmark.circle.fill")
            .font(.system(size: 60))
            .foregroundColor(.orange)
        }

        Text("Vérification du statut du bloqueur en cours…")
          .appFont(.title3Bold)
          .multilineTextAlignment(.center)
      } else if blockerViewModel.blockerExtensionStatus == .error {
        if #available(iOS 18.0, *) {
          Image(systemName: "xmark.octagon.fill")
            .font(.system(size: 60))
            .symbolEffect(.bounce.up.byLayer, options: .repeat(.periodic(delay: 1.0)))
            .foregroundColor(.red)
        } else {
          Image(systemName: "xmark.octagon.fill")
            .font(.system(size: 60))
            .foregroundColor(.red)
        }

        Text("Erreur lors de la vérification")
          .appFont(.title3Bold)
      } else if blockerViewModel.blockerExtensionStatus == .unexpected {
        if #available(iOS 18.0, *) {
          Image(systemName: "exclamationmark.triangle.fill")
            .font(.system(size: 60))
            .symbolEffect(
              .wiggle.up.byLayer,
              options: .repeat(.periodic(delay: 2.5))
            )
            .foregroundColor(.orange)
        } else {
          Image(systemName: "exclamationmark.triangle.fill")
            .font(.system(size: 60))
            .foregroundColor(.orange)
        }

        Text("Statut inattendu")
          .appFont(.title3Bold)
          .multilineTextAlignment(.center)
      }
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .center)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.red.opacity(0.15))
    )
  }

  // MARK: - Update State Helpers

  @ViewBuilder
  private var updateStateBanner: some View {
    VStack(spacing: 12) {
      HStack(spacing: 12) {
        // Icône avec animation conditionnelle pour iOS 18+
        if #available(iOS 18.0, *) {
          Image(systemName: blockerViewModel.updateState.iconName)
            .font(.system(size: 20))
            .frame(width: 24)
            .foregroundColor(blockerViewModel.updateState.color)
            .symbolEffect(
              .rotate,
              options: .repeating,
              isActive: blockerViewModel.updateState == .inProgress
            )
        } else {
          Image(systemName: blockerViewModel.updateState.iconName)
            .font(.system(size: 20))
            .frame(width: 24)
            .foregroundColor(blockerViewModel.updateState.color)
        }

        VStack(alignment: .leading, spacing: 2) {
          Text("État de la liste de blocage")
            .appFont(.subheadlineMedium)
            .foregroundColor(.primary)

          Text(blockerViewModel.updateState.description)
            .appFont(.caption)
            .foregroundColor(.secondary)
        }

        Spacer()
      }

      HStack(spacing: 12) {
        Image(systemName: "number.circle.fill")
          .font(.system(size: 20))
          .frame(width: 24)
          .foregroundColor(.green)

        VStack(alignment: .leading, spacing: 2) {
          Text("\(blockerViewModel.totalPhoneNumbersCount.formatted())")
            .appFont(.subheadlineMedium)
            .foregroundColor(.primary)

          Text("Numéros dans la base de données")
            .appFont(.caption)
            .foregroundColor(.secondary)
        }

        Spacer()
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(
      "État de la liste de blocage : \(blockerViewModel.updateState.description). "
        + "\(blockerViewModel.totalPhoneNumbersCount.formatted()) numéros dans la base de données"
    )
  }

  private var donationView: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Image(systemName: "heart.fill")
          .font(.system(size: 20))
          .foregroundColor(.red)

        Text("Soutenez Saracroche")
          .appFont(.headlineSemiBold)
      }

      Text(
        "Saracroche est une application entièrement gratuite, open source et sans publicité. "
          + "Elle vit grâce aux dons de ses utilisateurs pour continuer à évoluer."
      )
      .appFont(.body)

      Button {
        showDonationSheet = true
      } label: {
        HStack {
          Image(systemName: "heart.fill")
          Text("Soutenez")
        }
      }
      .buttonStyle(
        .fullWidth(background: Color.red, foreground: .white)
      )
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.gray.opacity(0.1))
    )
  }
}
