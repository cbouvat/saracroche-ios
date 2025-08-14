import SwiftUI

struct ReportNavigationView: View {
  @StateObject private var viewModel = ReportViewModel()
  @FocusState private var isPhoneFieldFocused: Bool

  var body: some View {
    NavigationView {
      Form {
        Section {
          VStack(spacing: 16) {
            Text(
              "Saisissez le numéro de téléphone au format international, par exemple +33612345678 pour la France."
            )
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)

            TextField("+33612345678", text: $viewModel.phoneNumber)
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
                    lineWidth: 1
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
                  .font(.body.weight(.bold))
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
            .accessibilityLabel("Bouton d'envoi du signalement")
          }
          .padding(.vertical, 6)
        } header: {
          Text("Signaler un numéro")
        } footer: {
          Text(
            "Signaler un numéro, contribue à améliorer la liste de "
              + "blocage et à rendre l'application plus efficace."
          )
        }
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

#Preview {
  ReportNavigationView()
}
