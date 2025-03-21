import SwiftUI
import FirebaseAuth

struct LogoutButtonView: View {
    @State private var showConfirmation = false
    @Environment(\.presentationMode) var presentationMode // 🔹 Allows us to dismiss the current screen
    @State private var navigateToLoginOptions = false // 🔹 Tracks navigation

    var body: some View {
        NavigationStack { // ✅ Ensure this is included at the root level
            VStack {
                Button(action: {
                    showConfirmation = true
                }) {
                    Text("Log Out")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .alert(isPresented: $showConfirmation) {
                    Alert(
                        title: Text("Log Out"),
                        message: Text("Are you sure you want to log out?"),
                        primaryButton: .destructive(Text("Log Out")) {
                            logoutUser()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .navigationDestination(isPresented: $navigateToLoginOptions) { // ✅ Fix: Ensure NavigationStack is present
                LoginOptions().navigationBarBackButtonHidden(true)
            }
        }
    }

    private func logoutUser() {
        do {
            try Auth.auth().signOut()
            print("✅ User logged out successfully.")

            // Reset admin status
            UserDefaults.standard.removeObject(forKey: "isAdmin")

            // Redirect to login screen
            DispatchQueue.main.async {
                navigateToLoginOptions = true // ✅ Trigger navigation
            }
        } catch {
            print("❌ Error logging out: \(error.localizedDescription)")
        }
    }
}
