import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) private var authVM
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.green)

                    Text("MoldLine")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Select a user to continue")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if authVM.isLoading {
                    ProgressView()
                        .padding()
                } else if let error = authVM.errorMessage {
                    VStack(spacing: 8) {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)

                        Button("Retry") {
                            Task { await authVM.loadUsers() }
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        ForEach(authVM.users) { user in
                            Button {
                                authVM.selectUser(user.userId)
                            } label: {
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .font(.title2)
                                    Text(user.name)
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: "arrow.right.circle")
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                }

                // Register button
                VStack(spacing: 8) {
                    Text("Don't have an account?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button {
                        showRegister = true
                    } label: {
                        Text("Create Account")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()
            }
            .navigationTitle("")
            .sheet(isPresented: $showRegister) {
                RegisterView()
            }
            .task {
                await authVM.loadUsers()
            }
        }
    }
}
