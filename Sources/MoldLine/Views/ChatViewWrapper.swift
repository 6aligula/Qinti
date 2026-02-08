import SwiftUI

struct ChatViewWrapper: View {
    let conversation: Conversation
    let currentUserId: String
    let webSocketService: WebSocketService
    var onBack: (() -> Void)?

    @State private var viewModel: ChatViewModel?

    var body: some View {
        Group {
            if let viewModel {
                ChatView(
                    viewModel: viewModel,
                    conversation: conversation,
                    currentUserId: currentUserId,
                    onBack: onBack
                )
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = ChatViewModel(
                    convoId: conversation.convoId,
                    userId: currentUserId,
                    webSocketService: webSocketService
                )
            }
        }
    }
}
