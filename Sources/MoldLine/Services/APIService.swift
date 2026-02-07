import Foundation

actor APIService {
    static let shared = APIService()

    private let baseURL = AppConstants.apiBaseURL
    private let session = URLSession.shared
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()

    // MARK: - Health

    func healthCheck() async throws -> Bool {
        let url = URL(string: "\(baseURL)/health")!
        let (_, response) = try await session.data(from: url)
        return (response as? HTTPURLResponse)?.statusCode == 200
    }

    // MARK: - Users

    func getUsers() async throws -> [User] {
        let url = URL(string: "\(baseURL)/users")!
        let (data, _) = try await session.data(from: url)
        return try decoder.decode([User].self, from: data)
    }

    func getMe(userId: String) async throws -> User {
        let url = URL(string: "\(baseURL)/me")!
        var request = URLRequest(url: url)
        request.setValue(userId, forHTTPHeaderField: "x-user-id")
        let (data, _) = try await session.data(for: request)
        return try decoder.decode(User.self, from: data)
    }

    // MARK: - Conversations

    func getConversations(userId: String) async throws -> [Conversation] {
        let url = URL(string: "\(baseURL)/conversations")!
        var request = URLRequest(url: url)
        request.setValue(userId, forHTTPHeaderField: "x-user-id")
        let (data, _) = try await session.data(for: request)
        return try decoder.decode([Conversation].self, from: data)
    }

    func getMessages(convoId: String, userId: String) async throws -> [Message] {
        let url = URL(string: "\(baseURL)/conversations/\(convoId)/messages")!
        var request = URLRequest(url: url)
        request.setValue(userId, forHTTPHeaderField: "x-user-id")
        let (data, _) = try await session.data(for: request)
        return try decoder.decode([Message].self, from: data)
    }

    func sendMessage(convoId: String, text: String, userId: String) async throws -> Message {
        let url = URL(string: "\(baseURL)/conversations/\(convoId)/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(userId, forHTTPHeaderField: "x-user-id")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["text": text])
        let (data, _) = try await session.data(for: request)
        return try decoder.decode(Message.self, from: data)
    }

    // MARK: - DMs

    func createDM(otherUserId: String, userId: String) async throws -> Conversation {
        let url = URL(string: "\(baseURL)/dm")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(userId, forHTTPHeaderField: "x-user-id")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["otherUserId": otherUserId])
        let (data, _) = try await session.data(for: request)
        return try decoder.decode(Conversation.self, from: data)
    }

    // MARK: - Rooms

    func getRooms(userId: String) async throws -> [Conversation] {
        let url = URL(string: "\(baseURL)/rooms")!
        var request = URLRequest(url: url)
        request.setValue(userId, forHTTPHeaderField: "x-user-id")
        let (data, _) = try await session.data(for: request)
        return try decoder.decode([Conversation].self, from: data)
    }

    func createRoom(name: String, userId: String) async throws -> Conversation {
        let url = URL(string: "\(baseURL)/rooms")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(userId, forHTTPHeaderField: "x-user-id")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["name": name])
        let (data, _) = try await session.data(for: request)
        return try decoder.decode(Conversation.self, from: data)
    }

    func joinRoom(roomId: String, userId: String) async throws {
        let url = URL(string: "\(baseURL)/rooms/\(roomId)/join")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(userId, forHTTPHeaderField: "x-user-id")
        let (_, _) = try await session.data(for: request)
    }
}
