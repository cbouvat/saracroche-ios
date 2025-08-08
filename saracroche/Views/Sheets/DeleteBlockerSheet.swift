import SwiftUI

struct DeleteBlockerSheet: View {
  @ObservedObject var viewModel: BlockerViewModel

  var body: some View {
    NavigationView {
      VStack(alignment: .center, spacing: 16) {
        Spacer()

        Text("Gardez l'application ouverte")
          .font(.title)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)

        if #available(iOS 18.0, *) {
          Image(systemName: "trash.fill")
            .font(.system(size: 100))
            .symbolEffect(
              .wiggle.clockwise.byLayer,
              options: .repeat(.periodic(delay: 1.0))
            )
            .foregroundColor(.red)
        } else {
          Image(systemName: "trash.fill")
            .font(.system(size: 100))
            .foregroundColor(.red)
        }

        Text("Suppression de la liste de blocage")
          .font(.title2)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)

        Text(
          "Cette action peut prendre plusieurs secondes. Veuillez patienter."
        )
        .font(.footnote)
        .multilineTextAlignment(.center)

        Spacer()
      }
      .padding()
    }
  }
}

#Preview {
  DeleteBlockerSheet(viewModel: BlockerViewModel())
}
