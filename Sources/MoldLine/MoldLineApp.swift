import SwiftUI

@main
struct MoldLineApp: App {
    @State private var authVM = AuthViewModel()
    @State private var webSocketService = WebSocketService()

    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.isLoggedIn {
                    ConversationsListView(
                        conversationsVM: ConversationsViewModel(webSocketService: webSocketService),
                        webSocketService: webSocketService
                    )
                } else {
                    LoginView()
                }
            }
            .environment(authVM)
            .task {
                await authVM.validateSession()
            }
        }
    }
}
