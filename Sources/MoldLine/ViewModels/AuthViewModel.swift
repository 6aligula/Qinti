import Foundation

@Observable
final class AuthViewModel {
    var currentUserId: String?
    private(set) var currentToken: String?
    var isLoading = false
    var errorMessage: String?

    var isLoggedIn: Bool {
        currentUserId != nil && currentToken != nil
    }

    // MARK: - Init (auto-login from Keychain)

    init() {
        self.currentUserId = KeychainService.loadUserId()
        self.currentToken = KeychainService.loadToken()
    }

    // MARK: - Login

    func login(name: String, password: String) async {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your nickname and password."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let request = LoginRequest(name: trimmedName, password: password)
            let response = try await AuthService.shared.login(request: request)
            handleAuthResponse(userId: response.userId, token: response.token)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Handle Auth Response (shared by login & register)

    func handleAuthResponse(userId: String, token: String) {
        KeychainService.saveToken(token)
        KeychainService.saveUserId(userId)
        currentUserId = userId
        currentToken = token
    }

    // MARK: - Logout

    func logout() {
        KeychainService.clearAll()
        currentUserId = nil
        currentToken = nil
        errorMessage = nil
    }

    // MARK: - Validate Session (silent check on app launch)

    func validateSession() async {
        guard let token = currentToken else { return }

        do {
            _ = try await AuthService.shared.getMe(token: token)
        } catch is AuthError {
            logout()
        } catch {
            // Network error — don't logout, user may be offline
        }
    }
}
