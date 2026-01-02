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
      .onAppear {
        blockerViewModel.startPeriodicRefresh()
      }
      .onDisappear {
        blockerViewModel.stopPeriodicRefresh()
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
      if blockerViewModel.updateState == .starting {
        startingView
      } else if blockerViewModel.updateState == .installing {
        installingView
      } else if blockerViewModel.updateState == .error {
        errorView
      } else if blockerViewModel.updateState == .idle {
        /*
        if blockerViewModel.blockerPhoneNumberBlocked == 0 {
          noBlockedNumbersView
        } else if blockerViewModel.blocklistInstalledVersion != blockerViewModel.blocklistVersion {
          updateAvailableView
        } else {
          completeInstallationView
          donationView
        }
         */
      }
    }
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
          .font(.title3)
          .bold()
          .multilineTextAlignment(.center)

        Text(
          "Pour activer le bloqueur, il suffit d'utiliser le bouton ci-dessous et d'activer "
            + "Saracroche dans les réglages. Une fois l'activation effectuée, "
            + "la liste de blocage sera automatiquement installée."
        )
        .font(.body)
        .frame(maxWidth: .infinity, alignment: .leading)

        Button {
          blockerViewModel.openSettings()
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
          .font(.title3)
          .bold()
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
          .font(.title3)
          .bold()
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
          .font(.title3)
          .bold()
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

  private var completeInstallationView: some View {
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
        .font(.title3)
        .bold()
        .multilineTextAlignment(.center)

      /*/
      Text("\(blockerViewModel.blockerPhoneNumberBlocked) numéros bloqués")
        .font(.title2)
        .fontWeight(.semibold)
        .foregroundColor(.green)
      */

      Text("Vous avez la dernière version de la liste de blocage installée.")
        .font(.body)
        .multilineTextAlignment(.center)

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
    .frame(maxWidth: .infinity, alignment: .center)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.green.opacity(0.15))
    )
  }

  private var installingView: some View {
    VStack(alignment: .center, spacing: 16) {
      if #available(iOS 18.0, *) {
        Image(systemName: "arrow.clockwise.circle.fill")
          .font(.system(size: 60))
          .symbolEffect(
            .rotate.byLayer,
            options: .repeat(.periodic(delay: 2.0))
          )
          .foregroundColor(.blue)
      } else {
        Image(systemName: "arrow.clockwise.circle.fill")
          .font(.system(size: 60))
          .foregroundColor(.blue)
      }

      Text("Installation de la liste")
        .font(.title3)
        .fontWeight(.semibold)
        .multilineTextAlignment(.center)

      Text(
        "La dernière version de la liste de blocage est en cours d'installation."
      )
      .font(.body)
      .multilineTextAlignment(.center)

      updateProgressView
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.blue.opacity(0.1))
    )
  }

  private var errorView: some View {
    VStack(alignment: .center, spacing: 16) {
      if #available(iOS 18.0, *) {
        Image(systemName: "exclamationmark.triangle.fill")
          .font(.system(size: 60))
          .symbolEffect(.wiggle.clockwise.byLayer, options: .repeat(.periodic(delay: 1.0)))
          .foregroundColor(.red)
      } else {
        Image(systemName: "exclamationmark.triangle.fill")
          .font(.system(size: 60))
          .foregroundColor(.red)
      }

      Text("Erreur")
        .font(.title3)
        .fontWeight(.semibold)
        .multilineTextAlignment(.center)

      Text(
        """
        **L'application n'arrive pas à installer la liste de blocage.** Pour résoudre ce problème, essayez les étapes suivantes :

        - Rechargez votre téléphone au **delà de 80%**.
        - Désactivez le mode économie d'énergie.
        - Vérifiez que l'**actualisation en arrière-plan** est activée pour Saracroche dans les réglages.
        - Puis **réinitialisez l'application** en utilisant le bouton ci-dessous.
        """
      )
      .font(.body)
      .multilineTextAlignment(.leading)
      .frame(maxWidth: .infinity, alignment: .leading)

      Button {
        blockerViewModel.resetApplication()
      } label: {
        HStack {
          Image(systemName: "trash.circle.fill")
          Text("Réinitialiser l'application")
        }
      }
      .buttonStyle(
        .fullWidth(background: .red, foreground: .white)
      )

      Text(
        """
        **Si le problème persiste** après avoir essayé ces étapes, voici une procédure plus complète :

        - Désactivez Saracroche dans les réglages, si elle apparaît ou si vous le pouvez.
        - Désinstallez l'application Saracroche.
        - Redémarrez votre appareil.
        - Réinstallez l'application Saracroche depuis l'App Store.
        """
      )
      .font(.body)
      .multilineTextAlignment(.leading)
      .frame(maxWidth: .infinity, alignment: .leading)

      Button {
        blockerViewModel.openSettings()
      } label: {
        HStack {
          Image(systemName: "gearshape.fill")
          Text("Ouvrir les réglages")
        }
      }
      .buttonStyle(
        .fullWidth(background: .black, foreground: .white)
      )

    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.red.opacity(0.1))
    )
  }

  private var startingView: some View {
    VStack(alignment: .center, spacing: 16) {
      if #available(iOS 18.0, *) {
        Image(systemName: "hourglass.circle.fill")
          .font(.system(size: 60))
          .symbolEffect(.rotate.byLayer, options: .repeat(.periodic(delay: 1.0)))
          .foregroundColor(.blue)
      } else {
        Image(systemName: "hourglass.circle.fill")
          .font(.system(size: 60))
          .foregroundColor(.blue)
      }

      Text("Démarrage en cours")
        .font(.title3)
        .fontWeight(.semibold)
        .multilineTextAlignment(.center)

      Text(
        "Préparation de l'installation de la liste de blocage."
      )
      .multilineTextAlignment(.center)
      .font(.body)

      updateProgressView
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.blue.opacity(0.1))
    )
  }

  private var noBlockedNumbersView: some View {
    VStack(alignment: .center, spacing: 16) {
      if #available(iOS 18.0, *) {
        Image(systemName: "arrow.down.circle.fill")
          .font(.system(size: 60))
          .symbolEffect(.wiggle.down.byLayer, options: .repeat(.periodic(delay: 1.0)))
          .foregroundColor(.blue)
      } else {
        Image(systemName: "arrow.down.circle.fill")
          .font(.system(size: 60))
          .foregroundColor(.blue)
      }

      Text("Aucun numéro bloqué")
        .font(.title3)
        .fontWeight(.semibold)
        .multilineTextAlignment(.center)

      Text(
        "La liste de blocage va être installée automatiquement, veuillez patienter quelques instants."
      )
      .multilineTextAlignment(.center)
      .font(.body)

      updateProgressView
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.blue.opacity(0.1))
    )
  }

  private var updateAvailableView: some View {
    VStack(alignment: .center, spacing: 16) {
      if #available(iOS 18.0, *) {
        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill")
          .font(.system(size: 60))
          .symbolEffect(.wiggle.clockwise.byLayer, options: .repeat(.periodic(delay: 1.0)))
          .foregroundColor(.orange)
      } else {
        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill")
          .font(.system(size: 60))
          .foregroundColor(.orange)
      }

      Text("Lancement de la mise à jour")
        .font(.title3)
        .fontWeight(.semibold)
        .multilineTextAlignment(.center)

      Text(
        "Une nouvelle version de la liste de blocage est disponible. La mise à jour va être installée automatiquement."
      )
      .font(.body)
      .multilineTextAlignment(.center)

      updateProgressView
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.orange.opacity(0.1))
    )
  }

  @ViewBuilder
  private var updateProgressView: some View {
    if blockerViewModel.updateState.isInProgress {
      VStack(spacing: 16) {
        ProgressView()
          .scaleEffect(1.5)
        /*
        if blockerViewModel.blockerPhoneNumberBlocked > 0 {
          Text(
            "\(blockerViewModel.blockerPhoneNumberBlocked) numéros bloqués sur \(blockerViewModel.blockerPhoneNumberTotal)"
          )
          .font(.body.monospacedDigit())
          .multilineTextAlignment(.center)
        }
         */
      }
    }
  }

  @ViewBuilder
  private var donationView: some View {
    /*
    if blockerViewModel.updateState == .idle && blockerViewModel.blockerPhoneNumberBlocked != 0 {
      VStack(alignment: .leading, spacing: 16) {
        HStack {
          Image(systemName: "heart.fill")
            .font(.system(size: 20))
            .foregroundColor(.red)
    
          Text("Application gratuite et open source")
            .font(.headline)
            .fontWeight(.semibold)
        }
    
        Text(
          "Saracroche est une application entièrement gratuite et open source. "
            + "Elle vit grâce aux dons de ses utilisateurs pour continuer à évoluer et rester sans publicité."
        )
        .font(.body)
    
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
     */
  }
}
