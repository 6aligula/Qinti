import SwiftUI

@main
struct MoldLineApp: App {
    @State private var authVM = AuthViewModel()
    @State private var webSocketService = WebSocketService()
    @State private var userCache = UserCache()

    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.isLoggedIn {
                    ConversationsListView(
                        conversationsVM: ConversationsViewModel(webSocketService: webSocketService),
                        webSocketService: webSocketService,
                        userCache: userCache
                    )
                } else {
                    LoginView()
                }
            }
            .environment(authVM)
            .task {
                await authVM.validateSession()
                if authVM.isLoggedIn {
                    await userCache.loadUsers()
                }
            }
        }
    }
}
