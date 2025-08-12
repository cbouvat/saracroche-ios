import SwiftUI

struct DeleteBlockerSheet: View {
  @ObservedObject var viewModel: BlockerViewModel

  var body: some View {
    NavigationView {
      VStack(alignment: .center, spacing: 16) {
        Spacer()

        if #available(iOS 18.0, *) {
          Image(systemName: "trash.fill")
            .font(.system(size: 80))
            .symbolEffect(
              .wiggle.clockwise.byLayer,
              options: .repeat(.periodic(delay: 1.0))
            )
            .foregroundColor(.red)
        } else {
          Image(systemName: "trash.fill")
            .font(.system(size: 80))
            .foregroundColor(.red)
        }

        Text("Suppression de la liste de blocage")
          .font(.title)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)

        Spacer()

        Text("Gardez l'application ouverte")
          .font(.title3)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)

        Text(
          "Cette action peut prendre plusieurs secondes.\nVeuillez patienter."
        )
        .font(.footnote)
        .multilineTextAlignment(.center)

      }
      .padding()
    }
  }
}

#Preview {
  DeleteBlockerSheet(viewModel: BlockerViewModel())
}
