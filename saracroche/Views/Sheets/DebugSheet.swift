import SwiftUI

struct DebugSheet: View {
  @Environment(\.dismiss) private var dismiss
  @State private var alertMessage: String?
  @State private var showAlert = false

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          VStack(spacing: 16) {
            if #available(iOS 18.0, *) {
              Image(systemName: "hammer.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
                .symbolEffect(.wiggle.byLayer, options: .repeat(.periodic(delay: 1.0)))
            } else {
              Image(systemName: "hammer.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            }

            Text("Debug")
              .font(.title)
              .fontWeight(.bold)
              .multilineTextAlignment(.center)
          }

          VStack(alignment: .leading, spacing: 16) {
            // Avertissement
            VStack(spacing: 8) {
              Text(
                "Ces outils sont réservés aux tests et peuvent causer des instabilités dans l'application."
              )
              .font(.body)
              .multilineTextAlignment(.leading)
            }

            DebugButton(
              action: {
                downloadList()
              },
              title: "Télécharger la liste",
              background: .blue,
              foreground: .white
            )

            DebugButton(
              action: {
                reloadBackgroundService()
              },
              title: "Recharger le service d'arrière-plan",
              background: .blue,
              foreground: .white
            )

            DebugButton(
              action: {
                convertList()
              },
              title: "Convertir la liste",
              background: .blue,
              foreground: .white
            )
          }
        }
        .padding()
      }
      .padding()
    }
    .toolbar {
      ToolbarItem {
        Button("Fermer") {
          dismiss()
        }
      }
    }
    .alert("Résultat de l'opération", isPresented: $showAlert) {
      Button("OK") {}
    } message: {
      Text(alertMessage ?? "Opération terminée")
    }
  }

  private func downloadList() {
    Task {
      do {
        let jsonResponse = try await ListAPIService().downloadFrenchList()
        DispatchQueue.main.async {
          alertMessage =
            "✅ Téléchargement réussi: version \(jsonResponse["version"] as? String ?? "inconnue")"
          showAlert = true
        }
      } catch {
        DispatchQueue.main.async {
          alertMessage = "❌ Échec du téléchargement: \(error.localizedDescription)"
          showAlert = true
        }
      }
    }
  }

  private func reloadBackgroundService() {
    BackgroundService().forceBackgroundUpdate { success in
      DispatchQueue.main.async {
        alertMessage = success ? "✅ Service rechargé" : "❌ Échec du rechargement"
        showAlert = true
      }
    }
  }

  private func convertList() {
    Task {
      ListService().update(
        onProgress: {
          // Handle progress if needed
        },
        completion: { success in
          DispatchQueue.main.async {
            alertMessage = success ? "✅ Conversion réussie" : "❌ Échec de la conversion"
            showAlert = true
          }
        }
      )
    }
  }
}

struct DebugButton: View {
  let action: () -> Void
  let title: String
  let background: Color
  let foreground: Color

  var body: some View {
    Button(action: action) {
      Text(title)
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(background)
        .foregroundColor(foreground)
        .font(.body.weight(.bold))
        .cornerRadius(24)
    }
  }
}
