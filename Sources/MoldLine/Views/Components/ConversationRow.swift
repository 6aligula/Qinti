import SwiftUI

struct ConversationRow: View {
    let conversation: Conversation
    let currentUserId: String
    var userCache: UserCache?

    var displayName: String {
        switch conversation.kind {
        case .dm:
            let otherUserId = conversation.members.first(where: { $0 != currentUserId }) ?? ""
            return userCache?.name(for: otherUserId) ?? otherUserId
        case .room:
            return conversation.convoId
        }
    }

    var icon: String {
        conversation.kind == .dm ? "person.circle.fill" : "person.3.fill"
    }

    var subtitle: String {
        switch conversation.kind {
        case .dm:
            return "Direct message"
        case .room:
            return "\(conversation.members.count) members"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(conversation.kind == .dm ? .blue : .green)

            VStack(alignment: .leading, spacing: 2) {
                Text(displayName)
                    .font(.headline)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
