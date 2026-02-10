import SwiftUI

struct ReinstallSheet: View {
  @Environment(\.dismiss) private var dismiss
  @ObservedObject var blockerViewModel: BlockerViewModel

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          VStack(spacing: 16) {
            if #available(iOS 18.0, *) {
              Image(systemName: "arrow.clockwise.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .symbolEffect(.wiggle.byLayer, options: .repeat(.periodic(delay: 2)))
            } else {
              Image(systemName: "arrow.clockwise.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            }

            Text("Réinstaller la liste de blocage")
              .appFont(.titleBold)
              .multilineTextAlignment(.center)
          }

          VStack(alignment: .leading, spacing: 8) {
            Text("Informations")
              .appFont(.headlineSemiBold)
              .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 16) {
              Text(
                "Les numéros installés seront supprimés de l'extension puis réinstallés progressivement."
              )
              .appFont(.body)
              .multilineTextAlignment(.leading)

              VStack(alignment: .leading, spacing: 16) {
                BenefitRow(
                  icon: "phone.fill.badge.checkmark",
                  title: "Extension réinitialisée",
                  description:
                    "Les numéros bloqués seront temporairement supprimés",
                  iconColor: .blue
                )

                BenefitRow(
                  icon: "arrow.clockwise",
                  title: "Réinstallation automatique",
                  description:
                    "Les numéros seront réinstallés progressivement",
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
            Task {
              await blockerViewModel.reinstallBlockList()
              dismiss()
            }
          } label: {
            Label("Réinstaller", systemImage: "arrow.clockwise")
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
  ReinstallSheet(blockerViewModel: BlockerViewModel())
}
