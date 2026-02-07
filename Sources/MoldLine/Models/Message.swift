import Foundation

struct Message: Codable, Identifiable, Hashable {
    let messageId: String
    let convoId: String
    let from: String
    let text: String
    let ts: Double

    var id: String { messageId }

    var date: Date {
        Date(timeIntervalSince1970: ts / 1000)
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
