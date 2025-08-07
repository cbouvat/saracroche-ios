# Copilot Instructions for Saracroche iOS

## Project Context
Saracroche is an iOS call blocking app using CallKit with:
- SwiftUI main app
- Call Directory extension for call blocking
- App Groups for data sharing between app and extension

## Code Standards

KISS (Keep It Simple, Stupid) principles are followed to ensure clarity and maintainability.

### Swift & SwiftUI
- Use Swift 6 with latest features
- Target iOS 15 and above
- Use SwiftUI for all UI components
- SwiftUI exclusively for UI
- 2 spaces indentation (no tabs)
- Max 120 characters per line when possible
- English comments for complex logic

### Architecture
- MVVM pattern
- UserDefaults with suiteName for App Groups data sharing
