import SwiftUI

struct ConversationsListView: View {
    @Environment(AuthViewModel.self) private var authVM
    let conversationsVM: ConversationsViewModel
    let webSocketService: WebSocketService

    @State private var showNewChat = false
    @State private var showNewRoom = false
    @State private var path: [Conversation] = []

    var body: some View {
        NavigationStack(path: $path) {
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
                ChatViewWrapper(
                    conversation: conversation,
                    currentUserId: authVM.currentUserId ?? "",
                    webSocketService: webSocketService,
                    onBack: { if !path.isEmpty { path.removeLast() } }
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
                NewChatView(conversationsVM: conversationsVM) { newConversation in
                    showNewChat = false
                    path = [newConversation]
                }
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
