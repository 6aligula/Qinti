import Foundation

@Observable
final class RegisterViewModel {
    var nickname = ""
    var password = ""
    var confirmPassword = ""
    var email = ""
    var phone = ""
    var isLoading = false
    var errorMessage: String?
    var registeredUserId: String?

    var isFormValid: Bool {
        !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !password.isEmpty
        && password.count >= 4
        && password == confirmPassword
    }

    var passwordMismatch: Bool {
        !confirmPassword.isEmpty && password != confirmPassword
    }

    func register() async -> String? {
        let trimmedName = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !password.isEmpty else { return nil }

        isLoading = true
        errorMessage = nil

        let request = RegisterRequest(
            name: trimmedName,
            password: password,
            email: email.isEmpty ? nil : email,
            phone: phone.isEmpty ? nil : phone
        )

        do {
            let response = try await APIService.shared.register(request: request)
            registeredUserId = response.userId
            isLoading = false
            return response.userId
        } catch {
            errorMessage = "Registration failed: \(error.localizedDescription)"
            isLoading = false
            return nil
        }
    }
}
