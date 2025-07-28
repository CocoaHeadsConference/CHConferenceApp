# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the CocoaHeads Brasil iOS application - a SwiftUI-based app designed for supporting CocoaHeads Brazil events, attendees and organizers. The app supports multiple platforms (iOS, macOS through iOS, visionOS, watchOS, App Clip) and uses CloudKit for backend services.

## Project Structure

The codebase is organized into several key components:

- **NSBrazilConf.xcodeproj** - Main Xcode project with multiple targets
- **CocoaHeadsKit** - Core Swift Package containing the main business logic and UI components
- **Common** - Shared utilities and extensions Swift Package  
- **Platform-specific targets**:
  - `NSBrazilConf` (iOS main app)
  - `NSClip` (App Clip)
  - `CocoaHeadsBR Vision` (visionOS)
  - `CocoaHeadsBR Watch` (watchOS)

## Core Architecture

### Server-Driven UI Pattern
The app implements a server-driven UI architecture where content is dynamically loaded from CloudKit:
- `Page` struct loads UI configurations by slug from CloudKit
- `PageRenderer` and `EventDetailRenderer` convert server data to SwiftUI views
- UI elements are defined in `EventDetailUI` enum for flexible rendering

### CloudKit Integration
- `CloudKitService` actor handles all backend communication
- Environment injection pattern: `@Environment(\.cloudKitService) var cloudKit`
- Supports Chapters, Events, Pages, and Raffle functionality
- Container ID: `iCloud.br.com.cocoaHeads.conf`

### Key Models
- `Chapter` - Conference chapter/location data
- `EventDetailUI` - Server-driven UI component definitions
- `UI` - Base UI element type for page rendering

## Development Commands

### Building
```bash
# Build all targets
xcodebuild -project NSBrazilConf.xcodeproj -scheme NSBrazilConf build

# Build specific target
xcodebuild -project NSBrazilConf.xcodeproj -scheme "CocoaHeadsBR Vision" build
```

### Testing
```bash
# Run all tests using test plan
xcodebuild test -project NSBrazilConf.xcodeproj -testPlan NSBrazilConf

# Run specific package tests
swift test --package-path CocoaHeadsKit
swift test --package-path Common
```

### Package Management
```bash
# In CocoaHeadsKit directory
swift package resolve
swift package update

# Clean and rebuild packages
swift package clean
swift package build
```

## Platform Requirements

- **CocoaHeadsKit**: iOS 18.2+, visionOS 2.2+, Swift 6.0
- **Common**: iOS 17+, tvOS 17+, macOS 14+, visionOS 1+, watchOS 10+, Swift 5.9
- **Dependencies**: SwiftSoup for HTML parsing

## Key Technical Concepts

### Environment-Based Architecture
- CloudKit service injected via SwiftUI Environment
- Enables testing with mock services (planned improvement)

### Multi-Platform Considerations
- Shared CocoaHeadsKit provides common functionality
- Platform-specific apps are thin wrappers around shared components
- App Clip requires size optimization (current TODO item)

### Current Migration State
The codebase is in transition toward:
1. **The Composable Architecture (TCA)** - Multiple TODOs reference planned TCA migration
2. **Enhanced Server-Driven UI** - Moving more UI logic to server configuration
3. **Service Layer Separation** - Breaking CloudKit dependencies for better testing

## Configuration Files

- `Version.xcconfig` - Centralized version management (MARKETING_VERSION = 2025.3, CURRENT_PROJECT_VERSION = 3)
- Various `.entitlements` files for platform-specific permissions
- CloudKit container configuration in project settings

## Testing Strategy

- Unit tests in `CocoaHeadsKitTests` and `CommonTests`
- Test plan configuration in `NSBrazilConf.xctestplan`
- Mock services planned for CloudKit testing (see TODO items)

## Known Technical Debt

Refer to `TODO_LIST.md` for comprehensive list of 69 TODO/FIXME items, including:
- Critical performance issue with cascaded shadows
- Service layer abstraction needs
- TCA migration requirements
- Multi-platform UI optimizations
- Caching and persistence improvements

## Hidden Development Features

The app includes hidden feature screens in `CocoaHeadsKit/Sources/CocoaHeadsKit/Hidden/`:
- Page creation and editing tools
- Chapter management
- CloudKit debugging utilities
- Raffle creation and management

These features are intended for chapter leaders and conference organizers to manage content directly in the app.