import SwiftUI
import FirebaseAuth
import FirebaseMessaging
import FirebaseFirestore

struct LogInScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Reset credentials on navigation
    var resetCredentials: Bool  // Flag passed from LoginOptions to reset fields

    var body: some View {
        NavigationStack {
            VStack {
                Text("Login")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.top, 50)
                
                // Email Field
                TextField("Email", text: $email)
                    .padding()
                    .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.white)
                    .cornerRadius(10)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.top, 20)
                
                // Password Field
                SecureField("Password", text: $password)
                    .padding()
                    .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.white)
                    .cornerRadius(10)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.top, 20)
                
                // Login Button
                Button(action: {
                    // Firebase Login
                    Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                        if let error = error {
                            DispatchQueue.main.async {
                                alertMessage = "Login Failed: \(error.localizedDescription)"
                                showAlert = true
                            }
                        } else if let user = authResult?.user {
                            // Successful Login
                            DispatchQueue.main.async {
                                updateFCMToken(for: user) // Update FCM token for the logged-in user
                                isLoggedIn = true
                            }
                        }
                    }
                }) {
                    Text("Login")
                        .font(.headline)
                        .padding()
                        .frame(minWidth: 200)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Login Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                
                Spacer()
            }
            .padding()
            .background(colorScheme == .dark ? Color.black : Color.white)
            .cornerRadius(10)
            
            // Navigate to HomeScreen if login is successful
            NavigationLink(destination: NaviView(), isActive: $isLoggedIn) {
                EmptyView()
            }
        }
        .onAppear {
            // Reset credentials if the flag is true
            if resetCredentials {
                email = ""
                password = ""
            }
        }
    }
    
    // Update FCM Token for the logged-in user
    func updateFCMToken(for firebaseUser: FirebaseAuth.User) {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error retrieving FCM token: \(error.localizedDescription)")
            } else if let token = token {
                let db = Firestore.firestore()
                db.collection("users").document(firebaseUser.uid).updateData([
                    "fcmToken": token
                ]) { error in
                    if let error = error {
                        print("Error updating FCM token in Firestore: \(error.localizedDescription)")
                    } else {
                        print("FCM token updated successfully for user \(firebaseUser.uid)")
                    }
                }
            }
        }
    }
}
