import SwiftUI

struct DebugSheet: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var backgroundService = BackgroundService()
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
                downloadBlockList()
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
                convertBlockList()
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

  private func downloadBlockList() {
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
    backgroundService.forceBackgroundUpdate { success in
      DispatchQueue.main.async {
        alertMessage = success ? "✅ Service rechargé" : "❌ Échec du rechargement"
        showAlert = true
      }
    }
  }

  private func convertBlockList() {
    Task {
      do {
        let jsonResponse = try await ListAPIService().downloadFrenchList()
        _ = try ListConverterService().convertBlockListToCoreData(
          jsonResponse: jsonResponse)
        DispatchQueue.main.async {
          alertMessage = "✅ Conversion réussie"
          showAlert = true
        }
      } catch {
        DispatchQueue.main.async {
          alertMessage = "❌ Échec de la conversion: \(error.localizedDescription)"
          showAlert = true
        }
      }
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
