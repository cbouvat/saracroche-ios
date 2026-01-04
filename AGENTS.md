# AGENTS.md

## Project Overview

Saracroche is an iOS call blocking app built with CallKit. It provides comprehensive spam call blocking, unwanted communication reporting, SMS filtering, background block list updates, and call reporting capabilities.

The application is built as a modular iOS system with:

- **Main app** (`saracroche/`): SwiftUI-based user interface
- **Call Directory extension** (`blocker/`): Manages call blocking using CallKit
- **Unwanted extension** (`unwanted/`): Handles reporting of unwanted calls
- **Filter extension** (`filter/`): SMS filtering capabilities
- **Helpers** (`saracroche/Utilities/`): Helper functions and extensions
- **Shared data**: App Groups (`group.com.saracroche`) for data sharing between app and extensions

## Guidelines

### Do

- **Code Formatting**: Run `swift-format --in-place --recursive .` after making changes to Swift code
- **Design Principles**: Keep it simple (KISS principle), follow Single Responsibility Principle
- **Target Platform**: Write for iOS 15 and later versions
- **Architecture**: Follow MVVM (Model-View-ViewModel) architecture pattern
- **Naming Conventions**: Use explicit, descriptive names for variables and functions
- **Accessibility**: Ensure A11Y compliance with VoiceOver support
- **Configuration**: Store app configuration in `AppConstants.swift`
- **Data Sharing**: Use App Groups for inter-process communication between app and extensions
- **Documentation**: Write comprehensive documentation in `docs/` folder and add SwiftDoc comments for all public APIs and complex functions
- **Testing**: Write unit tests for critical components and business logic
- **Error Handling**: Implement proper error handling and logging

### Don't

- **Legacy Code**: Don't write Objective-C code (Swift-only project)
- **Hardcoding**: Don't hardcode configuration values or strings
- **Global State**: Avoid using global variables or singletons when possible
- **Force Unwrapping**: Don't use force unwrapping (`!`) - prefer optional binding
- **Committing**: Don't commit directly

## Development Workflow

### Commands

- **Code Formatting**: `swift-format --in-place --recursive .` - Format Swift code according to project standards
- **Building**: Use `xcodebuild` for building specific schemes
