# AGENTS.md

## Project Overview

Saracroche is an iOS call blocking app built with CallKit. It provides comprehensive spam call blocking, unwanted communication reporting, SMS filtering, background block list updates, and call reporting capabilities.

The application is built as a modular iOS system with:

- **Main app** (`saracroche/`): SwiftUI-based user interface
- **Call Directory extension** (`blocker/`): Manages call blocking using CallKit
- **Unwanted extension** (`unwanted/`): Handles reporting of unwanted calls
- **Filter extension** (`filter/`): SMS filtering capabilities
- **Shared data**: App Groups (`group.com.saracroche`) for data sharing between app and extensions

## Do

- **Run `make lint` after making changes to Swift code**
- Keep it simple (KISS principle)
- Use Swift 6
- Write SwiftUI (iOS 15+)
- Follow MVVM architecture
- Write comments in English
- Use explicit names for variables and functions
- Ensure A11Y compliance with VoiceOver
- Store configuration in `AppConstants.swift`
- Use App Groups for inter-process communication

## Don't

- Don't use comments to explain code logic
- Don't write Objective-C code

## Commands

- `make lint`: Lint Swift code with SwiftLint
