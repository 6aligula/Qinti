# MoldLine

Native iOS chat application built with Swift and SwiftUI.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Swift 5.9+ |
| UI Framework | SwiftUI |
| Architecture | MVVM with `@Observable` |
| Concurrency | Swift Concurrency (`async/await`, `actor`, `@MainActor`) |
| Minimum Target | iOS 17 |
| Package Manager | Swift Package Manager |
| Backend | Google Cloud Run (2 microservices) |
| Real-time | WebSocket (RFC 6455) |
| Auth | JWT + Keychain |

## Project Structure

```
Sources/MoldLine/
├── Models/                 # Data layer
│   ├── User.swift
│   ├── Message.swift
│   ├── Conversation.swift
│   └── RegisterRequest.swift
│
├── Services/               # Network & business logic
│   ├── AuthService.swift         # Auth API client (actor-based)
│   ├── APIService.swift          # Chat API client (actor-based)
│   ├── WebSocketService.swift    # Real-time messaging (@MainActor)
│   ├── KeychainService.swift     # Secure token/userId storage
│   └── UserCache.swift           # In-memory user name cache
│
├── ViewModels/             # State management (@Observable)
│   ├── AuthViewModel.swift
│   ├── ChatViewModel.swift
│   └── ConversationsViewModel.swift
│
├── Views/                  # UI screens
│   ├── LoginView.swift
│   ├── RegisterView.swift
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

- **JWT Authentication** — Login, register, session validation, auto-login from Keychain
- **Token Refresh** — Silent token renewal to keep sessions alive
- **Direct Messages** — 1-on-1 private conversations
- **Rooms** — Group chat creation and participation
- **Real-time Messaging** — Instant message delivery via WebSocket with auto-reconnect
- **Message Deduplication** — Prevents duplicate display from REST + WebSocket overlap
- **User Name Resolution** — Displays user names instead of UUIDs via UserCache
- **Secure Storage** — Tokens and userId stored in iOS Keychain
- **Pull-to-Refresh** — On conversation list and chat views
- **Auto-scroll** — Chat scrolls to latest message automatically

### Planned

_Features will be added here as the project grows._

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐
│   Views      │────▶│  ViewModels   │────▶│    Services      │
│  (SwiftUI)   │◀────│ (@Observable) │◀────│ (actor / @MainActor)│
└─────────────┘     └──────────────┘     └─────────────────┘
                                                │
                                         ┌──────┴──────┐
                                         │  Keychain    │
                                         │  (Secure     │
                                         │   Storage)   │
                                         └─────────────┘
```

- **Views** bind to ViewModels via SwiftUI's observation system
- **ViewModels** are `@Observable` with `@MainActor` isolation for thread-safe UI updates
- **AuthService / APIService** are `actor`-based for thread-safe network calls using `async/await`
- **WebSocketService** is `@MainActor` with handler registry pattern and automatic reconnection
- **KeychainService** handles secure persistence of JWT tokens and user IDs

## Backend Services

The app communicates with two Cloud Run microservices:

| Service | Purpose |
|---------|---------|
| **Auth API** | Registration, login, token refresh, user profiles |
| **Chat API** | Conversations, messages, DMs, rooms |
| **WebSocket** | Real-time message delivery |

### Auth API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/register` | Register new user |
| `POST` | `/login` | Login with credentials |
| `GET` | `/me` | Get user profile (auth required) |
| `POST` | `/refresh` | Refresh JWT token |
| `GET` | `/users` | List all users (auth required) |
| `GET` | `/health` | Health check |

### Chat API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/conversations` | List user conversations |
| `GET` | `/conversations/:id/messages` | Get conversation messages |
| `POST` | `/conversations/:id/messages` | Send a message |
| `POST` | `/dm` | Create a direct message |
| `GET` | `/rooms` | List rooms |
| `POST` | `/rooms` | Create a room |
| `POST` | `/rooms/:id/join` | Join a room |
| `GET` | `/health` | Health check |

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
    static let chatAPIBaseURL = "https://..."
    static let authAPIBaseURL = "https://..."
    static let wsBaseURL      = "wss://..."
}
```

Update these values to point to your own backend instances.

## Agent Skills

This project uses [skills.sh](https://skills.sh) to enforce best practices via AI coding agents. The following skills are installed and active:

### Swift & SwiftUI (Core)

| Skill | Source | Purpose |
|-------|--------|---------|
| `swiftui-expert-skill` | avdlee | State management, view composition, performance, modern APIs, Liquid Glass |
| `swift-concurrency` | avdlee | async/await, actors, Sendable, @MainActor, Swift 6 migration |
| `swift-concurrency-expert` | dimillian | Concurrency reviews, Swift 6.2+ fixes |
| `swiftui-ui-patterns` | dimillian | View composition, state ownership, component patterns |
| `swiftui-performance-audit` | dimillian | Runtime performance auditing and optimization |
| `swiftui-view-refactor` | dimillian | View structure standardization and dependency cleanup |
| `swiftui-liquid-glass` | dimillian | iOS 26+ Liquid Glass API adoption |

### Architecture & Code Quality

| Skill | Source | Purpose |
|-------|--------|---------|
| `architecture-patterns` | wshobson | Scalable system design, microservices patterns |
| `api-design-principles` | wshobson | RESTful design, versioning, API best practices |
| `code-review-excellence` | wshobson | Systematic code evaluation and review |
| `design-system-patterns` | wshobson | Component libraries, design tokens, theming |
| `auth-implementation-patterns` | wshobson | Authentication flow best practices |
| `error-handling-patterns` | wshobson | Robust error handling strategies |
| `debugging-strategies` | wshobson | Systematic debugging approaches |

### iOS Tooling

| Skill | Source | Purpose |
|-------|--------|---------|
| `ios-debugger-agent` | dimillian | Build, run, and debug on iOS simulators |
| `app-store-changelog` | dimillian | Generate release notes from git history |
| `gh-issue-fix-flow` | dimillian | End-to-end GitHub issue resolution |

### Install Skills

```bash
npx skills add avdlee/swiftui-agent-skill --yes
npx skills add avdlee/swift-concurrency-agent-skill --yes
npx skills add dimillian/skills --yes
npx skills add wshobson/agents --yes
```
