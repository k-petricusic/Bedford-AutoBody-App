import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SwitchToAdminView: View {
    @State private var isAdmin: Bool? = nil
    @State private var navigateToAdmin = false

    var body: some View {
        VStack {
            if isAdmin == nil {
                ProgressView("Checking Admin Status...")
            } else if isAdmin == true {
                Button(action: {
                    navigateToAdmin = true
                }) {
                    Text("Switch to Admin Mode")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black) // ✅ Changed color to black
                        .foregroundColor(.white)
                        .cornerRadius(12) // ✅ Matches Logout button styling
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
        }
        .onAppear {
            checkAdminStatus()
        }
        .navigationDestination(isPresented: $navigateToAdmin) {
            AdminRootView().navigationBarBackButtonHidden(true)
        }
    }

    private func checkAdminStatus() {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.isAdmin = false
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
            }
        }
    }
}
