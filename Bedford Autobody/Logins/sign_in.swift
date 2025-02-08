import SwiftUI
import Security
import FirebaseFirestore
import FirebaseAuth
import FirebaseMessaging

struct SignUpScreen: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isSignedUp = false // Flag to track successful sign-up
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Sign Up")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.top, 50)
                
                // First Name and Last Name Fields
                HStack {
                    TextField("First Name", text: $firstName)
                        .padding()
                        .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.white)
                        .cornerRadius(10)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    TextField("Last Name", text: $lastName)
                        .padding()
                        .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.white)
                        .cornerRadius(10)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                .padding(.top, 20)
                
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
                
                // Confirm Password Field
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.white)
                    .cornerRadius(10)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.top, 20)
                
                // Sign Up Button
                Button(action: {
                    // Check if all fields are filled
                    if firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
                        alertMessage = "Please fill in all fields."
                        showAlert = true
                        return
                    }

                    // Check if passwords match
                    if password != confirmPassword {
                        alertMessage = "Passwords do not match."
                        showAlert = true
                        return
                    }
                    
                    // Min password length
                    if password.count < 8 {
                        alertMessage = "Password must be at least 8 characters long."
                        showAlert = true
                        return
                    }

                    // Firebase: Create User
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        if let error = error {
                            DispatchQueue.main.async {
                                alertMessage = "Error: \(error.localizedDescription)"
                                showAlert = true
                            }
                            return
                        }

                        if let user = authResult?.user {
                            // Save additional user info to Firestore
                            let db = Firestore.firestore()
                            db.collection("users").document(user.uid).setData([
                                "firstName": firstName,
                                "lastName": lastName,
                                "email": email
                            ]) { error in
                                if let error = error {
                                    DispatchQueue.main.async {
                                        alertMessage = "Failed to save user info: \(error.localizedDescription)"
                                        showAlert = true
                                    }
                                    return
                                }
                                updateFCMToken(for: user)
                                isSignedUp = true // Navigate to HomeScreen
                            }
                        }
                    }
                }) {
                    Text("Sign Up")
                        .font(.title2)
                        .bold()
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.top, 20)
                }
                
                // NavigationLink for HomeScreen
                NavigationLink(destination: NaviView(), isActive: $isSignedUp) {
                    EmptyView()
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .padding()
        }
    }
    
    // Update FCM Token for the newly signed-up user
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
