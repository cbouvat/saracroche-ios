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
            // Warning
            VStack(spacing: 8) {
              Text(
                "These tools are reserved for testing and may cause instabilities in the application."
              )
              .font(.body)
              .multilineTextAlignment(.leading)
            }

            DebugButton(
              action: {
                reloadBackgroundService()
              },
              title: "Reload background service",
              background: .blue,
              foreground: .white
            )

            DebugButton(
              action: {
                downloadList()
              },
              title: "Download list",
              background: .blue,
              foreground: .white
            )

            DebugButton(
              action: {
                convertList()
              },
              title: "Update list",
              background: .blue,
              foreground: .white
            )
          }
        }
        .padding()
      }
      .padding()
      .toolbar {
        ToolbarItem {
          Button("Close") {
            dismiss()
          }
        }
      }
    }
    .alert("Operation Result", isPresented: $showAlert) {
      Button("OK") {}
    } message: {
      Text(alertMessage ?? "Operation completed")
    }
  }

  private func downloadList() {
    Task {
      do {
        let jsonResponse = try await ListAPIService().downloadFrenchList()
        DispatchQueue.main.async {
          alertMessage =
            "✅ Download successful: version \(jsonResponse["version"] as? String ?? "unknown")"
          showAlert = true
        }
      } catch {
        DispatchQueue.main.async {
          alertMessage = "❌ Download failed: \(error.localizedDescription)"
          showAlert = true
        }
      }
    }
  }

  private func reloadBackgroundService() {
    BackgroundService().forceBackgroundUpdate { success in
      DispatchQueue.main.async {
        alertMessage = success ? "✅ Service reloaded" : "❌ Reload failed"
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
            alertMessage = success ? "✅ Conversion successful" : "❌ Conversion failed"
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
