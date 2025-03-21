import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct BottomMenuView: View {
    @Binding var selectedTab: Int // Keeps track of the active tab
    @State private var hasUnreadAdminMessage = false // ✅ Track unread admin messages

    var body: some View {
        HStack {
            Spacer()
            
            // Home Button
            Button(action: { selectedTab = 0 }) {
                VStack {
                    Image(systemName: "house.fill")
                        .font(.system(size: 24))
                    Text("Home").font(.caption)
                }
            }
            .foregroundColor(selectedTab == 0 ? .blue : .gray)
            .padding()

            Spacer()
            
            // Cars Button
            Button(action: { selectedTab = 1 }) {
                VStack {
                    Image(systemName: "car.fill")
                        .font(.system(size: 24))
                    Text("Cars").font(.caption)
                }
            }
            .foregroundColor(selectedTab == 1 ? .blue : .gray)
            .padding()

            Spacer()
            
            // Chat Button with Red Dot for Unread Admin Messages
            Button(action: { selectedTab = 2 }) {
                VStack {
                    ZStack {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 24))

                        // 🔴 Show Red Dot if There Are Unread Admin Messages
                        if hasUnreadAdminMessage {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 10, height: 10)
                                .offset(x: 10, y: -10) // Adjust position
                        }
                    }
                    Text("Chat").font(.caption)
                }
            }
            .foregroundColor(selectedTab == 2 ? .blue : .gray)
            .padding()

            Spacer()
            
            // FAQ Button
            Button(action: { selectedTab = 3 }) {
                VStack {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 24))
                    Text("FAQ").font(.caption)
                }
            }
            .foregroundColor(selectedTab == 3 ? .blue : .gray)
            .padding()

            Spacer()
            
            // Profile Button
            Button(action: { selectedTab = 4 }) {
                VStack {
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                    Text("Profile").font(.caption)
                }
            }
            .foregroundColor(selectedTab == 4 ? .blue : .gray)
            .padding()

            Spacer()
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6).ignoresSafeArea(edges: .bottom))
        .shadow(radius: 2)
        .onAppear {
            checkForUnreadAdminMessages()
        }
    }

    private func checkForUnreadAdminMessages() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("messages")
            .whereField("userId", isEqualTo: userId) // ✅ Get messages for this user
            .whereField("senderId", isEqualTo: "admin") // ✅ Only check messages from admin
            .whereField("isRead", isEqualTo: false) // ✅ Only check unread messages
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error fetching unread admin messages: \(error.localizedDescription)")
                    return
                }

                // ✅ If there are any unread messages from admin, show red dot
                self.hasUnreadAdminMessage = !(snapshot?.documents.isEmpty ?? true)
            }
    }
}
