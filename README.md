# MoldLine

Native iOS chat application built with Swift and SwiftUI.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Swift 5.9+ |
| UI Framework | SwiftUI |
| Architecture | MVVM with `@Observable` |
| Minimum Target | iOS 17 |
| Package Manager | Swift Package Manager |
| Backend | Google Cloud Run |
| Real-time | WebSocket (RFC 6455) |

## Project Structure

```
Sources/MoldLine/
├── Models/                 # Data layer
│   ├── User.swift
│   ├── Message.swift
│   └── Conversation.swift
│
├── Services/               # Network & business logic
│   ├── APIService.swift          # REST API client (actor-based)
│   └── WebSocketService.swift    # Real-time messaging
│
├── ViewModels/             # State management
│   ├── AuthViewModel.swift
│   ├── ChatViewModel.swift
│   └── ConversationsViewModel.swift
│
├── Views/                  # UI screens
│   ├── LoginView.swift
│   ├── ConversationsListView.swift
│   ├── ChatView.swift
│   ├── NewChatView.swift
│   ├── NewRoomView.swift
│   └── Components/
│       ├── MessageBubble.swift
│       ├── ConversationRow.swift
│       └── ChatInputBar.swift
│
├── Utilities/
│   └── Constants.swift     # API endpoints config
│
├── Assets.xcassets/
└── MoldLineApp.swift       # App entry point
```

## Features

### Implemented

- **Authentication** — User selection from registered users list
- **Direct Messages** — 1-on-1 private conversations
- **Rooms** — Group chat creation and participation
- **Real-time Messaging** — Instant message delivery via WebSocket with auto-reconnect
- **Message Deduplication** — Prevents duplicate display from REST + WebSocket overlap
- **User Name Resolution** — Displays user names instead of UUIDs throughout the UI
- **Pull-to-Refresh** — On conversation list and chat views
- **Auto-scroll** — Chat scrolls to latest message automatically

### Planned

_Features will be added here as the project grows._

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐
│   Views      │────▶│  ViewModels   │────▶│    Services      │
│  (SwiftUI)   │◀────│ (@Observable) │◀────│ (API + WebSocket)│
└─────────────┘     └──────────────┘     └─────────────────┘
```

- **Views** bind to ViewModels via SwiftUI's observation system
- **ViewModels** manage UI state and coordinate between Views and Services
- **APIService** is an `actor` for thread-safe network calls using `async/await`
- **WebSocketService** handles persistent connections with callback-based message delivery and automatic reconnection

## Backend Services

The app communicates with two Cloud Run microservices:

| Service | Purpose |
|---------|---------|
| **Chat API** | Conversations, messages, users, rooms |
| **WebSocket** | Real-time message delivery |

### API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/health` | Health check |
| `GET` | `/users` | List all users |
| `GET` | `/me` | Get current user |
| `GET` | `/conversations` | List user conversations |
| `GET` | `/conversations/:id/messages` | Get conversation messages |
| `POST` | `/conversations/:id/messages` | Send a message |
| `POST` | `/dm` | Create a direct message |
| `GET` | `/rooms` | List rooms |
| `POST` | `/rooms` | Create a room |
| `POST` | `/rooms/:id/join` | Join a room |

### WebSocket Events

| Event | Direction | Description |
|-------|-----------|-------------|
| `hello` | Server → Client | Connection confirmed |
| `message` | Server → Client | New message received |

## Getting Started

### Prerequisites

- Xcode 15+
- iOS 17+ device or simulator

### Build & Run

1. Clone the repository
2. Open `MoldLineApp.xcodeproj` in Xcode
3. Select a target device/simulator
4. Build and run (`Cmd + R`)

## Configuration

API endpoints are defined in `Sources/MoldLine/Utilities/Constants.swift`:

```swift
enum AppConstants {
    static let apiBaseURL = "https://..."
    static let wsBaseURL  = "wss://..."
}
```

Update these values to point to your own backend instances.
