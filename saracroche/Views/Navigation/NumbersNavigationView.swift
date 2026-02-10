import SwiftUI

struct NumbersNavigationView: View {
  @StateObject private var viewModel = NumbersViewModel()
  @State private var showAddPatternSheet = false
  @State private var editingPattern: Pattern?

  var body: some View {
    NavigationView {
      Form {
        // SECTION 1: Liste
        Section {
          if viewModel.apiPatterns.isEmpty {
            VStack {
              Text("La liste sera téléchargée automatiquement. Veuillez patienter.")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          } else {
            NavigationLink {
              APIPatternListView(patterns: viewModel.apiPatterns)
            } label: {
              VStack(alignment: .leading, spacing: 12) {
                // List name
                Text(viewModel.frenchListName)
                  .font(.headline)
                  .lineLimit(2)

                // Version
                HStack(spacing: 4) {
                  Image(systemName: "tag.circle.fill")
                  Text("Version " + viewModel.frenchListVersion)
                }
                .font(.caption)
                .foregroundColor(.secondary)

                // Blocked numbers count
                HStack(spacing: 4) {
                  Image(systemName: "number.circle.fill")
                  Text("\(viewModel.frenchListBlockedCount) numéros bloqués")
                }
                .font(.caption)
                .foregroundColor(.secondary)
              }
            }
          }
        } header: {
          Text("Liste")
        } footer: {
          Text(
            "Liste téléchargée automatiquement et mise à jour régulièrement."
          )
        }

        // SECTION 2: Mes préfixes et numéros
        Section {
          if viewModel.userPatterns.isEmpty {
            VStack {
              Text("Aucun préfixe ou numéro personnalisé n'a été ajouté encore.")
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          } else {
            ForEach(viewModel.userPatterns) { pattern in
              Button {
                editingPattern = pattern
              } label: {
                PatternRow(pattern: pattern)
              }
              .foregroundColor(.primary)
              .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                  Task {
                    await viewModel.deletePattern(pattern)
                  }
                } label: {
                  Label("Supprimer", systemImage: "trash.fill")
                }
              }
            }
          }

          // Add new prefix button
          Button {
            showAddPatternSheet = true
          } label: {
            HStack {
              Image(systemName: "plus.circle.fill")
              Text("Ajouter un préfixe")
            }
          }
          .buttonStyle(.fullWidth(background: Color("AppColor"), foreground: .black))
        } header: {
          Text("Mes préfixes et numéros")
        } footer: {
          Text(
            "Ajoutez vos propres préfixes ou numéros pour les bloquer les identifier."
          )
        }
      }
      .navigationTitle("Numéros")
      .sheet(isPresented: $showAddPatternSheet) {
        AddPatternSheet(viewModel: viewModel, isPresented: $showAddPatternSheet)
      }
      .sheet(item: $editingPattern) { pattern in
        EditPatternSheet(
          viewModel: viewModel, isPresented: $editingPattern, pattern: pattern
        )
      }
      .alert("Erreur", isPresented: $viewModel.showAlert) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(viewModel.alertMessage)
      }
      .onAppear {
        Task {
          await viewModel.loadData()
        }
      }
    }
  }
}

#Preview {
  NumbersNavigationView()
}
