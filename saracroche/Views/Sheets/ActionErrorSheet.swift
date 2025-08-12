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

        Spacer()

        VStack(alignment: .leading, spacing: 12) {
          Text(
            "Vérifiez que l'extension de blocage d'appels est activée dans les réglages et attendez quelques minutes avant de réessayer."
          )
          .fontWeight(.semibold)
          .multilineTextAlignment(.leading)

          Text("Si le problème persiste :")
            .font(.title3)
            .fontWeight(.semibold)

          HStack(alignment: .top, spacing: 10) {
            Text("1")
              .fontWeight(.bold)
            Text("Désactivez Saracroche dans les réglages, si elle apparaît.")
              .multilineTextAlignment(.leading)
          }

          HStack(alignment: .top, spacing: 10) {
            Text("2")
              .fontWeight(.bold)
            Text("Désinstallez l'application Saracroche.")
              .multilineTextAlignment(.leading)
          }

          HStack(alignment: .top, spacing: 10) {
            Text("3")
              .fontWeight(.bold)
            Text("Redémarrez votre appareil.")
              .multilineTextAlignment(.leading)
          }

          HStack(alignment: .top, spacing: 10) {
            Text("4")
              .fontWeight(.bold)
            Text("Réinstallez l'application Saracroche depuis l'App Store.")
              .multilineTextAlignment(.leading)
          }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)

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
