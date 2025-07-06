import SwiftUI

struct ReportNavigationView: View {
  @StateObject private var viewModel = ReportViewModel()
  @FocusState private var isPhoneFieldFocused: Bool

  var body: some View {
    NavigationView {
      ScrollView {
        VStack {
          GroupBox(
            label:
              Label(
                "Signaler un numéro (Beta)",
                systemImage: "phone.fill.badge.plus"
              )
          ) {
            VStack(alignment: .leading) {
              Text(
                "Dans le but d'améliorer le blocage des appels et SMS indésirables, il est possible de signaler les numéros qui ne sont pas bloqués par l'application. Cela contribuera à établir une liste de blocage et à rendre l'application plus efficace."
              )
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)

              Text(
                "Saisissez le numéro de téléphone au format E.164 (ex: +33612345678)"
              )
              .fontWeight(.semibold)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)

              TextField("Numéro au format E.164", text: $viewModel.phoneNumber)
                .keyboardType(.phonePad)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .padding(12)
                .font(.title3)
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .overlay(
                  RoundedRectangle(cornerRadius: 10)
                    .stroke(
                      isPhoneFieldFocused
                        ? Color("AppColor") : Color(.systemGray4),
                      lineWidth: 2
                    )
                )
                .focused($isPhoneFieldFocused)
                .disabled(viewModel.isLoading)
                .onChange(of: viewModel.phoneNumber) { newValue in
                  viewModel.phoneNumber = viewModel.formatPhoneNumber(newValue)
                }
                .toolbar {
                  ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Terminé") {
                      isPhoneFieldFocused = false
                    }
                    .fontWeight(.semibold)
                  }
                }
                .accessibilityLabel("Champ de saisie du numéro de téléphone")
                .accessibilityHint(
                  "Saisissez le numéro au format E.164, par exemple +33612345678"
                )

              Button {
                Task {
                  await viewModel.submitPhoneNumber()
                }
              } label: {
                HStack {
                  Image(systemName: "paperplane.fill")
                  Text("Envoyer")
                }
              }
              .buttonStyle(
                .fullWidth(
                  background: Color("AppColor"),
                  foreground: .black,
                  isLoading: viewModel.isLoading
                )
              )
              .padding(.top, 8)
              .accessibilityLabel("Bouton d'envoi du signalement")
            }
          }
          .background(Color(.systemGray6))
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

          DisclosureGroup(
            content: {
              Text(
                "Le service 33700 est un service gratuit mis en place par les opérateurs de téléphonie mobile pour signaler les appels et SMS indésirables. Il permet aux utilisateurs de signaler les numéros directement auprès de leur opérateur, qui peut ensuite prendre des mesures pour bloquer ces numéros."
              )
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)

              Button {
                if let url = URL(
                  string:
                    "https://www.33700.fr/"
                ) {
                  UIApplication.shared.open(url)
                }
              } label: {
                HStack {
                  Image(systemName: "flag.fill")
                  Text("Accéder au service 33700")
                }
              }
              .buttonStyle(
                .fullWidth(background: Color("AppColor"), foreground: .black)
              )
              .padding(.top)
            },
            label: {
              Label(
                "Service 33700",
                systemImage: "flag.fill"
              )
              .font(.headline)
            }
          )
          .padding()
          .background(Color(.systemGray6))
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

          DisclosureGroup(
            content: {
              Text(
                "Pour connaître l'opérateur d'un numéro, vous pouvez utiliser le service gratuit de l'ARCEP. Le service est accessible via le lien ci-dessous. Il vous suffit de saisir le numéro de téléphone pour obtenir des informations sur l'opérateur."
              )
              .font(.body)
              .padding(.top, 4)
              .frame(maxWidth: .infinity, alignment: .leading)

              Button {
                if let url = URL(
                  string:
                    "https://www.arcep.fr/mes-demarches-et-services/entreprises/fiches-pratiques/base-numerotation.html"
                ) {
                  UIApplication.shared.open(url)
                }
              } label: {
                HStack {
                  Image(systemName: "person.fill.questionmark")
                  Text("Connaitre l'opérateur")
                }
              }
              .buttonStyle(
                .fullWidth(background: Color("AppColor"), foreground: .black)
              )
              .padding(.top)
            },
            label: {
              Label(
                "Connaitre l'opérateur du numéro",
                systemImage: "person.fill.questionmark"
              )
              .font(.headline)
            }
          )
          .padding()
          .background(Color(.systemGray6))
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(.horizontal)
      }
      .navigationTitle("Signaler")
      .alert(viewModel.alertType.title, isPresented: $viewModel.showAlert) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(viewModel.alertMessage)
      }
      .onTapGesture {
        isPhoneFieldFocused = false
      }
    }
  }
}
