import Foundation

actor APIService {
    static let shared = APIService()

    private let baseURL = AppConstants.chatAPIBaseURL
    private let session = URLSession.shared
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()

    // MARK: - Authenticated Request Helper

    private func authenticatedRequest(url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let token = KeychainService.loadToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    // MARK: - Health

    func healthCheck() async throws -> Bool {
        let url = URL(string: "\(baseURL)/health")!
        let (_, response) = try await session.data(from: url)
        return (response as? HTTPURLResponse)?.statusCode == 200
    }

    // MARK: - Conversations

    func getConversations() async throws -> [Conversation] {
        let url = URL(string: "\(baseURL)/conversations")!
        let request = authenticatedRequest(url: url)
        let (data, _) = try await session.data(for: request)
        return try decoder.decode([Conversation].self, from: data)
    }

    func getMessages(convoId: String) async throws -> [Message] {
        let url = URL(string: "\(baseURL)/conversations/\(convoId)/messages")!
        let request = authenticatedRequest(url: url)
        let (data, _) = try await session.data(for: request)
        return try decoder.decode([Message].self, from: data)
    }

    func sendMessage(convoId: String, text: String) async throws -> Message {
        let url = URL(string: "\(baseURL)/conversations/\(convoId)/messages")!
        var request = authenticatedRequest(url: url, method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["text": text])
        let (data, _) = try await session.data(for: request)
        return try decoder.decode(Message.self, from: data)
    }

    // MARK: - DMs

    func createDM(otherUserId: String) async throws -> Conversation {
        let url = URL(string: "\(baseURL)/dm")!
        var request = authenticatedRequest(url: url, method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["otherUserId": otherUserId])
        let (data, _) = try await session.data(for: request)
        return try decoder.decode(Conversation.self, from: data)
    }

    // MARK: - Rooms

    func getRooms() async throws -> [Conversation] {
        let url = URL(string: "\(baseURL)/rooms")!
        let request = authenticatedRequest(url: url)
        let (data, _) = try await session.data(for: request)
        return try decoder.decode([Conversation].self, from: data)
    }

    func createRoom(name: String) async throws -> Conversation {
        let url = URL(string: "\(baseURL)/rooms")!
        var request = authenticatedRequest(url: url, method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["name": name])
        let (data, _) = try await session.data(for: request)
        return try decoder.decode(Conversation.self, from: data)
    }

    func joinRoom(roomId: String) async throws {
        let url = URL(string: "\(baseURL)/rooms/\(roomId)/join")!
        let request = authenticatedRequest(url: url, method: "POST")
        let (_, _) = try await session.data(for: request)
    }
}
