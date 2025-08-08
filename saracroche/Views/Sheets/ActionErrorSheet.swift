import SwiftUI

struct ActionErrorSheet: View {
  @ObservedObject var viewModel: BlockerViewModel

  var body: some View {
    NavigationView {
      VStack(alignment: .center, spacing: 16) {
        Spacer()

        if #available(iOS 18.0, *) {
          Image(systemName: "exclamationmark.triangle.fill")
            .font(.system(size: 80))
            .symbolEffect(
              .wiggle.clockwise.byLayer,
              options: .repeat(.periodic(delay: 1.0))
            )
            .foregroundColor(.red)
        } else {
          Image(systemName: "exclamationmark.triangle.fill")
            .font(.system(size: 80))
            .foregroundColor(.red)
        }

        Text("Erreur")
          .font(.title)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)

        Text("L'opération n'a pas pu être effectuée.")
          .font(.title2)
          .multilineTextAlignment(.center)
          .foregroundColor(.secondary)

        VStack(alignment: .leading, spacing: 12) {
          Text("Recommandations :")
            .font(.headline)
            .fontWeight(.semibold)

          VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
              Text("•")
                .fontWeight(.bold)
              Text(
                "Vérifiez que l'extension de blocage d'appels est activée dans les réglages"
              )
              .multilineTextAlignment(.leading)
            }

            HStack(alignment: .top, spacing: 10) {
              Text("•")
                .fontWeight(.bold)
              Text("Redémarrez votre appareil si le problème persiste")
                .multilineTextAlignment(.leading)
            }

            HStack(alignment: .top, spacing: 10) {
              Text("•")
                .fontWeight(.bold)
              Text("Désinstallez et réinstallez l'application si nécessaire")
                .multilineTextAlignment(.leading)
            }

            HStack(alignment: .top, spacing: 10) {
              Text("•")
                .fontWeight(.bold)
              Text("Attendez quelques heures avant de réessayer")
                .multilineTextAlignment(.leading)
            }
          }
          .font(.body)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)

        Spacer()

        Button {
          viewModel.openSettings()
        } label: {
          HStack {
            Image(systemName: "gearshape.fill")
            Text("Ouvrir les réglages")
          }
        }
        .buttonStyle(
          .fullWidth(background: Color("AppColor"), foreground: .black)
        )
      }
      .padding()
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Fermer") {
            viewModel.clearAction()
          }
        }
      }
    }
  }
}

#Preview {
  ActionErrorSheet(viewModel: BlockerViewModel())
}
