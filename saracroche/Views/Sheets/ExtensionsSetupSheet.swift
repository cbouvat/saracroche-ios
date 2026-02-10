import SwiftUI

struct ExtensionsSetupSheet: View {
  @Environment(\.dismiss) private var dismiss
  @ObservedObject var blockerViewModel: BlockerViewModel

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          VStack(spacing: 16) {
            if #available(iOS 18.0, *) {
              Image(systemName: "gearshape.2.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .symbolEffect(.wiggle.byLayer, options: .repeat(.periodic(delay: 2)))
            } else {
              Image(systemName: "gearshape.2.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            }

            Text("Activer les protections supplémentaires")
              .appFont(.titleBold)
              .multilineTextAlignment(.center)
          }

          VStack(alignment: .leading, spacing: 8) {
            Text("Filtre SMS")
              .appFont(.headlineSemiBold)
              .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 16) {
              Text(
                "Activez le filtre SMS pour que Saracroche filtre automatiquement les messages indésirables."
              )
              .appFont(.body)
              .multilineTextAlignment(.leading)

              VStack(alignment: .leading, spacing: 16) {
                BenefitRow(
                  icon: "message.fill",
                  title: "Comment activer",
                  description:
                    "Réglages > Apps> Messages > Filter les messages texte > Saracroche",
                  iconColor: .blue
                )
              }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
              RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
            )
          }

          VStack(alignment: .leading, spacing: 8) {
            Text("Signalement d'appels")
              .appFont(.headlineSemiBold)
              .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 16) {
              Text(
                "Activez le signalement pour pouvoir signaler les appels indésirables directement depuis l'historique d'appels."
              )
              .appFont(.body)
              .multilineTextAlignment(.leading)

              VStack(alignment: .leading, spacing: 16) {
                BenefitRow(
                  icon: "phone.fill",
                  title: "Comment activer",
                  description:
                    "Réglages > Apps> Téléphone > Signalements des SMS/appels > Saracroche",
                  iconColor: .blue
                )
              }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
              RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
            )
          }

          Button {
            blockerViewModel.dismissExtensionsSetup()
            dismiss()
          } label: {
            Label("J'ai activé les protections", systemImage: "checkmark.circle.fill")
          }
          .buttonStyle(
            .fullWidth(background: .blue, foreground: .white)
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
}

#Preview {
  ExtensionsSetupSheet(blockerViewModel: BlockerViewModel())
}
