import Foundation

@MainActor
@Observable
final class UserCache {
    private var users: [String: String] = [:]  // userId -> name
    private var loaded = false

    func loadUsers() async {
        guard !loaded else { return }
        guard let token = KeychainService.loadToken() else { return }
        do {
            let userList = try await AuthService.shared.getUsers(token: token)
            for user in userList {
                users[user.userId] = user.name
            }
            loaded = true
        } catch {
            // Silently fail — will show userId as fallback
        }
    }

    func name(for userId: String) -> String {
        users[userId] ?? userId
    }
}
