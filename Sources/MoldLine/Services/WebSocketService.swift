import Foundation

@Observable
final class WebSocketService {
    private var webSocketTask: URLSessionWebSocketTask?
    private var userId: String?
    private(set) var isConnected = false

    var onMessageReceived: ((Message) -> Void)?

    func connect(userId: String) {
        self.userId = userId
        let url = AppConstants.wsURL(userId: userId)
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        isConnected = true
        receiveMessages()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
    }

    private func receiveMessages() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self.handleMessage(text)
                    }
                @unknown default:
                    break
                }
                self.receiveMessages()

            case .failure:
                self.isConnected = false
                self.reconnect()
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
                DispatchQueue.main.async {
                    self.onMessageReceived?(messageEvent.data)
                }
            }
        case "hello":
            DispatchQueue.main.async {
                self.isConnected = true
            }
        default:
            break
        }
    }

    private func reconnect() {
        guard let userId else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.connect(userId: userId)
        }
    }
}
