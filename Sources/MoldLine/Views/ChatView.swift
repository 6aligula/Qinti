import SwiftUI

struct ChatView: View {
    @Bindable var viewModel: ChatViewModel
    let conversation: Conversation
    let currentUserId: String

    var title: String {
        switch conversation.kind {
        case .dm:
            return conversation.members.first(where: { $0 != currentUserId }) ?? "Chat"
        case .room:
            return conversation.convoId
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(
                                message: message,
                                isFromCurrentUser: message.from == currentUserId
                            )
                            .id(message.id)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .onChange(of: viewModel.messages.count) {
                    if let lastMessage = viewModel.messages.last {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }

            ChatInputBar(text: $viewModel.messageText) {
                Task {
                    await viewModel.sendMessage()
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadMessages()
        }
    }
}
