import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AdminMenu: View {
    @State private var isAdmin: Bool? = nil // Tracks admin status
    @State private var isLoading = true // Show loading while checking admin status

    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView("Checking Admin Status...") // ✅ Show loading while checking
            } else if isAdmin == true {
                List {
                    NavigationLink("View Users", destination: UsersList())
                    NavigationLink("Current Repairs", destination: CurrentRepairsScreen())
                }
                .navigationTitle("Admin Menu")
            } else {
                // 🔹 Redirect non-admins (you can customize this screen)
                Text("Access Denied")
                    .font(.title)
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            checkAdminStatus() // ✅ Fetch admin status when the view loads
        }
    }

    private func checkAdminStatus() {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.isAdmin = false
            self.isLoading = false
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            DispatchQueue.main.async {
                if let document = document, document.exists {
                    self.isAdmin = document.data()?["isAdmin"] as? Bool ?? false
                } else {
                    self.isAdmin = false
                }
                self.isLoading = false
            }
        }
    }
}
