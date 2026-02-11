import SwiftUI

struct NumbersNavigationView: View {
  @StateObject private var viewModel = NumbersViewModel()
  @State private var showAddPatternSheet = false

  var body: some View {
    NavigationView {
      Form {
        // SECTION 1: Liste
        Section {
          if viewModel.apiPatterns.isEmpty {
            VStack {
              Text("La liste sera téléchargée automatiquement. Veuillez patienter.")
                .appFont(.caption)
                .foregroundColor(.secondary)
            }
          } else {
            NavigationLink {
              APIPatternListView(patterns: viewModel.apiPatterns)
            } label: {
              VStack(alignment: .leading, spacing: 12) {
                // List name
                Text(viewModel.frenchListName)
                  .appFont(.headline)
                  .lineLimit(2)

                // Version
                HStack(spacing: 4) {
                  Image(systemName: "tag.circle.fill")
                    .appFont(.body)
                    .foregroundColor(.primary)
                  Text("Version " + viewModel.frenchListVersion)
                    .appFont(.caption)
                    .foregroundColor(.secondary)
                }

                // Blocked numbers count
                HStack(spacing: 4) {
                  Image(systemName: "number.circle.fill")
                    .appFont(.body)
                    .foregroundColor(.primary)
                  Text("\(viewModel.frenchListBlockedCount) numéros bloqués")
                    .appFont(.caption)
                    .foregroundColor(.secondary)
                }
              }
            }
          }
        } header: {
          Text("Liste")
            .appFont(.subheadlineSemiBold)
        } footer: {
          Text(
            "Liste téléchargée automatiquement et mise à jour régulièrement."
          )
          .appFont(.caption)
        }

        // SECTION 2: Mes préfixes
        Section {
          if viewModel.userPatterns.isEmpty {
            VStack {
              Text("Aucun préfixe personnalisé n'a été ajouté encore.")
                .appFont(.caption)
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          } else {
            ForEach(viewModel.userPatterns) { pattern in
              PatternRow(pattern: pattern)
                .foregroundColor(.primary)
                .swipeActions(edge: .trailing) {
                  Button(role: .destructive) {
                    Task {
                      await viewModel.deletePattern(pattern)
                    }
                  } label: {
                    Label("Supprimer", systemImage: "trash.fill")
                  }
                  .tint(.red)
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
          Text("Mes préfixes")
            .appFont(.subheadlineSemiBold)
        } footer: {
          Text(
            "Ajoutez vos propres préfixes pour les bloquer les identifier."
          )
          .appFont(.caption)
        }
      }
      .navigationTitle("Numéros")
      .sheet(isPresented: $showAddPatternSheet) {
        AddPatternSheet(viewModel: viewModel, isPresented: $showAddPatternSheet)
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
