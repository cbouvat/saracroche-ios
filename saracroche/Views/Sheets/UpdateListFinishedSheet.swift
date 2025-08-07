import SwiftUI

struct UpdateListFinishedSheet: View {
  @ObservedObject var viewModel: BlockerViewModel

  var body: some View {
    NavigationView {
      VStack(alignment: .center, spacing: 16) {
        Spacer()

        Text("Terminé")
          .font(.title)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)

        if #available(iOS 18.0, *) {
          Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 100))
            .symbolEffect(
              .wiggle.counterClockwise.byLayer,
              options: .repeat(.periodic(delay: 0.5))
            )
            .foregroundColor(Color.green)
        } else {
          Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 100))
            .foregroundColor(Color.green)
        }

        Text("La liste de blocage a été installée avec succès")
          .font(.title2)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)

        Spacer()

        Button("Fermer") {
          viewModel.clearAction()
        }
        .buttonStyle(
          .fullWidth(background: Color("AppColor"), foreground: .black)
        )
      }
      .padding()
    }
  }
}
