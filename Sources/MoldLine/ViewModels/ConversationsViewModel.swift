import Foundation

@MainActor
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
        webSocketService.addMessageHandler { [weak self] _ in
            Task { @MainActor in
                await self?.loadConversations()
            }
        }
    }

    func loadConversations() async {
        isLoading = true
        errorMessage = nil
        do {
            conversations = try await APIService.shared.getConversations()
        } catch {
            errorMessage = "Error loading conversations: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func createDM(otherUserId: String) async -> Conversation? {
        do {
            let conversation = try await APIService.shared.createDM(otherUserId: otherUserId)
            await loadConversations()
            return conversation
        } catch {
            errorMessage = "Error creating DM: \(error.localizedDescription)"
            return nil
        }
    }

    func createRoom(name: String) async -> Conversation? {
        do {
            let room = try await APIService.shared.createRoom(name: name)
            await loadConversations()
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
