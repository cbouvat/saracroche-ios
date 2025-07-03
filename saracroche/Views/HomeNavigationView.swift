import SwiftUI

struct HomeNavigationView: View {
  @ObservedObject var viewModel: SaracrocheViewModel
  @Environment(\.scenePhase) private var scenePhase
  var body: some View {
    NavigationView {
      VStack {
        ScrollView {
          VStack {
            VStack(alignment: .center) {
              if viewModel.blockerExtensionStatus == .enabled {
                if #available(iOS 18.0, *) {
                  Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 48))
                    .symbolEffect(
                      .bounce.up.byLayer,
                      options: .repeat(.periodic(delay: 1.0))
                    )
                    .foregroundColor(.green)
                    .padding(.bottom)
                } else {
                  Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.green)
                    .padding(.bottom)
                }

                Text("Le bloqueur d'appels est actif")
                  .font(.title3)
                  .bold()
                  .multilineTextAlignment(.center)
              } else if viewModel.blockerExtensionStatus == .disabled {
                if #available(iOS 18.0, *) {
                  Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 48))
                    .symbolEffect(
                      .bounce.up.byLayer,
                      options: .repeat(.periodic(delay: 1.0))
                    )
                    .foregroundColor(.red)
                    .padding(.bottom)
                } else {
                  Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.red)
                    .padding(.bottom)
                }

                Text("Le bloqueur d'appels n'est pas activé")
                  .font(.title3)
                  .bold()
                  .multilineTextAlignment(.center)

                Text(
                  "Pour activer le bloqueur d'appels, il suffit d'utiliser le bouton ci-dessous et d'activer Saracroche dans les réglages de votre iPhone. Une fois l'activation effectuée, il sera possible d'installer la liste de blocage afin de filtrer les appels indésirables."
                )
                .font(.body)
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .center)

                Button {
                  viewModel.openSettings()
                } label: {
                  HStack {
                    Image(systemName: "gear")
                    Text("Activer dans les réglages de l'iPhone")
                  }
                }
                .buttonStyle(
                  .fullWidth(background: Color.red, foreground: .white)
                )
              } else if viewModel.blockerExtensionStatus == .unknown {
                if #available(iOS 18.0, *) {
                  Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 48))
                    .symbolEffect(
                      .bounce.up.byLayer,
                      options: .repeat(.periodic(delay: 1.0))
                    )
                    .foregroundColor(.orange)
                    .padding(.bottom)
                } else {
                  Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)
                    .padding(.bottom)
                }

                Text("Vérification du statut du bloqueur en cours…")
                  .font(.title3)
                  .bold()
                  .multilineTextAlignment(.center)
              } else if viewModel.blockerExtensionStatus == .error {
                if #available(iOS 18.0, *) {
                  Image(systemName: "xmark.octagon.fill")
                    .font(.system(size: 48))
                    .symbolEffect(
                      .bounce.up.byLayer,
                      options: .repeat(.periodic(delay: 1.0))
                    )
                    .foregroundColor(.red)
                    .padding(.bottom)
                } else {
                  Image(systemName: "xmark.octagon.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.red)
                    .padding(.bottom)
                }

                Text("Erreur lors de la vérification")
                  .font(.title3)
                  .bold()
              } else if viewModel.blockerExtensionStatus == .unexpected {
                if #available(iOS 18.0, *) {
                  Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .symbolEffect(
                      .bounce.up.byLayer,
                      options: .repeat(.periodic(delay: 1.0))
                    )
                    .foregroundColor(.orange)
                    .padding(.bottom)
                } else {
                  Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)
                    .padding(.bottom)
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
                .fill(
                  viewModel.blockerExtensionStatus == .enabled
                    ? Color.green.opacity(0.15)
                    : Color.red.opacity(0.15)
                )
            )
            .overlay(
              RoundedRectangle(cornerRadius: 16)
                .stroke(
                  viewModel.blockerExtensionStatus == .enabled
                    ? Color.green.opacity(0.5)
                    : Color.red.opacity(0.5),
                  lineWidth: 1
                )
            )

            if viewModel.blockerExtensionStatus == .enabled {
              VStack {
                if viewModel.blockerPhoneNumberBlocked == 0 {
                  Image(
                    systemName: "exclamationmark.triangle.fill"
                  )
                  .font(.system(size: 48))
                  .foregroundColor(.gray)

                  Text("Aucun numéro bloqué")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top)

                  Text(
                    "Pour bloquer les appels indésirables, installez la liste de blocage qui contient les numéros à bloquer."
                  )
                  .multilineTextAlignment(.center)
                  .font(.body)
                  .padding(.vertical)

                  Button {
                    viewModel.updateBlockerList()
                  } label: {
                    HStack {
                      Image(systemName: "arrow.down.square.fill")
                      Text("Installer la liste de blocage")
                    }
                  }
                  .buttonStyle(
                    .fullWidth(background: Color.blue, foreground: .white)
                  )
                } else if viewModel.blocklistVersion
                  != viewModel.blocklistInstalledVersion
                {
                  Image(
                    systemName: "arrow.clockwise.circle.fill"
                  )
                  .font(.system(size: 48))
                  .foregroundColor(.orange)

                  Text("Mise à jour disponible")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top)

                  Text(
                    "Une nouvelle version de la liste de blocage est disponible. Vous pouvez l'installer pour bloquer de nouveaux numéros indésirables."
                  )
                  .multilineTextAlignment(.center)
                  .font(.body)
                  .padding(.top)

                  Text(
                    "Version installée : \(viewModel.blocklistInstalledVersion), version disponible : \(viewModel.blocklistVersion)"
                  )
                  .font(.footnote)
                  .padding(.vertical)

                  Button {
                    viewModel.updateBlockerList()
                  } label: {
                    HStack {
                      Image(systemName: "arrow.counterclockwise.circle.fill")
                      Text("Mettre à jour la liste de blocage")
                    }
                  }
                  .buttonStyle(
                    .fullWidth(background: Color.red, foreground: .white)
                  )
                } else if viewModel.blockerPhoneNumberBlocked
                  != viewModel.blockerPhoneNumberTotal
                {
                  Image(
                    systemName: "exclamationmark.triangle.fill"
                  )
                  .font(.system(size: 48))
                  .foregroundColor(.orange)

                  Text("Liste de blocage partiellement installée")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top)

                  Text(
                    "\(viewModel.blockerPhoneNumberBlocked) numéros bloqués sur \(viewModel.blockerPhoneNumberTotal)"
                  )
                  .font(.body)
                  .padding(.vertical)
                  .multilineTextAlignment(.center)

                  Button {
                    viewModel.updateBlockerList()
                  } label: {
                    HStack {
                      Image(systemName: "arrow.down.square.fill")
                      Text("Mettre à jour la liste de blocage")
                    }
                  }
                  .buttonStyle(
                    .fullWidth(background: Color.red, foreground: .white)
                  )
                } else {
                  Image(
                    systemName: "checklist.checked"
                  )
                  .font(.system(size: 48))
                  .foregroundColor(.green)

                  Text(
                    "\(viewModel.blockerPhoneNumberBlocked) numéros bloqués"
                  )
                  .font(.title3)
                  .fontWeight(.semibold)
                  .padding(.top)

                  Text(
                    "Version de la liste de blocage : \(viewModel.blocklistVersion)"
                  )
                  .font(.footnote)
                  .padding(.top, 2)
                }
              }
              .padding()
              .frame(maxWidth: .infinity)
              .background(
                RoundedRectangle(cornerRadius: 16)
                  .fill(Color.white.opacity(0.2))
              )
              .overlay(
                RoundedRectangle(cornerRadius: 16)
                  .stroke(Color.gray.opacity(0.5), lineWidth: 1)
              )
              .padding(.top)
            }
          }
          .padding()
        }
        Spacer()
      }
      .navigationTitle("Saracroche")
      .onChange(of: scenePhase) { newPhase in
        if newPhase == .active {
          viewModel.checkBlockerExtensionStatus()
        }
      }
    }
  }
}
