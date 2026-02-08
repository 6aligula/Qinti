import Foundation

struct RegisterRequest: Encodable {
    let name: String
    let password: String
    var email: String?
    var phone: String?
}

struct RegisterResponse: Decodable {
    let userId: String
    let name: String
}
