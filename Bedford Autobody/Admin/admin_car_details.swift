import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import PhotosUI

struct CarDetailView: View {
    @State var car: Car
    @State private var selectedState: String
    @State private var showConfirmation = false
    @State private var showMaintenanceLogs = false
    @State private var maintenanceType: String = ""
    @State private var showAddMaintenanceAlert = false
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showAdminImages = false
    @State private var isUploadingImage = false // Track upload state
    @State private var showEstimateAlert = false // For showing the alert to update estimate
    @State private var newEstimate: String = "" // Holds the new estimate value
    @State private var showPDFPicker = false // To show the file picker
    @State private var selectedPDFURL: URL? = nil // Holds the selected PDF file URL
    @Environment(\.presentationMode) var presentationMode

    init(car: Car) {
        self.car = car
        self._selectedState = State(initialValue: car.currentRepairState)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Car Details Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Car Details")
                        .font(.title2)
                        .bold()
                    Text("Make: \(car.make)")
                    Text("Model: \(car.model)")
                    Text("Year: \(car.year)")
                    Text("VIN: \(car.vin)")
                    Text("Color: \(car.color)")
                    Text("Current Repair State: \(car.currentRepairState)")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                // Repair State Management Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Repair State Management")
                        .font(.title2)
                        .bold()

                    Text("Change Repair State:")
                        .font(.headline)

                    Picker("Repair State", selection: $selectedState) {
                        ForEach(car.repairStates, id: \.self) { state in
                            Text(state).tag(state)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)

                    Button(action: {
                        showConfirmation = true
                    }) {
                        Text("Save New State")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                // Add Image Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Images")
                        .font(.title2)
                        .bold()

                    if isUploadingImage {
                        ProgressView("Uploading...")
                            .padding()
                    }

                    Button(action: {
                        showImagePicker = true // Open the image picker
                    }) {
                        Text("Add Image")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(isUploadingImage)

                    Button(action: {
                        showAdminImages = true // Navigate to AdminImages screen
                    }) {
                        Text("View Images")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 300, maxHeight: 300)
                            .cornerRadius(10)
                            .padding()
                        Button("Upload Image") {
                            uploadImage()
                        }
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

                // New Placeholder Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("New Section Placeholder")
                        .font(.title2)
                        .bold()

                    Button(action: {
                        showEstimateAlert = true
                    }) {
                        Text("Update Estimate Total")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .alert("Update Estimate Total", isPresented: $showEstimateAlert) {
                        TextField("Enter new estimate", text: $newEstimate)
                            .keyboardType(.decimalPad)
                        Button("Save", action: updateEstimateTotal)
                        Button("Cancel", role: .cancel, action: {})
                    }


                    Button(action: {
                        showPDFPicker = true
                    }) {
                        Text("Add Estimate PDF")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $showPDFPicker) {
                        DocumentPicker(fileURL: $selectedPDFURL, onUpload: uploadPDF)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .background(
            NavigationLink(
                destination: AdminImages(car: car),
                isActive: $showAdminImages
            ) {
                EmptyView()
            }
        )
        .navigationTitle("Admin Car Details")
        .alert("Confirm Update", isPresented: $showConfirmation) {
            Button("Update", action: updateRepairState)
            Button("Cancel", role: .cancel, action: {})
        } message: {
            Text("Are you sure you want to change the repair state to '\(selectedState)'?")
        }
        .background(

        )
    }

    private func sendEstimateUpdateNotification(ownerId: String, carId: String, newEstimate: Double) {
        let notificationTitle = "Estimate Updated"
        let notificationBody = "The estimate for your car \(car.make) \(car.model) has been updated to $\(String(format: "%.2f", newEstimate))."
        let notificationData: [String: String] = [
            "carId": carId,
            "newEstimate": "\(newEstimate)"
        ]

        NotificationHelper.createNotification(
            for: ownerId,
            title: notificationTitle,
            body: notificationBody,
            type: "estimate",
            data: notificationData
        )
    }
    
    private func updateRepairState() {
        guard let carId = car.id else {
            print("Error: Car ID is nil.")
            return
        }
        guard let ownerId = car.ownerId else {
            print("Error: Owner ID is nil. Cannot determine customer database path.")
            return
        }

        let db = Firestore.firestore()
        db.collection("users")
            .document(ownerId) // Use the customer's user ID
            .collection("cars")
            .document(carId)
            .updateData([
                "currentRepairState": selectedState
            ]) { error in
                if let error = error {
                    print("Error updating repair state: \(error.localizedDescription)")
                } else {
                    print("Repair state updated successfully for customer!")
                    car.currentRepairState = selectedState
                    presentationMode.wrappedValue.dismiss()

                    // Create a notification for the repair state change
                    NotificationHelper.createNotification(
                        for: ownerId,
                        title: "Repair Status Update",
                        body: "Your car's repair status has changed to \(selectedState).",
                        type: "repair",
                        data: ["carId": carId, "repairState": selectedState]
                    )
                }
            }
    }

    private func uploadImage() {
        guard let selectedImage = selectedImage else { return }
        guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
            print("Error converting image to data.")
            return
        }

        isUploadingImage = true

        guard let carId = car.id, let ownerId = car.ownerId else {
            print("Missing car or owner ID.")
            isUploadingImage = false
            return
        }

        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("users/\(ownerId)/cars/\(carId)/images/\(UUID().uuidString).jpg")

        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                isUploadingImage = false
                return
            }

            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    isUploadingImage = false
                    return
                }

                if let url = url {
                    saveImageURLToFirestore(url.absoluteString)
                }
            }
        }
    }

