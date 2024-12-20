import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AddCarView: View {
    @Binding var cars: [Car]
    @State private var make = ""
    @State private var model = ""
    @State private var year = ""
    @State private var vin = "" // Added VIN field
    @State private var color = "" // Added color field
    @State private var showAlert = false // For displaying the alert
    @Environment(\.presentationMode) var presentationMode  // Access the presentation mode
    
    var body: some View {
        VStack {
            Text("Add New Car")
                .font(.largeTitle)
                .bold()
                .padding(.top)
            
            TextField("Maker", text: $make)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Model", text: $model)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Year", text: $year)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("VIN", text: $vin) // VIN input field
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Add a new field for car color
            TextField("Color", text: $color) // Color input field
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                // Check if all fields are filled
                if make.isEmpty || model.isEmpty || year.isEmpty || vin.isEmpty || color.isEmpty {
                    showAlert = true // Show alert if fields are empty
                } else {
                    // Create a new car with the added color field
                    let newCar = Car(make: make, model: model, year: year, vin: vin, color: color)
                    cars.append(newCar)  // Append the new car to the list


                    // Get the current user ID
                    if let user = Auth.auth().currentUser {
                        let db = Firestore.firestore()
                        let carRef = db.collection("users").document(user.uid).collection("cars").document() // Create a new document in the user's "cars" subcollection
                        
                        // Save car data to Firestore
                        carRef.setData([
                            "make": newCar.make,
                            "model": newCar.model,
                            "year": newCar.year,
                            "vin": newCar.vin,
                            "color": newCar.color
                        ]) { error in
                            if let error = error {
                                print("Error adding car to Firestore: \(error.localizedDescription)")
                            } else {
                                print("Car added to Firestore successfully!")
                            }
                        }
                    }

                    // Dismiss the AddCarView
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("Save Car")
                    .font(.headline)
                    .padding()
                    .frame(minWidth: 200)
                    .background(
                        make.isEmpty || model.isEmpty || year.isEmpty || vin.isEmpty || color.isEmpty ?
                        Color.green.opacity(0.5) : Color.green
                    )  // Adjust opacity when disabled
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            .disabled(make.isEmpty || model.isEmpty || year.isEmpty || vin.isEmpty || color.isEmpty) // Disable button if any field is empty
            
            Spacer()
        }
        .padding()
        .navigationTitle("Add Car")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Validation Error"),
                  message: Text("Please fill in all the fields."),
                  dismissButton: .default(Text("OK")))
        }
    }
}
