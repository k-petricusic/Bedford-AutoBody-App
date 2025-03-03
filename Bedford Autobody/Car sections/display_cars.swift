import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct DisplayCars: View {
    @State private var cars: [Car] = []
    @Binding var selectedCar: Car?
    @State private var showingAddCarView = false
    @State private var carOffsetY: CGFloat = 0 // Bounce animation state
    
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
                            Button(action: {
                                selectCar(car)
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("\(car.year) \(car.make) \(car.model)")
                                            .font(.headline)
                                        Text("VIN: \(car.vin)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    if selectedCar?.id == car.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.vertical, 5)
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
                    loadCars()
                }) {
                    AddCarView(cars: $cars)
                }
            }
            .navigationTitle("Your Cars")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
            .onAppear {
                loadCars()
            }
        }
    }
    
    // 🔹 Bounce animation function
    private func startBounceAnimation() {
        withAnimation(
            Animation
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
        ) {
            carOffsetY = -20
        }
    }
    
    // 🔹 Select a car, persist selection, and **force UI refresh**
    private func selectCar(_ car: Car) {
        guard let carId = car.id else { return }
        selectedCar = car
        saveSelectedCar(carId: carId) { success in
            if success {
                DispatchQueue.main.async {
                    self.loadCars()
                    self.selectedCar = car
                }
            }
        }
    }
    
    // 🔹 Load all cars from Firestore **and ensure the correct car is selected**
    private func loadCars() {
        fetchCars { fetchedCars, fetchedSelectedCar in
            DispatchQueue.main.async {
                self.cars = fetchedCars
                if let selected = fetchedSelectedCar {
                    self.selectedCar = selected
                } else if let firstCar = fetchedCars.first {
                    self.selectCar(firstCar)
                }
            }
        }
    }
    
    // 🔹 Delete a car and update selection **only if necessary**
    private func deleteCar(at offsets: IndexSet) {
        for index in offsets {
            let car = cars[index]
            guard let carId = car.id else { continue }
            
            deleteSelectedCar(carId: carId) { success in
                if success {
                    DispatchQueue.main.async {
                        cars.remove(at: index)
                        if selectedCar?.id == carId {
                            selectedCar = nil
                            loadCars()
                        }
                    }
                }
            }
        }
    }
}
