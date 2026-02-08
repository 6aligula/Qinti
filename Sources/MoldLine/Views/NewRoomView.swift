import SwiftUI

struct NewRoomView: View {
    @Environment(\.dismiss) private var dismiss
    let conversationsVM: ConversationsViewModel

    @State private var roomName = ""
    @State private var isCreating = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Room Details") {
                    TextField("Room name", text: $roomName)
                }

                Section {
                    Button {
                        createRoom()
                    } label: {
                        HStack {
                            Spacer()
                            if isCreating {
                                ProgressView()
                            } else {
                                Text("Create Room")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(roomName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isCreating)
                }
            }
            .navigationTitle("New Room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func createRoom() {
        let name = roomName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        isCreating = true
        Task {
            _ = await conversationsVM.createRoom(name: name)
            dismiss()
        }
    }
}
