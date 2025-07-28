# CLAUDE.md - QAKit Package

This file provides guidance to Claude Code when working with the QAKit Swift Package.

## Package Overview

QAKit is a standalone Swift Package that provides a complete Q&A system for CocoaHeads events. It enables event attendees to ask questions and interact with each other through a real-time question and answer interface.

## Architecture

- **Modular Design**: Self-contained package with minimal dependencies
- **Protocol-Based**: Uses `QAServiceProtocol` for testability and flexibility
- **Actor-Based Service**: `QAService` uses Swift's actor model for thread-safe CloudKit operations
- **SwiftUI Views**: Native SwiftUI components with Brazilian Portuguese localization
- **Polling-Based Updates**: Reliable 3-second polling for remote questions
- **Optimistic UI**: Immediate local updates when users post questions

## Key Components

### Models
- `Question`: Core data model with CloudKit serialization support

### Services
- `QAServiceProtocol`: Service interface for dependency injection
- `QAService`: CloudKit-backed implementation with polling support

### Views
- `QAListView`: Main question listing with real-time updates
- `QAEntryView`: Two-step question submission (name → question)
- `QAQuestionRow`: Individual question display component
- `QASection`: Integration component for EventDetailUI

### Testing
- `MockQAService`: Comprehensive mock implementation for testing
- 21 unit tests covering models, services, and UI components
- Full test coverage for error scenarios and edge cases

## Development Commands

### Building
```bash
cd QAKit
swift build
```

### Testing
```bash
cd QAKit
swift test
```

## Important Development Rules

**⚠️ ALWAYS RUN THESE COMMANDS BEFORE COMPLETING ANY WORK:**

1. **Build Check**: `swift build` - Must pass without errors
2. **Test Check**: `swift test` - All tests must pass (currently 21/21)
3. **No Failing Tests**: Never leave tests in a failing state
4. **Cross-Platform**: Ensure builds work on iOS, visionOS, and macOS

## Technical Considerations

### CloudKit Integration
- Uses existing container: `iCloud.br.com.cocoaHeads.conf`
- Requires "Question" record type in CloudKit Dashboard
- Thread-safe operations through actor isolation

### Real-time Updates
- **Local Updates**: Immediate via `NotificationCenter.default.post`
- **Remote Updates**: 3-second polling with duplicate prevention
- **Notification**: `.localQuestionPosted` for instant local feedback

### Platform Support
- **iOS 18.2+**: Full feature support with haptic feedback
- **visionOS 2.2+**: Complete compatibility
- **macOS 14.0+**: Conditional compilation for iOS-specific features

### Localization
- **Brazilian Portuguese**: All user-facing text
- **Accessibility**: Full VoiceOver support with proper labels and hints
- **Keyboard Support**: Submit on return key press

## Integration with Main App

### 1. Package Dependency
Add to main app's Package.swift or Xcode project dependencies.

### 2. EventDetailUI Integration
```swift
.qa(sessionID: "unique-session-id")  // Add to EventDetailUI array
```

### 3. CloudKit Record Type
Create "Question" record type with fields: sessionID, userName, questionText, timestamp

## Testing Strategy

### Unit Tests
- **Question Model**: CloudKit serialization, validation, edge cases
- **QAService**: CRUD operations, error handling, filtering
- **UI Components**: View creation, validation logic, user interactions

### Mock Objects
- `MockQAService`: Complete service mock with error simulation
- Configurable error states for testing failure scenarios
- Helper methods for test data management

## Code Quality Standards

### Error Handling
- Graceful degradation for network failures
- User-friendly error messages in Portuguese
- Silent failures for background polling to avoid spam

### Performance
- Efficient duplicate detection in polling
- Animated UI updates for smooth user experience
- Memory-efficient actor-based service layer

### Accessibility
- Comprehensive VoiceOver support
- Semantic accessibility labels and hints
- Keyboard navigation support

## Common Issues & Solutions

### Build Failures
1. Check platform-specific conditional compilation
2. Verify import statements for UIKit (iOS-only)
3. Ensure CloudKit framework availability

### Test Failures
1. Verify MockQAService implementation matches protocol
2. Check MainActor annotations for UI tests
3. Ensure proper async/await handling in tests

### Integration Issues
1. Confirm CloudKit container ID matches main app
2. Verify EventDetailUI enum includes .qa case
3. Check QAService environment injection

## Maintenance Notes

- **Polling Interval**: Currently 3 seconds (adjustable in `QAListView.swift`)
- **CloudKit Container**: Shared with main app for consistency
- **Notification Names**: Use consistent naming across components
- **Test Coverage**: Maintain comprehensive test suite for reliability

---

**Remember**: Always run `swift build` and `swift test` before completing any work on this package!