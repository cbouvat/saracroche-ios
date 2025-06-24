import SwiftUI

struct BlockerStatusSheet: View {
  @ObservedObject var viewModel: SaracrocheViewModel

  var body: some View {
    VStack(alignment: .center) {
      if viewModel.blockerActionState == .update {
        Text("Garder l’application ouverte")
          .font(.title)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)

        if #available(iOS 18.0, *) {
          Image(
            systemName: "gearshape.arrow.trianglehead.2.clockwise.rotate.90"
          )
          .font(.system(size: 100))
          .symbolEffect(
            .rotate.byLayer,
            options: .repeat(.periodic(delay: 0.5))
          )
          .foregroundColor(Color("AppColor"))
          .padding(.vertical)
        } else {
          Image(
            systemName: "gearshape.arrow.trianglehead.2.clockwise.rotate.90"
          )
          .font(.system(size: 100))
          .foregroundColor(Color("AppColor"))
          .padding(.vertical)
        }

        Text("Installation de la liste de blocage")
          .font(.title2)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)

        if viewModel.blockerPhoneNumberBlocked == 0 {
          Text("Démarrage de l’installation de la liste de blocage")
            .font(.body)
            .padding(.top)
            .multilineTextAlignment(.center)
        } else {
          Text(
            "\(viewModel.blockerPhoneNumberBlocked) numéros bloqués sur \(viewModel.blockerPhoneNumberTotal)"
          )
          .font(.body)
          .padding(.top)
          .multilineTextAlignment(.center)
        }

        ProgressView(
          value: Double(viewModel.blockerPhoneNumberBlocked),
          total: Double(viewModel.blockerPhoneNumberTotal)
        )
        .progressViewStyle(LinearProgressViewStyle(tint: Color("AppColor")))
        .padding(.top)

        Text("Cette action peut prendre plusieurs minutes. Veuillez patienter.")
          .font(.footnote)
          .padding(.top)
          .multilineTextAlignment(.center)

        Button("Annuler") {
          viewModel.cancelUpdateBlockerAction()
        }
        .buttonStyle(.fullWidth(background: Color.gray, foreground: .white))
        .padding(.top)

      } else if viewModel.blockerActionState == .delete {
        Text("Gardez l’application ouverte")
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
            .padding(.vertical)
        } else {
          Image(systemName: "trash.fill")
            .font(.system(size: 100))
            .foregroundColor(.red)
            .padding(.vertical)
        }

        Text("Suppression de la liste de blocage")
          .font(.title2)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)

        Text(
          "Cette action peut prendre plusieurs secondes. Veuillez patienter."
        )
        .font(.footnote)
        .padding(.top)
        .multilineTextAlignment(.center)

        Button("Annuler") {
          viewModel.cancelRemoveBlockerAction()
        }
        .buttonStyle(.fullWidth(background: Color.gray, foreground: .white))
        .padding(.top)
        .transition(.opacity)
      } else if viewModel.blockerActionState == .finish {
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
            .padding(.vertical)
        } else {
          Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 100))
            .foregroundColor(Color.green)
            .padding(.vertical)
        }

        Text("La liste de blocage a été installée avec succès")
          .font(.title2)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)

        Button("Fermer") {
          viewModel.markBlockerActionFinished()
        }
        .buttonStyle(
          .fullWidth(background: Color("AppColor"), foreground: .black)
        )
        .padding(.top)
      }
    }
    .padding()
  }
}
