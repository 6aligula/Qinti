import Foundation

@MainActor
@Observable
final class WebSocketService {
    private var webSocketTask: URLSessionWebSocketTask?
    private var userId: String?
    private var receiveTask: Task<Void, Never>?
    private(set) var isConnected = false

    private var messageHandlers: [UUID: (Message) -> Void] = [:]

    @discardableResult
    func addMessageHandler(_ handler: @escaping (Message) -> Void) -> UUID {
        let id = UUID()
        messageHandlers[id] = handler
        return id
    }

    func removeMessageHandler(_ id: UUID) {
        messageHandlers[id] = nil
    }

    func connect(userId: String) {
        disconnect()
        self.userId = userId
        let url = AppConstants.wsURL(userId: userId)
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        isConnected = true
        startReceiving()
    }

    func disconnect() {
        receiveTask?.cancel()
        receiveTask = nil
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
    }

    private func startReceiving() {
        guard let task = webSocketTask else { return }
        receiveTask = Task { [weak self] in
            while !Task.isCancelled {
                do {
                    let wsMessage = try await task.receive()
                    guard !Task.isCancelled else { return }
                    let text: String?
                    switch wsMessage {
                    case .string(let str):
                        text = str
                    case .data(let data):
                        text = String(data: data, encoding: .utf8)
                    @unknown default:
                        text = nil
                    }
                    if let text {
                        await self?.handleMessage(text)
                    }
                } catch {
                    guard !Task.isCancelled else { return }
                    await MainActor.run {
                        self?.isConnected = false
                    }
                    try? await Task.sleep(for: .seconds(2))
                    guard !Task.isCancelled else { return }
                    await MainActor.run {
                        guard let self, let userId = self.userId else { return }
                        self.connect(userId: userId)
                    }
                    return
                }
            }
        }
    }

    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }

        struct WSEvent: Decodable {
            let type: String
        }

        guard let event = try? JSONDecoder().decode(WSEvent.self, from: data) else { return }

        switch event.type {
        case "message":
            struct MessageEvent: Decodable {
                let type: String
                let data: Message
            }
            if let messageEvent = try? JSONDecoder().decode(MessageEvent.self, from: data) {
                for handler in messageHandlers.values {
                    handler(messageEvent.data)
                }
            }
        case "hello":
            isConnected = true
        default:
            break
        }
    }
}
