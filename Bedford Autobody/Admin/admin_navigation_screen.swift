import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AdminBottomMenu: View {
    @Binding var selectedTab: Int
    @State private var hasUnreadCustomerMessage = false // ✅ Track unread customer messages
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: { selectedTab = 0 }) {
                VStack {
                    Image(systemName: "house.fill")
                        .font(.system(size: 24))
                    Text("Dashboard").font(.caption)
                }
            }
            .foregroundColor(selectedTab == 0 ? .blue : .gray)
            .padding()
            
            Spacer()
            
            Button(action: { selectedTab = 1 }) {
                VStack {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 24))
                    Text("Users").font(.caption)
                }
            }
            .foregroundColor(selectedTab == 1 ? .blue : .gray)
            .padding()
            
            Spacer()
            
            Button(action: { selectedTab = 2 }) {
                VStack {
                    Image(systemName: "wrench.fill")
                        .font(.system(size: 24))
                    Text("Repairs").font(.caption)
                }
            }
            .foregroundColor(selectedTab == 2 ? .blue : .gray)
            .padding()
            
            Spacer()
            
            // 🔹 Chat Button with Red Dot for Unread Customer Messages
            Button(action: { selectedTab = 3 }) {
                VStack {
                    ZStack {
                        Image(systemName: "message.fill")
                            .font(.system(size: 24))
                        
                        // 🔴 Show Red Dot if There Are Unread Customer Messages
                        if hasUnreadCustomerMessage {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 10, height: 10)
                                .offset(x: 10, y: -10) // Adjust position
                        }
                    }
                    Text("Chats").font(.caption)
                }
            }
            .foregroundColor(selectedTab == 3 ? .blue : .gray)
            .padding()
            
            Spacer()
        }
        .frame(height: 60)
        .background(Color(.systemGray6).ignoresSafeArea(edges: .bottom))
        .shadow(radius: 2)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            checkForUnreadCustomerMessages()
        }
    }
    
    private func checkForUnreadCustomerMessages() {
        guard let adminId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("messages")
            .whereField("receiverId", isEqualTo: adminId) // ✅ Get messages sent to the admin
            .whereField("senderId", isNotEqualTo: "admin") // ✅ Only check messages from customers
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error fetching unread customer messages: \(error.localizedDescription)")
                    return
                }
                
                // ✅ Check if there are unread messages
                let unreadMessages = snapshot?.documents.filter { document in
                    let data = document.data()
                    return (data["isRead"] as? Bool) == false // ✅ Ensure `isRead` is `false`
                } ?? []
                
                DispatchQueue.main.async {
                    self.hasUnreadCustomerMessage = !unreadMessages.isEmpty
                }
            }
    }
    
}
