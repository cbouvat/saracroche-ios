import SwiftUI

struct UpdateListSheet: View {
  @ObservedObject var viewModel: BlockerViewModel

  var body: some View {
    NavigationView {
      VStack(alignment: .center, spacing: 16) {
        Spacer()

        Text("Garder l'application ouverte")
          .font(.title)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)

        if #available(iOS 18.0, *) {
          Image(
            systemName: "gearshape.arrow.trianglehead.2.clockwise.rotate.90"
          )
          .font(.system(size: 100))
          .symbolEffect(
            .rotate.clockwise.byLayer,
            options: .repeat(.periodic(delay: 2.0))
          )
          .foregroundColor(.app)
        } else {
          Image(
            systemName: "gearshape.arrow.trianglehead.2.clockwise.rotate.90"
          )
          .font(.system(size: 100))
          .foregroundColor(.app)
        }

        Text("Installation de la liste de blocage")
          .font(.title2)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)

        if viewModel.blockerPhoneNumberBlocked == 0 {
          Text("Démarrage de l'installation de la liste de blocage")
            .font(.body)
            .padding(.top)
            .multilineTextAlignment(.center)
        } else {
          Text(
            "\(viewModel.blockerPhoneNumberBlocked) numéros bloqués sur \(viewModel.blockerPhoneNumberTotal)"
          )
          .font(.body)
          .multilineTextAlignment(.center)
        }

        ProgressView(
          value: Double(viewModel.blockerPhoneNumberBlocked),
          total: Double(viewModel.blockerPhoneNumberTotal)
        )
        .progressViewStyle(LinearProgressViewStyle(tint: Color("AppColor")))

        Text("Cette action peut prendre plusieurs minutes. Veuillez patienter.")
          .font(.footnote)
          .multilineTextAlignment(.center)

        Spacer()
      }
      .padding()
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Annuler") {
            viewModel.clearAction()
          }
        }
      }
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}
