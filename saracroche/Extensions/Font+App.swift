import SwiftUI

/// Semantic font styles for the app using Atkinson Hyperlegible Next variable font.
enum AppFont {
  case largeTitle
  case title, titleBold
  case title2
  case title3, title3Bold
  case headline, headlineSemiBold
  case subheadline, subheadlineMedium, subheadlineSemiBold
  case body, bodyBold
  case callout
  case footnote
  case caption, captionSemiBold
  case caption2

  private static let regular = "AtkinsonHyperlegibleNextVFLight-Regular"
  private static let medium = "AtkinsonHyperlegibleNextVFLight-Medium"
  private static let semiBold = "AtkinsonHyperlegibleNextVFLight-SemiBold"
  private static let bold = "AtkinsonHyperlegibleNextVFLight-Bold"

  // (fontName, fontSize, lineHeight, textStyle)
  private var config: (String, CGFloat, CGFloat, Font.TextStyle) {
    switch self {
    case .largeTitle: return (Self.regular, 34, 41, .largeTitle)
    case .title: return (Self.regular, 28, 34, .title)
    case .titleBold: return (Self.bold, 28, 34, .title)
    case .title2: return (Self.regular, 22, 28, .title2)
    case .title3: return (Self.regular, 20, 25, .title3)
    case .title3Bold: return (Self.bold, 20, 25, .title3)
    case .headline: return (Self.bold, 18, 22, .headline)
    case .headlineSemiBold: return (Self.semiBold, 18, 22, .headline)
    case .subheadline: return (Self.regular, 15, 20, .subheadline)
    case .subheadlineMedium: return (Self.medium, 15, 20, .subheadline)
    case .subheadlineSemiBold: return (Self.semiBold, 15, 20, .subheadline)
    case .body: return (Self.regular, 16, 22, .body)
    case .bodyBold: return (Self.bold, 16, 22, .body)
    case .callout: return (Self.regular, 16, 21, .callout)
    case .footnote: return (Self.regular, 14, 18, .footnote)
    case .caption: return (Self.regular, 14, 16, .caption)
    case .captionSemiBold: return (Self.semiBold, 14, 16, .caption)
    case .caption2: return (Self.regular, 13, 15, .caption2)
    }
  }

  var font: Font {
    let (name, size, _, style) = config
    return .custom(name, size: size, relativeTo: style)
  }

  var lineSpacing: CGFloat {
    let (name, size, lineHeight, _) = config
    guard let uiFont = UIFont(name: name, size: size) else { return 0 }
    return max(0, lineHeight - uiFont.lineHeight)
  }
}

private struct AppFontModifier: ViewModifier {
  let appFont: AppFont

  func body(content: Content) -> some View {
    content
      .font(appFont.font)
      .lineSpacing(appFont.lineSpacing)
  }
}

extension View {
  func appFont(_ style: AppFont) -> some View {
    modifier(AppFontModifier(appFont: style))
  }
}
