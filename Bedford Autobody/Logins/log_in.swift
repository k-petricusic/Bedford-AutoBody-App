import SwiftUI
import FirebaseAuth
import FirebaseMessaging

struct LogInScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var isAdmin = false // Track admin status
    @State private var showAlert = false
    @State private var alertMessage = ""

    var resetCredentials: Bool

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
                    loginUser()
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

            // 🔹 Navigate Based on Role (Admin or Regular User)
            .navigationDestination(isPresented: $isLoggedIn) {
                if isAdmin {
                    AdminRootView()
                } else {
                    NaviView()
                }
            }
        }
        .onAppear {
            if resetCredentials {
                email = ""
                password = ""
            }
        }
    }

    private func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "Login Failed: \(error.localizedDescription)"
                    showAlert = true
                }
            } else if authResult?.user != nil { // ✅ No need to store 'user' if not used
                checkAdminStatus { isAdmin in
                    DispatchQueue.main.async {
                        self.isAdmin = isAdmin
                        self.isLoggedIn = true
                    }
                }
            }
        }
    }
}
