import SwiftUI

/// Reusable row displaying an icon, title and description.
/// Used across multiple sheets (donation, business code, reset, etc.).
struct BenefitRow: View {
  let icon: String
  let title: String
  let description: String
  var iconColor: Color = .accent

  var body: some View {
    HStack(alignment: .center, spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 20))
        .foregroundColor(iconColor)
        .frame(width: 28, height: 24)

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .appFont(.subheadlineMedium)

        Text(description)
          .appFont(.caption)
          .foregroundColor(.secondary)
      }

      Spacer()
    }
  }
}

#Preview {
  VStack(spacing: 16) {
    BenefitRow(
      icon: "heart.fill",
      title: "Example",
      description: "A benefit row example"
    )
    BenefitRow(
      icon: "trash.fill",
      title: "Danger",
      description: "A red benefit row",
      iconColor: .red
    )
  }
  .padding()
}
