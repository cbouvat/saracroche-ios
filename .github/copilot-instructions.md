# Copilot Instructions for Saracroche

## Project Context
Saracroche is an iOS call blocking app using CallKit with:
- SwiftUI main app
- Call Directory extension for call blocking
- App Groups for data sharing between app and extension

## Code Standards

### Swift & SwiftUI
- Use Swift 6 with latest features
- SwiftUI exclusively for UI
- 2 spaces indentation (no tabs)
- Max 80 characters per line when possible
- English comments for complex logic

### Architecture
- MVVM pattern with `@StateObject` and `@ObservableObject`
- Combine for state management
- UserDefaults with suiteName for App Groups data sharing
- SwiftUI navigation (NavigationView, TabView)

### Naming Conventions
- Structs/Classes: PascalCase (e.g., `SaracrocheViewModel`)
- Variables/Functions: camelCase (e.g., `blockerExtensionStatus`)
- Constants: camelCase (e.g., `sharedUserDefaults`)
- Enums: PascalCase with camelCase cases

### Key Practices

#### SwiftUI
- Use `@StateObject` for ViewModels
- Prefer `@Published` for observable properties
- Create custom ButtonStyles for reusability
- Use extensions to organize code

#### CallKit / Call Directory
- Handle incremental vs complete contexts
- Use shared UserDefaults for communication
- Implement robust error handling
- Log important actions for debugging

#### Data Management
- Use JSON for structured data (prefixes.json)
- Validate data before processing
- Handle errors gracefully
- Persist critical states

### Privacy & Security
- No call data collection
- All data stays on device
- Request only necessary permissions

### Performance
- Load number lists asynchronously
- Avoid expensive operations on main thread
- Optimize UI updates
- Manage memory efficiently for large lists

### Avoid
- UIKit in new features
- Business logic in views
- Direct file access without validation
- Blocking synchronous operations

### Code Examples

#### ViewModel Pattern
```swift
class SaracrocheViewModel: ObservableObject {
  @Published var blockerExtensionStatus: BlockerExtensionStatus = .unknown
  
  private let sharedUserDefaults = UserDefaults(
    suiteName: "group.com.cbouvat.saracroche"
  )
}
```

#### Button Style
```swift
struct FullWidthButtonStyle: ButtonStyle {
  var backgroundColor: Color
  var foregroundColor: Color
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding()
      .bold()
      .frame(maxWidth: .infinity)
      .background(backgroundColor)
      .foregroundColor(foregroundColor)
      .cornerRadius(16)
      .opacity(configuration.isPressed ? 0.8 : 1.0)
  }
}
```
