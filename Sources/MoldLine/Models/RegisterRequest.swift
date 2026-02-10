import Foundation

// MARK: - Register

struct RegisterRequest: Encodable {
    let name: String
    let password: String
    var email: String?
    var phone: String?
}

struct RegisterResponse: Decodable {
    let userId: String
    let name: String
    let token: String
}

// MARK: - Login

struct LoginRequest: Encodable {
    let name: String
    let password: String
}

struct LoginResponse: Decodable {
    let userId: String
    let name: String
    let token: String
}

// MARK: - Refresh

struct RefreshResponse: Decodable {
    let token: String
}

// MARK: - Profile

struct UserProfile: Decodable {
    let userId: String
    let name: String
    let email: String?
    let createdAt: String?
}
