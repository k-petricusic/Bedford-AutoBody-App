//
//  profile_info.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 2/14/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct PersonalInfoView: View {
    @State private var fullName: String = "Loading..."
    @State private var email: String = "Loading..."
    @State private var phone: String = "Loading..."
    @State private var showEditProfile = false // Controls Edit Profile sheet

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Personal Info")
                    .font(.headline)
                Spacer()
                Button("Edit") {
                    showEditProfile = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }

            Divider()

            ProfileInfoRow(icon: "person.fill", label: "Name", value: fullName)
            ProfileInfoRow(icon: "envelope.fill", label: "E-mail", value: email)
            ProfileInfoRow(icon: "phone.fill", label: "Phone number", value: phone)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
        .onAppear {
            loadUserProfile()
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(fullName: $fullName, email: $email, phone: $phone)
        }
    }

    private func loadUserProfile() {
        fetchUserName { firstName, lastName in
            self.fullName = "\(firstName) \(lastName)"
        }

        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching user profile: \(error.localizedDescription)")
                return
            }
            if let data = document?.data() {
                self.email = data["email"] as? String ?? "No Email"
                self.phone = data["phone"] as? String ?? "No Phone"
            }
        }
    }
}


// 🔹 Reusable Row Component
struct ProfileInfoRow: View {
    var icon: String
    var label: String
    var value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.body)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
