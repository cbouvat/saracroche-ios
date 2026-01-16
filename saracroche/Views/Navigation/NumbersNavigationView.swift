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
            VStack(alignment: .leading, spacing: 12) {
              // List name with icon
              HStack {
                Text(viewModel.frenchListName)
                  .font(.headline)
                  .lineLimit(2)
              }

              // Version
              Label("Version " + viewModel.frenchListVersion, systemImage: "number.circle.fill")
                .font(.caption)
                .foregroundColor(.secondary)

              // Date
              if let date = viewModel.frenchListDate {
                Label(
                  "Téléchargement le " + date.formatted(date: .abbreviated, time: .omitted),
                  systemImage: "calendar.circle.fill"
                )
                .font(.caption)
                .foregroundColor(.secondary)
              }

              // Blocked numbers count
              Label(
                "\(viewModel.frenchListBlockedCount) numéros bloqués",
                systemImage: "shield.fill"
              )
              .font(.caption)
              .foregroundColor(.secondary)

              // Navigation to full prefix list
              NavigationLink {
                APIPatternListView(patterns: viewModel.apiPatterns)
              } label: {
                HStack {
                  Image(systemName: "list.bullet")
                  Text("Voir tous les préfixes")
                }
                .font(.body)
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
                  viewModel.deletePattern(pattern)
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
    }
  }
}

#Preview {
  NumbersNavigationView()
}
