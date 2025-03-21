//
//  car_buttons.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 2/14/25.
//

import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

struct CarActionButtons: View {
    var selectedCarId: String?
    @State private var selectedPickerItem: PhotosPickerItem? // Holds the selected picker item
    @State private var selectedImage: UIImage? // Holds the converted image
    @State private var isUploading = false // Tracks upload state

    var body: some View {
        VStack(spacing: 10) {
            NavigationLink(destination: ImagesScreen(carId: selectedCarId ?? "")) {
                ActionButton(title: "View All Images", icon: "photo.on.rectangle.angled")
            }

            NavigationLink(destination: DisplayCars(selectedCar: .constant(nil))) {
                ActionButton(title: "Change Car", icon: "arrow.2.squarepath")
            }

            // 🔹 Upload Damage Photos Button
            PhotosPicker(selection: $selectedPickerItem, matching: .images) {
                ActionButton(title: "Upload Damage Photos", icon: "camera")
            }
            .disabled(isUploading) // Disable while uploading
            .onChange(of: selectedPickerItem) {
                if let newItem = selectedPickerItem {
                    convertPickerItemToImage(newItem)
                }
            }
        }
        .padding()
    }

    // 🔹 Convert `PhotosPickerItem` to `UIImage`
    func convertPickerItemToImage(_ item: PhotosPickerItem) {
        Task {
            if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                selectedImage = image
                uploadImageToFirebase(image: image)
            } else {
                print("❌ Error: Failed to convert picker item to UIImage")
            }
        }
    }

    // 🔹 Upload Image to Firebase Storage
    func uploadImageToFirebase(image: UIImage) {
        guard let user = Auth.auth().currentUser, let carId = selectedCarId else {
            print("❌ Error: User not authenticated or car not selected.")
            return
        }

        isUploading = true // Show loading state

        let storageRef = Storage.storage().reference()
        let imageId = UUID().uuidString // Unique ID for image
        let imagePath = "users/\(user.uid)/cars/\(carId)/images/\(imageId).jpg"
        let imageRef = storageRef.child(imagePath)

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Error: Failed to convert image to data")
            isUploading = false
            return
        }

        imageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("❌ Error uploading image: \(error.localizedDescription)")
                isUploading = false
                return
            }

            imageRef.downloadURL { url, error in
                if let error = error {
                    print("❌ Error fetching image URL: \(error.localizedDescription)")
                    isUploading = false
                    return
                }

                if let downloadURL = url {
                    saveImageMetadataToFirestore(imageURL: downloadURL.absoluteString, carId: carId, userId: user.uid)
                }
            }
        }
    }

    // 🔹 Save Image Metadata to Firestore
    func saveImageMetadataToFirestore(imageURL: String, carId: String, userId: String) {
        let db = Firestore.firestore()
        let imageMetadata = [
            "url": imageURL,
            "timestamp": FieldValue.serverTimestamp()
        ] as [String: Any]

        db.collection("users")
            .document(userId)
            .collection("cars")
            .document(carId)
            .collection("images")
            .addDocument(data: imageMetadata) { error in
                if let error = error {
                    print("❌ Error saving metadata to Firestore: \(error.localizedDescription)")
                } else {
                    print("✅ Image metadata saved successfully!")
                }
                isUploading = false
            }
    }
}

// 🔹 Styled Button Component
struct ActionButton: View {
    var title: String
    var icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
