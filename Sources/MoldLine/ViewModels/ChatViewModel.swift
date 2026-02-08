import Foundation

@Observable
final class ChatViewModel {
    var messages: [Message] = []
    var isLoading = false
    var errorMessage: String?
    var messageText = ""

    private let convoId: String
    let userId: String
    private let webSocketService: WebSocketService

    init(convoId: String, userId: String, webSocketService: WebSocketService) {
        self.convoId = convoId
        self.userId = userId
        self.webSocketService = webSocketService
        setupWebSocket()
    }

    private func setupWebSocket() {
        let previousHandler = webSocketService.onMessageReceived
        webSocketService.onMessageReceived = { [weak self] message in
            previousHandler?(message)
            guard let self else { return }
            if message.convoId == self.convoId {
                if !self.messages.contains(where: { $0.messageId == message.messageId }) {
                    self.messages.append(message)
                }
            }
        }
    }

    func loadMessages() async {
        isLoading = true
        errorMessage = nil
        do {
            messages = try await APIService.shared.getMessages(convoId: convoId)
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
