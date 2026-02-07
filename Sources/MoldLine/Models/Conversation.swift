import Foundation

struct Conversation: Codable, Identifiable, Hashable {
    let convoId: String
    let kind: ConversationKind
    let members: [String]

    var id: String { convoId }
}

enum ConversationKind: String, Codable, Hashable {
    case dm
    case room
}
