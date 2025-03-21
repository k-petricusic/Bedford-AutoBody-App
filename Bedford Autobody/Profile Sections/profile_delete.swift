//
//  profile_delete.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 3/17/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct AccountDeletionSection: View {
    @State private var showDeleteAlert = false
    @State private var isProcessing = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Account Deletion")
                .font(.title2)
                .bold()
            
            Text("Deleting your account will permanently remove all your data, including your cars, messages, and any stored information. This action cannot be undone.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
            
            Button(action: {
                showDeleteAlert = true
            }) {
                Text("Delete My Account")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isProcessing)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Account?"),
                message: Text("Are you sure? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    deleteAccount()
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        
        isProcessing = true
        let userId = user.uid
        let db = Firestore.firestore()
        let storage = Storage.storage()

        // Step 1: Delete user data from Firestore
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                let userCarsRef = db.collection("users").document(userId).collection("cars")
                
                // Delete user's cars and their images
                userCarsRef.getDocuments { snapshot, error in
                    if let snapshot = snapshot {
                        for doc in snapshot.documents {
                            let carId = doc.documentID
                            let carImagesRef = userCarsRef.document(carId).collection("images")
                            
                            // Delete images from Firebase Storage
                            carImagesRef.getDocuments { imageSnapshot, error in
                                if let imageSnapshot = imageSnapshot {
                                    for imgDoc in imageSnapshot.documents {
                                        if let imageUrl = imgDoc.data()["url"] as? String {
                                            storage.reference(forURL: imageUrl).delete { error in
                                                if let error = error {
                                                    print("Error deleting image: \(error.localizedDescription)")
                                                }
                                            }
                                        }
                                        imgDoc.reference.delete()
                                    }
                                }
                            }
                            
                            userCarsRef.document(carId).delete()
                        }
                    }
                }
                
                // Delete user's messages
                let messagesRef = db.collection("messages").whereField("userId", isEqualTo: userId)
                messagesRef.getDocuments { snapshot, error in
                    if let snapshot = snapshot {
                        for doc in snapshot.documents {
                            doc.reference.delete()
                        }
                    }
                }

                // Delete user's notifications
                let notificationsRef = db.collection("users").document(userId).collection("notifications")
                notificationsRef.getDocuments { snapshot, error in
                    if let snapshot = snapshot {
                        for doc in snapshot.documents {
                            doc.reference.delete()
                        }
                    }
                }

                // Delete the user document
                db.collection("users").document(userId).delete()
            }
        }

        // Step 2: Delete Firebase Auth user account
        user.delete { error in
            DispatchQueue.main.async {
                isProcessing = false
                if let error = error {
                    print("Error deleting account: \(error.localizedDescription)")
                } else {
                    print("Account deleted successfully.")
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
