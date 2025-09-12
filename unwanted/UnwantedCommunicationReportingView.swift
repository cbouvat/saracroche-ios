import Foundation
import SwiftUI
import UIKit

class UnwantedReportViewModel: ObservableObject {
  @Published var phoneNumber: String = ""
}

struct UnwantedCommunicationReportingView: View {
  @ObservedObject var viewModel: UnwantedReportViewModel

  init(viewModel: UnwantedReportViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        reportCardView
      }
      .padding()
    }
  }
  private var reportCardView: some View {
    VStack(alignment: .center, spacing: 20) {
      if #available(iOS 18.0, *) {
        Image(systemName: "exclamationmark.shield.fill")
          .font(.system(size: 60))
          .symbolEffect(.bounce.up.byLayer, options: .repeat(.periodic(delay: 2.0)))
          .foregroundColor(.orange)
      } else {
        Image(systemName: "exclamationmark.shield.fill")
          .font(.system(size: 60))
          .foregroundColor(.orange)
      }

      HStack {
        Text("Numéro à signaler")
          .font(.title3)
          .fontWeight(.bold)

        Text("Bientôt")
          .font(.caption)
          .fontWeight(.bold)
          .padding(.horizontal, 6)
          .padding(.vertical, 2)
          .background(Color.orange)
          .foregroundColor(.white)
          .clipShape(Capsule())
      }

      Text(viewModel.phoneNumber)
        .font(.title2)
        .fontWeight(.semibold)
        .multilineTextAlignment(.center)
        .padding(.horizontal)

      Text(
        "La fonctionnalité de signalement direct sera bientôt disponible. En attendant, ouvrez l'application Saracroche et saisissez manuellement ce numéro pour le signaler."
      )
      .font(.body)
      .foregroundColor(.secondary)
      .multilineTextAlignment(.center)
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.orange.opacity(0.1))
    )
  }
}

// Extension pour le style de bouton personnalisé (copié depuis CustomButtonStyle.swift)
extension ButtonStyle where Self == CustomButtonStyle {
  static func fullWidth(
    background: Color,
    foreground: Color
  ) -> CustomButtonStyle {
    return CustomButtonStyle(
      background: background,
      foreground: foreground
    )
  }
}

struct CustomButtonStyle: ButtonStyle {
  let background: Color
  let foreground: Color

  init(background: Color, foreground: Color) {
    self.background = background
    self.foreground = foreground
  }

  func makeBody(configuration: Configuration) -> some View {
    HStack {
      configuration.label
    }
    .frame(maxWidth: .infinity)
    .padding(12)
    .background(background)
    .foregroundColor(foreground)
    .font(.body.weight(.bold))
    .cornerRadius(24)
    .opacity(configuration.isPressed ? 0.8 : 1.0)
  }
}
