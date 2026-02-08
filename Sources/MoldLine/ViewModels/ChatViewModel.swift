import Foundation

@MainActor
@Observable
final class ChatViewModel {
    var messages: [Message] = []
    var isLoading = false
    var errorMessage: String?
    var messageText = ""

    private let convoId: String
    let userId: String
    private let webSocketService: WebSocketService
    private var handlerId: UUID?
    private let handlerIdBox = UnsafeSendableBox()

    /// Thread-safe box to pass handlerId out of @MainActor for deinit
    private final class UnsafeSendableBox: @unchecked Sendable {
        var id: UUID?
    }

    init(convoId: String, userId: String, webSocketService: WebSocketService) {
        self.convoId = convoId
        self.userId = userId
        self.webSocketService = webSocketService
        setupWebSocket()
    }

    deinit {
        let id = handlerIdBox.id
        let service = webSocketService
        if let id {
            Task { @MainActor in
                service.removeMessageHandler(id)
            }
        }
    }

    private func setupWebSocket() {
        handlerId = webSocketService.addMessageHandler { [weak self] message in
            guard let self, message.convoId == self.convoId else { return }
            guard !self.messages.contains(where: { $0.messageId == message.messageId }) else { return }
            self.messages.append(message)
        }
        handlerIdBox.id = handlerId
    }

    func loadMessages() async {
        isLoading = true
        errorMessage = nil
        do {
            let loaded = try await APIService.shared.getMessages(convoId: convoId)
            messages = loaded
        } catch {
            errorMessage = "Error loading messages: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func sendMessage() async {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        messageText = ""
        do {
            let message = try await APIService.shared.sendMessage(convoId: convoId, text: text)
            if !messages.contains(where: { $0.messageId == message.messageId }) {
                messages.append(message)
            }
        } catch {
            errorMessage = "Error sending message: \(error.localizedDescription)"
            messageText = text
        }
    }
}
