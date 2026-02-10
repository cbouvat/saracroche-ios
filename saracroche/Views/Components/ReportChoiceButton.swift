import SwiftUI

struct ReportChoiceButton: View {
  let title: String
  let description: String
  let icon: String
  let isSelected: Bool
  let color: Color
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 12) {
        Image(systemName: icon)
          .font(.system(size: 18))
          .foregroundColor(color)
          .frame(width: 24)

        VStack(alignment: .leading, spacing: 2) {
          Text(title)
            .appFont(.subheadlineSemiBold)
            .foregroundColor(.primary)
          Text(description)
            .appFont(.caption)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        if isSelected {
          Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 18))
            .foregroundColor(color)
        }
      }
      .padding(12)
      .background(isSelected ? color.opacity(0.15) : Color(.systemBackground))
      .cornerRadius(12)
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(isSelected ? color : Color(.systemGray4), lineWidth: 1)
      )
    }
    .buttonStyle(.plain)
    .accessibilityLabel(title)
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }
}
