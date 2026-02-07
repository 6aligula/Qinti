import Foundation

@Observable
final class ConversationsViewModel {
    var conversations: [Conversation] = []
    var isLoading = false
    var errorMessage: String?

    private let webSocketService: WebSocketService
    private var userId: String?

    init(webSocketService: WebSocketService) {
        self.webSocketService = webSocketService
    }

    func setup(userId: String) {
        self.userId = userId
        webSocketService.connect(userId: userId)
        webSocketService.onMessageReceived = { [weak self] _ in
            guard let self, let userId = self.userId else { return }
            Task {
                await self.loadConversations(userId: userId)
            }
        }
    }

    func loadConversations(userId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            conversations = try await APIService.shared.getConversations(userId: userId)
        } catch {
            errorMessage = "Error loading conversations: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func createDM(otherUserId: String, userId: String) async -> Conversation? {
        do {
            let conversation = try await APIService.shared.createDM(otherUserId: otherUserId, userId: userId)
            await loadConversations(userId: userId)
            return conversation
        } catch {
            errorMessage = "Error creating DM: \(error.localizedDescription)"
            return nil
        }
    }

    func createRoom(name: String, userId: String) async -> Conversation? {
        do {
            let room = try await APIService.shared.createRoom(name: name, userId: userId)
            await loadConversations(userId: userId)
            return room
        } catch {
            errorMessage = "Error creating room: \(error.localizedDescription)"
            return nil
        }
    }

    func disconnect() {
        webSocketService.disconnect()
    }
}