    private func savePDFMetadataToFirestore(_ url: String) {
        guard let carId = car.id, let ownerId = car.ownerId else { return }

        let db = Firestore.firestore()
        db.collection("users")
            .document(ownerId)
            .collection("cars")
            .document(carId)
            .collection("pdfs")
            .addDocument(data: ["url": url, "timestamp": Timestamp(date: Date())]) { error in
                if let error = error {
                    print("Error saving PDF metadata: \(error.localizedDescription)")
                } else {
                    print("PDF metadata saved successfully!")
                }
            }
    }

    
    private func uploadPDF() {
        guard let selectedPDFURL = selectedPDFURL else { return }
        guard let carId = car.id, let ownerId = car.ownerId else {
            print("Error: Missing car or owner ID.")
            return
        }

        let storageRef = Storage.storage().reference()
        let pdfRef = storageRef.child("users/\(ownerId)/cars/\(carId)/pdfs/\(UUID().uuidString).pdf")

        do {
            let pdfData = try Data(contentsOf: selectedPDFURL)
            pdfRef.putData(pdfData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading PDF: \(error.localizedDescription)")
                    return
                }

                pdfRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting PDF download URL: \(error.localizedDescription)")
                        return
                    }

                    if let url = url {
                        savePDFMetadataToFirestore(url.absoluteString)
                    }
                }
            }
        } catch {
            print("Error reading PDF file: \(error.localizedDescription)")
        }
    }

    
    private func saveImageURLToFirestore(_ url: String) {
        guard let carId = car.id, let ownerId = car.ownerId else { return }

        let db = Firestore.firestore()
        db.collection("users")
            .document(ownerId)
            .collection("cars")
            .document(carId)
            .collection("images")
            .addDocument(data: ["url": url]) { error in
                isUploadingImage = false
                if let error = error {
                    print("Error saving image URL to Firestore: \(error.localizedDescription)")
                } else {
                    print("Image URL saved to Firestore successfully!")
                }
            }
    }
    
    private func updateEstimateTotal() {
        guard let carId = car.id, let ownerId = car.ownerId else {
            print("Error: Missing car or owner ID.")
            return
        }

        guard let newEstimateValue = Double(newEstimate) else {
            print("Error: Invalid estimate value.")
            return
        }

        let db = Firestore.firestore()
        db.collection("users")
            .document(ownerId)
            .collection("cars")
            .document(carId)
            .updateData(["estimateTotal": newEstimateValue]) { error in
                if let error = error {
                    print("Error updating estimate total: \(error.localizedDescription)")
                } else {
                    print("Estimate total updated successfully!")
                    car.estimateTotal = newEstimateValue
                    
                    // Send notification to the user
                    sendEstimateUpdateNotification(ownerId: ownerId, carId: carId, newEstimate: newEstimateValue)
                }
            }

    }

}

