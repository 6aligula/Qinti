import SwiftUI

struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool

    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer(minLength: 60) }

            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 2) {
                if !isFromCurrentUser {
                    Text(message.from)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }

                Text(message.text)
                    .font(.body)

                Text(message.formattedTime)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isFromCurrentUser ? Color.green.opacity(0.3) : Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            if !isFromCurrentUser { Spacer(minLength: 60) }
        }
    }
}
