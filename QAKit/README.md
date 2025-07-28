# QAKit - Q&A System for CocoaHeads Events

A real-time Q&A system integrated with CloudKit for event attendees to ask questions and interact.

## Features

- Simple name entry and question submission
- Real-time question sync across all devices using CloudKit
- Event-specific Q&A sessions
- Timestamps for all questions
- Clean, native SwiftUI interface

## Integration

### 1. Add QAKit to Your Target

In your Xcode project:
1. Add the QAKit package dependency to your target
2. Import QAKit where needed

### 2. CloudKit Setup

The Q&A system uses the existing CloudKit container: `iCloud.br.com.cocoaHeads.conf`

You'll need to add a new record type in CloudKit Dashboard:

**Record Type: Question**
- `sessionID` (String) - Unique identifier for the Q&A session
- `userName` (String) - Name of the person asking
- `questionText` (String) - The question content
- `timestamp` (Date) - When the question was asked

### 3. Add Q&A to Event Details

To add Q&A functionality to any content, include the `.qa(sessionID: String)` case in your EventDetailUI array:

```swift
let eventUI: [EventDetailUI] = [
    // ... other UI elements
    .qa(sessionID: "unique-session-identifier"),
    // ... more UI elements
]
```

### 4. Environment Setup

The QAService is automatically injected into the SwiftUI environment. Make sure your app's root view has access to CloudKit.

## Architecture

- **QAService**: Actor-based service handling all CloudKit operations
- **Question**: Core data model for questions
- **QAListView**: Main view displaying all questions
- **QAEntryView**: Two-step form for name entry and question submission
- **QASection**: Integration component for EventDetail view

## Real-time Updates

The system provides immediate updates through two mechanisms:

1. **Instant Local Updates**: When a user posts a question, it immediately appears in their own list (optimistic update)
2. **Polling for Remote Updates**: Every 3 seconds, the app checks for new questions from other users

This dual approach provides the best user experience - instant feedback for your own actions, plus reliable updates from others within a few seconds. The system automatically prevents duplicates when the user's own question comes back from the server.

## Usage

1. Users tap the Q&A section in an event
2. They enter their name (one-time per session)
3. They can ask multiple questions
4. All attendees see questions in real-time
5. Questions are sorted by newest first