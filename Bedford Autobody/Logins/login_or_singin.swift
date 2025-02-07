import SwiftUI

struct LoginOptions: View {
    @State private var navigateToSignIn = false
    @State private var navigateToLogIn = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.blue.ignoresSafeArea() // Set the background color to blue
                VStack(spacing: 20) { // Add spacing between elements in the VStack
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding()
                        .accessibilityLabel("App Logo")
                    
                    Text("Welcome to Bedford Autobody!")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .bold()
                        .multilineTextAlignment(.center)
                        .kerning(2)
                    
                    HStack(spacing: 20) { // Add spacing between the buttons
                        // Button for Sign Up
                        Button {
                            navigateToSignIn = true
                        } label: {
                            Text("Sign Up")
                                .font(.headline)
                                .padding()
                                .frame(minWidth: 100)
                                .background(Color.white)
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                        }
                        .accessibilityLabel("Sign Up Button")
                        
                        // Button for Log In
                        Button {
                            navigateToLogIn = true
                        } label: {
                            Text("Log In")
                                .font(.headline)
                                .padding()
                                .frame(minWidth: 100)
                                .background(Color.white)
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                        }
                        .accessibilityLabel("Log In Button")
                    }
                    .padding(.top, 20) // Add extra space between the text and buttons
                }
                .padding()
                
                // Use the new `navigationDestination` modifier to trigger the navigation
                .navigationDestination(isPresented: $navigateToSignIn) {
                    SignUpScreen()
                }
                .navigationDestination(isPresented: $navigateToLogIn) {
                    LogInScreen(resetCredentials: true)  // Pass flag to reset credentials
                }
            }
            .navigationBarBackButtonHidden(true) // Hide the back button when on LoginOptions screen
        }
    }
}
