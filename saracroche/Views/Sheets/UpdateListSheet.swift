import SwiftUI

struct UpdateListSheet: View {
  @ObservedObject var viewModel: BlockerViewModel

  var body: some View {
    NavigationView {
      VStack(alignment: .center, spacing: 16) {
        Spacer()

        if #available(iOS 18.0, *) {
          Image(
            systemName: "gearshape.arrow.trianglehead.2.clockwise.rotate.90"
          )
          .font(.system(size: 100))
          .symbolEffect(
            .rotate.clockwise.byLayer,
            options: .repeat(.periodic(delay: 3.0))
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
          .font(.title)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)

        if viewModel.blockerPhoneNumberBlocked == 0 {
          Text("Suppression de l'ancienne liste de blocage")
            .font(.body)
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

        Spacer()

        Text("Gardez l'application ouverte")
          .font(.title3)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)

        Text("Cette action peut prendre plusieurs minutes.\nVeuillez patienter.")
          .font(.footnote)
          .multilineTextAlignment(.center)
      }
      .padding()
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

#Preview {
  UpdateListSheet(viewModel: BlockerViewModel())
}
