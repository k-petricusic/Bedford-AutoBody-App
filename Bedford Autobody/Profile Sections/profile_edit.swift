//
//  EditProfileView.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 2/20/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EditProfileView: View {
    @Binding var fullName: String
    @Binding var email: String
    @Binding var phone: String
    @Environment(\.presentationMode) var presentationMode
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack {
                Text("Edit Personal Info")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 20)

                VStack(spacing: 15) {
                    TextField("Full Name", text: $fullName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    //TextField("Email", text: $email)
                      //  .textFieldStyle(RoundedBorderTextFieldStyle())
                        //.padding(.horizontal)
                        //.keyboardType(.emailAddress)
                        //.autocapitalization(.none)

                    TextField("Phone Number", text: $phone)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .keyboardType(.phonePad)
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }

                Button(action: saveProfileData) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save Changes")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 20)
                .disabled(isSaving)

                Spacer()
            }
            .padding()
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    private func saveProfileData() {
        isSaving = true
        saveProfile(fullName: fullName, email: email, phone: phone) { success, error in
            isSaving = false
            if success {
                presentationMode.wrappedValue.dismiss()
            } else {
                errorMessage = error ?? "Failed to update profile."
            }
        }
    }
}
