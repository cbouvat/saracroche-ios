import SwiftUI

struct CustomButtonStyle: ButtonStyle {
  let background: Color
  let foreground: Color
  let isLoading: Bool

  init(background: Color, foreground: Color, isLoading: Bool = false) {
    self.background = background
    self.foreground = foreground
    self.isLoading = isLoading
  }

  func makeBody(configuration: Configuration) -> some View {
    HStack {
      if isLoading {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: foreground))
          .scaleEffect(0.8)
      } else {
        configuration.label
      }
    }
    .frame(maxWidth: .infinity)
    .frame(height: 48)
    .background(background)
    .foregroundColor(foreground)
    .font(.body.weight(.bold))
    .cornerRadius(100)
    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    .opacity(configuration.isPressed ? 0.8 : 1.0)
    .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
  }
}

extension ButtonStyle where Self == CustomButtonStyle {
  static func fullWidth(
    background: Color,
    foreground: Color,
    isLoading: Bool = false
  ) -> CustomButtonStyle {
    return CustomButtonStyle(
      background: background,
      foreground: foreground,
      isLoading: isLoading
    )
  }
}
