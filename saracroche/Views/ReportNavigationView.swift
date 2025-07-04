import SwiftUI

struct ReportNavigationView: View {
  @State private var phoneNumber: String = ""
  @State private var showAlert = false
  @State private var alertMessage = ""
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

              TextField("Numéro au format E.164", text: $phoneNumber)
                .keyboardType(.phonePad)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .padding(8)
                .font(.title3)
                .background(Color(.white))
                .cornerRadius(8)
                .focused($isPhoneFieldFocused)
                .toolbar {
                  ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Terminé") {
                      isPhoneFieldFocused = false
                    }
                    .fontWeight(.semibold)
                  }
                }
              Button {
                submitPhoneNumber()
              } label: {
                HStack {
                  Image(systemName: "paperplane.fill")
                  Text("Envoyer")
                }
              }
              .buttonStyle(
                .fullWidth(background: Color("AppColor"), foreground: .black)
              )
              .padding(.top, 4)
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
      .alert(isPresented: $showAlert) {
        Alert(
          title: Text("Information"),
          message: Text(alertMessage),
          dismissButton: .default(Text("OK"))
        )
      }
      .onTapGesture {
        isPhoneFieldFocused = false
      }
    }
  }

  private func submitPhoneNumber() {
    let e164Regex = "^\\+[1-9]\\d{7,14}$"
    if !phoneNumber.matches(e164Regex) {
      alertMessage = "Le numéro doit être au format E.164 (ex: +33612345678)."
      showAlert = true
      return
    }
    guard let url = URL(string: Config.reportServerURL) else {
      alertMessage = "URL invalide."
      showAlert = true
      return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    let appVersion =
      Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
      ?? "unknown"
    let json: [String: String] = [
      "number": phoneNumber,
      "deviceId": deviceId,
      "appVersion": appVersion,
    ]
    do {
      let jsonData = try JSONSerialization.data(
        withJSONObject: json,
        options: []
      )
      request.httpBody = jsonData
    } catch {
      alertMessage = "Erreur lors de la création du JSON."
      showAlert = true
      return
    }
    let task = URLSession.shared.dataTask(with: request) {
      data,
      response,
      error in
      DispatchQueue.main.async {
        if let error = error {
          alertMessage =
            "Erreur lors de l'envoi : \(error.localizedDescription)"
        } else {
          alertMessage =
            "Numéro signalé avec succès ! Merci de votre contribution 😘."
          phoneNumber = ""
        }
        showAlert = true
      }
    }
    task.resume()
  }
}

extension String {
  fileprivate func matches(_ regex: String) -> Bool {
    return self.range(of: regex, options: .regularExpression) != nil
  }
}
