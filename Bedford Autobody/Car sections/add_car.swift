import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AddCarView: View {
    @Binding var cars: [Car]
    @State private var make = ""
    @State private var model = ""
    @State private var submodel = "" // 🔹 Optional submodel field
    @State private var year = ""
    @State private var vin = ""
    @State private var color = ""
    @State private var estimatedPickupDate = ""
    
    @State private var numDoors = 4 // 🔹 Default to 4 doors
    @State private var carType = "Car" // 🔹 Default to "Car" instead of "None"
    
    @State private var showAlert = false
    @Environment(\.presentationMode) var presentationMode

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
            TextField("Submodel (Optional)", text: $submodel) // 🔹 Optional submodel field
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

            // 🔹 "Choose your vehicle" label
            Text("Choose your vehicle")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            // 🔹 Picker for Car Type
            Picker("", selection: $carType) {
                Text("Car").tag("Car") // 🔹 Changed from "None"
                Text("SUV").tag("SUV")
                Text("Van").tag("Van")
                Text("Truck").tag("Truck")
            }
            .pickerStyle(MenuPickerStyle())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            // 🔹 Picker for Number of Doors (Aligned Left)
            Picker("", selection: $numDoors) {
                Text("2 Doors").tag(2)
                Text("4 Doors").tag(4)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

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
                message: Text("Please fill in all the required fields."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func saveCar() {
        // Check if all required fields are filled
        if make.isEmpty || model.isEmpty || year.isEmpty || vin.isEmpty || color.isEmpty {
            showAlert = true // Show alert if required fields are empty
            return
        }

        // Get the current user ID
        guard let user = Auth.auth().currentUser else {
            print("Error: User is not authenticated.")
            return
        }

        // Create a new car with the entered details
        let newCar = Car(
            ownerId: user.uid,
            make: make,
            model: model,
            submodel: submodel, // 🔹 Save submodel
            year: year,
            vin: vin,
            color: color,
            numDoors: numDoors, // 🔹 Save numDoors
            carType: carType, // 🔹 Save carType
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
