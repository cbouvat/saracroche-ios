import SwiftUI

struct CustomButtonStyle: ButtonStyle {
  let background: Color
  let foreground: Color

  init(background: Color, foreground: Color) {
    self.background = background
    self.foreground = foreground
  }

  @Environment(\.isEnabled) private var isEnabled

  func makeBody(configuration: Configuration) -> some View {
    HStack {
      configuration.label
    }
    .frame(maxWidth: .infinity)
    .padding(12)
    .background(isEnabled ? background : Color(.systemGray4))
    .foregroundColor(isEnabled ? foreground : Color(.systemGray))
    .appFont(.bodyBold)
    .cornerRadius(24)
    .opacity(configuration.isPressed ? 0.8 : 1.0)
  }
}

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
