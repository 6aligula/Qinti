import Foundation

struct User: Codable, Identifiable, Hashable {
    let userId: String
    let name: String

    var id: String { userId }
}
