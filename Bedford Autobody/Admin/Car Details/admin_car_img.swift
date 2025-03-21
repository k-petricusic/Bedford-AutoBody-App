import SwiftUI
import FirebaseStorage
import PhotosUI

struct CarImagesSection: View {
    var car: Car
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var isUploadingImage = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Images")
                .font(.title2)
                .bold()

            if isUploadingImage {
                ProgressView("Uploading...")
                    .padding()
            }

            Button(action: { showImagePicker = true }) {
                Text("Select Image")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isUploadingImage)

            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300, maxHeight: 300)
                    .cornerRadius(10)
                    .padding()
                
                Button("Upload Image") { uploadImage() }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(isUploadingImage)
            } else {
                Text("No image selected.")
                    .foregroundColor(.gray)
                    .italic()
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }

    private func uploadImage() {
        guard let selectedImage = selectedImage else {
            print("❌ No image selected.")
            return
        }
        guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
            print("❌ Error converting image to data.")
            return
        }

        print("📢 Starting image upload...")

        isUploadingImage = true
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("cars/\(car.id ?? "unknown")/images/\(UUID().uuidString).jpg")


        imageRef.putData(imageData, metadata: nil) { _, error in
            isUploadingImage = false
            if let error = error {
                print("❌ Error uploading image: \(error.localizedDescription)")
                return
            }

            print("✅ Image uploaded successfully!")
            
            // Now trigger the notification
            sendImageUploadNotification()
        }
    }


    private func sendImageUploadNotification() {
        guard let ownerId = car.ownerId else {
            print("❌ Error: Car owner ID is missing")
            return
        }

        print("📢 Sending image upload notification to user: \(ownerId)")

        let notificationTitle = "New Image Uploaded"
        let notificationBody = "A new image has been added to your car \(car.make) \(car.model)."

        NotificationHelper.sendPushNotification(
            to: ownerId,
            title: notificationTitle,
            body: notificationBody
        )
    }

}
