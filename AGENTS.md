# AGENTS.md

## Project Overview

Saracroche is an iOS call blocking app built with CallKit. It provides comprehensive spam call blocking, unwanted communication reporting, SMS filtering, background block list updates, and call reporting capabilities.

## Architecture

### Target Structure

The project consists of four targets:

- **saracroche** (main app): SwiftUI-based user interface with MVVM architecture
- **blocker** (Call Directory extension): Manages call blocking/identification using CallKit's incremental updates
- **unwanted** (Unwanted Communication Reporting extension): Handles reporting of spam calls to the server
- **filter** (Message Filter extension): SMS filtering capabilities

### Data Flow

- **App Groups**: All targets share data via `group.com.cbouvat.saracroche` (defined in `AppConstants.swift`)
- **CoreData**: Main app stores blocking patterns in `DataModel.xcdatamodeld` with the `Pattern` entity
- **Shared UserDefaults**: Extensions communicate with the main app through shared UserDefaults to exchange phone numbers and actions
- **Pattern System**: Phone numbers use wildcard patterns (e.g., `0899######` where `#` matches any digit) stored in CoreData and processed in batches

## Guidelines

- **Code Formatting**: Run `swift-format --in-place --recursive .` after making changes to Swift code
- **Design Principles**: Keep it simple (KISS principle), follow Single Responsibility Principle
- **Target Platform**: Write for iOS 15 and later versions
- **Architecture**: Follow MVVM (Model-View-ViewModel) architecture pattern
- **Concurrency**: Use async/await for all asynchronous operations
- **Naming Conventions**: Use explicit, descriptive names for variables and functions
- **Accessibility**: Ensure A11Y compliance with VoiceOver support
- **Configuration**: Store app configuration in `AppConstants.swift`
- **Data Sharing**: Use App Groups for inter-process communication between app and extensions
- **Documentation**: Write comprehensive documentation in `docs/` folder and add SwiftDoc comments for all public APIs and complex functions
- **Testing**: Write unit tests for critical components and business logic
- **Error Handling**: Implement proper error handling and logging
- **Legacy Code**: Don't write Objective-C code (Swift-only project)
- **Hardcoding**: Don't hardcode configuration values or strings
- **Don't commit**: Don't commit code

## Development Commands

### Building

```bash
# Build main app
xcodebuild -scheme saracroche -configuration Debug build

# Build all targets
xcodebuild -project saracroche.xcodeproj build
```

### Code Formatting

```bash
# Format all Swift code (REQUIRED after changes)
make lint
# or
swift-format --in-place --recursive .
```
