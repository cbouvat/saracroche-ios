import SwiftUI

struct HelpSheet: View {
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
              Text("Quels numéros sont bloqués ?")
                .font(.title3)
                .fontWeight(.semibold)

              Text(
                """
                Plus de **16,7 millions de numéros** sont bloqués, dont **12,5 millions** correspondent aux préfixes réservés au démarchage téléphonique, communiqués par l’ARCEP : 0162, 0163, 0270, 0271, 0377, 0378, 0424, 0425, 0568, 0569, 0948, 0949, ainsi que ceux allant de 09475 à 09479.

                **En plus**, elle bloque aussi des numéros de téléphone des opérateurs : Manifone, DVS Connect, Ze Telecom, Oxilog, BJT Partners, Ubicentrex, Destiny, Kav El International, Spartel Services et Comunik CRM. Ce qui représente plus de **4,2 millions de numéros** supplémentaires dont des numéros de **téléphone mobiles**.

                Ces numéros sont mis à jour régulièrement pour s'assurer que l'application reste efficace contre les appels indésirables. Les signalements permettent d'améliorer la liste de blocage en ajoutant de nouveaux opérateurs.
                """
              )
              .font(.body)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
            )

            VStack(alignment: .leading, spacing: 16) {
              Text("Pourquoi les numéros bloqués apparaissent-ils dans l'historique des appels ?")
                .font(.title3)
                .fontWeight(.semibold)

              Text(
                """
                Depuis iOS 18, les numéros bloqués par les extensions de blocage d'appels sont visibles dans l'historique des appels. Cela permet de garder une trace des appels bloqués, mais ne signifie pas que l'appel a été reçu ou que vous devez y répondre.
                """
              )
              .font(.body)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
            )

            VStack(alignment: .leading, spacing: 8) {
              Text("D'autres questions ?")
                .font(.headline)
                .fontWeight(.semibold)

              Text(
                "Si vous avez d'autres questions ou besoin d'aide, n'hésitez pas à vous rendre sur la page d'aide ou envoyer un e-mail."
              )
              .font(.body)
              .foregroundColor(.secondary)
            }
            .padding()
          }
        }
        .padding()
      }
      .navigationTitle("En savoir plus sur le blocage")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Fermer") {
            dismiss()
          }
        }
      }
    }
  }
}

#Preview {
  HelpSheet()
}
