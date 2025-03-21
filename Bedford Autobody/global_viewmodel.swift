import FirebaseAuth
import FirebaseFirestore

class AppDataViewModel: ObservableObject {
    @Published var firstName: String = "User"
    @Published var lastName: String = ""
    @Published var profilePictureURL: String? = nil
    @Published var isAdmin: Bool = false
    @Published var unreadNotifications: Int = 0

    init() {
        fetchUserData()
        checkUnreadNotifications()
    }

    private func fetchUserData() {
        guard let user = Auth.auth().currentUser else { return }

        Firestore.firestore().collection("users").document(user.uid)
            .addSnapshotListener { document, error in
                if let data = document?.data() {
                    DispatchQueue.main.async {
                        self.firstName = data["firstName"] as? String ?? "User"
                        self.lastName = data["lastName"] as? String ?? ""
                        self.profilePictureURL = data["profilePictureURL"] as? String // ✅ Cached profile picture
                        self.isAdmin = data["isAdmin"] as? Bool ?? false
                    }
                }
            }
    }

    // 🔹 Fetch Unread Notifications Count
    private func checkUnreadNotifications() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("users").document(userId).collection("notifications")
            .whereField("isRead", isEqualTo: false)
            .addSnapshotListener { snapshot, error in
                DispatchQueue.main.async {
                    self.unreadNotifications = snapshot?.documents.count ?? 0
                }
            }
    }
}
