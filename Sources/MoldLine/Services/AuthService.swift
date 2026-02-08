import Foundation

enum AuthError: LocalizedError {
    case invalidCredentials
    case usernameTaken
    case registrationFailed
    case unauthorized
    case validationError(String)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid nickname or password."
        case .usernameTaken:
            return "This nickname is already in use."
        case .registrationFailed:
            return "Registration failed. Please try again."
        case .unauthorized:
            return "Session expired. Please login again."
        case .validationError(let message):
            return message
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}

actor AuthService {
    static let shared = AuthService()

    private let baseURL = AppConstants.authAPIBaseURL
    private let session = URLSession.shared
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()

    // MARK: - Register

    func register(request: RegisterRequest) async throws -> RegisterResponse {
        let url = URL(string: "\(baseURL)/register")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await session.data(for: urlRequest)

        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 201:
                return try decoder.decode(RegisterResponse.self, from: data)
            case 409:
                throw AuthError.usernameTaken
            case 400:
                if let body = try? JSONDecoder().decode([String: String].self, from: data),
                   let message = body["message"] {
                    throw AuthError.validationError(message)
                }
                throw AuthError.registrationFailed
            default:
                throw AuthError.registrationFailed
            }
        }
        throw AuthError.registrationFailed
    }

    // MARK: - Login

    func login(request: LoginRequest) async throws -> LoginResponse {
        let url = URL(string: "\(baseURL)/login")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await session.data(for: urlRequest)

        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200:
                return try decoder.decode(LoginResponse.self, from: data)
            case 401:
                throw AuthError.invalidCredentials
            default:
                throw AuthError.invalidCredentials
            }
        }
        throw AuthError.invalidCredentials
    }

    // MARK: - Me (Profile)

    func getMe(token: String) async throws -> UserProfile {
        let url = URL(string: "\(baseURL)/me")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
            throw AuthError.unauthorized
        }

        return try decoder.decode(UserProfile.self, from: data)
    }

    // MARK: - Refresh Token

    func refreshToken(currentToken: String) async throws -> RefreshResponse {
        let url = URL(string: "\(baseURL)/refresh")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(currentToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
            throw AuthError.unauthorized
        }

        return try decoder.decode(RefreshResponse.self, from: data)
    }

    // MARK: - Users (authenticated)

    func getUsers(token: String) async throws -> [User] {
        let url = URL(string: "\(baseURL)/users")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
            throw AuthError.unauthorized
        }

        return try decoder.decode([User].self, from: data)
    }

    // MARK: - Health

    func healthCheck() async throws -> Bool {
        let url = URL(string: "\(baseURL)/health")!
        let (_, response) = try await session.data(from: url)
        return (response as? HTTPURLResponse)?.statusCode == 200
    }
}
