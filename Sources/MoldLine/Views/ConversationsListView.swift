import SwiftUI

struct ConversationsListView: View {
    @Environment(AuthViewModel.self) private var authVM
    let conversationsVM: ConversationsViewModel
    let webSocketService: WebSocketService

    @State private var showNewChat = false
    @State private var showNewRoom = false

    var body: some View {
        NavigationStack {
            Group {
                if conversationsVM.isLoading && conversationsVM.conversations.isEmpty {
                    ProgressView("Loading conversations...")
                } else if conversationsVM.conversations.isEmpty {
                    ContentUnavailableView(
                        "No conversations",
                        systemImage: "bubble.left.and.bubble.right",
                        description: Text("Start a new chat or create a room")
                    )
                } else {
                    List(conversationsVM.conversations) { conversation in
                        NavigationLink(value: conversation) {
                            ConversationRow(
                                conversation: conversation,
                                currentUserId: authVM.currentUserId ?? ""
                            )
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Chats")
            .navigationDestination(for: Conversation.self) { conversation in
                ChatView(
                    viewModel: ChatViewModel(
                        convoId: conversation.convoId,
                        userId: authVM.currentUserId ?? "",
                        webSocketService: webSocketService
                    ),
                    conversation: conversation,
                    currentUserId: authVM.currentUserId ?? ""
                )
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Logout") {
                        conversationsVM.disconnect()
                        authVM.logout()
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showNewChat = true
                        } label: {
                            Label("New Chat", systemImage: "person.badge.plus")
                        }

                        Button {
                            showNewRoom = true
                        } label: {
                            Label("New Room", systemImage: "person.3.fill")
                        }
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showNewChat) {
                NewChatView(conversationsVM: conversationsVM)
            }
            .sheet(isPresented: $showNewRoom) {
                NewRoomView(conversationsVM: conversationsVM)
            }
            .refreshable {
                await conversationsVM.loadConversations()
            }
            .task {
                guard let userId = authVM.currentUserId else { return }
                conversationsVM.setup(userId: userId)
                await conversationsVM.loadConversations()
            }
        }
    }
}
