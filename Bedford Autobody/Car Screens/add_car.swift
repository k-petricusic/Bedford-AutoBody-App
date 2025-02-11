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
    @State private var estimatedPickupDate = "" // Estimated Pickup Date input field
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
            TextField("Estimated Pickup Date (Optional)", text: $estimatedPickupDate)
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

        // Create a new car with the entered details and optional estimatedPickupDate
        let newCar = Car(
            ownerId: user.uid,
            make: make,
            model: model,
            year: year,
            vin: vin,
            color: color,
            estimateTotal: 0.0, // Default estimate total
            estimatedPickupDate: estimatedPickupDate.isEmpty ? nil : estimatedPickupDate
        )
        cars.append(newCar) // Append the new car to the local list

        // Save to Firestore using helper function
        addCarToFirestore(car: newCar, userId: user.uid)

        // Dismiss the AddCarView
        presentationMode.wrappedValue.dismiss()
    }
}
