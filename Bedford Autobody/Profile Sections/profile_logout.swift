//
//  profile_logout.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 2/14/25.
//

import SwiftUI
import FirebaseAuth

struct LogoutButtonView: View {
    @State private var showConfirmation = false

    var body: some View {
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

    private func logoutUser() {
        do {
            try Auth.auth().signOut()
            print("User logged out successfully.")
        } catch {
            print("Error logging out: \(error.localizedDescription)")
        }
    }
}
