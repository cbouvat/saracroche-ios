# Agents Instructions

## Project Overview
Saracroche is an iOS call blocking app built with CallKit. Block spam calls, report unwanted communications, filter SMS, background block list updates, call reporting.

- **Main app** (`saracroche/`): SwiftUI-based user interface
- **Call Directory extension** (`blocker/`): Manages call blocking using CallKit
- **Unwanted extension** (`unwanted/`): Handles reporting of unwanted calls
- **Filter extension** (`filter/`): SMS filtering capabilities
- **Shared data**: App Groups (`group.com.saracroche`) for data sharing between app and extensions

## Do
- Follow KISS principle
- Use Swift 6
- Write SwiftUI (iOS 15+)
- Follow MVVM architecture pattern
- Write all comments in English
- Use explicit variable and function names
- A11Y compliance with VoiceOver
- Lint code with `swift-format` (see `Makefile`)

## Don't
- Don't hardcode values (use `AppConstants.swift` instead)

## Commands

```bash
# Lint the codebase
make swift-format
```

## Key Files
- **Entry point**: `saracroche/App.swift`
- **Main view**: `saracroche/SaracrocheView.swift`
- **Call blocking**: `blocker/CallDirectoryHandler.swift`
- **Constants**: `saracroche/Utils/AppConstants.swift`
- **Shared data**: All services use App Groups (`group.com.saracroche`)

### Design Systems
- Follow existing design patterns in `saracroche/Views/Components/`

## Questions or Issues?
When in doubt:
1. Follow existing patterns in the codebase
2. Prioritize simplicity and clarity (KISS)
3. Ask for clarification on ambiguous requirements
