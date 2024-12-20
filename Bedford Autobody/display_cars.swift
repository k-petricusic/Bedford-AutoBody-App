import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct DisplayCars: View {
    @Binding var cars: [Car]
    @Binding var selectedCar: Car?
    @State private var showingAddCarView = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Your Cars")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                if cars.isEmpty {
                    Text("You haven't added any cars yet.")
                        .padding()
                } else {
                    List {
                        ForEach(cars) { car in
                            HStack {
                                Button(action: {
                                    selectedCar = car // Update selected car
                                    saveSelectedCar(car)
                                }) {
                                    HStack {
                                        Text("\(car.year) \(car.make) \(car.model)")
                                            .padding(.leading)
                                        Spacer()
                                        if selectedCar?.id == car.id {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue) // Optional: styling for the checkmark
                                        }
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deleteCar)
                    }
                }
                
                // In the logic for adding a new car:
                Button(action: {
                    showingAddCarView.toggle()
                }) {
                    Text("Add a New Car")
                        .font(.headline)
                        .padding()
                        .frame(minWidth: 200)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showingAddCarView, onDismiss: {
                    fetchCarsFromFirestore() // Refresh cars after adding a new one
                }) {
                    AddCarView(cars: $cars)  // Pass the binding to the parent `cars` array
                }
                
            }
            .navigationTitle("Your Cars")
            .padding()
            .onAppear {
                fetchCarsFromFirestore() // Ensure cars are fetched when the view appears
            }
        }
    }
    
    // Save selected car ID to Firestore
    func saveSelectedCar(_ car: Car) {
        guard let user = Auth.auth().currentUser else { return }
        guard let carId = car.id else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(user.uid).updateData([
            "lastSelectedCarId": carId
        ]) { error in
            if let error = error {
                print("Error saving selected car ID: \(error.localizedDescription)")
            } else {
                print("Selected car ID saved successfully!")
            }
        }
    }
    
    func fetchCarsFromFirestore() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()

        db.collection("users").document(user.uid).collection("cars")
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching cars: \(error.localizedDescription)")
                } else {
                    // Update the cars array with the id after fetching
                    self.cars = querySnapshot?.documents.compactMap { document in
                        var car = try? document.data(as: Car.self)
                        car?.id = document.documentID // Update the car with Firestore ID
                        return car
                    } ?? []
                    
                    // Auto-select the first car if no car is selected yet
                    if selectedCar == nil && !self.cars.isEmpty {
                        selectedCar = self.cars.first // Select the first car
                        saveSelectedCar(self.cars.first!) // Optionally, save the selected car
                    }
                }
            }
    }


    
    // Ensure to check for the first car when the list of cars is updated.
    func deleteCar(at offsets: IndexSet) {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        
        for index in offsets {
            let car = cars[index]
            guard let carId = car.id else { continue }
            
            if selectedCar?.id == carId {
                selectedCar = nil
            }
            
            db.collection("users").document(user.uid).collection("cars").document(carId).delete { error in
                if let error = error {
                    print("Error deleting car: \(error.localizedDescription)")
                } else {
                    print("Car deleted successfully!")
                }
            }
        }
        
        // Remove the car from the local array
        cars.remove(atOffsets: offsets)
        
        // Auto-select the first car if there are any remaining cars
        if selectedCar == nil && !cars.isEmpty {
            selectedCar = cars.first
            saveSelectedCar(cars.first!)  // Optionally, save the selected car
        }
    }

}
