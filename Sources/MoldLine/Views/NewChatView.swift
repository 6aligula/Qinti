import SwiftUI

struct NewChatView: View {
    @Environment(AuthViewModel.self) private var authVM
    @Environment(\.dismiss) private var dismiss
    let conversationsVM: ConversationsViewModel

    @State private var users: [User] = []
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else {
                    List(filteredUsers) { user in
                        Button {
                            startDM(with: user)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.blue)

                                VStack(alignment: .leading) {
                                    Text(user.name)
                                        .font(.headline)
                                    Text(user.userId)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("New Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task {
                await loadUsers()
            }
        }
    }

    private var filteredUsers: [User] {
        users.filter { $0.userId != authVM.currentUserId }
    }

    private func loadUsers() async {
        isLoading = true
        do {
            users = try await APIService.shared.getUsers()
        } catch {
            // silently fail
        }
        isLoading = false
    }

    private func startDM(with user: User) {
        guard let userId = authVM.currentUserId else { return }
        Task {
            _ = await conversationsVM.createDM(otherUserId: user.userId, userId: userId)
            dismiss()
        }
    }
}
