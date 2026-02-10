import SwiftUI

struct PatternRow: View {
  @ObservedObject var pattern: Pattern

  var body: some View {
    HStack(alignment: .center, spacing: 6) {
      Image(systemName: actionIcon)
        .font(.body)
        .foregroundColor(actionColor)

      VStack(alignment: .leading) {
        // Name and blocked numbers count
        HStack {
          if let name = pattern.name, !name.isEmpty {
            Text(name)
              .font(.caption.weight(.semibold))
              .lineLimit(1)
          }
          Spacer()
          Text("\(calculateBlockedCount(pattern)) numéros")
            .font(.caption2)
            .foregroundColor(.secondary)
        }

        // Pattern string
        Text(pattern.pattern ?? "")
          .font(.caption.monospaced())
          .foregroundColor(.secondary)
          .lineLimit(1)
      }
    }
    .accessibilityLabel(
      "Préfixe \(pattern.pattern ?? ""), action: \(actionLabel), \(calculateBlockedCount(pattern)) numéros bloqués"
    )
    .accessibilityHint("Balayez vers la gauche pour supprimer")
  }

  private var actionIcon: String {
    switch pattern.action {
    case "block": return "xmark.circle.fill"
    case "identify": return "info.circle.fill"
    default: return "questionmark.circle.fill"
    }
  }

  private var actionColor: Color {
    switch pattern.action {
    case "block": return .red
    case "identify": return .blue
    default: return .gray
    }
  }

  private var actionLabel: String {
    switch pattern.action {
    case "block": return "bloquer"
    case "identify": return "identifier"
    default: return "unknown"
    }
  }

  private func calculateBlockedCount(_ pattern: Pattern) -> Int64 {
    guard let patternString = pattern.pattern else { return 0 }
    return PhoneNumberHelpers.countPhoneNumbers(for: patternString)
  }
}
