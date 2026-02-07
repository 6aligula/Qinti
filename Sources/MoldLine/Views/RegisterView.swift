import SwiftUI

struct RegisterView: View {
    @Environment(AuthViewModel.self) private var authVM
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = RegisterViewModel()
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case nickname, password, confirmPassword, email, phone
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 48))
                            .foregroundStyle(.green)

                        Text("Create Account")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Join MoldLine and start chatting")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)

                    // Required fields
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Required")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)

                        VStack(spacing: 12) {
                            HStack(spacing: 10) {
                                Image(systemName: "person.fill")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 20)
                                TextField("Nickname", text: $viewModel.nickname)
                                    .textContentType(.username)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                    .focused($focusedField, equals: .nickname)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            HStack(spacing: 10) {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 20)
                                SecureField("Password", text: $viewModel.password)
                                    .textContentType(.newPassword)
                                    .focused($focusedField, equals: .password)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            HStack(spacing: 10) {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 20)
                                SecureField("Confirm password", text: $viewModel.confirmPassword)
                                    .textContentType(.newPassword)
                                    .focused($focusedField, equals: .confirmPassword)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            if viewModel.passwordMismatch {
                                Text("Passwords don't match")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }
                    }

                    // Optional fields
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Optional")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)

                        VStack(spacing: 12) {
                            HStack(spacing: 10) {
                                Image(systemName: "envelope.fill")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 20)
                                TextField("Email", text: $viewModel.email)
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                    .focused($focusedField, equals: .email)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            HStack(spacing: 10) {
                                Image(systemName: "phone.fill")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 20)
                                TextField("Phone number", text: $viewModel.phone)
                                    .textContentType(.telephoneNumber)
                                    .keyboardType(.phonePad)
                                    .focused($focusedField, equals: .phone)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    // Error message
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    // Register button
                    Button {
                        focusedField = nil
                        Task {
                            if let userId = await viewModel.register() {
                                authVM.selectUser(userId)
                            }
                        }
                    } label: {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Create Account")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isFormValid ? Color.green : Color.gray)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)

                    // Password hint
                    Text("Password must be at least 4 characters")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("Register")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
