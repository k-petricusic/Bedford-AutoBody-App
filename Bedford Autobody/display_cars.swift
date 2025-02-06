import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct DisplayCars: View {
    @Binding var cars: [Car]
    @Binding var selectedCar: Car?
    @State private var showingAddCarView = false
    @State private var carOffsetY: CGFloat = 0 // Vertical offset for bounce animation
    @State private var isBouncing = false // Animation state

    var body: some View {
        NavigationStack {
            VStack {
                Text("Your Cars")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                if cars.isEmpty {
                    VStack {
                        Text("You haven't added any cars yet.")
                            .padding()

                        ZStack {
                            Image(systemName: "car.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 50)
                                .foregroundColor(.blue)
                                .offset(y: carOffsetY)
                                .onAppear {
                                    startBounceAnimation()
                                }
                        }
                        .frame(height: 100)
                    }
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
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deleteCar)
                    }
                }
                
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
                    fetchCarsFromFirestore()
                }) {
                    AddCarView(cars: $cars)
                }
            }
            .navigationTitle("Your Cars")
            .padding()
            .onAppear {
                fetchCarsFromFirestore()
            }
        }
    }

    func startBounceAnimation() {
        withAnimation(
            Animation
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
        ) {
            carOffsetY = -20 // Bounce upward
        }
    }
    
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
                    self.cars = querySnapshot?.documents.compactMap { document in
                        var car = try? document.data(as: Car.self)
                        car?.id = document.documentID
                        return car
                    } ?? []
                    
                    if selectedCar == nil && !self.cars.isEmpty {
                        selectedCar = self.cars.first
                        saveSelectedCar(self.cars.first!)
                    }
                }
            }
    }

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
        
        cars.remove(atOffsets: offsets)
        
        if selectedCar == nil && !cars.isEmpty {
            selectedCar = cars.first
            saveSelectedCar(cars.first!)
        }
    }
}
