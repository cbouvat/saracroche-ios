import SwiftUI

struct DebugSheet: View {
  @Environment(\.dismiss) private var dismiss

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
              Text("Ces outils sont réservés aux tests et peuvent causer des instabilités dans l'application.")
              .font(.body)
              .multilineTextAlignment(.leading)
            }
        
            DebugButton(
              action: { /* Debug action */ },
              title: "1. performBackgroundUpdate",
              background: .blue,
              foreground: .white
            )

            DebugButton(
              action: { /* Debug action */ },
              title: "2. performUpdate",
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
