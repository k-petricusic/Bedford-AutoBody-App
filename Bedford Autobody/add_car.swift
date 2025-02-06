import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AddCarView: View {
    @Binding var cars: [Car]
    @State private var make = ""
    @State private var model = ""
    @State private var year = ""
    @State private var vin = "" // VIN input field
    @State private var color = "" // Color input field
    @State private var showAlert = false // For displaying the alert
    @Environment(\.presentationMode) var presentationMode // Access the presentation mode

    var body: some View {
        VStack {
            Text("Add New Car")
                .font(.largeTitle)
                .bold()
                .padding(.top)

            // Input fields
            TextField("Maker", text: $make)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Model", text: $model)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Year", text: $year)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("VIN", text: $vin)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Color", text: $color)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // Save Car Button
            Button(action: {
                saveCar()
            }) {
                Text("Save Car")
                    .font(.headline)
                    .padding()
                    .frame(minWidth: 200)
                    .background(
                        make.isEmpty || model.isEmpty || year.isEmpty || vin.isEmpty || color.isEmpty ?
                        Color.green.opacity(0.5) : Color.green
                    ) // Adjust opacity when disabled
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            .disabled(make.isEmpty || model.isEmpty || year.isEmpty || vin.isEmpty || color.isEmpty)

            Spacer()
        }
        .padding()
        .navigationTitle("Add Car")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Validation Error"),
                message: Text("Please fill in all the fields."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func saveCar() {
        // Check if all fields are filled
        if make.isEmpty || model.isEmpty || year.isEmpty || vin.isEmpty || color.isEmpty {
            showAlert = true // Show alert if fields are empty
            return
        }

        // Get the current user ID
        guard let user = Auth.auth().currentUser else {
            print("Error: User is not authenticated.")
            return
        }

        // Create a new car with the entered details and default estimateTotal
        let newCar = Car(
            ownerId: user.uid, // Set ownerId to the authenticated user's ID
            make: make,
            model: model,
            year: year,
            vin: vin,
            color: color,
            estimateTotal: 0.0 // Default estimate total
        )
        cars.append(newCar) // Append the new car to the local list

        let db = Firestore.firestore()
        let carRef = db.collection("users")
            .document(user.uid)
            .collection("cars")
            .document() // Create a new document in the user's "cars" subcollection

        // Save car data to Firestore
        do {
            try carRef.setData(from: newCar) { error in
                if let error = error {
                    print("Error adding car to Firestore: \(error.localizedDescription)")
                } else {
                    print("Car added to Firestore successfully!")
                }
            }
        } catch {
            print("Error encoding car data: \(error.localizedDescription)")
        }

        // Dismiss the AddCarView
        presentationMode.wrappedValue.dismiss()
    }
}
