import SwiftUI

struct ResetSheet: View {
  @Environment(\.dismiss) private var dismiss
  @ObservedObject var blockerViewModel: BlockerViewModel

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          VStack(spacing: 16) {
            if #available(iOS 18.0, *) {
              Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
                .symbolEffect(.wiggle.byLayer, options: .repeat(.periodic(delay: 2)))
            } else {
              Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            }

            Text("Réinitialiser l'application")
              .appFont(.titleBold)
              .multilineTextAlignment(.center)
          }

          VStack(alignment: .leading, spacing: 8) {
            Text("Attention")
              .appFont(.headlineSemiBold)
              .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 16) {
              Text(
                "Cette action est irréversible. Toutes les données seront supprimées et l'application se fermera."
              )
              .appFont(.body)
              .multilineTextAlignment(.leading)

              VStack(alignment: .leading, spacing: 16) {
                BenefitRow(
                  icon: "phone.fill.badge.checkmark",
                  title: "Numéros bloqués supprimés",
                  description: "Tous les numéros et préfixes installés seront effacés",
                  iconColor: .red
                )

                BenefitRow(
                  icon: "gearshape.fill",
                  title: "Réglages réinitialisés",
                  description: "Vos préférences reviendront aux valeurs par défaut",
                  iconColor: .red
                )

                BenefitRow(
                  icon: "xmark.app.fill",
                  title: "Fermeture de l'application",
                  description:
                    "L'application se fermera automatiquement après la réinitialisation",
                  iconColor: .red
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
            Task {
              await blockerViewModel.resetApplication()
            }
          } label: {
            Label("Réinitialiser", systemImage: "trash.fill")
          }
          .buttonStyle(
            .fullWidth(background: .red, foreground: .white)
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
  ResetSheet(blockerViewModel: BlockerViewModel())
}
