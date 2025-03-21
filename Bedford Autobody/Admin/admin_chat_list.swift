import SwiftUI
import FirebaseFirestore

struct AdminChatsListView: View {
    @State private var userChats: [UserChat] = []
    @State private var isLoading = true

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Chats...")
            } else if userChats.isEmpty {
                Text("No active chats found.")
                    .font(.headline)
                    .foregroundColor(.gray)
            } else {
                List(userChats) { chat in
                    NavigationLink(destination: AdminChatViewWrapper(userId: chat.userId)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(chat.userName)
                                    .font(.headline)

                                Text("Last Message: \(chat.lastMessage)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            // 🔴 Show red dot only if message is unread & was sent by the customer
                            if chat.hasUnreadMessage {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 10, height: 10)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("All Chats")
        .onAppear {
            fetchChats()
        }
    }




    private func fetchChats() {
        let db = Firestore.firestore()

        db.collection("users").getDocuments { userSnapshot, error in
            if let error = error {
                print("❌ Error fetching users: \(error.localizedDescription)")
                self.isLoading = false
                return
            }

            var chatMap: [String: UserChat] = [:]

            userSnapshot?.documents.forEach { document in
                let userId = document.documentID
                let firstName = document.data()["firstName"] as? String ?? "Unknown"
                let lastName = document.data()["lastName"] as? String ?? "User"
                let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)

                chatMap[userId] = UserChat(
                    userId: userId,
                    userName: fullName,
                    lastMessage: "No messages yet",
                    hasUnreadMessage: false,
                    lastMessageDate: Date.distantPast
                )
            }

            // 🔹 Fetch latest messages & track unread ones
            db.collection("messages")
                .order(by: "sentDate", descending: true)
                .getDocuments { messageSnapshot, error in
                    if let error = error {
                        print("❌ Error fetching messages: \(error.localizedDescription)")
                        self.userChats = Array(chatMap.values).sorted { $0.lastMessageDate > $1.lastMessageDate }
                        self.isLoading = false
                        return
                    }

                    messageSnapshot?.documents.forEach { document in
                        let data = document.data()
                        guard let userId = data["userId"] as? String,
                              let senderId = data["senderId"] as? String,
                              let text = data["text"] as? String,
                              let sentDate = (data["sentDate"] as? Timestamp)?.dateValue(),
                              let isRead = data["isRead"] as? Bool else { return }

                        // ✅ Only update if this is the latest message
                        if var chat = chatMap[userId], sentDate > chat.lastMessageDate {
                            chat.lastMessage = text
                            chat.lastMessageDate = sentDate

                            // ✅ Only show the red dot if the unread message was sent by the customer
                            chat.hasUnreadMessage = !isRead && senderId != "admin"

                            chatMap[userId] = chat
                        }
                    }

                    // ✅ Sort by latest message
                    self.userChats = Array(chatMap.values).sorted { $0.lastMessageDate > $1.lastMessageDate }
                    self.isLoading = false
                }
        }
    }
    }


private func fetchUserNamesFromHelper(userIds: [String], completion: @escaping ([String: String]) -> Void) {
    var userNames: [String: String] = [:]
    let group = DispatchGroup()

    for userId in userIds {
        group.enter()
        fetchUserNameById(userId: userId) { fullName in
            userNames[userId] = fullName
            group.leave()
        }
    }

    group.notify(queue: .main) {
        completion(userNames)
    }
}


struct UserChat: Identifiable {
    var id: String { userId }
    let userId: String
    var userName: String
    var lastMessage: String
    var hasUnreadMessage: Bool // ✅ New field to track unread messages
    var lastMessageDate: Date
}

