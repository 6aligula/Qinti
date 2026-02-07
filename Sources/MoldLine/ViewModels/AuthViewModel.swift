import Foundation

@Observable
final class AuthViewModel {
    var currentUserId: String?
    var users: [User] = []
    var isLoading = false
    var errorMessage: String?

    var isLoggedIn: Bool {
        currentUserId != nil
    }

    func loadUsers() async {
        isLoading = true
        errorMessage = nil
        do {
            users = try await APIService.shared.getUsers()
        } catch {
            errorMessage = "Error loading users: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func selectUser(_ userId: String) {
        currentUserId = userId
    }

    func logout() {
        currentUserId = nil
    }
}
