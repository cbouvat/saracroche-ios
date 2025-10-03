# Agents Instructions for Saracroche iOS

## Project Overview
Saracroche is an iOS call blocking app built with CallKit, comprising:
- **Main app** (`saracroche/`): SwiftUI-based user interface
- **Call Directory extension** (`blocker/`): Manages call blocking using CallKit
- **Unwanted extension** (`unwanted/`): Handles reporting of unwanted calls
- **Filter extension** (`filter/`): SMS filtering capabilities
- **Shared data**: App Groups (`group.com.saracroche`) for data sharing between app and extensions

### Key Features
- Block spam and unwanted calls
- Report unwanted communications
- Filter SMS messages
- Background updates of block lists
- Call reporting

## Code Standards

### Core Principles
**KISS (Keep It Simple, Stupid)**: Prioritize clarity and maintainability over cleverness. Write code that is easy to understand and modify.

### Swift & SwiftUI
- **Language**: Swift 6 with latest features and strict concurrency
- **Target**: iOS 15 and above
- **UI Framework**: SwiftUI exclusively for all user interfaces
- **Comments**: Write all comments in English
- **Naming**: Use clear, descriptive names following Swift conventions
  - Types: `PascalCase` (e.g., `BlockerViewModel`)
  - Variables/functions: `camelCase` (e.g., `updateBlockList`)
  - Constants: `camelCase` (e.g., `maxRetryCount`)

### Architecture
- **Pattern**: MVVM (Model-View-ViewModel)
  - Models in `Models/`
  - Views in `Views/`
  - ViewModels in `ViewModels/`
- **Services**: Business logic in `Services/` (e.g., `CallDirectoryService`, `NetworkService`)
- **Data Persistence**: 
  - `UserDefaults` with suiteName for App Groups sharing
  - Use `SharedUserDefaultsService` for cross-extension data access
- **Extensions**: Helper methods in `Extensions/`

### File Organization
```
saracroche/
├── App.swift                      # App entry point
├── Models/                        # Data models
├── Views/                         # SwiftUI views
│   ├── Components/                # Reusable UI components
│   └── Sheets/                    # Modal sheets
├── ViewModels/                    # View models (MVVM)
├── Services/                      # Business logic & APIs
├── Extensions/                    # Swift extensions
└── Utils/                         # Constants & utilities
```

## CallKit & Extensions Best Practices

### Call Directory Extension
- Call blocking happens in `CallDirectoryHandler.swift`
- Phone numbers must be in E.164 format and added in ascending order

### App Groups
- Suite name: `group.com.saracroche`
- Always use `SharedUserDefaultsService` for cross-extension data access
- Ensure data is synchronized before reloading extensions

### Background Updates
- Use `BackgroundUpdateService` for periodic updates
- Request appropriate permissions for background execution
- Handle network failures and retry logic

## Development Workflow

### Before Making Changes
1. **Understand the context**: Read related files and understand the existing architecture
2. **Check dependencies**: Identify affected services, models, and views
3. **Plan your approach**: Break down complex tasks into smaller steps

### When Implementing Features
1. **Model first**: Define or update data models in `Models/`
2. **Service layer**: Implement business logic in `Services/`
3. **ViewModel**: Create or update ViewModels in `ViewModels/`
4. **View**: Build SwiftUI views in `Views/`
5. **Integration**: Ensure proper data flow between layers

### When Fixing Bugs
1. **Reproduce**: Understand the issue and its root cause
2. **Isolate**: Identify the affected component or service
3. **Fix**: Apply the minimal change that resolves the issue
4. **Verify**: Ensure the fix doesn't introduce new issues

## Quality Gates

### Before Committing
- [ ] Code compiles without errors or warnings
- [ ] Follows Swift naming conventions and project structure
- [ ] MVVM pattern is respected
- [ ] No hardcoded values (use `AppConstants.swift`)
- [ ] Comments are in English and add value
- [ ] Error handling is implemented
- [ ] No force unwraps (`!`) unless absolutely necessary and documented

### Code Review Checklist
- [ ] Changes align with KISS principles
- [ ] No duplicate code (DRY principle)
- [ ] Services are properly injected/initialized
- [ ] UserDefaults uses App Groups suite when needed
- [ ] UI updates happen on main thread (`@MainActor`)

## Resources
- [CallKit Documentation](https://developer.apple.com/documentation/callkit)
- [App Groups](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups)

## Questions or Issues?
When in doubt:
1. Follow existing patterns in the codebase
2. Prioritize simplicity and clarity
3. Ask for clarification on ambiguous requirements
